# Field case: moved SharePoint folder, stale File Explorer sync path and interrupted restore

**Incident month:** November 2026. **Status:** Restoration and final re-sync were pending; this document deliberately does not claim resolution.

## Symptoms
A shared folder was moved within SharePoint and access behaviour changed. Local File Explorer continued showing the earlier path. A large library had only partially synchronized, and a Microsoft 365 service incident interrupted the backup/restore approach.

## Safe sequence
1. Verify the authoritative folder path and permissions in SharePoint **on the web**, including unique item ACLs.
2. Record restore point, destination path, versions, retention and contents before making changes.
3. Do not treat a stale local File Explorer path as evidence that cloud files were deleted.
4. Check OneDrive process, client status, account selection and sync health on the endpoint.
5. Reconcile cloud content and ACLs after restore, then follow supported OneDrive re-sync procedure for the library.
6. Confirm representative documents, folder hierarchy, users' effective access and sync consistency.

## Read-only endpoint checks
```powershell
Get-Process OneDrive -ErrorAction SilentlyContinue
Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
Test-Path "HKCU:\Software\Microsoft\OneDrive\Accounts"
```

## Safety
Never delete local sync roots or use indiscriminate `Remove-Item -Recurse` as a first step. A OneDrive reset can affect local sync state; take a backup and confirm correct cloud content first. Do not publish tenant URLs, user names or permission exports.

## Verification criteria
Restored files and versions correct online; permissions work; expected local folder path and client sync agree. Not yet confirmed for this case.
