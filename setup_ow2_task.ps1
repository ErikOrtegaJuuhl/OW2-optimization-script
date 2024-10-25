# Define the path to the batch script
$batchScriptPath = "$PSScriptRoot\OW2-optimization-script\ow2_startup.bat"

# Define the Overwatch 2 executable path
$ow2ExecutablePath = "C:\Program Files (x86)\Overwatch\Overwatch.exe"

# Create the XML for the event filter
$eventFilterXml = @"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">
      *[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (EventID=4688)]]
      and
      *[EventData[Data[@Name='NewProcessName'] and (Data='$ow2ExecutablePath')]]
    </Select>
  </Query>
</QueryList>
"@

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$batchScriptPath`""

# Create the scheduled task trigger
$trigger = New-ScheduledTaskTrigger -AtStartup

# Create the scheduled task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName "OW2 Startup Script" -Description "Runs a batch script when Overwatch 2 starts" -User "SYSTEM"

# Add the event filter to the task
$taskPath = "\OW2 Startup Script"
$task = Get-ScheduledTask -TaskPath $taskPath
$task.Xml = $task.Xml.Replace("<Select Path='System'>", $eventFilterXml)
$task | Set-ScheduledTask
