@echo off
setlocal enabledelayedexpansion
:: Define the program to monitor
set "program_to_monitor=Overwatch.exe"

:check_program
tasklist /FI "IMAGENAME eq %program_to_monitor%" 2>NUL | find /I "%program_to_monitor%" >NUL
if "%ERRORLEVEL%"=="0" goto run_commands
timeout /t 5 /nobreak >NUL
goto check_program

:run_commands
echo Program %program_to_monitor% detected. Running batch commands...

:: Delete temp files
echo Deleting temporary files...
del /s /q "%TEMP%\*"
del /s /q "C:\Windows\Temp\*"

:: Delete Internet Explorer Cache
del /s /q "C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\INetCache\*"

:: Delete Downloaded Program Files
del /s /q "C:\Windows\Downloaded Program Files\*"

:: Delete Thumbnail Cache
del /s /q "C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*"

:: Delete Log Files
del /s /q "C:\Windows\System32\winevt\Logs\*"

:: Delete Prefetch Files
del /s /q "C:\Windows\Prefetch\*"

:: Delete Crash Dumps
del /s /q "C:\Windows\Minidump\*"

:: Set Power Plan to Ultimate Performance
echo Setting power plan to Ultimate Performance...
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61

:: Disable Windows Defender Real-time Monitoring
echo Disabling Windows Defender real-time monitoring...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"

:: Stop and disable Windows Update service
net stop "wuauserv" 2>nul
sc config "wuauserv" start=disabled

:: Stop and disable Live Tile updates
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\LiveTile" /v "LiveTile" /t REG_DWORD /d 0 /f

:: Set low priority for specified programs
echo Setting low priority for programs...
set "low_programs=Discord.exe Brave.exe Spotify.exe Steam.exe Chrome.exe"
set "low_priority=64"

for %%p in (%low_programs%) do (
    echo Setting priority for %%p to Below Normal...
    powershell -Command "Get-Process -Name '%%p' | ForEach-Object { $_.PriorityClass = 'BelowNormal' }"
)

:: Set high priority for specified program
echo Setting high priority for programs...
set "high_programs=%program_to_monitor%"
set "high_priority=128"

for %%p in (%high_programs%) do (
    echo Setting priority for %%p to Above Normal...
    powershell -Command "Get-Process -Name '%%p' | ForEach-Object { $_.PriorityClass = 'AboveNormal' }"
)

:: Set CPU affinity for a specific process (example: using cores 0-3)
powershell -Command "Get-Process -Name '%program_to_monitor%' | ForEach-Object { $_.ProcessorAffinity = [IntPtr] 15 }"

pause
exit
