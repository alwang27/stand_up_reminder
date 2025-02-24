; required by scripts with almost only SetTimer, but it's not necessary for the sleep version
;#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Coordmode, Mouse, Screen
Menu, Tray, Icon, stand.ico

; 初始化程序列表
global programList := []
ReadProgramList()

; 添加托盘菜单
Menu, Tray, NoStandard
Menu, Tray, Add, 管理程序列表, ManagePrograms
Menu, Tray, Add
Menu, Tray, Add, 退出, GuiClose
Menu, Tray, Default, 管理程序列表

; 获取用户输入的等待时间
InputBox, userWait, 设置提醒时间, 请输入提醒间隔时间(分钟):,, 250, 130,,,,, 30    ; 默认30分钟

; 验证输入
if ErrorLevel     ; 用户按了取消按钮
{
    ExitApp
}
else if userWait is not number    ; 验证输入是否为数字
{
    MsgBox, 请输入有效的数字！
    ExitApp
}
else if (userWait < 1)    ; 确保时间大于1分钟
{
    MsgBox, 请输入大于0的数字！
    ExitApp
}

minWait := userWait    ; 储存用户设定的等待时间

; 将等待时间显示为分钟
waitMsg := minWait . "分钟后将提示您起身舒展身体。"    ; 构建提示信息
ToolTip, %waitMsg%    ; 显示初始提示
Sleep, 3000    ; 显示3秒
ToolTip    ; 清除提示

wait:    ; 主循环开始
    ; 启用 ESC 键处理
    Hotkey, Escape, GuiClose
    waitTime := minWait * 60 * 1000    ; 转换分钟为毫秒
    Sleep, %waitTime%    ; 等待设定时间

    ; 检查所有需要避免的程序
    for index, programName in programList
    {
        if WinExist(programName)
        {
            WinWaitClose, %programName%
        }
    }

    global isMouseOver := false    ; 初始化鼠标状态跟踪
    
    Gui, Destroy    ; 清理可能存在的旧界面
    Gui, Color, 1C1C1C, 2D2D2D    ; 设置深色主题
    Gui, Font, cWhite s10, Segoe UI    ; 设置白色字体
    Gui, Add, Text,, Stand up!`nWould you like it to remind later?    ; 添加提示文本
    Gui, Add, Button, gYesButton w60 Default, Yes    ; 添加确认按钮
    Gui, +AlwaysOnTop    ; 设置窗口始终置顶
    
    ; 获取屏幕尺寸
    SysGet, MonitorWorkArea, MonitorWorkArea    ; 获取工作区尺寸
    
    ; 获取GUI尺寸
    Gui, Show, Hide    ; 临时显示用于获取尺寸
    WinGetPos,,, w, h    ; 获取窗口尺寸
    
    ; 显示GUI并启动移动定时器
    maxX := MonitorWorkAreaRight - w
    maxY := MonitorWorkAreaBottom - h
    Random, x, %MonitorWorkAreaLeft%, %maxX%    ; 随机X坐标
    Random, y, %MonitorWorkAreaTop%, %maxY%    ; 随机Y坐标
    Gui, Show, x%x% y%y%, Stand Up    ; 在随机位置显示窗口
    SetTimer, CheckMouse, 100    ; 启动鼠标检测
    SetTimer, MoveWindow, 10000    ; 启动窗口移动（每10秒）
return

CheckMouse:    ; 检查鼠标是否在窗口上
    MouseGetPos,,, MouseWin
    WinGetTitle, CurrTitle, ahk_id %MouseWin%
    isMouseOver := (CurrTitle = "Stand Up")    ; 更新鼠标状态
return

MoveWindow:    ; 窗口随机移动
    if (!isMouseOver)    ; 仅在鼠标不在窗口上时移动
    {
        WinGetPos,,, w, h, Stand Up
        maxX := MonitorWorkAreaRight - w
        maxY := MonitorWorkAreaBottom - h
        Random, x, %MonitorWorkAreaLeft%, %maxX%
        Random, y, %MonitorWorkAreaTop%, %maxY%
        WinMove, Stand Up,, %x%, %y%    ; 移动到新位置
    }
return

YesButton:    ; 继续下一轮提醒
    Hotkey, Escape, Off    ; 临时禁用 ESC 热键
    SetTimer, CheckMouse, Off
    SetTimer, MoveWindow, Off
    Gui, Destroy
    Goto, wait
return

GuiClose:    ; 退出程序
    Hotkey, Escape, Off    ; 禁用 ESC 热键
    SetTimer, CheckMouse, Off
    SetTimer, MoveWindow, Off
    Gui, Destroy    ; 清理界面
    ExitApp    ; 退出程序
return

; 新增函数
ReadProgramList() {
    global programList
    programList := []
    Loop, Read, %A_ScriptDir%\programs.txt
    {
        if (A_LoopReadLine != "")
            programList.Push(A_LoopReadLine)
    }
}

SaveProgramList() {
    global programList
    FileDelete, %A_ScriptDir%\programs.txt
    for index, program in programList
        FileAppend, %program%`n, %A_ScriptDir%\programs.txt
}

ManagePrograms:
    Gui, 2:New
    Gui, 2:Add, ListView, r10 w300 vProgramListView, 程序名称
    for index, program in programList
        LV_Add(, program)
    Gui, 2:Add, Button, x10 y+10 w80 g2Add, 添加
    Gui, 2:Add, Button, x+10 w80 g2Delete, 删除
    Gui, 2:Add, Button, x+10 w80 g2Close, 关闭
    Gui, 2:Show,, 管理程序列表
return

2Add:    ; 改为新的标签名
    InputBox, newProgram, 添加程序, 请输入程序窗口标题:
    if !ErrorLevel
    {
        if newProgram
        {
            programList.Push(newProgram)
            LV_Add(, newProgram)
            SaveProgramList()
        }
    }
return

2Delete:    ; 改为新的标签名
    row := LV_GetNext()
    if row
    {
        LV_Delete(row)
        programList.RemoveAt(row)
        SaveProgramList()
    }
return

2Close:    ; 改为新的标签名
    Gui, 2:Destroy
return

2GuiClose:
2GuiEscape:
    Gui, 2:Destroy
return
