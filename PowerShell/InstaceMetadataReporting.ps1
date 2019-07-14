###################################################################################################################################
## 
### Example of reporting Instance Metadata to Azure Storage
# Created by: Brent Stineman, July 2019
# MIT Open Source License
# Description: This script will get the instance metadata information from the Azure VM that it is running on. This information
# is then written to an Azure Storage Append Blob. Note that this script does not include error handling to deal with errors in
# the call to the instance metadata service or storage. Most importantly there is no retry logic in the calls to either service 
# to deal with the throttling that can occur when these operations are run at high volume. When using this in a production
# environment, please industrialize the script to account for these factors as well as the proper handling of storage credentials.
###################################################################################################################################


###################################################################################################################################
## 
### Documentation
##
# Authorizing against Storage
#   https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
# Put Blob API (creates blob)
#   https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
# Append Block API
#   https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
# Instance Metadata Service
#   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service
###################################################################################################################################

###################################################################################################################################
## get instance metadata info and format entry for storage

$currentDate = Get-Date -Format "yyyy-MM-dd"
$instanceData = Invoke-RestMethod -Headers @{"Metadata"="true"} -URI http://169.254.169.254/metadata/instance?api-version=2018-10-01 -Method get
$instanceEntry =  $currentDate + ',' + $instanceData.Compute.subscriptionId + ',' + $instanceData.Compute.resourceGroupName + ',' + $instanceData.Compute.vmId + "`n"

# following line used for local dev purposes only
$instanceEntryLength = $instanceEntry | measure-object -character | select -expandproperty characters
###################################################################################################################################


###################################################################################################################################
# 
### Send instance reporting data to storage
#
###################################################################################################################################

# set up some common variables 
$storageAccountName = '<accountname>'
## WARNING!!!!! AVOID PUTTING THE ACCOUNT KEY IN YOUR SCRIPT. INSTEAD CONSIDER USING A CERTIFICATE
## THIS HAS BEEN DONE PURE FOR DEMONSTRATION/EDUCATION PURPOSES
$storageAccountKey = '<accountkey>'
$storageContainer = '<containername>'
$blobDate = Get-Date -Format "yyyyMMdd"
$x_ms_version="2015-02-21"
# this is our file name
$canonicalizedResource = "$storageContainer/$blobDate.log"

###################################################################################################################################
#
## Create Append Blob only do ONCE! Subsequent calls wipe all contents
#
###################################################################################################################################
$systemDate = [System.DateTime]::UtcNow.ToString("R")

# create hashed authorization header
$hasher = New-Object System.Security.Cryptography.HMACSHA256
$hasher.Key = [System.Convert]::FromBase64String($storageAccountKey)

$stringToSign = "PUT`n`n`n`n`n`n`n`n`n`n`n`nx-ms-blob-type:AppendBlob`nx-ms-date:$systemDate`nx-ms-version:$x_ms_version`n/$storageAccountName/$canonicalizedResource"
$signedSignature = [System.Convert]::ToBase64String($hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($stringToSign)))

$authHeader = "SharedKey ${storageAccountName}`:$signedSignature"

$headers = @{
    "x-ms-date"=$systemDate
    "Authorization"=$authHeader
    "x-ms-blob-type"="AppendBlob"
    "x-ms-version"=$x_ms_version
}

Invoke-RestMethod -Method "PUT" -Uri "https://$storageAccountName.blob.core.windows.net/$canonicalizedResource" -Headers $headers

###################################################################################################################################
#
## Append Content to the Blob
#
###################################################################################################################################
$systemDate = [System.DateTime]::UtcNow.ToString("R")

# create hashed key 
$hasher = New-Object System.Security.Cryptography.HMACSHA256
$hasher.Key = [System.Convert]::FromBase64String($storageAccountKey)

$stringToSign = "PUT`n`n`n$instanceEntryLength`n`napplication/octet-stream`n`n`n`n`n`n`nx-ms-date:$systemDate`nx-ms-version:$x_ms_version`n/$storageAccountName/$canonicalizedResource`ncomp:appendblock"
$signedSignature = [System.Convert]::ToBase64String($hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($stringToSign)))

$authHeader = "SharedKey ${storageAccountName}`:$signedSignature"

$headers = @{
    "x-ms-date"=$systemDate
    "Authorization"=$authHeader
    "Content-Length"=$instanceEntryLength
    "Content-Type"="application/octet-stream"
    "x-ms-version"=$x_ms_version
}

$URI = "https://$storageAccountName.blob.core.windows.net/$canonicalizedResource" + "?comp=appendblock"
Invoke-RestMethod -Method "PUT" -Uri $URI -Headers $headers -Body $instanceEntry

# error code 409 means the blob has reached the maximum number of blocks (50,000) or that you tried to write to a page or block blob
# error code 412 means you violated an optional condition (append position, or max size)
# error code 413 means the blob reached its maximum size (195GB)