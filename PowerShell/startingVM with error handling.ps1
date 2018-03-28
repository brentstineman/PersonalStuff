#
# Access granted under MIT Open Source License: https://en.wikipedia.org/wiki/MIT_License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, # and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions 
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.
#
# Created by: Brent Stineman
#
# Description: Just a sample of starting a VM using error handling and retry approaches. Should not be considered
# production ready as not all potential errors may be accounted for. Key item to keep in mind most Azure Powershell 
# failures don't generate exceptions that would be caught in traditional "try catch" blocks in Powershell. So please 
# only use this as a reference for your own implementations.
#
# This script has also not been fully tested. So please ensure you properly vet everything (especially the retry loop)
#
# Modifications
# 2018/03/28 : Initial publication
#

# these variables set which VM to start
$ResourceGroupName = "BrentStineman"
$VMName = "bmsstarttest"

# these add in maximum recount attempts as well as the delay time
$maxRetryCount = 3
$retrydelay = 60

# status of vm
$vmrunning = $false

write-host "Getting current status of virtual machine $VMName not found in resource group $ResourceGroupName"
$VMStatus = (Get-AzureRmVM -Name $VMName -ResourceGroupName $ResourceGroupName -Status)

if ($VMStatus -eq $null) # get status failed
{
    write-host "an error occured getting machine status"
    # if it failed because the target object doesn't exist, send message
    if ($error[0].Exception.Message.Contains('ResourceNotFound'))
    {
        Write-Host "Virtual Machine not found, ending script"
        break all
    }
}
else # object evidently exists, so lets try to work with it... 
{
    $currentStatus = ($VMStatus.Statuses | Where Code -Like 'PowerState/*')[0].DisplayStatus
    write-host "Current Status is: $currentStatus"
    $vmrunning = $currentStatus.Contains('running')

    # make sure machine isn't trying to stop
    if ($currentStatus.Contains('deallocating'))
    {
        write-host "VM is currently tryign to stop, exiting script"
        break all
    }

    # if not running, attempt start
    if (!$vmrunning)
    {
        write-host "attempting to start VM"
            
        # we're going to retry until we hit the retry count
        while ($startAttempts -lt $maxRetryCount) {
            $startAttempts++

            Start-AzureRMVM -ResourceGroupName $ResourceGroupName -Name $VMName

            #make sure its running properly 
            $VMStatus = (Get-AzureRmVM -Name $VMName -ResourceGroupName $ResourceGroupName -Status)
            $vmrunning = ($VMStatus.Statuses | Where Code -Like 'PowerState/*')[0].DisplayStatus.Contains('running')
            if ($vmrunning) {
                # successfully running, max out retry count so we exit the loop
                $startAttempts = $maxRetryCount
            }
            else
            {
                write-host "Startup attempt $startAttempts failed, waiting $retrydelay seconds before trying again"
                Start-Sleep -s $retrydelay
            }
                    
        }

        if ($vmrunning)
        {
            write-host "Startup successful, VM is running"
        }
        else
        {
            write-host "Startup failed, even after $startAttempts attempts"
        }
    }
}

write-host "script complete"    
