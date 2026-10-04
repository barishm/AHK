#Requires AutoHotkey v2.0

; Prevents Windows DPI display scaling from distorting coordinates
DllCall("SetThreadDpiAwarenessContext", "ptr", -3)

CoordMode("Mouse", "Screen")
SetMouseDelay(50)

; ==============================================================================
; GLOBAL VARIABLES
; ==============================================================================
global Char1_X := 480
global Char1_Y := 940

global Char2_X := 1440
global Char2_Y := 940

global MinIntervalMinutes := 5
global MaxIntervalMinutes := 15
global StartDelayMinutes := 0

global running := false
global nextChar1Time := 0
global nextChar2Time := 0

; Build and display the GUI on launch
CreateGUI()

; ==============================================================================
; GUI CREATION
; ==============================================================================
CreateGUI() {
    global configGui, edtChar1X, edtChar1Y, edtChar2X, edtChar2Y
    global edtMinMin, edtMaxMin, edtStartDelay
    global txtStatus, txtChar1Countdown, txtChar2Countdown
    global btnStart, btnStop

    configGui := Gui("+AlwaysOnTop", "Auto-Feeder Dashboard")
    configGui.MarginX := 15
    configGui.MarginY := 15

    ; --- CHARACTER 1 SECTION ---
    configGui.SetFont("s9 w600", "Segoe UI")
    configGui.Add("Text", "w220", "Character 1 Coordinates")
    configGui.SetFont("s9 w400", "Segoe UI")
    
    configGui.Add("Text", "x15 w50", "X:")
    edtChar1X := configGui.Add("Edit", "x+5 w55 Number", Char1_X)
    configGui.Add("Text", "x+10 w50", "Y:")
    edtChar1Y := configGui.Add("Edit", "x+5 w55 Number", Char1_Y)

    ; --- CHARACTER 2 SECTION ---
    configGui.SetFont("s9 w600", "Segoe UI")
    configGui.Add("Text", "x15 y+15 w220", "Character 2 Coordinates")
    configGui.SetFont("s9 w400", "Segoe UI")
    
    configGui.Add("Text", "x15 w50", "X:")
    edtChar2X := configGui.Add("Edit", "x+5 w55 Number", Char2_X)
    configGui.Add("Text", "x+10 w50", "Y:")
    edtChar2Y := configGui.Add("Edit", "x+5 w55 Number", Char2_Y)

    ; --- INTERVAL & DELAY SECTION ---
    configGui.SetFont("s9 w600", "Segoe UI")
    configGui.Add("Text", "x15 y+15 w220", "Interval (Minutes)")
    configGui.SetFont("s9 w400", "Segoe UI")
    
    configGui.Add("Text", "x15 w50", "Min:")
    edtMinMin := configGui.Add("Edit", "x+5 w55 Number", MinIntervalMinutes)
    configGui.Add("Text", "x+10 w50", "Max:")
    edtMaxMin := configGui.Add("Edit", "x+5 w55 Number", MaxIntervalMinutes)

    configGui.SetFont("s9 w600", "Segoe UI")
    configGui.Add("Text", "x15 y+15 w220", "Startup Delay (Minutes)")
    configGui.SetFont("s9 w400", "Segoe UI")
    
    configGui.Add("Text", "x15 w50", "Delay:")
    edtStartDelay := configGui.Add("Edit", "x+5 w55 Number", StartDelayMinutes)

    ; --- CONTROL BUTTONS ---
    btnSave := configGui.Add("Button", "x15 y+15 w220 h28", "Save & Apply")
    btnSave.OnEvent("Click", SaveSettings)

    btnStart := configGui.Add("Button", "x15 y+8 w105 h32 Default", "Start Feeding")
    btnStart.OnEvent("Click", (*) => ToggleFeeding(true))

    btnStop := configGui.Add("Button", "x+10 w105 h32 Disabled", "Stop Feeding")
    btnStop.OnEvent("Click", (*) => ToggleFeeding(false))

    ; --- LIVE STATUS DASHBOARD ---
    configGui.Add("Text", "x15 y+15 w220 h1 0x10") ; Divider line

    configGui.SetFont("s9 w600", "Segoe UI")
    configGui.Add("Text", "x15 y+10 w220", "Live Status")
    
    configGui.SetFont("s9 w400", "Segoe UI")
    txtStatus := configGui.Add("Text", "x15 y+5 w220 cGray", "Status: Idle")
    txtChar1Countdown := configGui.Add("Text", "x15 y+3 w220", "Char 1 Next: --:--")
    txtChar2Countdown := configGui.Add("Text", "x15 y+3 w220", "Char 2 Next: --:--")

    configGui.OnEvent("Close", (*) => ExitApp())
    configGui.Show()
}

