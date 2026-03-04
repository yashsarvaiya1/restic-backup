@echo off
chcp 65001 >nul

REM  Auto-elevate to administrator if not already running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

title Restic Backup
color 0A

REM ╔══════════════════════════════════════════════════════════╗
REM ║              CONFIGURATION — Edit this section           ║
REM ╚══════════════════════════════════════════════════════════╝

REM  Auto-detect HDD drive letter — works on any PC
set HDD=%~d0

set RESTIC_REPOSITORY=%HDD%\restic\temp\backup
set RESTIC_CACHE_DIR=%HDD%\restic\cache

REM  Uncomment below to skip password prompt on this PC
REM  set RESTIC_PASSWORD=yourpassword

REM  BACKUP PATHS
REM  One folder per line, keep ^ at end of every line except the last
set BACKUP_PATHS=^
  "C:\Users\Yash\Downloads\vishi"

REM  Global exclude rules file
set EXCLUDE_FILE=%HDD%\restic\exclude.txt

REM ╔══════════════════════════════════════════════════════════╗
REM ║                    Do not edit below                     ║
REM ╚══════════════════════════════════════════════════════════╝

cls
echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║               RESTIC BACKUP — Pictures               ║
echo  ╠══════════════════════════════════════════════════════╣
echo  ║  HDD  : %HDD%
echo  ║  PC   : %COMPUTERNAME%
echo  ║  User : %USERNAME%
echo  ║  Time : %DATE%  %TIME%
echo  ╚══════════════════════════════════════════════════════╝
echo.

REM  Ask for password once — reused for all commands below
if not defined RESTIC_PASSWORD (
    set /p RESTIC_PASSWORD=  Enter repository password: 
    echo.
)

echo  Folders queued for backup:
echo  %BACKUP_PATHS%
echo.

echo  ┌─────────────────────────────────────────────────────┐
echo  │  [1/3]  Running backup...                           │
echo  └─────────────────────────────────────────────────────┘
echo.

%HDD%\restic\restic.exe backup %BACKUP_PATHS% ^
  --exclude-file "%EXCLUDE_FILE%" ^
  --exclude-if-present .resticignore ^
  --use-fs-snapshot ^
  --verbose

echo.
echo  ┌─────────────────────────────────────────────────────┐
echo  │  [2/3]  Removing old snapshots (keeping last 20)... │
echo  └─────────────────────────────────────────────────────┘
echo.

%HDD%\restic\restic.exe forget --keep-last 20 --prune

echo.
echo  ┌─────────────────────────────────────────────────────┐
echo  │  [3/3]  Snapshot list                               │
echo  └─────────────────────────────────────────────────────┘
echo.

%HDD%\restic\restic.exe snapshots

echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║                  BACKUP COMPLETE                     ║
echo  ╚══════════════════════════════════════════════════════╝
echo.
pause >nul
