# Copyright (c) 2017 Brent Stineman & Microsoft
#
# Access granted under MIT Open Source License: https://en.wikipedia.org/wiki/MIT_License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, # and/or sell copies of the Software, 
#and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions 
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

# the contents of this cmdlet are based on comments provided by Samuel Murcio on the original Microsoft documentation 
# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/expand-os-disk

param (
	# The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
	[parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
		
    # The AD tenant where the ID is stored
	[parameter(Mandatory=$true)]
    [string]$VirtualMachineName,
        
	# optional, parameter of type boolean
	[parameter(Mandatory=$true)]
    [int]$NewSizeInGB
)

Write-Output "Starting resize" 

# get start time
$StartDate=(GET-DATE)

# get the details on the VM and its OS disk
Write-Output "Retrieving VM Details" 
$vm= Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName

# stop the VM, forcing it to shut down (no prompt)
Write-Output "Stopping virtual machine"
$stopresult = Stop-AzureRMVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force

# resize the OS disk
Write-Output "Resizing the disk"
$disk= Get-AzureRmDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.OsDisk.Name
$disk.DiskSizeGB=$NewSizeInGB
$updateresult = Update-AzureRmDisk -ResourceGroupName $vm.ResourceGroupName -Disk $disk -DiskName $disk.Name    
	
#start the VM back up
Write-Output "Restarting the VM"
Start-AzureRMVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name

Write-Output "Operation complete"

# get duration time
$EndDate=(GET-DATE)
$TimeDiff  = NEW-TIMESPAN -Start $StartDate -End $EndDate
Write-Output "Duration is $TimeDiff"
