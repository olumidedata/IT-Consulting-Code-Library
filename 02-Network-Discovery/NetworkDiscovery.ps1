# Script: NetworkDiscovery.ps1
# Purpose: Test selected IP addresses for ping responses.
# Environment: Windows PowerShell 7 on Windows.
# Usage: Run from a PowerShell terminal.
# Note: No ping response does not prove a device is offline.

$NetworkPrefix = "192.168.16"
$StartHost = 60
$EndHost = 65

$TestIPs = $StartHost..$EndHost | ForEach-Object {
    "$NetworkPrefix.$_"
}

$TestIPs

$Results = foreach ($IP in $TestIPs) {
    $Responded = Test-Connection `
        -ComputerName $IP `
        -Count 1 `
        -Quiet `
        -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        IPAddress = $IP
        Responded = [bool]$Responded
    }
}

$Results | Format-Table -AutoSize
