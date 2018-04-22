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
             Tux ASCII artwork from http://ascii.co.uk/art/tux ,
             Apple Logo made by myself.
#>

Param (
    [switch]$install
)

[scriptblock]$powerfetch = {
# Determine OS
if ($PSVersionTable.OS -like "*Linux*") {
    [string]$runningOS = 'Linux'
} elseif ($PSVersionTable.OS -like "*Darwin*") {
    [string]$runningOS = 'macOS'
} else {
    [string]$runningOS = 'Win'
}

# Information Collection
switch ($runningOS) {
    'Win' {
        ## Environment Information
        $gcimWin32OS = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object CSName, Caption, OSArchitecture, Version, FreePhysicalMemory, LastBootUpTime
        $username = $env:username
        $Machine = $gcimWin32OS.CSName
        $OS = $gcimWin32OS.Caption
        $Kernel = "$env:OS $($gcimWin32OS.Version)"
        $BitVer = $gcimWin32OS.OSArchitecture
        ## Uptime Information
        $uptime = [DateTime]::Now - $gcimWin32OS.LastBootUpTime
        $uptimeHours = $uptime.Hours + ($uptime.Days * 24)
        $uptimeMinutes = $uptime.Minutes
        ## Disk Information
        $DiskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID like '$env:systemdrive'" | Select-Object Size, FreeSpace
        $UsedDiskSizeGB = [math]::round(($DiskInfo.Size - $DiskInfo.FreeSpace) / 1GB)
        $DiskSizeGB = [math]::round(($DiskInfo.Size) / 1GB)
        $UsedDiskPercent = "{0:N0}" -f (($UsedDiskSizeGB / $DiskSizeGB) * 100);
        ## Hardware Information
        # The following does not work on UNIX-Systems yet
        $Motherboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product
        $GPU = (Get-CimInstance Win32_VideoController | Where-Object { $_.AdapterRAM -ne $null }) | Select-Object Name, AdapterRAM, CurrentHorizontalResolution, CurrentVerticalResolution, CurrentRefreshRate
        # CPU
        $CPUObject = Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
        $CPU = $CPUObject.Name
        $CPU = ($CPU -split " @")[0] + " @ " + $CPUObject.NumberOfCores + "x " + ($CPUObject.MaxClockSpeed / 1000 ) + " Ghz";
        # RAM
        $FreeRam = ([math]::Truncate($gcimWin32OS.FreePhysicalMemory / 1KB));
        $TotalRam = ([math]::Truncate((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB));

        [string[]]$art = @'
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
    'macOS' {
        # Mac Stuff
        [string[]]$art = '[38;2;98;187;71m               .zP[0m           ',
                        '[38;2;98;187;71m              f##l[0m           ',
                        '[38;2;98;187;71m             .##P[0m            ',
                        '[38;2;98;187;71m       .dSFz.lF .uqKEp.[0m      ',
                        '[38;2;98;187;71m    .dZP##$##########$KRb.[0m   ',
                        '[38;2;98;187;71m  .dZP##$##############$KRb.[0m ',
                        "[38;2;252;184;41m  dZP###################F*'[0m  ",
                        '[38;2;252;184;41m fZP##################R`[0m     ',
                        '[38;2;244;131;27m fZP#################R[0m       ',
                        '[38;2;244;131;27m HM##################R[0m       ',
                        '[91m HA$###################bz._[0m  ',
                        '[91m HA$#######################P[0m ',
                        '[38;2;150;61;151m \#######################$#F[0m',
                        '[38;2;150;61;151m  \#####################$#F[0m ',
                        '[38;2;0;157;222m   \##################$#/[0m   ',
                        "[38;2;0;157;222m    `*~####~*''*~####~*'[0m     "
    }
    default {
        ## Environment Information
        $username = $env:USER
        $Machine = $env:NAME
        $OS = (lsb_release -d) -replace "Description:([\s]*)"
        $Kernel = uname -sr 
        ## Uptime Information
        $uptimeHours = [int](((Get-Content -Path "/proc/uptime") -split "\.")[0] / 60 / 60)
        $uptimeMinutes = [int](((Get-Content -Path "/proc/uptime") -split "\.")[0] / 60 % 60)
        ## Disk Information
        $DiskInfo = df -hl | Where-Object { $_ -like 'rootfs*' } | Select-String '([\d]+)(?:G)' -AllMatches | ForEach-Object matches | ForEach-Object { $_.groups[1].Value }
        $UsedDiskPercent = df -hl | Where-Object { $_ -like 'rootfs*' } | Select-String '([\d]+)(?:%)' | ForEach-Object { $_.matches.groups[1].Value }
        $DiskSizeGB = $DiskInfo[0]
        $UsedDiskSizeGB = $DiskInfo[1]
        # CPU
        $CPU = (Get-Content /proc/cpuinfo | Select-String "model name" | Select-Object -ExpandProperty Line -First 1).Split(": ")[1]
        # RAM
        $ram = (Get-Content /proc/meminfo -First 2) | ForEach-Object { ($_ -replace "[\D]+") }
        $FreeRam = [int]($ram[1] / 1024)
        $TotalRam = [int]($ram[0] / 1024)

        [string[]]$art = '          _nnnn_         ',
                        '         dGGGGMMb        ',
                        '        @p~qp~~qMb       ',
                        '        M|O||O) M|       ',
                        '        @,----.JM|       ',
                        '       JS^\__/  qKL      ',
                        '     dZP        qKRb     ',
                        '    dZP          qKKb    ',
                        '   fZP            SMMb   ',
                        '   HZM            MMMM   ',
                        '   FqM            MMMM   ',
                        ' __| ".        |\dS"qML  ',
                        ' |    `.       | "` \Zq  ',
                        '_)      \.___.,|     ."  ',
                        "\__     )      |   .'    ",
                        "    `"--'       ``--'     "
    }
}

# All platforms
## RAM calc
if ($TotalRam -and $FreeRam) {
    $UsedRam = $TotalRam - $FreeRam;
    $FreeRamPercent = ($FreeRam / $TotalRam) * 100;
    $FreeRamPercent = "{0:N0}" -f $FreeRamPercent;
    $UsedRamPercent = ($UsedRam / $TotalRam) * 100;
    $UsedRamPercent = "{0:N0}" -f $UsedRamPercent;
}

# Cmdlets
$cmdlets = (Get-Command).Count

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

}

if ($install) {
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    }
    Add-Content -Path $PROFILE -Value 'function powerfetch {'
    Add-Content -Path $PROFILE -Value $powerfetch
    Add-Content -Path $PROFILE -Value '}'
} else {
    Invoke-Command -ScriptBlock $powerfetch
}
