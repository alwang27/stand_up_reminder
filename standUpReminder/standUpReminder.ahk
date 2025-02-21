; required by scripts with almost only SetTimer, but it's not necessary for the sleep version
;#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Coordmode, Mouse, Screen
Menu, Tray, Icon, stand.ico

; 获取用户输入的等待时间
InputBox, userWait, 设置提醒时间, 请输入提醒间隔时间(分钟):,, 250, 130,,,,, 30

; 验证输入
if ErrorLevel  ; 用户按了取消
{
    ExitApp
}
else if userWait is not number
{
    MsgBox, 请输入有效的数字！
    ExitApp
}
else if (userWait < 1)
{
    MsgBox, 请输入大于0的数字！
    ExitApp
}

minWait := userWait  ; 使用用户输入的时间

; 将等待时间显示为分钟
waitMsg := minWait . "分钟后将提示您起身舒展身体。"
ToolTip, %waitMsg%
Sleep, 3000
ToolTip

wait:
    waitTime := minWait * 60 * 1000    ; 将分钟转换为毫秒
    Sleep, %waitTime%

    if WinExist("War Thunder")
    {
        Goto, wait
    }
        Else
    {
        global isMouseOver := false  ; 添加全局变量跟踪鼠标状态
        
        Gui, Destroy  ; 确保先清除可能存在的旧GUI
        Gui, Color, 1C1C1C, 2D2D2D  ; 深灰色背景
        Gui, Font, cWhite s10, Segoe UI  ; 白色文字
        Gui, Add, Text,, Stand up!`nWould you like it to remind later?
        Gui, Add, Button, gYesButton w60 Default, Yes
        Gui, +AlwaysOnTop  ; 保持窗口置顶
        
        ; 获取屏幕尺寸
        SysGet, MonitorWorkArea, MonitorWorkArea
        
        ; 获取GUI尺寸
        Gui, Show, Hide
        WinGetPos,,, w, h
        
        ; 显示GUI并启动移动定时器
        maxX := MonitorWorkAreaRight - w
        maxY := MonitorWorkAreaBottom - h
        Random, x, %MonitorWorkAreaLeft%, %maxX%
        Random, y, %MonitorWorkAreaTop%, %maxY%
        Gui, Show, x%x% y%y%, Stand Up
        SetTimer, CheckMouse, 100
        SetTimer, MoveWindow, 10000
        ; WinWaitClose, Stand Up
    }
return

CheckMouse:
    MouseGetPos,,, MouseWin
    WinGetTitle, CurrTitle, ahk_id %MouseWin%
    isMouseOver := (CurrTitle = "Stand Up")  
return

MoveWindow:
    if (!isMouseOver)
    {
        WinGetPos,,, w, h, Stand Up  
        maxX := MonitorWorkAreaRight - w
        maxY := MonitorWorkAreaBottom - h
        Random, x, %MonitorWorkAreaLeft%, %maxX%
        Random, y, %MonitorWorkAreaTop%, %maxY%
        WinMove, Stand Up,, %x%, %y%  
    }
return

YesButton:
    SetTimer, CheckMouse, Off
    SetTimer, MoveWindow, Off
    Gui, Destroy
    Goto, wait
return

GuiClose:
    SetTimer, CheckMouse, Off
    SetTimer, MoveWindow, Off
    Gui, Destroy
    ExitApp
return
