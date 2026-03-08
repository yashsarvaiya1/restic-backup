@echo off
chcp 65001 >nul

REM  Auto-elevate to administrator if not already running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

title Restic Restore
color 0B

REM ╔══════════════════════════════════════════════════════════╗
REM ║              CONFIGURATION — Edit this section           ║
REM ╚══════════════════════════════════════════════════════════╝

REM  Auto-detect HDD drive letter — works on any PC
set HDD=%~d0

set RESTIC_REPOSITORY=%HDD%\restic\temp\backup
set RESTIC_CACHE_DIR=%HDD%\restic\cache

REM  Uncomment below to skip password prompt on this PC
REM  set RESTIC_PASSWORD=yourpassword

REM ┌─────────────────────────────────────────────────────────┐
REM │  SNAPSHOT_PATH and RESTORE_TARGET                       │
REM ├─────────────────────────────────────────────────────────┤
REM │  Rule: both point to the same folder, different slashes  │
REM │  SNAPSHOT_PATH  → forward slashes, no leading slash     │
REM │  RESTORE_TARGET → backslashes                           │
REM │                                                         │
REM │  Case 1 — Single folder:                               │
REM │    SNAPSHOT_PATH=   C/Users/Yash/Pictures              │
REM │    RESTORE_TARGET=  C:\Users\Yash\Pictures             │
REM │                                                         │
REM │  Case 2 — Multiple folders, same parent:               │
REM │    SNAPSHOT_PATH=   C/Users/Yash                       │
REM │    RESTORE_TARGET=  C:\Users\Yash                      │
REM │                                                         │
REM │  Case 3 — Multiple folders, different parents:         │
REM │    Set first pair below, then add extra restore command │
REM │    in the restore section for each additional parent:   │
REM │    restic.exe restore "latest:C/Work" --target "C:\Work"│
REM │                                                         │
REM │  Case 4 — Different drive e.g D:\Projects:             │
REM │    SNAPSHOT_PATH=   D/Projects                         │
REM │    RESTORE_TARGET=  D:\Projects                        │
REM └─────────────────────────────────────────────────────────┘

set SNAPSHOT_PATH=C/Users/Yash/Downloads/vishi
set RESTORE_TARGET=C:\Users\Yash\Downloads\vishi

REM ╔══════════════════════════════════════════════════════════╗
REM ║                    Do not edit below                     ║
REM ╚══════════════════════════════════════════════════════════╝

cls
echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║              RESTIC RESTORE — Pictures               ║
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

echo  ┌─────────────────────────────────────────────────────┐
echo  │  [1/3]  Available snapshots                         │
echo  └─────────────────────────────────────────────────────┘
echo.

%HDD%\restic\restic.exe snapshots

echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║  ^!  WARNING — Read before continuing                 ║
echo  ╠══════════════════════════════════════════════════════╣
echo  ║  Have unsaved local changes?                         ║
echo  ║  Press Ctrl+C NOW → run backup.bat → restore after  ║
echo  ║                                                      ║
echo  ║  To restore a specific snapshot by ID instead:      ║
echo  ║  Ctrl+C → open CMD → run:                           ║
echo  ║  restic.exe restore "^<ID^>:%SNAPSHOT_PATH%"            ║
echo  ║             --target "%RESTORE_TARGET%"              ║
echo  ╚══════════════════════════════════════════════════════╝
echo.
echo   Press any key to restore LATEST...  or Ctrl+C to cancel
echo.
pause >nul

echo.
echo  ┌─────────────────────────────────────────────────────┐
echo  │  [2/3]  Restoring latest snapshot...               │
echo  └─────────────────────────────────────────────────────┘
echo.

REM  Add extra restore commands below for Case 3 or Case 4
REM  e.g: %HDD%\restic\restic.exe restore "latest:D/Projects" --target "D:\Projects" --verbose
%HDD%\restic\restic.exe restore "latest:%SNAPSHOT_PATH%" --target "%RESTORE_TARGET%" --verbose

echo.
echo  ┌─────────────────────────────────────────────────────┐
echo  │  [3/3]  Snapshot list after restore                 │
echo  └─────────────────────────────────────────────────────┘
echo.

%HDD%\restic\restic.exe snapshots

echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║                  RESTORE COMPLETE                    ║
echo  ╚══════════════════════════════════════════════════════╝
echo.
pause >nul
