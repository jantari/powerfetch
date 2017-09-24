#### Screenfetch for PowerShell
#### by jantari ( https://github.com/jantari )
#### Inspiration from Julian Chow ( https://github.com/JulianChow94 )
#### windows-flag ASCII artwork based on the one in WinScreeny by
#### nijikokun ( https://github.com/nijikokun ) used with explicit permission
#### tux ASCII artwork from http://ascii.co.uk/art/tux

# with [Environment]::NewLine you can create a newline on Windows AND Linux
# this is a little tip as a thank you to anyone reading this source code

####### Information Collection #########

if ($PSVersionTable.Platform -eq 'Unix') {
    [bool]$unix = $true
} else {
    [bool]$unix = $false
}

## Uptime Information
if ($unix) {
    $uptimeHours = [int]((Get-Content /proc/uptime).Split(".")[0] / 60 / 60)
    $uptimeMinutes = [int]((Get-Content /proc/uptime).Split(".")[0] / 60 % 60)
} else {
    $uptime = ([DateTime]::Now - (Get-WmiObject Win32_OperatingSystem).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime))
    $uptimeHours = $uptime.Hours
    $uptimeMinutes = $uptime.Minutes
}

## Disk Information
if ($unix) {
    $DiskInfo = df -hl | Where-Object { $_ -like 'rootfs*' } | Select-String '([\d]+)(?:G)' -AllMatches | % matches | % { $_.groups[1].Value }
    $UsedDiskPercent = df -hl | Where-Object { $_ -like 'rootfs*' } | Select-String '([\d]+)(?:%)' | ForEach-Object { $_.matches.groups[1].Value }
    $DiskSizeGB = $DiskInfo[0]
    $UsedDiskSizeGB = $DiskInfo[1]
} else {
    $DiskInfo = Get-PSDrive $env:Systemdrive.Substring(0,1) | Select-Object Used, Free
    $UsedDiskSizeGB = [math]::round($DiskInfo.Used / 1GB)
    $DiskSizeGB = [math]::round(($DiskInfo.Used + $DiskInfo.Free) / 1GB)
    $UsedDiskPercent = "{0:N0}" -f (($UsedDiskSizeGB / $DiskSizeGB) * 100);
}

## Environment Information
if ($unix) {$username = $env:USER} else {$username = $env:username}
if (!$unix) {$gwmiWin32OS = Get-WmiObject Win32_OperatingSystem | Select-Object CSName,Caption,OSArchitecture,Version,FreePhysicalMemory}
if ($unix) {$Machine = $env:NAME} else { $Machine = $gwmiWin32OS.CSName }
if ($unix) {$OS = (lsb_release -d) -replace "Description:([\s]*)" } else {$OS = $gwmiWin32OS.Caption}
$BitVer = $gwmiWin32OS.OSArchitecture;
if ($unix) {$Kernel = uname -sr} else {$Kernel = "$env:OS $($gwmiWin32OS.Version)"}
$cmdlets = (Get-Command).Count

## Hardware Information

# The following does not work on UNIX-Systems yet
if (!$unix) {
    $Motherboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product
    $GPU = (Get-WmiObject Win32_VideoController | Where-Object { $_.AdapterRAM -ne $null }) | Select-Object Name, AdapterRAM, CurrentHorizontalResolution, CurrentVerticalResolution, CurrentRefreshRate
}

# CPU
if ($unix) {
    $CPU = (Get-Content /proc/cpuinfo | Select-String "model name" | Select-Object -ExpandProperty Line -First 1).Split(": ")[1]
} else {
    $CPUObject = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
    $CPU = $CPUObject.Name
    $CPU = $CPU.Split("@")[0] + " @ " + $CPUObject.NumberOfCores + "x " + ($CPUObject.MaxClockSpeed / 1000 ) + " Ghz";
}

# RAM
if ($unix) {
    $ram = (Get-Content /proc/meminfo -First 2) | ForEach-Object { ($_ -replace "[\D]+") }
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
if ($unix) {
    [string[]]$art = @'
          _nnnn_         
'@, @'
         dGGGGMMb        
'@, @'
        @p~qp~~qMb       
'@, @'
        M|O||O) M|       
'@, @'
        @,----.JM|       
'@, @'
       JS^\__/  qKL      
'@, @'
     dZP        qKRb     
'@, @'
    dZP          qKKb    
'@, @'
   fZP            SMMb   
'@, @'
   HZM            MMMM   
'@, @'
   FqM            MMMM   
'@, @'
 __| ".        |\dS"qML  
'@, @'
 |    `.       | `' \Zq  
'@, @'
_)      \.___.,|     .' 
'@, @'
\__     )      |   .'   
'@, @'
    `--'       `--' 
'@
} else {
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
}

####### Printing Output #########

# Line 1 - HostName
Write-Output "$($art[0]) [91m$Username[0m@[91m$Machine[0m"

# Line 2 - OS
Write-Output "$($art[1]) [91mOS:[0m $OS $BitVer"

# Line 3 - Kernel
Write-Output "$($art[2]) [91mKernel:[0m $Kernel"

# Line 4 - Uptime
Write-Output "$($art[3]) [91mUptime:[0m ${uptimeHours}:${uptimeMinutes}"
# .Days"d "$uptime.Hours"h " $uptime.Minutes"m " $uptime.Seconds"s " -Separator "";

# Line 5 - Motherboard
Write-Output "$($art[4]) [91mMotherboard:[0m $($Motherboard.Manufacturer) $($Motherboard.Product)"

# Line 6 - Shell (Hardcoded since it is unlikely anybody can run this without powershell)
Write-Output "$($art[5]) [91mShell:[0m PowerShell $($PSVersionTable.PSVersion)"

# Line 7 - Cmdlets
Write-Output "$($art[6]) [91mCmdlets:[0m $cmdlets"

# Line 8 - Resolution (for primary monitor only)
Write-Output "$($art[7]) [91mResolution:[0m$($GPU.CurrentHorizontalResolution) x $($GPU.CurrentVerticalResolution) @ $($GPU.CurrentRefreshRate) Hz"

# Line 9 - CPU
Write-Output "$($art[8]) [91mCPU:[0m $CPU"

# Line 10 - GPU
Write-Output "$($art[9]) [91mGPU:[0m $($GPU.Name) ($($GPU.AdapterRAM / 1GB)GB VRAM)"

# Line 11 - Ram
Write-Output "$($art[10]) [91mRAM:[0m $UsedRam MB / $TotalRam MB ([92m$UsedRamPercent%[0m)"

# Line 12 - Disk
Write-Output "$($art[11]) [91mDisk:[0m $UsedDiskSizeGB GB / $DiskSizeGB GB ([92m$UsedDiskPercent%[0m)"

# Empty Lines
Write-Output $art[12]
Write-Output $art[13]
Write-Output $art[14]
Write-Output $art[15]
