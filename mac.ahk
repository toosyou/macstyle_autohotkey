#SingleInstance Ignore
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}

; Docs:
; https://autohotkey.com/docs/Hotkeys.htm
; https://autohotkey.com/docs/KeyList.htm
; Ref https://autohotkey.com/board/topic/60675-osx-style-command-keys-in-windows/

; You need to disable "Between input languages" shotcut from Control Panel\Clock, Language, and Region\Language\Advanced settings > Change lanugage bar hot keys

SetTitleMatchMode, 2

; Suspend hotkeys
$^!F1::Suspend

; Universal shotcuts

$!x::Send ^x
$!c::Send ^c
$!v::Send ^v
$!+v::Send ^+v
$!s::Send ^s
$!a::Send ^a
$!z::Send ^z
$!+z::Send ^y
$!w::Send ^w
$!f::Send ^f
$!n::Send ^n
$!q::Send !{f4}
$!r::Send ^r
$!m::Send {LWin Down}{Down}{LWin Up}
$!`::Send {Alt Down}{Shift Down}{Tab}{Shift Up}

$F11::Send #d ; show desktop

; window control
$#+Left::
    Send #+{Left}
    WinMaximize, A
Return

$#+Right::
    Send #+{Right}
    WinMaximize, A
Return


; Quick Switch Tab shotcuts

$!1::Send ^1
$!2::Send ^2
$!3::Send ^3
$!4::Send ^4
$!5::Send ^5
$!6::Send ^6
$!7::Send ^7
$!8::Send ^8
$!9::Send ^9
$!0::Send ^0

; Chrome shotcuts

$!+]::Send {Ctrl Down}{Tab Down}{Tab Up}{Ctrl Up}
$!+[::Send {Ctrl Down}{Shift Down}{Tab Down}{Tab Up}{Shift Up}{Ctrl Up}
$!l::Send ^l

$!=::Send ^{=} ; zoom
$!-::Send ^{-}

$!+n::Send ^+n

#If WinActive("ahk_exe chrome.exe") or WinActive("ahk_exe Code.exe")
    $!q::
        If (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 200)
            Send !{f4}
        return

    Alt::
        KeyWait, Alt
        return

    LAlt Up::
        if (A_PriorKey = "Alt")
            return
        return
#If

; delete
#IfWinNotActive ahk_exe chrome.exe
    $!Backspace:: Send ^d
#IfWinNotActive

; Screenshots

$!+4::Send {LWinDown}{ShiftDown}{s}{ShiftUp}{LWinUp}

; input methods

; $+,::Send ^,
; $+.::Send ^.
$!Space::
    WinGet, WinID,, A
	thread_id := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	current_language := DllCall("GetKeyboardLayout", "UInt", thread_id, "UInt")

    Critical, On
    if (current_language == 0x04040404){ ; zh-cht in en mode
        if (IME_GetConvMode() == 0){ ; en mode 
            IME_SetConvMode(1) ; to chinese
            SetCapsLockState, off
        }else{
            SetDefaultKeyboard(0x0409) ; to en
        }
    }else{ ; en
        SetDefaultKeyboard(0x0404) ; to zh-cht
        IME_SetConvMode(1)
        SetCapsLockState, off
    }

    Return

SetDefaultKeyboard(LocaleID){
	Static SPI_SETDEFAULTINPUTLANG := 0x005A, SPIF_SENDWININICHANGE := 2
	
	Lan := DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", LocaleID), "Int", 0)
	VarSetCapacity(binaryLocaleID, 4, 0)
	NumPut(LocaleID, binaryLocaleID)
	DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG, "UInt", 0, "UPtr", &binaryLocaleID, "UInt", SPIF_SENDWININICHANGE)
	
	WinGet, windows, List
	Loop % windows {
		PostMessage 0x50, 0, % Lan, , % "ahk_id " windows%A_Index%
	}
}

$CapsLock::
    WinGet, WinID,, A
	thread_id := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	current_language := DllCall("GetKeyboardLayout", "UInt", thread_id, "UInt")

    if (current_language == 0x04040404){ ; zh-cht
        SetCapsLockState, off
        Send {RShift}
    }else{ ; en
        SetCapsLockState % !GetKeyState("CapsLock", "T") ; toggle capslock 
    }
    
    KeyWait, CapsLock

    Return

; volume control
$PrintScreen::Send {Volume_Mute}
$Scrolllock::Send {Volume_Down}
$Pause::Send {Volume_Up}

$!Scrolllock::
    chrome_volume := FindAppVolume("chrome.exe") * 100
    if (chrome_volume > 11)
        chrome_volume := FindAppVolume("chrome.exe", "change", -0.1) * 100
    ShowVolumeOSD(chrome_volume, false, "Google Chrome")
Return
$!Pause::
    FindAppVolume("chrome.exe", "mute", 0)
    chrome_volume := FindAppVolume("chrome.exe", "change", 0.1) * 100
    ShowVolumeOSD(chrome_volume, false, "Google Chrome")
Return

$!PrintScreen::
    chrome_muted := FindAppVolume("chrome.exe", "mute", 2)
    ShowVolumeOSD(FindAppVolume("chrome.exe") * 100, chrome_muted, "Google Chrome")
Return

$F24::
    FindAppVolume("Discord.exe", "mute", 0)
    discord_volume := FindAppVolume("Discord.exe", "change", 0.1) * 100
    ShowVolumeOSD(discord_volume, false, "Discord")
Return

$F23::
    discord_volume := FindAppVolume("Discord.exe") * 100
    if (discord_volume > 11)
        discord_volume := FindAppVolume("Discord.exe", "change", -0.1) * 100
    ShowVolumeOSD(discord_volume, false, "Discord")
Return

$F22::
    discord_muted := FindAppVolume("Discord.exe", "mute", 2)
    ShowVolumeOSD(FindAppVolume("Discord.exe") * 100, discord_muted, "Discord")
Return

$F21:: ; reset volume
    FindAppVolume("Discord.exe", "mute", 0)
    FindAppVolume("Discord.exe", "set", 1.0)
    FindAppVolume("chrome.exe", "mute", 0)
    FindAppVolume("chrome.exe", "set", 1.0)
    ShowVolumeOSD(100, false, "Reset")
Return


SendUpAndEnter() {
    Send {Up}
    Sleep 100
    Send {Enter}
}

#If WinActive("ahk_exe javaw.exe")
    ; switch tab and ` key
    $sc029::Send {Tab}
    $Tab::SendInput, `` 
