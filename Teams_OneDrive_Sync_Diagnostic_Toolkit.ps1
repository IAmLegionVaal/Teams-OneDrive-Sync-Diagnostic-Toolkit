#requires -Version 5.1
<#
.SYNOPSIS
    Teams OneDrive Sync Diagnostic Toolkit.
.DESCRIPTION
    Read-only Microsoft 365 collaboration connectivity checker.
#>
[CmdletBinding()]
param([string]$OutputPath)

$RunStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'M365_Collaboration_Reports' }
New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
function New-Check { param($Category,$Name,$Status,$Value,$Recommendation) [PSCustomObject]@{Category=$Category;Name=$Name;Status=$Status;Value=$Value;Recommendation=$Recommendation} }
$checks=@()
foreach($p in @('Teams','ms-teams','OneDrive')){ $proc=Get-Process $p -ErrorAction SilentlyContinue; $checks += New-Check 'Processes' $p 'Info' (@($proc).Count) 'Process count for support context.' }
foreach($hostName in @('teams.microsoft.com','login.microsoftonline.com','graph.microsoft.com','oneclient.sfx.ms')){
try{[void][System.Net.Dns]::GetHostAddresses($hostName);$dns='Resolved'}catch{$dns='DNS failed'}
try{$tcp=Test-NetConnection -ComputerName $hostName -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue}catch{$tcp=$false}
$checks += New-Check 'Connectivity' $hostName ($(if($tcp){'OK'}else{'Warning'})) "DNS=$dns; TCP443=$tcp" 'Review DNS, proxy, firewall, or internet path if this fails.'
}
$checks | Export-Csv (Join-Path $OutputPath "m365_collaboration_checks_$RunStamp.csv") -NoTypeInformation -Encoding UTF8
$checks | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $OutputPath "m365_collaboration_checks_$RunStamp.json") -Encoding UTF8
$checks | ConvertTo-Html -Title 'M365 Collaboration Diagnostic' -PreContent "<h1>M365 Collaboration Diagnostic - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p>" | Set-Content (Join-Path $OutputPath "m365_collaboration_report_$RunStamp.html") -Encoding UTF8
$checks | Format-Table -AutoSize -Wrap
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
Start-Process explorer.exe -ArgumentList "`"$OutputPath`"" -ErrorAction SilentlyContinue
