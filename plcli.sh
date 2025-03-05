#!/bin/bash

# reorder IDs after deletion
# implement update_task
# implement reorder_task
# get the time
# complete setup process
# color the output nicely

TASKS_DATA="tasks.csv"
if [ ! -f "$TASKS_DATA" ]; then
    touch "$TASKS_DATA"
fi

# argument functions
help_task() {
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
    echo "$ID,$NAME,$PRIORITY,$DUE,$NOTE" >> "$TASKS_DATA"
    echo "Task added with ID: $ID"

}

delete_task() {
    local INPUT_ID="$1"
    if [ -z "$INPUT_ID" ]; then
        echo "Error: you must specify an ID to delete."
        exit 1
    fi

    local MOD_DATA=""
    local FOUND="false"

    while IFS=',' read -r ID NAME PRIORITY DUE NOTE; do
        # Skip empty lines in the file
        if [ -z "$ID" ]; then
            continue
        fi
        if [ "$ID" = "$INPUT_ID" ]; then
            FOUND="true"
            continue
        fi
        MOD_DATA+="${ID},${NAME},${PRIORITY},${DUE},${NOTE}\n"
    done < "$TASKS_DATA"

    if [ "$FOUND" = "false" ]; then
        echo "Error: Task with ID '$INPUT_ID' not found."
        exit 1
    fi

    # Remove any empty lines before saving
    echo -e "$MOD_DATA" | sed '/^$/d' > "$TASKS_DATA"
    echo "Task with ID '$INPUT_ID' deleted."
}

# helper functions
generate_id() {
    if [ ! -s "$TASKS_DATA" ]; then
        echo 1
    else
        # Get the first field (ID) from each line, sort numerically, pick highest
        local MAX
        MAX=$(grep -o '^[^,]*' "$TASKS_DATA" | sort -n | tail -1)
        echo $((MAX+1))
    fi
}

list_task() {
    if [ ! -s "$TASKS_DATA" ]; then
        echo "No tasks found in data file."
        return
    fi

    clear
    # Define header with fixed column widths
    printf "\n| %-5s | %-25s | %-10s | %-12s | %-30s |\n" "ID:" "Name:" "Priority:" "Due Date:" "Additional Note:"
    echo '--------------------------------------------------------------------------------------------------'

    # Read the CSV file 
    while IFS=',' read -r ID NAME PRIORITY DUE NOTE; do
        printf "| %-5s | %-25s | %-10s | %-12s | %-30s |\n" "$ID" "$NAME" "$PRIORITY" "$DUE" "$NOTE"
    done < "$TASKS_DATA"
    
    echo '--------------------------------------------------------------------------------------------------'
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
    
    -d|--delete)
        shift
        ID="$1"
        delete_task "$ID"
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