#If

; monitor contorl
$!\::
    Sleep 1000
    SendMessage 0x112, 0xF170, 2, , Program Manager ; Monitor off
    Return


; vscode 
$!,::Send ^,
$!.::Send ^.
$!p::Send ^p
$!+p::Send ^+p
$!+f::Send ^+f

; navigation, selection, delete a word/till end

#If GetKeyState("Alt", "P")
    *Left::Send {Blind}{vkE8}{Alt up}{Home}
    *Right::Send {Blind}{vkE8}{Alt up}{End}
#If

$!Up::Send {Lctrl down}{Home}{Lctrl up}
$!Down::Send {Lctrl down}{End}{Lctrl up}

$#Left::Send {ctrl down}{Left}{ctrl up}
$#Right::Send {ctrl down}{Right}{ctrl up}
; $#+Left::Send {ctrl down}{shift down}{Left}{shift up}{ctrl up}
; $#+Right::Send {ctrl down}{shift down}{Right}{shift up}{ctrl up}

$!+Left::Send {shift down}{Home}{shift up}
$!+Right::Send {shift down}{End}{shift up}
$!+Up::Send {Ctrl Down}{shift down}{Home}{shift up}{Ctrl Up}
$!+Down::Send {Ctrl Down}{shift down}{End}{shift up}{Ctrl Up}

!BS::Send {LShift down}{Home}{LShift Up}{Del}
#BS::Send {LCtrl down}{BS}{LCtrl up}

