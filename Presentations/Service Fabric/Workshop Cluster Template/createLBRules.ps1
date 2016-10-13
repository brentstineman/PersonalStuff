Param(
    [Parameter()] [string] $ResourceGroupName,
    [Parameter()] [string] $LoadBalancerName,
    [Parameter()] [string] $LoadBalancerBEAddressPool = "LoadBalancerBEAddressPool",
    [Parameter()] [int] $StartingPort = 1600,
    [Parameter()] [int] $Count = 10
)

$beAddressPool = "LoadBalancerBEAddressPool"

$slb = Get-AzureRmLoadBalancer -Name "BackEndLoadBalancer" -ResourceGroupName $ResourceGroupName
$frontendIP = Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $slb -Name $LoadBalancerName
$backendPool = Get-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $slb -Name $LoadBalancerBEAddressPool

For ([int] $port=$StartingPort; $port -lt ($StartingPort + $Count); $port++)  
{
    $ruleName = "AppPortLBRule$($port.ToString().PadLeft(3,'0'))"

    Write-Output "Adding Rule: $($ruleName)"

    Add-AzureRMLoadBalancerRuleConfig -LoadBalancer $slb -Name $ruleName -BackendAddressPool $backendPool -FrontendIpConfiguration $frontendIP -Protocol Tcp -FrontendPort $port -BackendPort $port  
}

Set-AzureRmLoadBalancer -LoadBalancer $slb