param
(
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]
    $StorageAccountName,

)
$ErrorActionPreference = "Stop";

$netherRoot = "$PSScriptRoot/.."


# Publish Nether.Web
Write-Host
Write-Host "Publishing Nether.Web ..."
# $build = "Release"
$build = "Debug"
$publishPath = "$netherRoot/src/Nether.Web/bin/$build/netcoreapp1.1/publish"

Write-Host "Checking for resource group $ResourceGroupName..."
$resourceGroup = Get-AzureRmResourceGroup -name $ResourceGroupName -ErrorAction SilentlyContinue
if ($resourceGroup -eq $null){
    Write-Host "creating new resource group $ResourceGroupName ... in $Location"
    $resourceGroup = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
}

$storageAccount = Get-AzureRmStorageAccount `
                    -ResourceGroupName $ResourceGroupName `
                    -Name $storageAccountName `
                    -ErrorAction SilentlyContinue
if ($storageAccount -eq $null){
    Write-Host
    Write-Host "Creating storage account $StorageAccountName..."
    $storageAccount = New-AzureRmStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName `
        -Location $Location `
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
Get-ChildItem -File $netherRoot/deployment/* -Exclude *params.json -filter deploy*.json | Set-AzureStorageBlobContent `
        -Context $storageAccount.Context `
        -Container $containerName `
        -Force

$templateParameters = @{
    NetherWebDomainPrefix = $NetherWebDomainPrefix
    sqlServerName = $sqlServerName
    sqlAdministratorLogin = $sqlAdministratorLogin
    sqlAdministratorPassword = $SqlAdministratorPassword
    analyticsEventHubNamespace = $AnalyticsEventHubNamespace
    analyticsStorageAccountName = $AnalyticsStorageAccountName
    
    webZipUri = $webZipblob.ICloudBlob.Uri.AbsoluteUri
    # webZipUri = "https://netherassets.blob.core.windows.net/packages/package261.zip"
    # webZipUri = "https://netherbits.blob.core.windows.net/deployment/Nether.Web.zip"
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

$deploymentName = "Nether-Deployment-{0:yyyy-MM-dd-HH-mm-ss}" -f (Get-Date)
Write-Host
Write-Host "Deploying application... ($deploymentName)"
$result = New-AzureRmResourceGroupDeployment `
            -ResourceGroupName $ResourceGroupName `
            -Name $deploymentName `
            -TemplateFile "$PSScriptRoot\nether-deploy.json" `
            -TemplateParameterObject $templateParameters

Write-Host
Write-Host "Done."
