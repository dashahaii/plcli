@echo off
setlocal enabledelayedexpansion

:: plannerCLI for Windows (simplified version)

:: Define directories and files
set "TASKS_DIR=%USERPROFILE%\.local\share\plcli"
set "TASKS_DATA=%TASKS_DIR%\tasks.csv"

:: Create directory if it doesn't exist
if not exist "%TASKS_DIR%" mkdir "%TASKS_DIR%"

:: Create tasks file if it doesn't exist
if not exist "%TASKS_DATA%" type nul > "%TASKS_DATA%"

:: Character Limits
set MAX_NAME=25
set MAX_PRIORITY=10
set MAX_DUE=12
set MAX_NOTE=30

:: No arguments - list tasks
if "%~1"=="" goto :list_task

:: Parse arguments
if /i "%~1"=="-h" goto :help_task
if /i "%~1"=="--help" goto :help_task
if /i "%~1"=="-ai" goto :add_interactive
if /i "%~1"=="--add-interactive" goto :add_interactive
if /i "%~1"=="--add-file" goto :add_from_file
if /i "%~1"=="-af" goto :add_from_file
if /i "%~1"=="-a" goto :add_task_parse
if /i "%~1"=="--add" goto :add_task_parse
if /i "%~1"=="-u" goto :update_task_parse
if /i "%~1"=="--update" goto :update_task_parse
if /i "%~1"=="-d" goto :delete_task_parse
if /i "%~1"=="--delete" goto :delete_task_parse
if /i "%~1"=="-s" goto :swap_task_parse
if /i "%~1"=="--swap" goto :swap_task_parse

echo Error: unknown option: %1
call :help_task
exit /b 1

:generate_id
:: If file is empty, return 1
for %%A in ("%TASKS_DATA%") do if %%~zA==0 (
    set "ID=1"
    exit /b
)

:: Otherwise find highest ID and increment
set "MAX_ID=0"
for /f "usebackq tokens=1 delims=," %%a in ("%TASKS_DATA%") do (
    if %%a GTR !MAX_ID! set "MAX_ID=%%a"
)
set /a "ID=!MAX_ID!+1"
exit /b

:list_task
:: Get current time using standard date and time commands
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set "date=%%a/%%b/%%c")
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (set "time=%%a:%%b")
set "CURRENT_TIME=%date% %time%"

:: Check if file is empty
for %%A in ("%TASKS_DATA%") do if %%~zA==0 (
    echo No tasks found in data file.
    exit /b 0
)

cls
:: Print header
echo Welcome to plannerCLI! (plcli)                 (Version 0.0.1) ^| Last Refresh: %CURRENT_TIME%
echo ==================================================================================================
echo ^| ID:   ^| Name:                    ^| Priority:  ^| Due Date:    ^| Additional Note:                ^|
echo --------------------------------------------------------------------------------------------------

:: Read and display CSV data
for /f "usebackq tokens=1-5 delims=," %%a in ("%TASKS_DATA%") do (
    set "id=%%a:   "
    set "name=%%b                         "
    set "priority=%%c            "
    set "due=%%d              "
    set "note=%%e                                "
    
    :: Trim to exact field width
    set "id=!id:~0,5!"
    set "name=!name:~0,25!"
    set "priority=!priority:~0,10!"
    set "due=!due:~0,12!"
    set "note=!note:~0,30!"
    
    echo ^| !id! ^| !name! ^| !priority! ^| !due! ^| !note! ^|
)

echo --------------------------------------------------------------------------------------------------
echo ==================================================================================================
exit /b 0

:check_length
set "value=%~1"
set "max_len=%~2"
set "field_name=%~3"

call :strlen "%value%" len
if %len% GTR %max_len% (
    echo Error: '%field_name%' cannot exceed %max_len% characters.
    exit /b 1
)
exit /b 0

:strlen
setlocal enabledelayedexpansion
set str=%~1
set len=0
if defined str (
    for /L %%A in (0,1,100) do (
        if "!str:~%%A,1!" neq "" (
            set /a "len+=1"
        ) else (
            goto :strlen_end
        )
    )
)
:strlen_end
endlocal & set "%~2=%len%"
exit /b 0

