# Script: NetworkDiscovery.ps1
# Purpose: Test selected IP addresses for ping responses.
# Environment: Windows PowerShell 7 on Windows.
# Usage: Run from a PowerShell terminal.
# Note: No ping response does not prove a device is offline.

$TestIPs = @(
    "192.168.16.8"
    "192.168.16.62"
    "192.168.16.64"
    "192.168.16.129"
    "192.168.16.130"
)

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
