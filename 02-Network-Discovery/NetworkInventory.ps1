# Network Inventory Script
# Purpose: Collect network adapter and IP configuration information.
# Environment: Windows PowerShell 7 / Windows 11

$Adapters = Get-NetAdapter
$IPConfig = Get-NetIPConfiguration

$CombinedInventory = foreach ($IP in $IPConfig) {
    $Adapter = $Adapters |
        Where-Object { $_.Name -eq $IP.InterfaceAlias }

    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        CollectedAt  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Interface    = $IP.InterfaceAlias
        Status       = $Adapter.Status
        LinkSpeed    = $Adapter.LinkSpeed
        IPv4Address  = $IP.IPv4Address.IPAddress -join ", "
        Gateway      = $IP.IPv4DefaultGateway.NextHop -join ", "
        DNS          = $IP.DNSServer.ServerAddresses -join ", "
    }
}

$CombinedInventory | Format-Table -AutoSize
