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
; Sleep, 3600000
; half an hour
; Sleep, 1800000
; for test
Sleep, 2000
if WinExist("War Thunder")
{
	Goto, Wait
}
	Else
{
	Gui, Destroy  ; 确保先清除可能存在的旧GUI
	Gui, Color, 1C1C1C, 2D2D2D  ; 深灰色背景
	Gui, Font, cWhite s10, Segoe UI  ; 白色文字
	Gui, Add, Text,, Stand up!`nWould you like it to remind later?
	Gui, Add, Button, gYesButton w60, Yes
	Gui, Add, Button, x+10 gNoButton w60, No
	Gui, +AlwaysOnTop  ; 保持窗口置顶
	Gui, Show,, Stand Up Reminder
	WinWaitClose, Stand Up Reminder  ; 等待GUI窗口关闭
}
return

YesButton:
	Gui, Destroy
	Sleep, 2000  ; 添加短暂延迟
	Goto, wait
return

NoButton:
	Gui, Destroy
	ExitApp
return
