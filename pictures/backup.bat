@echo off
title Restic Backup — Pictures

REM ============================================================
REM  CONFIGURATION — Edit this section only
REM ============================================================

set RESTIC_REPOSITORY=D:\restic\pictures\backup
set RESTIC_CACHE_DIR=D:\restic\cache

REM  Uncomment below to skip password prompt on this PC
REM  set RESTIC_PASSWORD=yash2002

set BACKUP_PATHS=^
  "C:\Users\%USERNAME%\Pictures" ^
  "C:\Users\%USERNAME%\Music"

set EXCLUDE_FILE=D:\restic\exclude.txt

REM ============================================================
REM  BACKUP — Do not edit below this line
REM ============================================================

echo.
echo ==========================================
echo   RESTIC BACKUP — Pictures
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

echo  Backing up:
echo  %BACKUP_PATHS%
echo.
echo ------------------------------------------
echo [1/3] Running backup...
echo ------------------------------------------
echo.

D:\restic\restic.exe backup %BACKUP_PATHS% ^
  --exclude-file "%EXCLUDE_FILE%" ^
  --exclude-if-present .resticignore ^
  --verbose

echo.
echo ------------------------------------------
echo [2/3] Cleaning old snapshots (keeping last 20)...
echo ------------------------------------------
echo.

D:\restic\restic.exe forget --keep-last 20 --prune

echo.
echo ------------------------------------------
echo [3/3] All snapshots in this repo:
echo ------------------------------------------
echo.

D:\restic\restic.exe snapshots

echo.
echo ==========================================
echo   BACKUP COMPLETE
echo   Press any key to close...
echo ==========================================
echo.
pause >nul
