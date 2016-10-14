Param(
    [Parameter()] [string] $ResourceGroupName,
    [Parameter()] [string] $LoadBalancerName,
    [Parameter()] [string] $frontendIPConfiguration,
    [Parameter()] [string] $LoadBalancerBEAddressPool = "LoadBalancerBEAddressPool",
    [Parameter()] [int] $StartingPort = 1600,
    [Parameter()] [int] $Count = 5
)

$beAddressPool = "LoadBalancerBEAddressPool"

$slb = Get-AzureRmLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName
$frontendIP = Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $slb -Name $frontendIPConfiguration
$backendPool = Get-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $slb -Name $LoadBalancerBEAddressPool

For ([int] $port=$StartingPort; $port -lt ($StartingPort + $Count); $port++)  
{
    $ruleName = "AppPortLBRule$($port.ToString().PadLeft(3,'0'))"
    $probeName = "AppPortProbe$($port.ToString().PadLeft(3,'0'))"

    Write-Output "Adding Rule: $($ruleName)"

    #$lbProbe = Add-AzureRMLoadBalancerProbeConfig -LoadBalancer $slb -Name "AppPortLBProbe" -IntervalInSeconds 5 -ProbeCount 1 -Protocol Tcp -Port 80
    Add-AzureRMLoadBalancerProbeConfig -LoadBalancer $slb -Name $probeName -IntervalInSeconds 5 -ProbeCount 2 -Protocol Tcp -Port $port
    $lbProbe = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $slb -Name $probeName

    Add-AzureRMLoadBalancerRuleConfig -LoadBalancer $slb -Name $ruleName -BackendAddressPool $backendPool -FrontendIpConfiguration $frontendIP -Protocol Tcp -FrontendPort $port -BackendPort $port -Probe $lbProbe
}

Set-AzureRmLoadBalancer -LoadBalancer $slb