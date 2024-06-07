; required by scripts with almost only SetTimer, but it's not necessary for the sleep version
;#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Coordmode, Mouse, Screen
Menu, Tray, Icon, stand.ico
; code
ToolTip, 30分钟后将提示您起身舒展身体。
Sleep, 2000
ToolTip
;use SetTimer version
;SetTimer, standUp, 3600000
;return
;standUp:
;MsgBox, 4,, Stand up!`nWould you like the reminder to `continue?
;IfMsgBox NO
	;SetTimer, standUp, Off
;Return

;use sleep version
wait:
; an hour
;Sleep, 3600000
; half an hour
Sleep, 1800000
; for test
; Sleep, 2000
if WinExist("War Thunder")
{
	Goto, Wait
}
	Else
{
	; 4+4096, 4 sets the msgbox with Yes/No buttons, 4096 sets it with system modal, which will make it always on top.
	; I need the window to be on top, so it will not be hidden after I click on other area.
	MsgBox, 4100, Stand Up Reminder, Stand up!`nWould you like it to remind later?
	IfMsgBox Yes
		Goto, wait
}
return
