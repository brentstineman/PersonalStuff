# Select certificate generated from Enterprise PKI
# Cert must have minimum RSA 2048-bit key length for Public Key

    $cert = 
        ( Get-ChildItem Cert:\CurrentUser\My |
            Out-GridView `
                -Title "Select a certificate ..." `
                -PassThru
        )

# If not using Enterprise PKI, create self-signed certificate instead

    if (!$cert) {

        $certSubject = 
                Read-Host -Prompt “Issue By/To for the certificate”

        $cert = New-SelfSignedCertificate `
            -CertStoreLocation Cert:\CurrentUser\My `
            -Subject "CN=$($certSubject)" `
            -KeySpec KeyExchange `
            -HashAlgorithm SHA256

    }

# Get certificate thumbprint

    $certThumbprint = $cert.Thumbprint

# Get public key and properties from selected cert

    $keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

    $keyId = [guid]::NewGuid()

    $startDate = $cert.NotBefore

    $endDate = $cert.NotAfter

# Create a Key Credential object for selected cert

    Import-Module `
        -Name AzureRM.Resources

    $keyCredential = 
        New-Object -TypeName Microsoft.Azure.Commands.Resources.Models.ActiveDirectory.PSADKeyCredential

    $keyCredential.StartDate = $startDate

    $keyCredential.EndDate = $endDate

    $keyCredential.KeyId = $keyId

    $keyCredential.CertValue = $keyValue

# Define Azure AD App values for new Service Principal

    $adAppName = 
        Read-Host -Prompt “Enter unique Azure AD App name”

    #these aren't needed for our uses, but need to be completed anyways
    $adAppHomePage = "http://$($adAppName)"

    $adAppIdentifierUri = "http://$($adAppName)"

# Login to Azure as user credentials with Azure Subscription Owner and Azure AD Global Admin access

    Login-AzureRmAccount

# If more than 1 Azure subscription is present, select Azure subscription

    $subscriptionId = 
        ( Get-AzureRmSubscription |
            Out-GridView `
                -Title "Select an Azure Subscription ..." `
                -PassThru
        ).SubscriptionId

    Select-AzureRmSubscription `
        -SubscriptionId $subscriptionId

# Create Azure AD App object for new Service Principal

    $adApp = 
        New-AzureRmADApplication `
            -DisplayName $adAppName `
            -HomePage $adAppHomePage `
            -IdentifierUris $adAppIdentifierUri `
            -KeyCredentials $keyCredential 

    Write-Output “New Azure AD App Id: $($adApp.ApplicationId)”

# Create Service Principal

    $principleID = New-AzureRmADServicePrincipal  `
        -ApplicationId $adApp.ApplicationId


# give the new Identity permissions to the subscription
# Due to eventual consistency issues, this may take a few seconds, so we'll 
# loop until it works. 

    # introduce a delay to overcome the eventually consistency
    $addrolesuccess = $FALSE
    Do {

        Try
        {
            New-AzureRmRoleAssignment `
                -RoleDefinitionName Owner `
                -ServicePrincipalName $adApp.ApplicationId

            $addrolesuccess = $TRUE
        } 
        Catch [CloudException]
        {
            if ($Error[4].Exception.Error.Code -ne 'PrincipalNotFound')
            {
                Write-Host "unhandled error occured"
                break
            }
            # was acceptable exception, wait 2 seconds and try again
            Start-Sleep -s 2 # wait 2 seconds and try again
        }
    }
    Until ($addrolesuccess)

