#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include %A_ScriptDir%\WatchFolder.ahk

; automaticly copy screenshots to a folder
WatchFolder("C:\Users\" . A_UserName . "\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\TempState\ScreenClip", "copy_screenshots", , Watch := 1)

copy_screenshots(path, changes) {
    for k, change in changes{
        if (change.action == 1){ ; new file
            if (SubStr(change.name, -2) == "png"){
                height = 0
                width  = 0
                get_img_size(change.name, width, height)
                if (width != 364 && height !=180){ ; not the thumbnail
                    FormatTime, time_string, ,yyyy-MM-dd-HH-mm-ss
                    FileCopy, % change.name, C:\Users\%A_UserName%\Documents\Screenshots\%time_string%.png
                    return
                }
            }
        }
    }
}

; Docs:
; https://autohotkey.com/docs/Hotkeys.htm
; https://autohotkey.com/docs/KeyList.htm
; Ref https://autohotkey.com/board/topic/60675-osx-style-command-keys-in-windows/

; You need to disable "Between input languages" shotcut from Control Panel\Clock, Language, and Region\Language\Advanced settings > Change lanugage bar hot keys

SetTitleMatchMode, 2

~LAlt::Send {Blind}{vkE8} ; remove alt menu selection

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

#IfWinActive ahk_exe chrome.exe
    $!q::
        If (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 200)
            Send !{f4}
        return
#IfWinActive

; Screenshots

$!+4::Send {LWinDown}{ShiftDown}{s}{ShiftUp}{LWinUp}

; input methods

; $+,::Send ^,
; $+.::Send ^.
$!Space::
    WinGet, WinID,, A
	thread_id := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	current_language := DllCall("GetKeyboardLayout", "UInt", thread_id, "UInt")

    if (current_language == 0x04040404){ ; zh-cht in en mode
        if (IME_GetConvMode() == 0){ ; en mode 
            IME_SetConvMode(1) ; to chinese
        }else{
            Send {Alt Down}{Shift Down}{Shift Up}{Alt Up}
        }
    }else{ ; en
        Send {Alt Down}{Shift Down}{Shift Up}{Alt Up}
        IME_SetConvMode(1) ; to chinese
        SetCapsLockState, off
    }

    Return

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
