# 1) Name exceeds 25 chars
plcli -a "TaskNameExceedingTwentyFiveCharacters"

# 2) Priority exceeds 10 chars
plcli -a "TaskFail2" -p "PriorityTooLong"

# 3) Due exceeds 12 chars
plcli -a "TaskFail3" -d "2025-03-15_LONG_DUE"

# 4) Note exceeds 30 chars
plcli -a "TaskFail4" -n "This note has at least 31 characters total."

# 5) Update an existing ID but exceed name length
plcli -u 1 -t "VeryVeryLongNewNameExceedLimit"

# 6) Update priority with > 10 chars
plcli -u 2 -p "IMPOSSIBLELONG"

# 7) Update due with 13 chars 
plcli -u 3 -d "LongDeadline_123"

# 8) Update note with 31+ chars
plcli -u 4 -n "This new note definitely breaks limit!"

# 9) Adding a valid name but a very long note
plcli -a "TaskFail9" -n "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"  # 31 'A's

# 10) Attempt to add with a name that is just 1 char over limit (26 chars)
plcli -a "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