; ==============================================================================
; SETTINGS & CONTROL LOGIC
; ==============================================================================
SaveSettings(*) {
    global Char1_X, Char1_Y, Char2_X, Char2_Y
    global MinIntervalMinutes, MaxIntervalMinutes, StartDelayMinutes
    global edtChar1X, edtChar1Y, edtChar2X, edtChar2Y
    global edtMinMin, edtMaxMin, edtStartDelay, txtStatus

    Char1_X := Integer(edtChar1X.Value)
    Char1_Y := Integer(edtChar1Y.Value)
    Char2_X := Integer(edtChar2X.Value)
    Char2_Y := Integer(edtChar2Y.Value)

    MinIntervalMinutes := Integer(edtMinMin.Value)
    MaxIntervalMinutes := Integer(edtMaxMin.Value)
    StartDelayMinutes := Integer(edtStartDelay.Value)

    if (MinIntervalMinutes > MaxIntervalMinutes) {
        MsgBox("Min interval cannot be greater than Max interval!", "Error", "48")
        return
    }

    txtStatus.Text := "Status: Settings Saved!"
}

ToggleFeeding(enable) {
    global running, nextChar1Time, nextChar2Time, StartDelayMinutes
    global txtStatus, txtChar1Countdown, txtChar2Countdown
    global btnStart, btnStop

    running := enable

    if running {
        btnStart.Enabled := false
        btnStop.Enabled := true

        if (StartDelayMinutes > 0) {
            delayMs := StartDelayMinutes * 60000
            nextChar1Time := A_TickCount + delayMs
            nextChar2Time := 0
            
            txtStatus.Text := "Status: Delayed Start (" . StartDelayMinutes . " m)"
            SetTimer(UpdateCountdown, 1000)
            SetTimer(StartFeedingCycle, -delayMs)
        } else {
            txtStatus.Text := "Status: Feeding Active"
            SetTimer(UpdateCountdown, 1000)
            FeedChar1()
        }
    } else {
        SetTimer(StartFeedingCycle, 0)
        SetTimer(FeedChar1, 0)
        SetTimer(FeedChar2, 0)
        SetTimer(UpdateCountdown, 0)

        btnStart.Enabled := true
        btnStop.Enabled := false

        txtStatus.Text := "Status: Stopped"
        txtChar1Countdown.Text := "Char 1 Next: --:--"
        txtChar2Countdown.Text := "Char 2 Next: --:--"
    }
}

StartFeedingCycle() {
    global running, txtStatus
    if !running
        return
    txtStatus.Text := "Status: Feeding Active"
    FeedChar1()
}

; ==============================================================================
; CORE FEEDING & TIMER LOGIC
; ==============================================================================
FeedChar1() {
    global running, nextChar1Time, nextChar2Time, Char1_X, Char1_Y, MinIntervalMinutes, MaxIntervalMinutes

    if !running
        return

    ; Perform click for Character 1
    HardwareClick(Char1_X, Char1_Y)

    ; Calculate next random interval
    minMs := MinIntervalMinutes * 60000
    maxMs := MaxIntervalMinutes * 60000
    intervalMs := Random(minMs, maxMs)
    
    nextChar1Time := A_TickCount + intervalMs

    ; Schedule Character 2 to click at EXACTLY HALF of Character 1's interval
    halfIntervalMs := Round(intervalMs / 2)
    nextChar2Time := A_TickCount + halfIntervalMs

    SetTimer(FeedChar1, -intervalMs)
    SetTimer(FeedChar2, -halfIntervalMs)
}

FeedChar2() {
    global running, Char2_X, Char2_Y

    if !running
        return

    ; Perform click for Character 2
    HardwareClick(Char2_X, Char2_Y)
}

UpdateCountdown() {
    global running, nextChar1Time, nextChar2Time
    global txtChar1Countdown, txtChar2Countdown

    if !running
        return

    txtChar1Countdown.Text := "Char 1 Next: " . GetFormattedTime(nextChar1Time)
    txtChar2Countdown.Text := "Char 2 Next: " . GetFormattedTime(nextChar2Time)
}

GetFormattedTime(targetTick) {
    if (targetTick == 0)
        return "Waiting..."

    remainingMs := targetTick - A_TickCount
    
    if (remainingMs <= 0)
        return "Clicking now..."

    remainingSec := Round(remainingMs / 1000)
    minutes := Format("{:02d}", Floor(remainingSec / 60))
    seconds := Format("{:02d}", Mod(remainingSec, 60))

    return minutes . ":" . seconds
}

HardwareClick(targetX, targetY) {
    x := targetX + Random(-2, 2)
    y := targetY + Random(-2, 2)

    MouseMove(x, y, 10)
    Sleep(100)

    Click("Down Left")
    Sleep(150)
    Click("Up Left")
}