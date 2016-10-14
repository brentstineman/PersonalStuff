[string] $resourceGroup = Read-Host -Prompt "What resource group are we deploying too?"

[int] $attendeeCount = Read-Host -Prompt  "How many workshop attendees?"

[int] $startingPort = Read-Host -Prompt  "What is the starting port for attendee LB endpoints? (leave blank for default of 1600)"

[string] $parameterFile = Read-Host -Prompt  "What is your Parameter file? (press enter if you don't have one)"

if ($parameterFile.IsNullOrEmpty()) {
    ##TODO: prompt for required parameters
}
else {
    ##TODO: parse deployment parameters, not sure we need this yet
}

Write-Output "Starting deployment. This will likely take 10-20 minutes."

Write-Output "..."

Write-Output "..."

Write-Output "*"
Write-Output "** Please be patient. :) "
Write-Output "*"

Write-Output "*"
Write-Output "** Creating Service Fabric Cluster. **"
Write-Output "*"

#new-azurermresourcegroupdeployment -ResourceGroupName $resourceGroup -TemplateParameterFile $parameterFile -TemplateFile .\unsecureSvcFabClusterWithDMZ.json

Write-Output "*"
Write-Output "** Adding Public/Front End LB rules for attendees. **".
Write-Output "*"
./createLBrules.ps1 -ResourceGroupName $resourceGroup -LoadBalancerName 'FrontEndLoadBalancer' -frontendIPConfiguration 'LoadBalancerIPConfig' -StartingPort $startingPort -Count $attendeeCount

Write-Output "*"
Write-Output "** Adding Private/Back End LB rules for attendees. **".
Write-Output "*"
./createLBrules.ps1 -ResourceGroupName $resourceGroup -LoadBalancerName 'BackEndLoadBalancer' -frontendIPConfiguration 'LoadBalancerBackend-internal' -StartingPort $startingPort -Count $attendeeCount  