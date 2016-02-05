#Copyright (c) 2016 Brent Stineman
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
workflow Resize-AzureSQLDatabase
{   
	# Specify input parameters here
	param (
		# The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
		[parameter(Mandatory=$true)]
        [string]$CredentialAssetName,
        
        # resource group taht contains the database
    	[parameter(Mandatory=$true)]
        [string]$ResourceGroupName,

		# name of the database server
        [parameter(Mandatory=$true)]
        [string]$ServerName,

		# name of the database
		[parameter(Mandatory=$true)]
		[string]$DatabaseName,

		# Mandatory parameter of type DateTime
		[parameter(Mandatory=$true)]
		[string]$NewEdition,

		# Mandatory parameter of type boolean
		[parameter(Mandatory=$false)]
        [string]$NewPricingTier
    )
    
    #Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
    if(!$Cred) {
        Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    }
	Write-Output "retrieved credential"

    #Connect to your Azure Account
    $Account = Login-AzureRmAccount -Credential $Cred
    if(!$Account) {
        Throw "Could not authenticate to Azure using the credential asset '${CredentialAssetName}'. Make sure the user name and password are correct."
    }
	Write-Output "added account"

	if($NewEdition -eq "Basic")
	{
		$ScaleRequest = Set-AzureRMSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $ResourceGroupName -ServerName $ServerName -Edition $NewEdition
	}
	else
	{
		$ScaleRequest = Set-AzureRMSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $ResourceGroupName -ServerName $ServerName -Edition $NewEdition -RequestedServiceObjectiveName $NewPricingTier
	}
	Write-Output "resized DB"
}
