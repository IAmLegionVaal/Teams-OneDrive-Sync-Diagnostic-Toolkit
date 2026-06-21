[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
 [switch]$ResetOneDrive,
 [switch]$ClearTeamsCache,
 [switch]$RestartApps,
 [switch]$DryRun,
 [switch]$Yes,
 [string]$OutputPath=(Join-Path $env:LOCALAPPDATA 'TeamsOneDriveRepairReports')
)
$ErrorActionPreference='Stop';$script:Failures=0;$script:Actions=0
$run=Join-Path $OutputPath (Get-Date -Format yyyyMMdd_HHmmss);New-Item -ItemType Directory $run -Force|Out-Null
$log=Join-Path $run 'repair.log';$before=Join-Path $run 'before.json';$after=Join-Path $run 'after.json'
function Log($m){"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"|Tee-Object -FilePath $log -Append}
function State{[pscustomobject]@{Collected=Get-Date;OneDrive=Get-Process OneDrive -ErrorAction SilentlyContinue|Select-Object Id,StartTime,Path;Teams=Get-Process ms-teams,Teams -ErrorAction SilentlyContinue|Select-Object Id,Name,StartTime,Path;OneDriveRoots=Get-ChildItem Env:|Where-Object Name -like 'OneDrive*';CloudFiles=Get-Service cldflt -ErrorAction SilentlyContinue|Select-Object Name,Status,StartType}}
function Act($d,[scriptblock]$a){$script:Actions++;Log $d;if($DryRun){Log "DRY-RUN: $d";return};try{&$a;Log "SUCCESS: $d"}catch{$script:Failures++;Log "FAILED: $d - $($_.Exception.Message)"}}
State|ConvertTo-Json -Depth 5|Set-Content $before -Encoding UTF8
if(-not($ResetOneDrive -or $ClearTeamsCache -or $RestartApps)){Write-Error 'Choose at least one repair action.';exit 2}
if(-not $Yes -and -not $DryRun){if((Read-Host 'Apply selected Teams and OneDrive repairs? Apps will close. Type YES') -ne 'YES'){Log 'Cancelled.';exit 10}}
if($ResetOneDrive -or $ClearTeamsCache -or $RestartApps){Act 'Closing Teams and OneDrive processes' {Get-Process OneDrive,ms-teams,Teams -ErrorAction SilentlyContinue|Stop-Process -Force -ErrorAction SilentlyContinue}}
$oneDriveCandidates=@("$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe","$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe","${env:ProgramFiles(x86)}\Microsoft OneDrive\OneDrive.exe")
$oneDriveExe=$oneDriveCandidates|Where-Object {Test-Path $_}|Select-Object -First 1
if($ResetOneDrive){if(-not $oneDriveExe){Write-Error 'OneDrive.exe was not found.';exit 3};Act 'Resetting OneDrive sync client' {Start-Process $oneDriveExe -ArgumentList '/reset' -Wait};Start-Sleep 3;Act 'Starting OneDrive' {Start-Process $oneDriveExe}}
if($ClearTeamsCache){$paths=@("$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams","$env:APPDATA\Microsoft\Teams");foreach($p in $paths){Act "Clearing Teams cache at $p" {if(Test-Path $p){Get-ChildItem $p -Force -ErrorAction SilentlyContinue|Remove-Item -Recurse -Force -ErrorAction SilentlyContinue}}}}
if($RestartApps -and -not $ResetOneDrive -and $oneDriveExe){Act 'Starting OneDrive' {Start-Process $oneDriveExe}}
Start-Sleep 3;State|ConvertTo-Json -Depth 5|Set-Content $after -Encoding UTF8
if($script:Failures){Log "Completed with $script:Failures failure(s).";exit 20};Log "Repair completed. Actions: $script:Actions";exit 0