:help_task
echo Usage: plcli [options]
echo.
echo No options given will clear the screen ^& print the planner.
echo.
echo Task Options:
echo     -h, --help
echo         Displays tasks help message.
echo.
echo     -ai, --add-interactive
echo         Add a new task with an interactive prompt.
echo.
echo     -af, --add-file "filename.csv"
echo         Import tasks from a CSV file.
echo         Format: Name,Priority,DueDate,Note (no header required)
echo.
echo     -a, --add "NAME" [-p PRIORITY] [-d DUE] [-n NOTE]
echo         Add a new task with optional values.
echo.
echo     -u, --update ID [-t "NEW TITLE"] [-p PRIORITY] [-d DUE] [-n NOTE]
echo         Update a task given ID number, change any value optionally.
echo.
echo     -d, --delete ID
echo         Delete a task given ID number.
echo.
echo     -s, --swap ID1 ID2
echo         Swap the ID numbers of two tasks, reordering them in default view.
exit /b 0

:add_interactive
echo Enter new task details (interactive mode).
    
set /p "NAME=Task Name (required): "
if "!NAME!"=="" (
    echo Error: A task name is required.
    exit /b 1
)
set /p "PRIORITY=Priority (optional): "
set /p "DUE=Due Date (optional): "
set /p "NOTE=Additional Note (optional): "
call :add_task "!NAME!" "!PRIORITY!" "!DUE!" "!NOTE!"
exit /b 0

:add_from_file
shift
set "CSV_FILE=%~1"

if "%CSV_FILE%"=="" (
    echo Error: No CSV file specified.
    exit /b 1
)

if not exist "%CSV_FILE%" (
    echo Error: CSV file '%CSV_FILE%' not found.
    exit /b 1
)

echo Importing tasks from %CSV_FILE%...
set "imported=0"

:: Process each row (no header expected)
for /f "usebackq tokens=1-4 delims=," %%a in ("%CSV_FILE%") do (
    set "NAME=%%a"
    set "PRIORITY=%%b"
    set "DUE=%%c"
    set "NOTE=%%d"
    
    :: Generate new ID and add task
    call :generate_id
    echo !ID!,!NAME!,!PRIORITY!,!DUE!,!NOTE!>> "%TASKS_DATA%"
    set /a "imported+=1"
)

echo Successfully imported %imported% tasks from %CSV_FILE%.
exit /b 0

:add_task_parse
shift
set "NAME=%~1"
if "%NAME%"=="" (
    echo Error: No name provided with --add argument.
    echo plcli -h for usage help.
    exit /b 1
)

set "PRIORITY="
set "DUE="
set "NOTE="

:add_task_parse_loop
shift
if "%~1"=="" goto :add_task_exec
if /i "%~1"=="-p" (
    set "PRIORITY=%~2"
    shift
    goto :add_task_parse_loop
)
if /i "%~1"=="--priority" (
    set "PRIORITY=%~2"
    shift
    goto :add_task_parse_loop
)
if /i "%~1"=="-d" (
    set "DUE=%~2"
    shift
    goto :add_task_parse_loop
)
if /i "%~1"=="--due-date" (
    set "DUE=%~2"
    shift
    goto :add_task_parse_loop
)
if /i "%~1"=="-n" (
    set "NOTE=%~2"
    shift
    goto :add_task_parse_loop
)
if /i "%~1"=="--note" (
    set "NOTE=%~2"
    shift
    goto :add_task_parse_loop
)
if /i "%~1"=="--notes" (
    set "NOTE=%~2"
    shift
    goto :add_task_parse_loop
)
echo Error: unknown add argument: %~1
exit /b 1

:add_task_exec
call :add_task "%NAME%" "%PRIORITY%" "%DUE%" "%NOTE%"
exit /b 0

:add_task
set "NAME=%~1"
set "PRIORITY=%~2"
set "DUE=%~3"
set "NOTE=%~4"

