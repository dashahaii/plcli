# 1) Minimal fields - only name
./plcli.sh -a "BuyMilk"

# 2) Adding a task with name & priority
./plcli.sh -a "TaskTwo" -p "Urgent"

# 3) Adding a task with all optional fields within constraints
./plcli.sh -a "TaskThree" -p "High" -d "2025-03-15" -n "Check groceries"

# 4) Another short name, short note
./plcli.sh -a "T4" -p "Low" -d "04/25/2025" -n "Brief note"

# 5) Priority exactly at 10 chars
./plcli.sh -a "TaskFive" -p "1234567890" -d "2025/06/01" -n "Note limit test"

# 6) Due date at 12 chars max
./plcli.sh -a "TaskSix" -p "Normal" -d "Deadline-2025" -n "Nearing limit"

# 7) Name exactly 25 chars
./plcli.sh -a "TaskNameExactlyTwentyFive" -p "OK" -d "2025-12-31" -n "Max name length"

# 8) Note at exactly 30 chars
./plcli.sh -a "TaskEight" -p "Top" -d "2025-06-15" -n "This note is 30 chars long.."

# 9) Add a simple task, no optional flags
./plcli.sh -a "WriteCode"

# 10) Add with partial optional flags
./plcli.sh -a "TaskTen" -n "Remember to finalize specs"
