#!/bin/bash

TASKS_DATA="tasks.txt"
if [ ! -f "$TASKS_DATA" ]; then
    touch "$TASKS_DATA"
    # TODO: if its the user's first time, do a setup process
fi

# argument functions
help_task() {
    cat <<EOF
Usage: plcli [options]

No options given will clear the screen & print the planner.

Task Options:
    -h, --help
        Displays tasks help message.

    -a, --add "NAME" [-p PRIORITY] [-d DUE] [-n NOTE]
        Add a new task with optional values.

    -u, --update ID [-m "NEW TITLE"] [-p PRIORITY] [-d DUE] [-n NOTE]
        Update a task given ID number, change any value optionally.

    -d, --delete ID
        Delete a task given ID number.
EOF
}

add_task() {

    # inst. temp variables for new task
    local NAME="$1"
    local PRIORITY="$2"
    local DUE="$3"
    local NOTE="$4"

    # ensure task has a name
    if [ -z "$NAME" ]; then
        echo "Error: please give a name for this task."
        exit 1
    fi

    # inst. a new ID number
    local ID=$(generate_id)
    echo "$ID|$NAME|$PRIORITY|$DUE|$NOTE" >> "$TASKS_DATA"
    echo "Task added with ID: $ID"

}

# helper functions
generate_id() {
    if [ ! -s "$TASKS_DATA" ]; then
        echo 1
    else
        # take id from each line, sort numerically, then get tail
        MAX=$(grep -o '^[^|]*' "$TASKS_DATA" | sort -n | tail -1)
        echo $((MAX+1))
    fi
}

list_task() {
    if [ ! -s "$TASKS_DATA" ]; then
        echo "No tasks found in data file."
        return
    fi

    echo "ID | Description | Priority | Due Date | Notes"
    echo "--------------------------------------------------------------"
    while IFS='|' read -r ID NAME PRIORITY DUE NOTE; do
        echo"$ID | $NAME | ${PRIORITY: -N/A} | ${DUE: -N/A} | ${NOTE: -N/A}"
    done < "$TASKS_DATA"
}

# main logic
if [ $# -eq 0 ]; then
    list_task
    exit 0
fi