:: Ensure task has a name
if "%NAME%"=="" (
    echo Error: please give a name for this task.
    exit /b 1
)

:: Generate new ID
call :generate_id
echo %ID%,%NAME%,%PRIORITY%,%DUE%,%NOTE%>> "%TASKS_DATA%"
echo Task added with ID: %ID%
exit /b 0

:update_task_parse
shift
set "TARGET_ID=%~1"
if "%TARGET_ID%"=="" (
    echo Error: no task ID specified to update.
    exit /b 1
)

set "NEW_NAME="
set "NEW_PRIORITY="
set "NEW_DUE="
set "NEW_NOTE="

:update_task_parse_loop
shift
if "%~1"=="" goto :update_task_exec
if /i "%~1"=="-t" (
    set "NEW_NAME=%~2"
    shift
    goto :update_task_parse_loop
)
if /i "%~1"=="--title" (
    set "NEW_NAME=%~2"
    shift
    goto :update_task_parse_loop
)
if /i "%~1"=="-p" (
    set "NEW_PRIORITY=%~2"
    shift
    goto :update_task_parse_loop
)
if /i "%~1"=="--priority" (
    set "NEW_PRIORITY=%~2"
    shift
    goto :update_task_parse_loop
)
if /i "%~1"=="-d" (
    set "NEW_DUE=%~2"
    shift
    goto :update_task_parse_loop
)
if /i "%~1"=="--due" (
    set "NEW_DUE=%~2"
    shift
    goto :update_task_parse_loop
)
if /i "%~1"=="-n" (
    set "NEW_NOTE=%~2"
    shift
    goto :update_task_parse_loop
)
if /i "%~1"=="--note" (
    set "NEW_NOTE=%~2"
    shift
    goto :update_task_parse_loop
)
echo Error: unknown update argument: %~1
exit /b 1

:update_task_exec
call :update_task "%TARGET_ID%" "%NEW_NAME%" "%NEW_PRIORITY%" "%NEW_DUE%" "%NEW_NOTE%"
exit /b 0

:update_task
set "TARGET_ID=%~1"
set "NEW_NAME=%~2"
set "NEW_PRIORITY=%~3"
set "NEW_DUE=%~4"
set "NEW_NOTE=%~5"

if "%TARGET_ID%"=="" (
    echo Error: no task ID specified to update.
    exit /b 1
)

set "TEMP_FILE=%TEMP%\plcli_temp.csv"
set "FOUND=false"

if exist "%TEMP_FILE%" del "%TEMP_FILE%"

for /f "usebackq tokens=1-5 delims=," %%a in ("%TASKS_DATA%") do (
    set "ID=%%a"
    set "NAME=%%b"
    set "PRIORITY=%%c"
    set "DUE=%%d"
    set "NOTE=%%e"
    
    if "!ID!"=="%TARGET_ID%" (
        set "FOUND=true"
        if not "%NEW_NAME%"=="" set "NAME=%NEW_NAME%"
        if not "%NEW_PRIORITY%"=="" set "PRIORITY=%NEW_PRIORITY%"
        if not "%NEW_DUE%"=="" set "DUE=%NEW_DUE%"
        if not "%NEW_NOTE%"=="" set "NOTE=%NEW_NOTE%"
    )
    
    echo !ID!,!NAME!,!PRIORITY!,!DUE!,!NOTE!>> "%TEMP_FILE%"
)

if "%FOUND%"=="false" (
    echo Error: Task with ID '%TARGET_ID%' not found.
    exit /b 1
)

copy /y "%TEMP_FILE%" "%TASKS_DATA%" > nul
echo Task with ID '%TARGET_ID%' updated.
exit /b 0

:delete_task_parse
shift
set "INPUT_ID=%~1"
call :delete_task "%INPUT_ID%"
exit /b 0

:delete_task
set "INPUT_ID=%~1"
if "%INPUT_ID%"=="" (
    echo Error: you must specify an ID to delete.
    exit /b 1
)

set "TEMP_FILE=%TEMP%\plcli_temp.csv"
set "FOUND=false"

