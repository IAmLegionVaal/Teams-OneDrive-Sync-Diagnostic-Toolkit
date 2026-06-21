# Teams OneDrive Sync Diagnostic Toolkit

A PowerShell toolkit for Microsoft Teams and OneDrive support checks and selected guarded repairs.

## Diagnostic script

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Teams_OneDrive_Sync_Diagnostic_Toolkit.ps1
```

## Repair script

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Teams_OneDrive_Repair_Toolkit.ps1 -ResetOneDrive -DryRun
```

Examples:

```powershell
.\Teams_OneDrive_Repair_Toolkit.ps1 -ResetOneDrive
.\Teams_OneDrive_Repair_Toolkit.ps1 -ClearTeamsCache
.\Teams_OneDrive_Repair_Toolkit.ps1 -RestartApps
```

## What the repair does

- Closes Teams and OneDrive before maintenance.
- Runs the supported OneDrive `/reset` operation and starts OneDrive again.
- Clears classic Teams and new Teams local cache paths.
- Can restart the OneDrive client after closing applications.
- Captures process, sync-root and Cloud Files service state before and after repair.
- Supports `-DryRun`, confirmation prompts, logs and clear exit codes.

## Safety

OneDrive reset does not delete cloud files but rebuilds local sync state and may require time to resynchronise. Teams cache clearing can require sign-in again. The tool does not remove accounts or credentials.

## Author

Dewald Pretorius — L2 IT Support Engineer
