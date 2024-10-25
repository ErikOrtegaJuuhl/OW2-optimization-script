@echo off
:: ---------------------------------------
:: Erik's PC Tweaking Tool - Professional Version
:: ---------------------------------------
:: Check if running as admin
openfiles >nul 2>&1
if '%errorlevel%' neq '0' (
    echo You need to run this script as an administrator.
    pause
    exit /b
)

:: Create a system restore point
echo Creating system restore point...
powershell -command "Checkpoint-Computer -Description 'Pre-OW2 Tweaks Restore Point' -RestorePointType MODIFY_SETTINGS"
echo.

:: Display Menu
:menu
cls
echo =====================================
echo                Erik's
echo           PC TWEAKING TOOL
echo =====================================
echo                MENU
echo =====================================
echo 1. Optimize PC settings
echo 2. Import best OW2 settings
echo 3. Start up file for OW2
echo 4. Exit
echo =====================================
echo Credit to Chris Titus, Lecctron and www.boostingfactory.com for all tweaks.
set /p choice="Please enter your choice (1-5): "

if "%choice%" == "1" goto optimize_pc
if "%choice%" == "2" goto import_ow2_settings
if "%choice%" == "3" goto setup_startup_script
if "%choice%" == "4" goto exit_script
goto menu

:: Option 1 - Optimize PC for Gaming
:optimize_pc
cls
echo Optimizing PC for Gaming...

:: Enable Hardware-Accelerated GPU Scheduling
echo Enabling Hardware-Accelerated GPU Scheduling...
powershell -Command "if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\HardwareSettings\HWSchMode') { Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\HardwareSettings' -Name 'HWSchMode' -Value 2 -Force }"

:: Enable Optimization for Windowed Games
echo Enabling Optimization for Windowed Games...
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoHDRUserConsent" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "PerfWaitMult" /t REG_DWORD /d 1 /f

:: Add Overwatch 2 to High Performance Graphics Settings
echo Adding Overwatch 2 to High Performance Graphics Settings...
powershell -Command "& {Add-AppxPackage -register 'C:\Windows\System32\GraphicsPerfSvc.dll'; Start-Sleep -Seconds 2; $graphicsPath = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; if (-not (Test-Path $graphicsPath)) { New-Item -Path $graphicsPath -Force }; Set-ItemProperty -Path $graphicsPath -Name 'C:\Path\To\Overwatch2\Overwatch2.exe' -Value 'GpuPreference=2;' -Force }"

:: Enable Game Mode
echo Enabling Game Mode...
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f

:: Delete Temporary Files
echo Deleting temporary files...
del /q /s /f %TEMP%\*
del /q /s /f C:\Windows\Temp\*

:: Disable Consumer Features
echo Disabling consumer features...
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\FeatureManagement\Overrides" /v "EnabledState" /t REG_DWORD /d 1 /f

:: Disable Telemetry
echo Disabling telemetry...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f

:: Disable Activity History
echo Disabling activity history...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f

:: Disable GameDVR
echo Disabling GameDVR...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f

:: Disable Hibernation
echo Disabling hibernation...
powercfg -h off

:: Disable HomeGroup
echo Disabling HomeGroup services...
sc config "HomeGroupListener" start= disabled
sc config "HomeGroupProvider" start= disabled

:: Prefer IPv4 over IPv6
echo Preferring IPv4 over IPv6...
netsh interface ipv6 set global randomizeidentifiers=disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 0x20 /f

:: Disable Location Tracking
echo Disabling location tracking...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f

:: Disable Storage Sense
echo Disabling Storage Sense...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\StorageSense" /v "AllowStorageSenseGlobal" /t REG_DWORD /d 0 /f

:: Enable End Task with Right Click in Taskbar
echo Enabling end task with right-click...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /t REG_DWORD /d 0 /f

:: Run Disk Cleanup
echo Running disk cleanup...
cleanmgr /sagerun:1

:: Change Windows Terminal Default to PowerShell 7
echo Changing Windows Terminal default to PowerShell 7...
reg add "HKCU\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe" /v "Target" /t REG_SZ /d "%ProgramFiles%\PowerShell\7\pwsh.exe" /f

:: Disable PowerShell 7 Telemetry
echo Disabling PowerShell 7 telemetry...
reg add "HKLM\SOFTWARE\Microsoft\PowerShell\7" /v "DisableTelemetry" /t REG_DWORD /d 1 /f

:: Set Services to Manual
echo Setting services to manual...
sc config "wuauserv" start= demand
sc config "DiagTrack" start= demand

:: Debloat Microsoft Edge
echo Debloating Microsoft Edge...
taskkill /im msedge.exe /f
reg add "HKCU\Software\Microsoft\Edge" /v "HideFirstRunExperience" /t REG_DWORD /d 1 /f

:: Import Ultimate Power Plan
echo Importing Ultimate Power Plan...
powercfg -import "%~dp0UltimatePowerPlan.pow"

:: Set Ultimate Power Plan
echo Setting Ultimate Power Plan...
powercfg -setactive <UltimatePowerPlan_GUID>

echo Optimization completed!
timeout /t 5
goto menu

:: Import OW2 Settings
:import_ow2_settings
cls
echo Importing Overwatch 2 settings...

:: Prompt user for screen specs
set /p refreshRate="Enter your screen refresh rate (Normal refreshrates: 60, 144, 165, 200, 240): "
set /p screenWidth="Enter your screen width (Normal widths: 1920, 2560): "
set /p screenHeight="Enter your screen height (Normal heights: 1080, 1440): "
set /p FrameRateCap="Enter what you want your FrameRateCap to be in ow2: "

:: Update the [Render.13] section in the config file
set "configFile=%USERPROFILE%\Documents\Overwatch\Settings\Settings_v0.ini"
powershell -Command "
$configFile = '%configFile%';
(Get-Content $configFile) -replace '(?<=\[Render\.13\].*?FullScreenRefresh = )\d+', '$refreshRate' |
    -replace '(?<=\[Render\.13\].*?FullScreenWidth = )\d+', '$screenWidth' |
    -replace '(?<=\[Render\.13\].*?FullScreenHeight = )\d+', '$screenHeight' |
    -replace '(?<=\[Render\.13\].*?FrameRateCap = )\d+', '$FrameRateCap' |
    Set-Content $configFile
"

echo Overwatch 2 settings imported successfully!
timeout /t 5
goto menu

:: Setup Startup Script for OW2
:setup_startup_script
cls
echo Setting up startup script for Overwatch 2...

:: Define the path to the batch script
set "batchScriptPath=%~dp0ow2_startup.bat"

:: Define the Overwatch 2 executable path
set "ow2ExecutablePath=C:\Path\To\overwatch2.exe"

:: Create the XML for the event filter
set "eventFilterXml=<QueryList><Query Id='0' Path='System'><Select Path='System'>*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (EventID=4688)]] and *[EventData[Data[@Name='NewProcessName'] and (Data='%ow2ExecutablePath%')]]</Select></Query></QueryList>"

:: Create the scheduled task action
powershell -Command "New-ScheduledTaskAction -Execute 'cmd.exe' -Argument '/c `\"%batchScriptPath%`\"' | Register-ScheduledTask -Action $_ -Trigger (New-ScheduledTaskTrigger -AtStartup) -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable) -TaskName 'OW2 Startup Script' -Description 'Runs a batch script when Overwatch 2 starts' -User 'SYSTEM'"