; $#Space::Send {Ctrl Down}{LWin Down}{Space}{LWin Up}{Ctrl Up}

$!+Backspace::
    MsgBox, 3, Confirm, Clean the recycle bin?
    IfMsgBox Yes
        FileRecycleEmpty
    Return

#if is_not_fullscreen() or WinActive("ahk_exe explorer.exe") ; focus on the desktop
    $^Space::Send {LWinDown}{Space}{LWin Up}
    $!LButton::Send ^{LButton}

    $!t::Send ^t ; chrome new tab
    $!+t::Send ^+t ; chrome new tab

#if

is_not_fullscreen() {
    WinGet style, Style, A
	WinGetPos ,,,winW, winH, A
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth)
}

GetGUIThreadInfo_hwndActive(WinTitle="A") {
	ControlGet, hwnd, HWND,,, %WinTitle%
	if (WinActive(WinTitle)) {
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
		VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
		NumPut(cbSize, stGTI,  0, "UInt")
		return hwnd := DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", &stGTI)
				 ? NumGet(stGTI, 8+PtrSize, "Ptr") : hwnd
	}
	else {
		return hwnd
	}
}

IME_SetConvMode(ConvMode, WinTitle="A")   {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
          , "UInt", 0x0283      ;Message : WM_IME_CONTROL
          , "UPtr", 0x002       ;wParam  : IMC_SETCONVERSIONMODE
          ,  "Ptr", ConvMode)   ;lParam  : CONVERSIONMODE
}

IME_SetOpenStatus(Status, WinTitle="A") {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
          , "UInt", 0x0283      ;Message : WM_IME_CONTROL
          , "UPtr", 0x006       ;wParam  : IMC_SETOPENSTATUS
          ,  "Ptr", Status)     ;lParam  : 0 closed, 1 open
}

IME_GetOpenStatus(WinTitle="A") {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
          , "UInt", 0x0283      ;Message : WM_IME_CONTROL
          , "UPtr", 0x005       ;wParam  : IMC_GETOPENSTATUS
          ,  "Ptr", 0)
}

IME_GetConvMode(WinTitle="A") {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
    , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
    , "UInt", 0x0283
    , "Int", 0x001
    , "Int", 0) & 0xffff
}

get_img_size(img, ByRef width , ByRef height) { ; Get image's dimensions
    If FileExist(img) {
        GUI, Add, Picture, hwndpic, %img%
        ControlGetPos,,, width, height,, ahk_id %pic%
        Gui, Destroy
    } Else height := width := 0
}

