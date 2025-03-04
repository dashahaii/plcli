#!/bin/bash

TASKS_DATA="tasks.txt"
if [ ! -f "$TASKS_DATA" ]; then
    touch "$TASKS_DATA"
    # TODO: if its the user's first time, do a setup process
fi

# argument functions
help_task() {
  # Option for terminals with 256-color support: light blue (color code 12)
  LIGHT_BLUE=$(tput setaf 12)
  RESET=$(tput sgr0)
  
  cat <<EOF
${LIGHT_BLUE}
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
${RESET}
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

    clear
    echo " "
    echo "ID | Description | Priority | Due Date | Additional Note"
    echo "--------------------------------------------------------------"
    while IFS='|' read -r ID NAME PRIORITY DUE NOTE; do
        echo "$ID | $NAME | ${PRIORITY} | ${DUE} | ${NOTE}"
    done < "$TASKS_DATA"
    echo " "

    # TODO: stop printing bars after arguments aren't found. OR standardize spacing first.


}

# *main logic*
if [ $# -eq 0 ]; then
    list_task
    exit 0
fi

# argument parsing
case "$1" in 
    -a|--add)
        # example: plcli -a "NAME" {FLAG} [all other arguments optional] {FLAG} [...]
        shift
        NAME=""
        PRIORITY=""
        DUE=""
        NOTE=""

        # Check for name, non-optional.
        if [[ $# -gt 0 ]]; then
            NAME="$1"
            shift
        else
            echo "Error: No name provided with --add argument."
            echo "plcli -h for usage help."
            exit 1
        fi

        # Loop through command args to find optional flags.
        while [[ $# -gt 0 ]]; do
            KEY="$1"
            case $KEY in
                -p|--priority)
                    PRIORITY="$2"
                    shift
                    shift
                    ;;
                -d|--due-date)
                    DUE="$2"
                    shift
                    shift
                    ;;
                -n|--note|--notes)
                    NOTE="$2"
                    shift
                    shift
                    ;;
                *)
                    echo "Error: unknown add argument: $1"
                    exit 1
                    ;;
            esac
        done

        add_task "$NAME" "$PRIORITY" "$DUE" "$NOTE"
        ;;

    -h|--help)
        help_task
        ;;
    *)
        echo "Unknown option: $1"
        help_task
        exit 1
        ;;
esac    



