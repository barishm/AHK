
#Requires AutoHotkey v2.0
#SingleInstance Force

scriptEnabled := true

; --- Small draggable toggle ---
toggleGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Border")
toggleGui.BackColor := "00CC00"
toggleGui.MarginX := 0
toggleGui.MarginY := 0

toggleText := toggleGui.AddText(
    "cFFFFFF Center w35 h18 Background00CC00",
    "ON"
)

; Drag the window by clicking and holding the rectangle
toggleText.OnEvent("Click", (*) => 0)
OnMessage(0x0201, WM_LBUTTONDOWN)

toggleGui.Show("x20 y20 w35 h18")

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global toggleGui
    if (hwnd = toggleGui.Hwnd || hwnd = toggleText.Hwnd) {
        PostMessage(0xA1, 2,,, "ahk_id " toggleGui.Hwnd)
    }
}

; --- Up Arrow toggles ON/OFF ---
Up::ToggleScript()

ToggleScript(*) {
    global scriptEnabled, toggleGui, toggleText

    scriptEnabled := !scriptEnabled

    if scriptEnabled {
        toggleGui.BackColor := "00CC00"
        toggleText.Opt("Background00CC00 cFFFFFF")
        toggleText.Value := "ON"
    } else {
        toggleGui.BackColor := "CC0000"
        toggleText.Opt("BackgroundCC0000 cFFFFFF")
        toggleText.Value := "OFF"
    }
}

; --- Mouse4 sends backslash ---
#HotIf scriptEnabled
XButton1::Send("\\")

; --- Mouse5 combinations ---
#HotIf scriptEnabled && GetKeyState("XButton2", "P")
1::Send("6")
2::Send("7")
3::Send("8")
4::Send("9")
5::Send("0")
q::Send("[")
e::Send("]")
#HotIf
