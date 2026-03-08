# Restic Backup — Setup & Usage Guide

---

## How It Works

Restic is a single `.exe` that lives on this HDD.
No installation needed on any PC.
Each backup run creates a snapshot — only new or changed files are copied.
All snapshots are stored in the `backup\` folder inside each category folder.
The HDD drive letter is auto-detected, so bat files work on any PC regardless
of what drive letter Windows assigns to the HDD.

---

## Folder Structure

```
[HDD]:\restic\
├── restic.exe        ← place manually after downloading
├── exclude.txt       ← place manually, global ignore rules
├── cache\            ← auto-created by restic on first run, do not touch
│
├── documents\        ← create this folder manually
│   ├── backup.bat    ← place manually
│   ├── restore.bat   ← place manually
│   └── backup\       ← auto-created by init command, do not touch
│
├── projects\         ← create this folder manually
│   ├── backup.bat
│   ├── restore.bat
│   └── backup\       ← auto-created by init command
│
└── pictures\         ← create this folder manually
    ├── backup.bat
    ├── restore.bat
    └── backup\       ← auto-created by init command
```

Things you create manually:
- The `restic\` folder on the HDD root
- `restic.exe` and `exclude.txt` inside it
- Each category folder (`documents\`, `projects\`, `pictures\`)
- `backup.bat` and `restore.bat` inside each category folder

Things created automatically:
- `cache\` — created on first backup run
- `[category]\backup\` — created by the init command, one per category

---

## First Time Setup

### Step 1 — Download Restic
1. Go to: https://github.com/restic/restic/releases/latest
2. Download: `restic_x.x.x_windows_amd64.zip`
   (use `windows_386.zip` only if your PC is 32-bit)
3. Extract the zip — you get a single `restic.exe` file
4. Copy `restic.exe` into `[HDD]:\restic\`

### Step 2 — Verify It Works
Open CMD and run (replace D with your actual HDD drive letter):
```cmd
D:\restic\restic.exe version
```
Expected output:
```
restic 0.18.1 compiled with go1.25.1 on windows/amd64
```

### Step 3 — Create Category Folders and Place .bat Files
For each category you want to back up:
1. Create the folder on HDD, e.g. `D:\restic\documents\`
2. Place `backup.bat` and `restore.bat` inside it
3. Edit the CONFIGURATION section at the top of each bat file

### Step 4 — Initialize Each Repo (Run Once Per Category)
Open CMD and run one line per category.
This creates the `backup\` folder automatically — do not create it manually:
```cmd
D:\restic\restic.exe init --repo D:\restic\documents\backup --cache-dir D:\restic\cache
D:\restic\restic.exe init --repo D:\restic\projects\backup --cache-dir D:\restic\cache
D:\restic\restic.exe init --repo D:\restic\pictures\backup --cache-dir D:\restic\cache
```
Each repo will ask you to set a password.
⚠️ Remember each password — there is NO recovery option if lost.

---

## Daily Workflow

### To BACKUP (save your work to HDD)
1. Connect the HDD
2. Open the category folder e.g. `[HDD]:\restic\documents\`
3. Double-click `backup.bat`
4. Enter password when asked (unless saved in the bat file)
5. Progress is shown → snapshot list displayed → press any key to close

### To RESTORE (get files from HDD back to laptop)
⚠️ Rule: If you have LOCAL changes AND the HDD has newer snapshots
from other PCs — always BACKUP FIRST, then RESTORE.

Why this is safe:
- Backup saves your local work as a new snapshot first
- Restore brings in the latest state from HDD
- Restic only overwrites files that exist in the snapshot
- Any new local files not in the snapshot are left untouched

1. Connect the HDD
2. Open the category folder e.g. `[HDD]:\restic\documents\`
3. Double-click `restore.bat`
4. Enter password when asked
5. Read the warning — press any key to continue or Ctrl+C to cancel
6. Files are restored to their exact original paths

---

## Setting SNAPSHOT_PATH and RESTORE_TARGET in restore.bat

Restic stores Windows paths internally with a drive letter prefix:
`C:\Users\Yash\Pictures` is stored as `/C/Users/Yash/Pictures` in the snapshot.

The `latest:PATH` syntax tells restic to start restoring from a specific
subfolder inside the snapshot, which strips the prefix and lands files
at the correct location without creating nested folders.

### Case 1 — Single folder backup
```
Backup path:     C:\Users\Yash\Pictures
SNAPSHOT_PATH=   C/Users/Yash/Pictures
RESTORE_TARGET=  C:\Users\Yash\Pictures
```

### Case 2 — Multiple folders, same parent
```
Backup paths:    C:\Users\Yash\Pictures
                 C:\Users\Yash\Music
Common parent:   C:\Users\Yash
SNAPSHOT_PATH=   C/Users/Yash
RESTORE_TARGET=  C:\Users\Yash
```
One restore command covers both folders automatically.

### Case 3 — Multiple folders, different parents
```
Backup paths:    C:\Users\Yash\Pictures
                 C:\Work\Projects
No common parent — needs two separate restore commands
Set first pair:
SNAPSHOT_PATH=   C/Users/Yash
RESTORE_TARGET=  C:\Users\Yash

