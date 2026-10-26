# Script: NetworkDiscovery.ps1
# Purpose: Test selected IP addresses for ping responses.
# Environment: Windows PowerShell 7 on Windows.
# Usage: Run from a PowerShell terminal.
# Note: No ping response does not prove a device is offline.

function Test-NetworkRange {
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^(?:\d{1,3}\.){2}\d{1,3}$')]
        [string]$NetworkPrefix,

        [Parameter(Mandatory)]
        [ValidateRange(1, 254)]
        [int]$StartHost,

        [Parameter(Mandatory)]
        [ValidateRange(1, 254)]
        [int]$EndHost
    )

    if ($StartHost -gt $EndHost) {
        throw "StartHost cannot be greater than EndHost."
    }

    $PrefixParts = $NetworkPrefix.Split('.')

    foreach ($Part in $PrefixParts) {
        if ([int]$Part -gt 255) {
            throw "Invalid network prefix: $NetworkPrefix"
        }
    }

    $Results = foreach ($HostNumber in $StartHost..$EndHost) {
        $IP = "$NetworkPrefix.$HostNumber"

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

    $Results
}








