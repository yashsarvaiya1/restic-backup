@echo off
title Restic Restore — Pictures

REM ============================================================
REM  CONFIGURATION — Edit this section only
REM ============================================================

set RESTIC_REPOSITORY=D:\restic\pictures\backup
set RESTIC_CACHE_DIR=D:\restic\cache

REM  Uncomment below to skip password prompt on this PC
REM  set RESTIC_PASSWORD=yash2002

REM  SNAPSHOT_PATH — path inside snapshot after "latest:" (forward slashes)
REM  RESTORE_TARGET — matching destination on laptop (backslashes)
REM  Rule: both must point to the same logical parent folder
REM  if one folder, both path will be same as backup, till /picture (if only one)
REM  more than one folder, but same parent then both path will be same and till the parent folder - current case
REM  if more than one folder and seprate parents - then more restore command with seprate pair of snapshot-path and restore-path.
REM  Example pair:
REM    SNAPSHOT_PATH=/C/Users/%USERNAME%
REM    RESTORE_TARGET=C:\Users\%USERNAME%

set SNAPSHOT_PATH=/C/Users/%USERNAME%
set RESTORE_TARGET=C:\Users\%USERNAME%

REM  If backup paths have different parents, add extra restore
REM  commands at the bottom of the restore section, one pair per parent.
REM  Example for C:\Work\Projects:
REM    D:\restic\restic.exe restore latest:/C/Work --target C:\Work --verbose

REM ============================================================
REM  RESTORE — Do not edit below this line
REM ============================================================

echo.
echo ==========================================
echo   RESTIC RESTORE — Pictures
echo   PC   : %COMPUTERNAME%
echo   User : %USERNAME%
echo   Time : %DATE% %TIME%
echo ==========================================
echo.

REM  Ask for password once if not already set in config above
if not defined RESTIC_PASSWORD (
    set /p RESTIC_PASSWORD=Enter repository password: 
    echo.
)

echo ------------------------------------------
echo [1/3] Available snapshots:
echo ------------------------------------------
echo.

D:\restic\restic.exe snapshots

echo.
echo ==========================================
echo  ^!  WARNING — Read before continuing
echo.
echo  Have local changes not yet backed up?
echo  Press Ctrl+C NOW, run backup.bat first,
echo  then re-run restore.bat after.
echo.
echo  To restore a specific snapshot by ID:
echo  Press Ctrl+C, open CMD and run:
echo  restic.exe restore ^<ID^>:%SNAPSHOT_PATH% --target %RESTORE_TARGET%
echo ==========================================
echo.
echo  Press any key to restore LATEST snapshot...
echo  Or Ctrl+C to cancel.
echo.
pause >nul

echo.
echo ------------------------------------------
echo [2/3] Restoring latest snapshot...
echo ------------------------------------------
echo.

D:\restic\restic.exe restore latest:%SNAPSHOT_PATH% --target %RESTORE_TARGET% --verbose

echo.
echo ------------------------------------------
echo [3/3] All snapshots after restore:
echo ------------------------------------------
echo.

D:\restic\restic.exe snapshots

echo.
echo ==========================================
echo   RESTORE COMPLETE
echo   Press any key to close...
echo ==========================================
echo.
pause >nul
