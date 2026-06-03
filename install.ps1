$ErrorActionPreference = "Stop"
$scriptPath = Join-Path $PSScriptRoot "clipboard-image-paste.ahk"

Write-Output "[1/3] Checking AutoHotkey v2..."
$ahkBin = $null
$candidates = @(
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey32.exe",
    "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
    "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe",
    "C:\Program Files\AutoHotkey\AutoHotkey.exe"
)
foreach ($c in $candidates) {
    if (Test-Path $c) {
        $ver = (Get-Item $c).VersionInfo.ProductVersion
        if ($ver -match "^2\.") {
            $ahkBin = $c
            Write-Output "      Found AHK v2 at $ahkBin"
            break
        }
    }
}

if (-not $ahkBin) {
    Write-Output "      Not found. Installing via winget..."
    winget install --id AutoHotkey.AutoHotkey --exact --silent --accept-package-agreements --accept-source-agreements
    foreach ($c in $candidates) {
        if (Test-Path $c) { $ahkBin = $c; break }
    }
    if ($ahkBin) {
        Write-Output "      Installed: $ahkBin"
    } else {
        Write-Output "      WARNING: exe not found. Launch $scriptPath manually."
    }
}

Write-Output "[2/3] Creating startup shortcut..."
$startupDir = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startupDir "clipboard-image-paste.lnk"
$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $scriptPath
$shortcut.Description = "Clipboard image-to-path paste helper"
$shortcut.Save()
Write-Output "      Shortcut: $shortcutPath"

Write-Output "[3/3] Launching script..."
Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force
if ($ahkBin) {
    Start-Process $ahkBin $scriptPath
    Write-Output "      Running. Check system tray for AHK icon."
} else {
    Write-Output "      Skipped — AHK not found. Double-click the .ahk file to start."
}

Write-Output ""
Write-Output "Done. Ctrl+V now intercepts clipboard images."