if exist "%TEMP_FILE%" del "%TEMP_FILE%"

for /f "usebackq tokens=1-5 delims=," %%a in ("%TASKS_DATA%") do (
    set "ID=%%a"
    set "NAME=%%b"
    set "PRIORITY=%%c"
    set "DUE=%%d"
    set "NOTE=%%e"
    
    if "!ID!"=="%INPUT_ID%" (
        set "FOUND=true"
    ) else (
        echo !ID!,!NAME!,!PRIORITY!,!DUE!,!NOTE!>> "%TEMP_FILE%"
    )
)

if "%FOUND%"=="false" (
    echo Error: Task with ID '%INPUT_ID%' not found.
    exit /b 1
)

:: Renumber tasks to remove gaps
set "RENUMBER_FILE=%TEMP%\plcli_renumber.csv"
if exist "%RENUMBER_FILE%" del "%RENUMBER_FILE%"

set "i=1"
for /f "usebackq tokens=1-5 delims=," %%a in ("%TEMP_FILE%") do (
    set "NAME=%%b"
    set "PRIORITY=%%c"
    set "DUE=%%d"
    set "NOTE=%%e"
    echo !i!,!NAME!,!PRIORITY!,!DUE!,!NOTE!>> "%RENUMBER_FILE%"
    set /a "i+=1"
)

copy /y "%RENUMBER_FILE%" "%TASKS_DATA%" > nul
echo Task with ID '%INPUT_ID%' deleted.
echo Some tasks have been reordered to remove ID gaps.
exit /b 0

:swap_task_parse
shift
set "ID1=%~1"
set "ID2=%~2"
call :swap_task "%ID1%" "%ID2%"
exit /b 0

:swap_task
set "ID1=%~1"
set "ID2=%~2"
if "%ID1%"=="" (
    echo Error: you must specify two IDs to swap.
    exit /b 1
)
if "%ID2%"=="" (
    echo Error: you must specify two IDs to swap.
    exit /b 1
)

set "TEMP_FILE=%TEMP%\plcli_temp.csv"
set "FOUND1=false"
set "FOUND2=false"

if exist "%TEMP_FILE%" del "%TEMP_FILE%"

:: Read the file and swap IDs
for /f "usebackq tokens=1-5 delims=," %%a in ("%TASKS_DATA%") do (
    set "ID=%%a"
    set "NAME=%%b"
    set "PRIORITY=%%c"
    set "DUE=%%d"
    set "NOTE=%%e"
    
    if "!ID!"=="%ID1%" (
        set "FOUND1=true"
        echo %ID2%,!NAME!,!PRIORITY!,!DUE!,!NOTE!>> "%TEMP_FILE%"
    ) else if "!ID!"=="%ID2%" (
        set "FOUND2=true"
        echo %ID1%,!NAME!,!PRIORITY!,!DUE!,!NOTE!>> "%TEMP_FILE%"
    ) else (
        echo !ID!,!NAME!,!PRIORITY!,!DUE!,!NOTE!>> "%TEMP_FILE%"
    )
)

if "%FOUND1%"=="false" (
    echo Error: ID %ID1% not found in file.
    exit /b 1
)
if "%FOUND2%"=="false" (
    echo Error: ID %ID2% not found in file.
    exit /b 1
)

:: Sort by ID for consistent display
set "SORTED_FILE=%TEMP%\plcli_sorted.csv"
if exist "%SORTED_FILE%" del "%SORTED_FILE%"

:: Simple number sort (this is primitive but works for reasonable ID counts)
for /L %%i in (1,1,1000) do (
    for /f "usebackq tokens=1-5 delims=," %%a in ("%TEMP_FILE%") do (
        if "%%a"=="%%i" echo %%a,%%b,%%c,%%d,%%e>> "%SORTED_FILE%"
    )
)

copy /y "%SORTED_FILE%" "%TASKS_DATA%" > nul
echo Tasks with IDs %ID1% and %ID2% have been swapped.
exit /b 0

endlocal