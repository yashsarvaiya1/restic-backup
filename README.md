# Restic Backup — Setup & Usage Guide

---

## How It Works

Restic is a single `.exe` that lives on this HDD.
No installation needed on any PC.
Each backup run creates a snapshot — only new or changed files are copied.
All snapshots are stored in the `backup\` folder inside each category folder.

---

## Folder Structure

```
D:\restic\
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
- `D:\restic\` folder
- `restic.exe` and `exclude.txt` inside it
- Each category folder (`documents\`, `projects\`, `pictures\`)
- `backup.bat` and `restore.bat` inside each category folder

Things created automatically:
- `D:\restic\cache\` — created on first backup run
- `D:\restic\documents\backup\` — created by init command
- `D:\restic\projects\backup\` — created by init command
- `D:\restic\pictures\backup\` — created by init command

---

## First Time Setup

### Step 1 — Download Restic
1. Go to: https://github.com/restic/restic/releases/latest
2. Download: `restic_x.x.x_windows_amd64.zip`
   (use `windows_386.zip` only if your PC is 32-bit)
3. Extract the zip — you get a single `restic.exe` file
4. Copy `restic.exe` into `D:\restic\`

### Step 2 — Verify It Works
Open CMD and run:
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
2. Open the category folder e.g. `D:\restic\documents\`
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
- Any new local files not in the snapshot are untouched

1. Connect the HDD
2. Open the category folder e.g. `D:\restic\documents\`
3. Double-click `restore.bat`
4. Enter password when asked
5. Read the warning — press any key to continue or Ctrl+C to cancel
6. Files are restored to their exact original paths on `C:\`
7. restore path was added for setting restore at separate location, 
can be avoided for the same path restore as backup.

---

## All Manual Commands Reference

> Set these in CMD first to avoid typing --repo and --cache-dir every time:
> ```cmd
> set RESTIC_REPOSITORY=D:\restic\documents\backup
> set RESTIC_CACHE_DIR=D:\restic\cache
> ```
> Then all commands below work without those flags.

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
D:\restic\restic.exe restore latest --target "C:\" --repo D:\restic\documents\backup --cache-dir D:\restic\cache
```

### Restore a specific snapshot by ID
```cmd
REM Step 1 — find the snapshot ID you want
D:\restic\restic.exe snapshots --repo D:\restic\documents\backup --cache-dir D:\restic\cache

REM Step 2 — restore it (replace a7e27891 with actual ID)
D:\restic\restic.exe restore a7e27891 --target "C:\" --repo D:\restic\documents\backup --cache-dir D:\restic\cache
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
the contents don't matter (you can leave it empty or add a comment).

Example — skip heavy auto-generated folders:
```
C:\Users\Yash\Projects\my-app\node_modules\.resticignore
C:\Users\Yash\Projects\my-app\.next\.resticignore
C:\Users\Yash\Projects\my-app\venv\.resticignore
C:\Users\Yash\Projects\my-app\dist\.resticignore
```

The backup command uses `--exclude-if-present .resticignore` which tells
restic: if you find a file called `.resticignore` inside any folder,
skip that entire folder.

Global file-level rules like `*.pyc`, `*.log`, `.env` are handled
by `D:\restic\exclude.txt` — you don't need `.resticignore` for those.

---

## Cache Notes

`D:\restic\cache\` is shared across all repos and all PCs automatically.
Restic creates one subfolder per repo inside it on first run:
```
D:\restic\cache\
├── d959c3a99c\    ← auto-created for documents repo
├── a1b2c3d4e5\    ← auto-created for projects repo
└── f6g7h8i9j0\    ← auto-created for pictures repo
```
To clear cache: delete the entire `D:\restic\cache\` folder.
Restic recreates it automatically on the next backup run.

---

## Password Notes

- Each repo has its own independent password set during `init`
- `.bat` files have the password line commented out by default
- Uncomment and fill it in if you want no password prompt on that PC
- If left commented, restic asks for it each time the bat runs
- Never lose the password — the repo cannot be opened without it


***

## Copying for Other Categories

For `projects\` and `pictures\`, copy the same two `.bat` files and change **only these lines** at the top:

**projects\backup.bat:**
```bat
set RESTIC_REPOSITORY=D:\restic\projects\backup
set BACKUP_PATHS="C:\Users\%USERNAME%\Projects"
```
**projects\restore.bat:**
```bat
set RESTIC_REPOSITORY=D:\restic\projects\backup
set RESTORE_PATH=C:/Users/%USERNAME%/Projects
```

**pictures\backup.bat:**
```bat
set RESTIC_REPOSITORY=D:\restic\pictures\backup
set BACKUP_PATHS="C:\Users\%USERNAME%\Pictures"
```
**pictures\restore.bat:**
```bat
set RESTIC_REPOSITORY=D:\restic\pictures\backup
set RESTORE_PATH=C:/Users/%USERNAME%/Pictures
```

Everything else in both files stays identical. ✅
