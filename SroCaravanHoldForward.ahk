#Requires AutoHotkey v2.0

; Global variable to track toggle state
global isUpHeld := false

; Hotkey trigger: Left Arrow and Right Arrow pressed together
~Left & Right::
~Right & Left::
{
    global isUpHeld
    
    if (!isUpHeld) {
        Send("{Up Down}")
        isUpHeld := true
    } else {
        Send("{Up Up}")
        isUpHeld := false
    }
}   