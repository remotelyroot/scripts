<#
.SYNOPSIS
    Performs system cleanup including temp file removal and health scans.

.DESCRIPTION
    This script deletes temp files, clears the Recycle Bin, and runs DISM/SFC to improve performance.

.NOTES
    Author: Dominic Spucches
    Version: 1.0
    Date: 2025-05-08
#>

Write-Host @"
__________                       __         .__          __________               __ /\             
\______   \ ____   _____   _____/  |_  ____ |  | ___.__. \______   \ ____   _____/  |)/ ______      
 |       _// __ \ /     \ /  _ \   __\/ __ \|  |<   |  |  |       _//  _ \ /  _ \   __\/  ___/      
 |    |   \  ___/|  Y Y  (  <_> )  | \  ___/|  |_\___  |  |    |   (  <_> |  <_> )  |  \___ \       
 |____|_  /\___  >__|_|  /\____/|__|  \___  >____/ ____|  |____|_  /\____/ \____/|__| /____  >      
        \/     \/      \/                 \/     \/              \/                        \/       
 __      __.__            .___                    _________ .__                                     
/  \    /  \__| ____    __| _/______  _  ________ \_   ___ \|  |   ____ _____    ____   ___________ 
\   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/ /    \  \/|  | _/ __ \\__  \  /    \_/ __ \_  __ \
 \        /|  |   |  \/ /_/ (  <_> )     /\___ \  \     \___|  |_\  ___/ / __ \|   |  \  ___/|  | \/
  \__/\  / |__|___|  /\____ |\____/ \/\_//____  >  \______  /____/\___  >____  /___|  /\___  >__|   
       \/          \/      \/                 \/          \/          \/     \/     \/     \/       
"@ -ForegroundColor Green

$TempPaths = @("$env:TEMP", "$env:LOCALAPPDATA\Temp")


# Function to clean-up Temporary Files on the Windows Desktop Machine
function Clear-TempFiles {
    foreach ($temp_files in $TempPaths){
        try {
            Remove-Item -Path $temp_files -Force -Recurse -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "Could not delete $temp_files $_" -ForegroundColor Green
        }
        Write-Host "Temporary files have been removed." -ForegroundColor Green
    }
}

function Start-RecycleBin {
    Clear-RecycleBin
    Write-Host "Recycle bin has been emptied" -ForegroundColor Green
}

function Start-DISM {
    Start-Process -FilePath "dism.exe" -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" -Wait -NoNewWindow
}

function Start-SFC {
    Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -NoNewWindow

}



$tasks = @(
    @{Name="Clear-TempFiles"; Label = "Cleaning Temp Files..."}
    @{Name="Start-RecycleBin"; Label = "Start Recycle Bin..."}
    @{Name="Start-DISM"; Label="Starting the DISM process..."}
    @{Name="Start-SFC"; Label="Starting the SFC /scannow process..."}
)

for ($i = 0; $i -lt $tasks.Count; $i++) {
    $task = $tasks[$i]
    $percent = [math]::Round(($i / $tasks.Count)*100)

    Write-Progress -Activity "System Cleanup in Progress..." -Status $task.Label -PercentComplete $percent

    & $task.Name

}

Write-Progress -Activity "System Cleanup" -Completed
Write-Host "`n✅ All cleanup tasks completed!" -ForegroundColor Green