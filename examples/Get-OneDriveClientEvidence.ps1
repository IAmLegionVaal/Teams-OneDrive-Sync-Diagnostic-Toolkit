#Requires -Version 5.1
<#
.SYNOPSIS
    Read-only, minimal OneDrive Windows client evidence collector.
.DESCRIPTION
    Does not expose token values, tenant names, URLs or file contents.
#>
[CmdletBinding()]
param([string]$ExpectedLocalPath)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
try {
    $running = @(Get-Process -Name OneDrive -ErrorAction SilentlyContinue).Count
    $localExe = Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe'
    $machineExe = Join-Path $env:ProgramFiles 'Microsoft OneDrive\OneDrive.exe'
    $key = 'HKCU:\Software\Microsoft\OneDrive\Accounts'
    $accounts = if (Test-Path -LiteralPath $key) {
        @(Get-ChildItem -LiteralPath $key -ErrorAction Stop).Count
    } else { 0 }
    $pathExists = if ([string]::IsNullOrWhiteSpace($ExpectedLocalPath)) {
        $null
    } else { Test-Path -LiteralPath $ExpectedLocalPath }

    [pscustomobject]@{
        TimestampUtc = (Get-Date).ToUniversalTime().ToString('o')
        OneDriveProcessCount = $running
        ClientBinaryPresent = ((Test-Path -LiteralPath $localExe) -or (Test-Path -LiteralPath $machineExe))
        AccountRegistryKeyCount = $accounts
        ExpectedPathPresent = $pathExists
        CloudRestoreValidated = 'Not checked'
        PermissionsValidated = 'Not checked'
    } | Format-List
} catch {
    Write-Error ('Unable to collect OneDrive client evidence: {0}' -f $_.Exception.Message)
    throw
}
