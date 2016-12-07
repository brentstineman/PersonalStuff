    $tenantId =  
        Read-Host -Prompt “Azure AD Tenant ID”

    $appId = 
        Read-Host -Prompt “Azure AD Application ID”

    # prompt for a certificate, you could substitue this with asking for a certificate thumbpring
    $cert = 
        ( Get-ChildItem Cert:\CurrentUser\My |
            Out-GridView `
                -Title "Select a certificate ..." `
                -PassThru
        )
    $certThumbprint = $cert.Thumbprint
    #$certThumbprint = 
    #    Read-Host -Prompt “Thumbprint for the Certificate”

    Login-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $tenantId `
        -ApplicationId $appId `
        -CertificateThumbprint $certThumbprint

    Get-AzureRmVM