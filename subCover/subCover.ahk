#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Coordmode, Mouse, Screen

; use InputBox to get the height value
InputBox, height, "height", "Type the height of the black cover that you want:"
if ErrorLevel
	; if the height value is not set, then use the value in the ini file
	IniRead, height, subCover.ini, Settings, height
else
	; if the value is set, then change the value in the ini file to the value given
	IniWrite, %height%, subCover.ini, Settings, height

gui, subCover: new
;gui, add, text, cwhite w%wid% center y%texthei%, R
;gui, show, w1440 h150 x0 y750
;yPos := A_ScreenHeight - 150
yPos := A_ScreenHeight - height
gui, show, w%A_ScreenWidth% h%height% x0 y%yPos%, subCover
;winset, transparent, 255, subCover.ahk
;black is 000000
gui, color, 000000
gui -caption
WinSet, AlwaysOnTop, on, subCover