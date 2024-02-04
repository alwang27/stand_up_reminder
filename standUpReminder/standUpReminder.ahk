#Persistent ; required for scripts with almost only SetTimer
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Coordmode, Mouse, Screen
; code
ToolTip, 一小时后将提示您起身舒展身体。
Sleep, 2000
ToolTip
;use SetTimer version
;SetTimer, standUp, 216000000
;return
;standUp:
;MsgBox, 4,, Stand up!`nWould you like the reminder to `continue?
;IfMsgBox NO
	;SetTimer, standUp, Off
;Return

;use sleep version
wait:
Sleep, 216000000
;216000000 is one hour
MsgBox, 4,, Stand up!`nWould you like the reminder to `continue?
IfMsgBox Yes
	Goto, wait
return