; macOS-style volume OSD: a dark rounded panel with a speaker glyph, an app
; label and a segmented level bar. `percent` is 0..100; `muted` swaps the
; glyph; `label` is the app name shown at the top. The panel is centred
; horizontally and pinned near the bottom of the primary screen.
ShowVolumeOSD(percent, muted := false, label := "") {
    Static isGuiShown := false
    Static lastOperationTime := 0
    Static segCount := 15
    Static duration := 1000
    Static iconHwnd := 0
    Static labelHwnd := 0
    Static segHwnd := 0
    Static segHwnds := []

    W := 200, H := 210, radius := 30
    barLeft := 20, barH := 7.5, gap := 0
    barY := H - 26 - barH

    if (percent = "")
        percent := 0
    percent := Round(percent)
    if (percent < 0)
        percent := 0
    else if (percent > 100)
        percent := 100
    filled := Round(percent / 100 * segCount)
    iconGlyph := muted ? Chr(0xE74F) : Chr(0xE767) ; Segoe MDL2: Mute / Volume

    if (!isGuiShown) {
        Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow +Disabled
        Gui, Color, 1A1A1A ; dark panel background
        Gui, Margin, 0, 0

        Gui, Font, s9, Segoe UI
        Gui, Add, Text, x0 y14 w%W% h18 Center c909090 hwndlabelHwnd

        ; icon fills the space between the label and the bar, +0x200
        ; (SS_CENTERIMAGE) vertically centres the single-line glyph
        iconTop := 30
        iconH := barY - iconTop - 6
        Gui, Font, s64, Segoe MDL2 Assets
        Gui, Add, Text, x0 y%iconTop% w%W% h%iconH% Center +0x200 cC8C8C8 hwndiconHwnd

        barW := W - barLeft * 2
        segW := (barW - gap * (segCount - 1)) / segCount
        ; -Theme so the Progress bars honour the flat custom colours
        bgOpt := "x" barLeft " y" barY " w" barW " h" barH " -Theme Background2E2E2E"
        Gui, Add, Progress, %bgOpt%
        segHwnds := []
        Loop % segCount {
            sx := Round(barLeft + (A_Index - 1) * (segW + gap))
            sw := Round(barLeft + A_Index * (segW + gap) - gap) - sx
            segOpt := "x" sx " y" barY " w" sw " h" barH " -Theme Background2E2E2E cE6E6E6 hwndsegHwnd"
            Gui, Add, Progress, %segOpt%
            segHwnds[A_Index] := segHwnd
        }

        xPos := (A_ScreenWidth - W) // 2
        yPos := A_ScreenHeight - H - 130
        Gui, Show, % "NoActivate x" xPos " y" yPos " w" W " h" H
        WinSet, Region, % "0-0 w" W " h" H " r" radius "-" radius
        WinSet, Transparent, 215

        isGuiShown := true
    }

    GuiControl, , %labelHwnd%, %label%
    GuiControl, , %iconHwnd%, %iconGlyph%
    Loop % segCount {
        h := segHwnds[A_Index]
        GuiControl, , %h%, % (A_Index <= filled ? 100 : 0)
    }

    lastOperationTime := A_TickCount
    SetTimer, HideVolumeOSD, % "-" duration
    Return

    HideVolumeOSD:
        if (A_TickCount - lastOperationTime >= duration) {
            Gui, Destroy
            isGuiShown := false
        }
    Return
}


