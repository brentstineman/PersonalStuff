param
(
    [Parameter(Mandatory=$false)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory=$false)]
    [string]
    $resourcPrefix,

    [Parameter(Mandatory=$false)]
    [string]
    $sqlAdminUser,

    [Parameter(Mandatory=$false)]
    [string]
    $sqlAdminPassword
)
$ErrorActionPreference = "Stop";

$scriptRoot = "$PSScriptRoot/"

if ([string]::IsNullOrEmpty($ResourceGroupName)){
    $ResourceGroupName = Read-Host 'What is the name of the Resource Group we are deploying too?'
}

#$pass = Read-Host 'What is your password?' -AsSecureString

Write-Host "Checking for resource group $ResourceGroupName..."
$resourceGroup = Get-AzureRmResourceGroup -name $ResourceGroupName -ErrorAction SilentlyContinue
if ($resourceGroup -eq $null){
        $Location = Read-Host 'The resource Group does not exist. Which Azure region should we create it in?'

    Write-Host "creating new resource group $ResourceGroupName ... in $Location"
    $resourceGroup = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
}

if ([string]::IsNullOrEmpty($resourcPrefix)){
    $resourcPrefix = Read-Host 'What resource prefix should be used for resources?'
    $resourcPrefix = $resourcPrefix.ToString().ToLower()
}
$tempStorageAccountName = $resourcPrefix+"tmp"

$storageAccount = Get-AzureRmStorageAccount `
                    -ResourceGroupName $ResourceGroupName `
                    -Name $tempStorageAccountName `
                    -ErrorAction SilentlyContinue
if ($storageAccount -eq $null){
    Write-Host
    Write-Host "Creating storage account $StorageAccountName..."
    $storageAccount = New-AzureRmStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $tempStorageAccountName `
        -Location $resourceGroup.Location `
        -SkuName Standard_LRS
}

$containerName = "deployment"
$container = Get-AzureStorageContainer `
                    -Context $storageAccount.Context `
                    -Container $containerName `
                    -ErrorAction SilentlyContinue
if ($container -eq $null){
    # TODO - create SAS URL rather than making the container public??
    Write-Host
    Write-Host "Creating public (blob) storage container $containerName..."
    $container = New-AzureStorageContainer `
                        -Context $storageAccount.Context `
                        -Name $containerName `
                        -Permission Blob
}

#deploy from template

Write-Host
Write-Host "Uploading Deployment scripts to storage..."
Get-ChildItem -File $scriptRoot* -Exclude *params.json -filter deploy-*.json | Set-AzureStorageBlobContent `
        -Context $storageAccount.Context `
        -Container $containerName `
        -Force

# get remaining parameters
if ([string]::IsNullOrEmpty($sqlAdminUser)){
    $sqlAdminUser = Read-Host 'What the administrateive username?'
}

if ([string]::IsNullOrEmpty($sqlAdminPassword)){
    $sqlAdminPassword = Read-Host 'What the administrateive password?' -AsSecureString
}


$templateParameters = @{
    resourcePrefix = $resourcPrefix
    sqlAdministratorLogin = $sqlAdminUser
    sqlAdministratorPassword = $sqlAdminPassword

    # templateBaseURL is used for linked template deployments, see deployment/readme.md
    #    This must end with "/" or it will break the linked templates
    templateBaseURL = $container.CloudBlobContainer.StorageUri.PrimaryUri.AbsoluteUri + "/"
    
    #
    ### to customize your deployment, uncomment and provide values for the following parameters
    ### you can find sample value by looking at nether-deploy.json's parameters
    #
    # WebHostingPlan = "Free (no 'always on')"
    # InstanceCount = 1
    # databaseSKU = "Basic"
    # templateSASToken = "" #used for linked template deployments from private locations, see deployment/readme.md
    # ... and more! see nether-deploy.json template for full list of available parameters
}

$deploymentName = "Deployment-{0:yyyy-MM-dd-HH-mm-ss}" -f (Get-Date)
Write-Host
Write-Host "Deploying application... ($deploymentName)"
$result = New-AzureRmResourceGroupDeployment `
            -ResourceGroupName $ResourceGroupName `
            -Name $deploymentName `
            -TemplateFile "$PSScriptRoot\deploy-master.json" `
            -TemplateParameterObject $templateParameters

Write-Host
Write-Host "Done."
