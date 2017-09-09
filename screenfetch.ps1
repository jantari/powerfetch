#### Screenfetch for PowerShell
#### Original Author Julian Chow ( https://github.com/JulianChow94 )
#### Improvements by jantari ( https://github.com/jantari )

# with [Environment]::NewLine you can create a newline on Windows AND Linux
# this is a little tip as a thank you to anyone reading this source code

####### Information Collection #########

[bool]$linux = $false

## Uptime Information
if ($linux) {
    $uptimeHours = [int]((Get-Content /proc/uptime).Split(".")[0] / 60 / 60)
    $uptimeMinutes = [int]((Get-Content /proc/uptime).Split(".")[0] / 60 % 60)
} else {
    $uptime = ([DateTime]::Now - (Get-WmiObject Win32_OperatingSystem).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime))
    $uptimeHours = $uptime.Hours
    $uptimeMinutes = $uptime.Minutes
}

## Disk Information
if ($linux) {
    $DiskInfo = df -hl | Where-Object { $_ -like '*rootfs*' } | Select-String '[\d]+.G' -AllMatches | % matches | % value
    $UsedDiskPercent = df -hl | Where-Object { $_ -like '*rootfs*' } | Select-String '[\d]+.%' | % matches | % value
    $DiskSizeGB = $DiskInfo[0]
    $UsedDiskSizeGB = $DiskInfo[1]
} else {
    $DiskInfo = Get-PSDrive $env:Systemdrive.Substring(0,1) | Select-Object Used, Free
    $UsedDiskSizeGB = [math]::round($DiskInfo.Used / 1GB)
    $DiskSizeGB = [math]::round(($DiskInfo.Used + $DiskInfo.Free) / 1GB)
    $UsedDiskPercent = "{0:N0}" -f (($UsedDiskSizeGB / $DiskSizeGB) * 100);
}

## Environment Information
if ($linux) {$username = $env:USER} else {$username = $env:username}
if (!$linux) {$gwmiWin32OS = Get-WmiObject Win32_OperatingSystem | Select-Object CSName,Caption,OSArchitecture,Version,FreePhysicalMemory}
if ($linux) {$Machine = $env:NAME} else { $Machine = $gwmiWin32OS.CSName }
if ($linux) {$OS = (lsb_release -d) -replace "Description:([\s]*)" } else {$OS = $gwmiWin32OS.Caption}
$BitVer = $gwmiWin32OS.OSArchitecture;
if ($linux) {$Kernel = uname -sr} else {$Kernel = $env:OS +" "+ $gwmiWin32OS.Version}
$cmdlets = (Get-Command).Count

## Hardware Information

# The following does not work on UNIX-Systems yet
if (!$linux) {
    $Motherboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product
    $GPU = (Get-WmiObject Win32_VideoController).Caption
    $display = Get-WmiObject Win32_VideoController | Select-Object CurrentHorizontalResolution, CurrentVerticalResolution, CurrentRefreshRate
}

# CPU
if ($linux) {
    $CPU = (Get-Content /proc/cpuinfo | Select-String "model name" | Select -ExpandProperty Line -First 1).Split(": ")[1]
} else {
    $CPUObject = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
    $CPU = $CPUObject.Name
    $CPU = $CPU.Split("@")[0] + " @ " + $CPUObject.NumberOfCores + "x " + ($CPUObject.MaxClockSpeed / 1000 ) + " Ghz";
}

