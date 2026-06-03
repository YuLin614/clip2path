#Requires AutoHotkey v2.0
#SingleInstance Force

CF_BITMAP := 2
CF_DIB := 8
CF_DIBV5 := 17

psScript := A_ScriptDir "\save-clipboard-image.ps1"

^v:: {
    global CF_BITMAP, CF_DIB, CF_DIBV5, psScript

    hasImage := DllCall("IsClipboardFormatAvailable", "UInt", CF_BITMAP)
                || DllCall("IsClipboardFormatAvailable", "UInt", CF_DIB)
                || DllCall("IsClipboardFormatAvailable", "UInt", CF_DIBV5)

    if (!hasImage) {
        Hotkey("^v", "Off")
        Send("^v")
        Hotkey("^v", "On")
        return
    }

    shell := ComObject("WScript.Shell")
    exec := shell.Exec('powershell -ExecutionPolicy Bypass -NoProfile -File "' . psScript . '"')
    imagePath := StrReplace(StrReplace(Trim(exec.StdOut.ReadAll()), "`r", ""), "`n", "")

    if (imagePath == "") {
        Hotkey("^v", "Off")
        Send("^v")
        Hotkey("^v", "On")
        return
    }

    SendText(imagePath)
}
