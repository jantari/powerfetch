# powerfetch
PowerShell-based cross-platform 'screenfetch'-like tool

![Alt text](powerfetch-chia-screenshot.png?raw=true "Powerfetch with Chia screenshot")
![Alt text](screenshot.png?raw=true "sample Windows screenshot")

### Try it out!

To try `powerfetch` anywhere and without downloading, you can run:

```powershell
iex (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jantari/powerfetch/master/powerfetch.ps1')
```

This will run the script directly from this GitHub. 

### About

1. This script requires at least Windows 10 v1703 to display correctly
2. The macOS and Linux compatibility is definitely very much still work in progress
3. Requires [PowerShell](https://github.com/PowerShell/PowerShell "PowerShell GitHub page")
4. The windows-flag ASCII artwork used in this script is based on nijikokun's in [WinScreeny](https://github.com/nijikokun/WinScreeny "WinScreeny GitHub page") that I used with explicit permission