# RAM
if ($linux) {
    $ram = (Get-Content /proc/meminfo -First 2) | % { ($_ -replace "[\D]+") }
    $FreeRam = [int]($ram[1] / 1024)
    $TotalRam = [int]($ram[0] / 1024)
} else {
    $FreeRam = ([math]::Truncate($gwmiWin32OS.FreePhysicalMemory / 1KB));
    $TotalRam = ([math]::Truncate((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1MB));
}
$UsedRam = $TotalRam - $FreeRam;
$FreeRamPercent = ($FreeRam / $TotalRam) * 100;
$FreeRamPercent = "{0:N0}" -f $FreeRamPercent;
$UsedRamPercent = ($UsedRam / $TotalRam) * 100;
$UsedRamPercent = "{0:N0}" -f $UsedRamPercent;

## Array with ASCII art
[string[]] $art = @'
         [91m,zz::A33tz;,[0m                   
'@, @'
         [91m@t:::EE333EE3[0m [92m.[0m                
'@, @'
        [91m;Et:::EE33EEE7[0m [92m@Ee.,     .,g[0m    
'@, @'
       [91m.St:::EE333EE3[0m [92m;EEEEEEttt333#[0m    
'@, @'
       [91m@t:::zE333EE3`[0m[92m.SEEEEEtttt33Q[0m     
'@, @'
      [91m:Et:::EE333EE7[0m [92m@EEEEEEtttt33F[0m     
'@, @'
      [91m@P*''``''*4Qj[0m [92m:EEEEEEtttt33@[0m      
'@, @'
     [94m,,::::33tz;,[0m [91m*[0m [92m@EEEEEEttz33Q7[0m      
'@, @'
    [94m;t::::ztttt33)[0m [93m.[0m [92m*4EEEjjjiP*[0m        
'@, @'
   [94m:tt::::ttttt33[0m [93m:Z3:..[0m  [92m``[0m [93m,,g[0m        
'@, @'
   [94mit::::ztttt33F[0m [93mAEEEEEtttttE3F[0m        
'@, @'
  [94m;t:::::tttt33V[0m [93m;EEEEEttttttt3[0m         
'@, @'
  [94mEt::::ztttt337[0m [93m@EEEEttttttt3F[0m          
'@, @'
  [94m@P*''``''*4Qj[0m [93m;EEEEEtttttttZ`[0m          
'@, @'
             [94m`[0m  [93mEEEEEtttttttj7[0m            
'@, @'
                [93m`^VEtjjjz>*`[0m          
'@

####### Printing Output #########

# Line 1 - HostName
Write-Host $art[0] "[91m$Username[0m@[91m$Machine[0m"

# Line 2 - OS
Write-Host $art[1] "[91mOS:[0m $OS $BitVer"

# Line 3 - Kernel
Write-Host $art[2] "[91mKernel:[0m $Kernel"

# Line 4 - Uptime
Write-Host $art[3] "[91mUptime:[0m ${uptimeHours}:${uptimeMinutes}"
# .Days"d "$uptime.Hours"h " $uptime.Minutes"m " $uptime.Seconds"s " -Separator "";

# Line 5 - Motherboard
Write-Host $art[4] "[91mMotherboard:[0m" $Motherboard.Manufacturer $Motherboard.Product

# Line 6 - Shell (Hardcoded since it is unlikely anybody can run this without powershell)
Write-Host $art[5] "[91mShell:[0m PowerShell $($PSVersionTable.PSVersion)"

# Line 7 - Cmdlets
Write-Host $art[6] "[91mCmdlets:[0m $cmdlets"

# Line 8 - Resolution (for primary monitor only)
Write-Host $art[7] "[91mResolution:[0m$($display.CurrentHorizontalResolution) x$($display.CurrentVerticalResolution) @$($display.CurrentRefreshRate) Hz"

# Line 9 - CPU
Write-Host $art[8] "[91mCPU:[0m $CPU"

# Line 10 - GPU
Write-Host $art[9] "[91mGPU:[0m $GPU"

# Line 11 - Ram
Write-Host $art[10] "[91mRAM:[0m $UsedRam MB / $TotalRam MB ([92m$UsedRamPercent%[0m)"

# Line 12 - Disk
Write-Host $art[11] "[91mDisk:[0m $UsedDiskSizeGB GB / $DiskSizeGB GB ([92m$UsedDiskPercent%[0m)"

# Empty Lines
Write-Host $art[12]
Write-Host $art[13]
Write-Host $art[14]
Write-Host $art[15]