@echo off
setlocal enabledelayedexpansion

rem === Config ===
set "QUARANTINE=Quarantine"
set "SUSPICIOUS_EXTENSIONS=.exe .bat .cmd .vbs .ps1 .js .dll .scr"
set "SUSPICIOUS_KEYWORDS=keylog stealer backdoor rat hook persist inject disable defender bypass uac powershell base64"

rem === Create quarantine folder ===
if not exist "%QUARANTINE%" mkdir "%QUARANTINE%"

rem === Ask for folder ===
set /p "FOLDER=Enter full folder path to scan: "
if not exist "%FOLDER%" (
    echo Folder not found: %FOLDER%
    pause
    exit /b 1
)

echo Scanning folder: %FOLDER%
echo.

rem === Scan files recursively ===
for /r "%FOLDER%" %%F in (*) do (
    set "FILE=%%~nxF"
    set "EXT=%%~xF"
    set "LOWER_EXT=!EXT:~0!"

    rem Check extension
    set "EXT_MATCH=0"
    for %%E in (%SUSPICIOUS_EXTENSIONS%) do (
        if /i "%%E"=="!LOWER_EXT!" set EXT_MATCH=1
    )

    if !EXT_MATCH! EQU 1 (
        rem Search file for suspicious keywords
        set "FOUND=0"
        for %%K in (%SUSPICIOUS_KEYWORDS%) do (
            findstr /i /m "%%K" "%%F" >nul 2>&1
            if !errorlevel! EQU 0 (
                set FOUND=1
                goto :found_match
            )
        )
        :found_match

        if !FOUND! EQU 1 (
            rem Move to quarantine (avoid overwriting)
            set "BASENAME=%%~nF"
            set "EXTENSION=%%~xF"
            set "DEST=%QUARANTINE%\!BASENAME!!EXTENSION!"
            set /a COUNT=1
            :check_exists
            if exist "!DEST!" (
                set "DEST=%QUARANTINE%\!BASENAME!_!COUNT!!EXTENSION!"
                set /a COUNT+=1
                goto check_exists
            )
            move "%%F" "!DEST!" >nul
            echo Quarantined: %%F
        )
    )
)

echo.
echo Scan complete.
pause
