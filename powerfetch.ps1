<#
    .SYNOPSIS
    Presents system information in a visually appealing, human-readable way.

    .DESCRIPTION
    Presents system information in a visually appealing, human-readable way.

    .PARAMETER install
    Adds this script to tthe users PowerShell profile as a function.

    .NOTES
    Author: jantari ( https://github.com/jantari )
    Repo: https://github.com/jantari/powerfetch
    Credits: Inspiration to make this from Julian Chow ( https://github.com/JulianChow94 ).
             Windows-flag ASCII artwork based on the one in WinScreeny by
             nijikokun ( https://github.com/nijikokun ) used with explicit permission.
             Tux ASCII artwork from http://ascii.co.uk/art/tux .
#>

Param (
    [switch]$Colors
)
    
###### Information Collection #########

if ($PSVersionTable.Platform -eq 'Unix') {
    [bool]$unix = $true
} else {
    [bool]$unix = $false
}

## Uptime Information
if ($unix) {
    $uptime        = Get-Uptime
    $uptimeHours   = $uptime.Hours + ($uptime.Days * 24)
    $uptimeMinutes = $uptime.Minutes
} else {
    $uptime        = [DateTime]::Now - (Get-WinEvent -FilterHashtable @{'id' = 27; 'ProviderName' = 'Microsoft-Windows-Kernel-Boot'; Data = 0, 1 } -MaxEvents 1).TimeCreated
    $uptimeHours   = $uptime.Hours + ($uptime.Days * 24)
    $uptimeMinutes = $uptime.Minutes
}

## Disk Information
if ($unix) {
    $diskInfo        = (lsblk --json -p -b | ConvertFrom-Json).blockdevices | Where-Object { $_.type -eq 'disk' } | Select-Object -Property name, size
    [array]$diskInfo = $diskInfo | Format-Table -Property name, @{'Name' = 'sizegb'; Expression = { "$($_.size / 1GB) GB" }} -HideTableHeaders | Out-String -NoNewline
} else {
    $DiskInfo        = Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType = 3'
    $diskinfo        = ($DiskInfo | Format-Table Name,
        @{'Name' = 'Size'; Expression = { "$([Math]::Round( ($_.Size - $_.FreeSpace) / 1GB)) / $([Math]::Round($_.Size / 1GB)) GB" }},
        @{'Name' = 'Perc'; Expression = {"({0:N0}%)" -f (100 - ($_.FreeSpace / $_.Size) * 100) }
    } -HideTableHeaders | Out-String).Trim() -split [System.Environment]::NewLine
    <#
    $UsedDiskSizeGB  = [math]::round(($DiskInfo.Size - $DiskInfo.FreeSpace) / 1GB)
    $DiskSizeGB      = [math]::round(($DiskInfo.Size) / 1GB)
    $UsedDiskPercent = "{0:N0}" -f (($UsedDiskSizeGB / $DiskSizeGB) * 100);
    $diskInfo        = "$UsedDiskSizeGB GB / $DiskSizeGB GB ([92m$UsedDiskPercent%[0m)"
    #>
}

## Environment Information
if (-not $unix) {
    $gcimWin32OS = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version, FreePhysicalMemory
    $username = $env:username
    $OS       = $gcimWin32OS.Caption
    $Kernel   = "$env:OS $($gcimWin32OS.Version)"
    $BitVer   = $gcimWin32OS.OSArchitecture
} else {
    $username = $env:USER
    $OS       = (lsb_release -d) -replace "Description:([\s]*)"
    $OS       = grep -oP "(?<=^PRETTY_NAME=\`")[^\`"]+" /etc/os-release
    $Kernel   = uname -sr
}
$Machine = hostname
$cmdlets = (Get-Command).Count

## Hardware Information

# The following does not work on UNIX-Systems yet
if (!$unix) {
    $Motherboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product
    $GPU         = (Get-CimInstance CIM_VideoController | Where-Object { $null -ne $_.AdapterRAM }) | Select-Object Name, AdapterRAM, CurrentHorizontalResolution, CurrentVerticalResolution, CurrentRefreshRate
}

# CPU
if ($unix) {
    $CPU = (Get-Content /proc/cpuinfo | Select-String "model name" | Select-Object -ExpandProperty Line -First 1).Split(": ")[1]
} else {
    $CPUObject = ([wmisearcher]("SELECT Name, NumberOfCores, MaxClockSpeed FROM Win32_Processor")).Get()
    $CPU       = ($CPUObject.Name -split " @")[0].Trim() + " @ " + $CPUObject.NumberOfCores + "x " + ($CPUObject.MaxClockSpeed / 1000 ) + " Ghz";
}

# RAM
if ($unix) {
    $ram      = (Get-Content /proc/meminfo -First 2) | ForEach-Object { ($_ -replace "[\D]+") }
    $FreeRam  = [int]($ram[1] / 1024)
    $TotalRam = [int]($ram[0] / 1024)
} else {
    $FreeRam  = ([math]::Truncate($gcimWin32OS.FreePhysicalMemory / 1KB));
    $TotalRam = ([math]::Truncate((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB));
}
$UsedRam        = $TotalRam - $FreeRam;
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
  [94m:tt::::ttttt33[0m [93m:E3s..[0m  [92m``[0m [93m,,g[0m        
'@, @'
  [94mit::::ztttt33F[0m [93mAEEEEEtttttE3F[0m        
'@, @'
 [94m;t:::::tttt33V[0m [93m;EEEEEttttttt3[0m         
'@, @'
 [94mft::::ztttt337[0m [93m@EEEEttttttt3F[0m         
'@, @'
 [94m@P*''``''*4Qj[0m [93m;EEEEEtttttttZ`[0m         
'@, @'
             [94m`[0m [93mEEEEEtttttttj7[0m          
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
Write-Output "$($art[3]) [91mUptime:[0m ${uptimeHours}h ${uptimeMinutes}m"
# .Days"d "$uptime.Hours"h " $uptime.Minutes"m " $uptime.Seconds"s " -Separator "";

# Line 5 - Motherboard
Write-Output "$($art[4]) [91mMotherboard:[0m $($Motherboard.Manufacturer -replace 'Micro-Star International Co., Ltd.', 'MSI') $($Motherboard.Product)"

# Line 6 - Shell (Hardcoded since it is unlikely anybody can run this without powershell)
Write-Output "$($art[5]) [91mShell:[0m PowerShell $($PSVersionTable.PSVersion)"

# Line 7 - Cmdlets
Write-Output "$($art[6]) [91mCmdlets:[0m $cmdlets"

# Line 8 - Resolution (for primary monitor only)
Write-Output "$($art[7]) [91mResolution:[0m $($GPU.CurrentHorizontalResolution) x $($GPU.CurrentVerticalResolution) @ $($GPU.CurrentRefreshRate) Hz"

# Line 9 - CPU
Write-Output "$($art[8]) [91mCPU:[0m $CPU"

# Line 10 - GPU
Write-Output "$($art[9]) [91mGPU:[0m $($GPU.Name) ($("{0:F2}" -f ($GPU.AdapterRAM / 1GB))GB VRAM)"

# Line 11 - Ram
Write-Output "$($art[10]) [91mRAM:[0m $UsedRam MB / $TotalRam MB ([92m$UsedRamPercent%[0m)"

# Line 12 - Disk
$i = 11
foreach ($disk in $diskInfo) {
    Write-Output "$($art[$i]) [91mDisk:[0m $($DISKINFO[11 - $i++])"
}

# Print empty Line to seperate colors
Write-Output $art[$i++]

if (!$unix -and $Colors) {
    foreach ($j in 40..48 + 100..107) {
        [string]$sec = '[' + $j + 'm'
        if ($j -eq 48) {
            Write-Output "$($art[$i++]) $conColorLine"
            $conColorLine = ''
        } else {
            $conColorLine += '' + $sec + '    [0m'
        }
    }
    Write-Output "$($art[$i++]) $conColorLine"
}

# Print the remaining ascii artwork lines
while ($i -lt $art.Count) {
    Write-Output $art[$i++]
}