Add second command in the restore section:
restic.exe restore "latest:C/Work" --target "C:\Work" --verbose
```

### Case 4 — Backup from a different drive
```
Backup path:     D:\Projects
SNAPSHOT_PATH=   D/Projects
RESTORE_TARGET=  D:\Projects
```
Restic stores each drive letter as the first folder in the snapshot path.
Replace C with the actual drive letter in both SNAPSHOT_PATH and RESTORE_TARGET.

### Case 5 — Mixed drives
```
Backup paths:    C:\Users\Yash\Pictures
                 D:\Projects
Set first pair:
SNAPSHOT_PATH=   C/Users/Yash
RESTORE_TARGET=  C:\Users\Yash

Add second command in restore section:
restic.exe restore "latest:D/Projects" --target "D:\Projects" --verbose
```

---

## All Manual Commands Reference

> Set these in CMD first to avoid repeating flags every time:
> ```cmd
> set RESTIC_REPOSITORY=D:\restic\documents\backup
> set RESTIC_CACHE_DIR=D:\restic\cache
> ```
> After setting those, all commands below work without --repo and --cache-dir.

### Initialize a repo
```cmd
D:\restic\restic.exe init --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### Run a backup
```cmd
D:\restic\restic.exe backup "C:\Users\%USERNAME%\Documents" --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### List all snapshots
```cmd
D:\restic\restic.exe snapshots --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### List snapshots from this PC only
```cmd
D:\restic\restic.exe snapshots --repo D:\restic\documents\backup --cache-dir D:\restic\cache --host %COMPUTERNAME%
```

### Browse files inside a snapshot (without restoring)
```cmd
REM Latest snapshot
D:\restic\restic.exe ls latest --repo D:\restic\documents\backup --cache-dir D:\restic\cache

REM Specific snapshot by ID
D:\restic\restic.exe ls a7e27891 --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### Restore latest snapshot
```cmd
D:\restic\restic.exe restore "latest:C/Users/%USERNAME%/Documents" --target "C:\Users\%USERNAME%\Documents" --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### Restore a specific snapshot by ID
```cmd
REM Step 1 — find the snapshot ID you want
D:\restic\restic.exe snapshots --repo D:\restic\documents\backup --cache-dir D:\restic\cache

REM Step 2 — restore it (replace a7e27891 with actual ID)
D:\restic\restic.exe restore "a7e27891:C/Users/%USERNAME%/Documents" --target "C:\Users\%USERNAME%\Documents" --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### Delete old snapshots (keep last 20)
```cmd
D:\restic\restic.exe forget --keep-last 20 --prune --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### Check repo health
```cmd
D:\restic\restic.exe check --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### Show repo disk usage
```cmd
D:\restic\restic.exe stats --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

---

## .resticignore File (Per-Folder Skip)

Place a `.resticignore` file inside any subfolder you want restic to skip
entirely during backup. Just the presence of the file is enough —
contents don't matter, leave it empty or add a comment.

Example — skip heavy auto-generated folders:
```
C:\Users\Yash\Projects\my-app\node_modules\.resticignore
C:\Users\Yash\Projects\my-app\.next\.resticignore
C:\Users\Yash\Projects\my-app\venv\.resticignore
C:\Users\Yash\Projects\my-app\dist\.resticignore
```

The backup command uses `--exclude-if-present .resticignore` which tells
restic: if a file named `.resticignore` exists inside a folder, skip that
entire folder.

Global file-level rules like `*.pyc`, `*.log`, `.env` are handled by
`exclude.txt` at the restic root — no `.resticignore` needed for those.

---

## Cache Notes

`cache\` is shared across all repos and all PCs automatically.
Restic creates one subfolder per repo inside it on first run:
```
cache\
├── d959c3a99c\    ← auto-created for documents repo
├── a1b2c3d4e5\    ← auto-created for projects repo
└── f6g7h8i9j0\    ← auto-created for pictures repo
```
To clear cache: delete the entire `cache\` folder.
Restic recreates it automatically on the next backup run.

---

## Password Notes

- Each repo has its own independent password set during `init`
- `.bat` files have the password line commented out by default
- Uncomment and fill it in if you want no password prompt on that PC
- If left commented, restic asks for it once and reuses it for all commands
- Never lose the password — the repo cannot be opened without it

---

## Adding a New Category

1. Create folder e.g. `[HDD]:\restic\music\`
2. Copy `backup.bat` and `restore.bat` from any existing category into it
3. Edit only the CONFIGURATION section at the top — change these lines:

**backup.bat:**
```bat
set RESTIC_REPOSITORY=%HDD%\restic\music\backup
set BACKUP_PATHS="C:\Users\%USERNAME%\Music"
```

**restore.bat:**
```bat
set RESTIC_REPOSITORY=%HDD%\restic\music\backup
set SNAPSHOT_PATH=C/Users/%USERNAME%/Music
set RESTORE_TARGET=C:\Users\%USERNAME%\Music
```

4. Run init once for the new repo:
```cmd
D:\restic\restic.exe init --repo D:\restic\music\backup --cache-dir D:\restic\cache
```

Everything else in both files stays identical. ✅
