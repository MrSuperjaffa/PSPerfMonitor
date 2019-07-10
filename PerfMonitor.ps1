# PERF MONITOR v1.3
# Tony Unruh
# Mr_Superjaffa#5430

$version = "v1.3"
[xml]$Config = Get-Content "./PerfMonitorConfig.xml"
$Process = $Config.Settings.Process
$CycleTime = $Config.Settings.CycleTime
$LogFolder = $Config.Settings.LogFolder
$ErrorActionPreference = 'silentlycontinue'
$CpuCores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors

$CounterPaths = (
                "\Process($process)\% Processor Time",
                "\GPU(_total)\% GPU Time",
                "\GPU(_total)\% GPU Memory Reads/Writes",
                "\GPU(_total)\% GPU Memory Used",
                "\GPU(_total)\GPU Memory Used (MiB)",
                "\GPU(_total)\GPU Power Usage (Watts)",
                "\GPU(_total)\GPU Temperature (in degrees C)",
                "\GPU(_total)\% GPU Fan Speed"
                )

Write-Output "Perf Monitor $version by Mr_Superjaffa#5430"

Do {
    If (Get-Process $Process) {
        Write-Output "$Process found! Starting output..."
        # Prepping our log and CSV
        $LogTimestamp = (Get-Date).ToString('MMddyyyy-hhmmss')

        # Setting our log path
        If (Test-Path $LogFolder) {
            #$LogPath = Join-Path -Path $LogFolder -ChildPath "PerfLog-$Process-$LogTimestamp.log"
            $CSVPath = Join-Path -Path $LogFolder -ChildPath "PerfLog-$Process-$LogTimestamp.csv"
        } Else {
            #$LogPath = "Logs\PerfLog-$Process-$LogTimestamp.log"
            $CSVPath = "Logs\PerfLog-$Process-$LogTimestamp.csv"
        }

        Write-Output "Perf Monitor $version by Mr_Superjaffa#5430" | Out-File -FilePath $LogPath -Append

        $CSVFormat = "Timestamp,Process,Working Set (MB),Private Memory (MB),Non-Paged System Memory (MB),Paged System Memory (MB),Paged Memory (MB),Virtual Memory (MB),CPU Handles,CPU Usage (%),GPU Usage (%),GPU Memory Reads/Writes (%),GPU Memory Used (%),GPU Memory Used (MB),GPU Power Usage (Watts),GPU Temp (C),GPU Fan Speed (%)"

        # Beginning log output
        Write-Output "`n"
        Out-File -FilePath $CSVPath -InputObject $CSVFormat

        While (Get-Process $Process) {
            # Heres where the magic happens.
            $Timestamp = (Get-Date).ToString('yyyy-MM-dd hh:mm:ss')
            $Procs = Get-Process $Process
            $ChildProcs = ($Procs.ProcessName).Count

            
            $WorkingSet = $Procs.WorkingSet64 | Measure-Object -Sum | Select-Object Sum
            $WorkingSet = [int64]($WorkingSet.Sum / 1MB)

            $PrivateMemory = $Procs.PrivateMemorySize64 | Measure-Object -Sum | Select-Object Sum
            $PrivateMemory = [int64]($PrivateMemory.Sum / 1MB)

            $NonPagedSystemMemory = $Procs.NonpagedSystemMemorySize64 | Measure-Object -Sum | Select-Object Sum
            $NonPagedSystemMemory = [int64]($NonPagedSystemMemory.Sum / 1MB)

            $PagedSystemMemory = $Procs.PagedMemorySize64 | Measure-Object -Sum | Select-Object Sum
            $PagedSystemMemory = [int64]($PagedSystemMemory.Sum / 1MB)

            $PagedMemory = $Procs.PagedMemorySize64 | Measure-Object -Sum | Select-Object Sum
            $PagedMemory = [int64]($PagedMemory.Sum / 1MB)

            $VirtualMemory = $Procs.VirtualMemorySize64 | Measure-Object -Sum | Select-Object Sum
            $VirtualMemory = [int64]($VirtualMem.Sum / 1MB)
            
            $CPUHandles = $Procs.Handles | Measure-Object -Sum | Select-Object Sum
            $CPUHandles = $CPUHandles.Sum

            $CounterOutput = (Get-Counter $CounterPaths).CounterSamples

            [int64]$CPUUsage = $CounterOutput[0].CookedValue
            [int64]$GPUTimePercent = $CounterOutput[1].CookedValue
            [int64]$GPUMemRWPercent = $CounterOutput[2].CookedValue
            [int64]$GPUMemUsedPercent = $CounterOutput[3].CookedValue
            [int64]$GPUMemUsedMB = $CounterOutput[4].CookedValue
            [int64]$GPUPowerUsage = $CounterOutput[5].CookedValue
            [int64]$GPUTemp = $CounterOutput[6].CookedValue
            [int64]$GPUFanSpeed = $CounterOutput[7].CookedValue

            # Outputting to console.
            Clear-Host
            Write-Output "Perf Monitor $version by Mr_Superjaffa#5430`nProcess: $Process`nChild Processes: $ChildProcs`n$Timestamp"
            Write-Output "`nWS: $WorkingSet MB`nPM: $PrivateMemory MB`nNPSM: $NonPagedSystemMemory MB`nPSM: $PagedSystemMemory MB`nPGM: $PagedMemory MB`nVM: $VirtualMemory MB`nCPU: $CPUUsage %`nGPU: $GPUTimePercent %`nGPU RW: $GPUMemRWPercent %`nGPU Mem: $GPUMemUsedPercent %`nGPU Mem: $GPUMemUsedMB MB`nGPU Power: $GPUPowerUsage W`nGPU Temp: $GPUTemp C`nGPU Fan: $GPUFanSpeed %"
            
            # Outputting to the CSV
            $OutputCSV = "$Timestamp,$Process,$WorkingSet,$PrivateMemory,$NonPagedSystemMemory,$PagedSystemMemory,$PagedMemory,$VirtualMem,$CPUHandles,$CPUUsage,$GPUTimePercent,$GPUMemRWPercent,$GPUMemUsedPercent,$GPUMemUsedMB,$GPUPowerUsage,$GPUTemp,$GPUFanSpeed"
            Out-File -FilePath $CSVPath -InputObject $OutputCSV -Append

            Start-Sleep($CycleTime)
        }
    }

Write-Host "`rWaiting for $Process.  "  -NoNewline
Start-Sleep (1);
Write-Host "`rWaiting for $Process.. " -NoNewline
Start-Sleep (1);
Write-Host "`rWaiting for $Process..." -NoNewline
Start-Sleep (1)
} while ($true)