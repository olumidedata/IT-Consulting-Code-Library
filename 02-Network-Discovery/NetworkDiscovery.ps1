
# Script: NetworkDiscovery.ps1
# Purpose: Test selected IP addresses and generate discovery reports.
# Environment: PowerShell 7 on Windows.
# Note: No ping response does not prove a device is offline.

# --------------------------------------------------
# 1. Define the network discovery function
# --------------------------------------------------

function Test-NetworkRange {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$NetworkPrefix,

        [Parameter(Mandatory)]
        [ValidateRange(1, 254)]
        [int]$StartHost,

        [Parameter(Mandatory)]
        [ValidateRange(1, 254)]
        [int]$EndHost
    )

    # Validate the format of the three-octet prefix.
    if ($NetworkPrefix -notmatch '^(0|[1-9]\d{0,2})\.(0|[1-9]\d{0,2})\.(0|[1-9]\d{0,2})$') {
        throw "Invalid network prefix format. Example: 192.168.0"
    }

    # Check that every octet is between 0 and 255.
    $PrefixParts = $NetworkPrefix.Split('.')

    foreach ($Part in $PrefixParts) {
        $Octet = [int]$Part

        if ($Octet -gt 255) {
            throw "Invalid network prefix: $NetworkPrefix. Each octet must be between 0 and 255."
        }
    }

    # Check that the host range is in the correct order.
    if ($StartHost -gt $EndHost) {
        throw "StartHost cannot be greater than EndHost."
    }

    # Test each address and return structured results.
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

    return $Results
}

# --------------------------------------------------
# 2. Configure the discovery test
# --------------------------------------------------

$NetworkPrefix = "192.168.0"
$StartHost = 1
$EndHost = 10

# --------------------------------------------------
# 3. Run the discovery test
# --------------------------------------------------

Write-Host "`nStarting network discovery..." -ForegroundColor Cyan

$Results = @(
    Test-NetworkRange `
        -NetworkPrefix $NetworkPrefix `
        -StartHost $StartHost `
        -EndHost $EndHost
)

# --------------------------------------------------
# 4. Calculate the summary
# --------------------------------------------------

$TotalTested = $Results.Count

$Responding = @(
    $Results | Where-Object { $_.Responded -eq $true }
).Count

$NotResponding = @(
    $Results | Where-Object { $_.Responded -eq $false }
).Count

$Summary = [PSCustomObject]@{
    NetworkPrefix = $NetworkPrefix
    TotalTested   = $TotalTested
    Responding    = $Responding
    NotResponding = $NotResponding
}

# --------------------------------------------------
# 5. Display the detailed results
# --------------------------------------------------

Write-Host "`nNETWORK DISCOVERY RESULTS" -ForegroundColor Cyan
Write-Host "========================="

$Results | Format-Table -AutoSize

# --------------------------------------------------
# 6. Display the summary
# --------------------------------------------------

Write-Host "`nNETWORK SUMMARY" -ForegroundColor Cyan
Write-Host "==============="

$Summary | Format-Table -AutoSize

# --------------------------------------------------
# 7. Export timestamped CSV reports
# --------------------------------------------------

$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ResultsFile = Join-Path $PSScriptRoot `
    "NetworkDiscovery_Results_$Timestamp.csv"

$SummaryFile = Join-Path $PSScriptRoot `
    "NetworkDiscovery_Summary_$Timestamp.csv"

$Results | Export-Csv `
    -Path $ResultsFile `
    -NoTypeInformation

$Summary | Export-Csv `
    -Path $SummaryFile `
    -NoTypeInformation

# --------------------------------------------------
# 8. Confirm completion
# --------------------------------------------------

Write-Host "`nReports saved successfully:" -ForegroundColor Green
Write-Host "Detailed results: $ResultsFile"
Write-Host "Summary report:   $SummaryFile"
