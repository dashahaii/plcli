# plannerCLI (plcli)

A simple shell-based planner that manages tasks in a CSV file. The **plannerCLI** script supports listing, adding, updating, swapping, and deleting tasks, all from your terminal.

## Features

1. **Task Management**  
   - Add new tasks (including interactive mode).  
   - Update existing tasks.  
   - Delete tasks by ID.  
   - Swap the IDs of two tasks, letting you reorder them.  

2. **CSV-based Storage**  
   - Stores tasks in a `tasks.csv` file in the current directory.  
   - Automatically creates `tasks.csv` if it doesn’t exist.  

3. **Character Limit Checks**  
   - Each field (Name, Priority, Due, Note) enforces maximum lengths:
     - Name: 25 characters
     - Priority: 10 characters
     - Due Date: 12 characters
     - Additional Note: 30 characters  

4. **Interactive Mode**  
   - `-ai` or `--add-interactive` prompts you step-by-step to enter each task field.  

5. **Colorful Feedback**  
   - Uses minimal terminal colors (requires a terminal that supports `tput`).

6. **Automatic ID Management**  
   - Each new task is assigned the next numeric ID.  
   - Task deletions reorder IDs to remove gaps.

---

## Installation

1. **Clone or Download** this repository, navigate to project folder.  
2. **Make the script executable**:
   ```bash
   chmod +x ./plcli
   ```
3. *(Optional)* Place it in your `$PATH` for easier usage:
   ```bash
   sudo cp ./plcli /usr/local/bin/
   ```
   Now you can run `plcli` from anywhere.

---

## Usage

### 1. No Arguments

Running `plcli` with **no arguments** will **list** the tasks in `tasks.csv`:

```bash
plcli
```

You’ll see an ASCII table of all existing tasks along with a time-stamped header.

### 2. Add Interactive Task

Use **`-ai`** or **`--add-interactive`** to add a task in interactive mode:

```bash
plcli -ai
# or
plcli --add-interactive
```

You’ll be prompted for each field:
- **Task Name** (required, cannot be empty)
- **Priority** (optional)
- **Due Date** (optional)
- **Additional Note** (optional)

### 3. Add Task with Arguments

Use **`-a`** or **`--add`** followed by the required name and optional flags:

```bash
plcli -a "Buy milk" -p "High" -d "2025-03-15" -n "Get from grocery store"
```

**Flags**:
- `-p|--priority PRIORITY`
- `-d|--due-date DUE`
- `-n|--note|--notes NOTE`

Example:

```bash
plcli --add "Finish Homework" \
      --priority "Urgent" \
      --due-date "2025-03-10" \
      --note "Math section 5"
```

### 4. Update Task

Use **`-u`** or **`--update`** followed by the task **ID**. Provide the new values using optional flags:

```bash
plcli -u 1 -t "Buy almond milk" -p "Low" -d "2025-03-20" -n "Switched to almond"
```

**Flags**:
- `-t|--title NEW_TITLE`
- `-p|--priority NEW_PRIORITY`
- `-d|--due NEW_DUE`
- `-n|--note NEW_NOTE`

### 5. Delete Task

Use **`-d`** or **`--delete`** with the task **ID** to remove a task:

```bash
plcli -d 3
```

If tasks are deleted, the script automatically reorders the remaining task IDs so there are no gaps.

### 6. Swap Task IDs

Use **`-s`** or **`--swap`** with two task IDs. The two tasks will exchange their IDs and be reordered numerically:

```bash
plcli -s 1 2
```

---

## Script Arguments Overview

```
-h, --help
    Show help message.

-ai, --add-interactive
    Add a new task in interactive mode.

-a, --add "NAME" [-p PRIORITY] [-d DUE] [-n NOTE]
    Add a new task. NAME is required; other fields optional.

-u, --update ID [-t "TITLE"] [-p PRIORITY] [-d DUE] [-n NOTE]
    Update a task by ID. Only the fields specified will be changed.

-d, --delete ID
    Delete a task by ID; tasks below it reorder to remove gaps.

-s, --swap ID1 ID2
    Swap the two tasks' IDs (reordered to remain sequential).
```

---

## Contributing

- Fork this repository.  
- Make your changes in a feature branch.  
- Submit a pull request with a clear description.  

---

## License

*APACHE 2.0 found in LICENSE file.*
