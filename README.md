# clip2path

Windows system-wide Ctrl+V interceptor: when your clipboard contains an image, it automatically saves the image to a temp file and pastes the file path as text instead. Regular text paste is unaffected.

Useful for AI coding tools (Claude Code, Cursor, etc.) that accept file paths but not raw clipboard images.

## How it works

- **AutoHotkey v2** intercepts Ctrl+V system-wide
- **Win32 `IsClipboardFormatAvailable`** checks for image format instantly (no process spawn)
- If image detected: PowerShell saves it as PNG to `%TEMP%\cc-img-<timestamp>.png` and AHK pastes the path as text
- If no image: normal Ctrl+V passthrough

## Requirements

- Windows 10/11
- PowerShell 5.1 (built-in)
- AutoHotkey v2 (installed automatically by `install.ps1`)

## Install

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

This will:
1. Install AutoHotkey v2 via winget (if not already installed)
2. Create a startup shortcut so the script runs on login
3. Launch the script immediately for the current session

## Usage

1. Copy an image to clipboard (e.g. Win+Shift+S snip, or copy from browser)
2. Press Ctrl+V anywhere
3. The file path is pasted as text instead of the image

Regular text paste works exactly as before.

## Uninstall

```powershell
Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\clipboard-image-paste.lnk" -ErrorAction SilentlyContinue
```

## Files

| File | Purpose |
|------|---------|
| `clipboard-image-paste.ahk` | AHK v2 hotkey script — intercepts Ctrl+V |
| `save-clipboard-image.ps1` | PowerShell helper — saves clipboard image, returns path |
| `install.ps1` | One-shot installer — AHK + startup shortcut + launch |

## Limitations

- ~300-500ms latency when clipboard contains an image (only then, not for text)
- AHK must be running (tray icon visible) for the hotkey to work
- Temp files are not auto-cleaned; clear `%TEMP%\cc-img-*.png` manually if needed

## License

MIT
