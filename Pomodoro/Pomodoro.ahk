workDuration := 25
restDuration := 5
minutesLeft := 0
secondsLeft := 0
TimerRunning := false
IsResting := false

; GUI Setup
Gui +AlwaysOnTop
Gui, Font, S20 CDefault Bold, Courier New
Gui, Add, Text, x20 y10 w100 h30 vTimerText, 25:00
Gui, Font, S8 CDefault, Courier New
Gui, Add, Button, x110 y10 w50 h25 gStartTimer, Start
Gui, Add, Button, x160 y10 w50 h25 gPauseTimer, Pause
Gui, -MinimizeBox -MaximizeBox
Gui, Show, w220 h50, POMODORO

; 타이머 시작
StartTimer() {
    global
    static lastClickTime := 0
    currentClickTime := A_TickCount

    ; 빠르게 두 번 클릭했는지 확인
    if (currentClickTime - lastClickTime < 500) {  ; 500ms 내에 두 번 클릭했는지 확인
        ; 빠르게 두 번 클릭했을 경우 타이머를 리셋
        minutesLeft := workDuration  ; 작업 시간으로 초기화
        secondsLeft := 0
        TimerRunning := true
        SetTimer, UpdateTimer, 1000  ; 함수를 타이머 콜백으로 사용
    } else if (TimerPaused) {
        TimerPaused := false
        TimerRunning := true
        SetTimer, UpdateTimer, 1000  ; 함수를 타이머 콜백으로 사용
    } else {
        minutesLeft := workDuration  ; 작업 시간으로 초기화
        secondsLeft := 0
        TimerRunning := true
        SetTimer, UpdateTimer, 1000  ; 함수를 타이머 콜백으로 사용
    }

    lastClickTime := currentClickTime
}

; Pause Timer
PauseTimer() {
    global
    if (TimerRunning) {
        TimerRunning := false
        TimerPaused := true
        SetTimer, UpdateTimer, Off
    } else {
        TimerPaused := false
        StartTimer()
    }
}

; Update Timer
UpdateTimer:
    ;global
    if (TimerRunning) {
        secondsLeft--
        if (secondsLeft < 0) {
            secondsLeft := 59
            minutesLeft--
        }
        if (minutesLeft < 0) {
            ToggleWorkRest()
        }
        SetTimerLabel(minutesLeft, secondsLeft)
    }
return

; Work/Rest 전환 및 알람 소리 재생
ToggleWorkRest() {
    global
    IsResting := !IsResting
    if FileExist("ring.mp3") {
        SoundPlay, ring.mp3  ; ring.mp3 파일 재생
    } else {
        SoundBeep 1000, 500  ; 파일이 없을 경우 기본적인 비프 소리 재생
    }
    if (IsResting) {
        minutesLeft := restDuration
        MsgBox, 작업 시간이 끝났습니다. 휴식 시간을 시작하세요!
    } else {
        minutesLeft := workDuration
        MsgBox, 휴식 시간이 끝났습니다. 작업을 다시 시작하세요!
    }
    secondsLeft := 0
}


; Set Timer Label
SetTimerLabel(minutes, seconds) {
    global
    GuiControl,, TimerText, % (minutes < 10 ? "0" : "") minutes ":" (seconds < 10 ? "0" : "") seconds
}

; Button Handlers
ButtonStartTimer:
    StartTimer()
return

ButtonPauseTimer:
    PauseTimer()
return

GuiClose:
    ExitApp
return
