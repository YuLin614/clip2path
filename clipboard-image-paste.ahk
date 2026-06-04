#Requires AutoHotkey v2.0
#SingleInstance Force

CF_BITMAP := 2
CF_DIB := 8
CF_DIBV5 := 17

psScript := A_ScriptDir "\save-clipboard-image.ps1"

; Apps that support direct image paste — skip path conversion for these
imageCapableApps := ["slack.exe", "discord.exe", "teams.exe", "whatsapp.exe",
                     "chrome.exe", "firefox.exe", "msedge.exe", "opera.exe",
                     "brave.exe", "vivaldi.exe"]

^v:: {
    global CF_BITMAP, CF_DIB, CF_DIBV5, psScript, imageCapableApps

    hasImage := DllCall("IsClipboardFormatAvailable", "UInt", CF_BITMAP)
                || DllCall("IsClipboardFormatAvailable", "UInt", CF_DIB)
                || DllCall("IsClipboardFormatAvailable", "UInt", CF_DIBV5)

    if (!hasImage) {
        Hotkey("^v", "Off")
        Send("^v")
        Hotkey("^v", "On")
        return
    }

    ; Let image-capable apps handle image paste natively
    activeExe := StrLower(WinGetProcessName("A"))
    for , app in imageCapableApps {
        if (activeExe == app) {
            Hotkey("^v", "Off")
            Send("^v")
            Hotkey("^v", "On")
            return
        }
    }

    shell := ComObject("WScript.Shell")
    exec := shell.Exec('powershell -ExecutionPolicy Bypass -NoProfile -NoLogo -NonInteractive -File "' . psScript . '"')

    ; Extract only the file path line — filters out PowerShell banner/upgrade nag
    imagePath := ""
    Loop Parse, exec.StdOut.ReadAll(), "`n", "`r" {
        line := Trim(A_LoopField)
        if RegExMatch(line, "^[A-Za-z]:\\") {
            imagePath := line
            break
        }
    }

    if (imagePath == "") {
        Hotkey("^v", "Off")
        Send("^v")
        Hotkey("^v", "On")
        return
    }

    SendText(imagePath)
}
