#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Coordmode, Mouse, Screen

gui, subCover: new
;gui, add, text, cwhite w%wid% center y%texthei%, R
;gui, show, w1440 h150 x0 y750
yPos := A_ScreenHeight - 150
gui, show, w%A_ScreenWidth% h150 x0 y%yPos%
;winset, transparent, 255, subCover.ahk
;black is 000000
gui, color, 000000
gui -caption
WinSet, AlwaysOnTop, on, subCover.ahk