; op: "get" (default) returns the loudest active session's volume (0..1);
;     "set"    sets every matching session to `value` (0..1);
;     "change" adds `value` to the "get" level and sets every session to it;
;     "mute"   applies `value` to every matching session (0 unmute, 1 mute, 2 toggle),
;              returns the resulting mute state.
; Chrome spawns several audio sessions (e.g. "Google Chrome" and
; "YouTube - Google Chrome"), so every write has to walk all of them.
FindAppVolume(appName, op := "get", value := 0)
{
    if !appName
    {
        WinGet, activePID, ID, A
        WinGet, activeName, ProcessName, ahk_id %activePID%
        appName := activeName
    }

    ; Sessions of one app can sit at different levels, so resolve a relative
    ; change against a single reference level and write it to every session.
    if ( op = "change" )
    {
        newVolume := FindAppVolume(appName) + value
        Return FindAppVolume(appName, "set", newVolume)
    }

    IMMDeviceEnumerator := ComObjCreate( "{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}" )
    DllCall( NumGet( NumGet( IMMDeviceEnumerator+0 ) + 4*A_PtrSize ), "UPtr", IMMDeviceEnumerator, "UInt", 0, "UInt", 1, "UPtrP", IMMDevice, "UInt" )
    ObjRelease(IMMDeviceEnumerator)

    VarSetCapacity( GUID, 16 )
    DllCall( "Ole32.dll\CLSIDFromString", "Str", "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}", "UPtr", &GUID)
    DllCall( NumGet( NumGet( IMMDevice+0 ) + 3*A_PtrSize ), "UPtr", IMMDevice, "UPtr", &GUID, "UInt", 23, "UPtr", 0, "UPtrP", IAudioSessionManager2, "UInt" )
    ObjRelease( IMMDevice )

    DllCall( NumGet( NumGet( IAudioSessionManager2+0 ) + 5*A_PtrSize ), "UPtr", IAudioSessionManager2, "UPtrP", IAudioSessionEnumerator, "UInt" )
    ObjRelease( IAudioSessionManager2 )

    DllCall( NumGet( NumGet( IAudioSessionEnumerator+0 ) + 3*A_PtrSize ), "UPtr", IAudioSessionEnumerator, "UIntP", SessionCount, "UInt" )

    result := ""
    muteTarget := ""
    activeMax := ""
    anyMax := ""
    Loop % SessionCount
    {
        DllCall( NumGet( NumGet( IAudioSessionEnumerator+0 ) + 4*A_PtrSize ), "UPtr", IAudioSessionEnumerator, "Int", A_Index-1, "UPtrP", IAudioSessionControl, "UInt" )
        IAudioSessionControl2 := ComObjQuery( IAudioSessionControl, "{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}" )
        ObjRelease( IAudioSessionControl )

        DllCall( NumGet( NumGet( IAudioSessionControl2+0 ) + 14*A_PtrSize ), "UPtr", IAudioSessionControl2, "UIntP", PID, "UInt" )
        
        PHandle := DllCall( "OpenProcess", "uint", 0x0010|0x0400, "Int", false, "UInt", PID )
        if !( ErrorLevel or PHandle = 0 )
        {
            name_size = 1023
            VarSetCapacity( PName, name_size )
            DllCall( "psapi.dll\GetModuleFileNameEx" . ( A_IsUnicode ? "W" : "A" ), "uint", PHandle, "uint", 0, "str", PName, "uint", name_size )
            DllCall( "CloseHandle", PHandle )
            SplitPath PName, PName
            if ( PName = appName )
            {
                ; ISimpleAudioVolume vtable: 3 SetMasterVolume, 4 GetMasterVolume, 5 SetMute, 6 GetMute
                ISimpleAudioVolume := ComObjQuery(IAudioSessionControl2, "{87CE5498-68D6-44E5-9215-6DA47EF883D8}")
                DllCall( NumGet( NumGet( ISimpleAudioVolume+0 ) + 4*A_PtrSize ), "UPtr", ISimpleAudioVolume, "FloatP", curVolume, "UInt" )

                if ( op = "set" )
                {
                    newVolume := value
                    if ( newVolume < 0 )
                        newVolume := 0
                    else if ( newVolume > 1 )
                        newVolume := 1
                    DllCall( NumGet( NumGet( ISimpleAudioVolume+0 ) + 3*A_PtrSize ), "UPtr", ISimpleAudioVolume, "Float", newVolume, "Ptr", 0, "UInt" )
                    result := newVolume
                }
                else if ( op = "mute" )
                {
                    if ( value = 2 )
                    {
                        if ( muteTarget = "" )
                        {
                            DllCall( NumGet( NumGet( ISimpleAudioVolume+0 ) + 6*A_PtrSize ), "UPtr", ISimpleAudioVolume, "IntP", curMute, "UInt" )
                            muteTarget := !curMute
                        }
                    }
                    else
                        muteTarget := value
                    DllCall( NumGet( NumGet( ISimpleAudioVolume+0 ) + 5*A_PtrSize ), "UPtr", ISimpleAudioVolume, "Int", muteTarget, "Ptr", 0, "UInt" )
                    result := muteTarget
                }
                else
                {
                    ; IAudioSessionControl::GetState (vtable 3), 1 = AudioSessionStateActive
                    DllCall( NumGet( NumGet( IAudioSessionControl2+0 ) + 3*A_PtrSize ), "UPtr", IAudioSessionControl2, "IntP", state, "UInt" )
                    if ( anyMax = "" || curVolume > anyMax )
                        anyMax := curVolume
                    if ( state = 1 && ( activeMax = "" || curVolume > activeMax ) )
                        activeMax := curVolume
                }

                ObjRelease(ISimpleAudioVolume)
            }
        }
        ObjRelease(IAudioSessionControl2)
    }
    ObjRelease(IAudioSessionEnumerator)

    ; "get": report the loudest session that is playing, else the loudest overall,
    ; rather than whichever session happened to be enumerated last
    if ( op = "get" )
        result := ( activeMax != "" ) ? activeMax : anyMax

	Return result

}