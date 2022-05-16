#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Docs:
; https://autohotkey.com/docs/Hotkeys.htm
; https://autohotkey.com/docs/KeyList.htm
; Ref https://autohotkey.com/board/topic/60675-osx-style-command-keys-in-windows/

; You need to disable "Between input languages" shotcut from Control Panel\Clock, Language, and Region\Language\Advanced settings > Change lanugage bar hot keys

; Universal shotcuts

$!x::Send ^x
$!c::Send ^c
$!v::Send ^v
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

; delete
$!Backspace:: Send ^d

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

$!t::Send ^t
$!+t::Send ^+t
$!+]::Send {Ctrl Down}{Tab Down}{Tab Up}{Ctrl Up}
$!+[::Send {Ctrl Down}{Shift Down}{Tab Down}{Tab Up}{Shift Up}{Ctrl Up}
$!l::Send ^l

$!=::Send ^{=} ; zoom
$!-::Send ^{-}

$!+n::Send ^+n

; Screenshots

$!+4::Send {LWinDown}{ShiftDown}{s}{ShiftUp}{LWinUp}

; input methods

; $+,::Send ^,
; $+.::Send ^.
$!Space::Send {Alt Down}{Shift Down}{Alt Up}{Shift Up}

$CapsLock::
    WinGet, WinID,, A
	thread_id := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	current_language := DllCall("GetKeyboardLayout", "UInt", thread_id, "UInt")

    if (current_language == 0x04040404){ ; zh-cht
        SetCapsLockState, off
        Send {LShift}
    }else{ ; en
        SetCapsLockState % !GetKeyState("CapsLock", "T") ; toggle capslock 
    }
    
    KeyWait, CapsLock
    Return

; volume control
$PrintScreen::Send {Volume_Mute}
$Scrolllock::Send {Volume_Down}
$Pause::Send {Volume_Up}

; vscode 
$!,::Send ^,
$!.::Send ^.
$!p::Send ^p
$!+p::Send ^+p
$!Enter::Send ^{Enter}

; navigation, selection, delete a word/till end

$!Left::Send {Home}
$!Right::Send {End}
$!Up::Send {Lctrl down}{Home}{Lctrl up}
$!Down::Send {Lctrl down}{End}{Lctrl up}

$#Left::Send {ctrl down}{Left}{ctrl up}
$#Right::Send {ctrl down}{Right}{ctrl up}
$#+Left::Send {ctrl down}{shift down}{Left}{shift up}{ctrl up}
$#+Right::Send {ctrl down}{shift down}{Right}{shift up}{ctrl up}

$!+Left::Send {shift down}{Home}{shift up}
$!+Right::Send {shift down}{End}{shift up}
$!+Up::Send {Ctrl Down}{shift down}{Home}{shift up}{Ctrl Up}
$!+Down::Send {Ctrl Down}{shift down}{End}{shift up}{Ctrl Up}

!BS::Send {LShift down}{Home}{LShift Up}{Del}
#BS::Send {LCtrl down}{BS}{LCtrl up}

; $#Space::Send {Ctrl Down}{LWin Down}{Space}{LWin Up}{Ctrl Up}

$!LButton::Send ^{LButton}
$!+Backspace::
    MsgBox, 3, Confirm, Clean the recycle bin?
    IfMsgBox Yes
        FileRecycleEmpty
    Return

#if is_not_fullscreen() or WinActive("ahk_exe explorer.exe") ; focus on the desktop
    $^Space::Send {LWinDown}{Space}{LWin Up}
#if

is_not_fullscreen()
{
    WinGet style, Style, A
	WinGetPos ,,,winW, winH, A
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth)
}