#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Coordmode, Mouse, Screen
Menu, Tray, Icon, stand.ico

global isDarkTheme := true    ; 主题设置：true=深色主题，false=浅色主题
global nextRemindTime := 0    ; 下次提醒的时间戳（毫秒）
global programList := []    ; 需要暂停提醒的程序列表

; 设置托盘图标鼠标悬停消息处理（0x404 = WM_MOUSEMOVE）
OnMessage(0x404, "AHK_NOTIFYICON")    ; 监听鼠标悬停事件，用于显示剩余时间

; 初始化程序列表
ReadProgramList()    ; 从配置文件加载需要暂停提醒的程序列表

; 配置托盘菜单
Menu, Tray, NoStandard    ; 移除默认菜单项
Menu, ThemeMenu, Add, 深色主题, ToggleDarkTheme    ; 添加主题切换选项
Menu, ThemeMenu, Add, 浅色主题, ToggleLightTheme
Menu, Tray, Add, 主题设置, :ThemeMenu    ; 添加主题子菜单
Menu, Tray, Add, 管理程序列表, ManagePrograms    ; 添加程序列表管理选项
Menu, Tray, Add    ; 添加分隔线
Menu, Tray, Add, 退出, GuiClose
Menu, Tray, Default, 管理程序列表    ; 设置默认菜单项

; 设置初始主题选中状态
Menu, ThemeMenu, Check, 深色主题

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
else if (userWait <= 0)    ; 确保时间大于0分钟
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

wait:    ; 主循环开始处理标签
    waitTime := minWait * 60 * 1000    ; 将分钟转换为毫秒
    nextRemindTime := A_TickCount + waitTime    ; 计算下次提醒时间点
    Sleep, %waitTime%    ; 等待指定时间

    ; 检查是否有需要等待关闭的程序
    for index, programName in programList    ; 遍历程序列表
    {
        if WinExist(programName)    ; 如果程序正在运行
        {
            WinWaitClose, %programName%    ; 等待程序关闭
        }
    }

    global isMouseOver := false    ; 初始化鼠标状态跟踪
    
    Gui, Destroy    ; 清理可能存在的旧界面
    if (isDarkTheme)
    {
        Gui, Color, 1C1C1C, 2D2D2D    ; 深色主题
        Gui, Font, cWhite s10, Segoe UI
    }
    else
    {
        Gui, Color, F0F0F0, FFFFFF    ; 浅色主题
        Gui, Font, c000000 s10, Segoe UI
    }
    
    ; 设置固定的GUI尺寸
    guiWidth := 250
    guiHeight := 100
    Gui, +AlwaysOnTop -MinimizeBox    ; 添加-MinimizeBox以禁用最小化按钮
    Gui, Add, Text, w200 Center, Stand up!`nWould you like it to remind later?
    Gui, Add, Button, x95 y+10 w60 gYesButton Default, Yes
    
    ; 获取当前活动窗口
    WinGetActiveTitle, previousWindow
    
    ; 获取屏幕尺寸
    SysGet, MonitorWorkArea, MonitorWorkArea
    
    ; 计算屏幕中央位置
    centerX := MonitorWorkAreaLeft + (MonitorWorkAreaRight - MonitorWorkAreaLeft - guiWidth) / 2
    centerY := MonitorWorkAreaTop + (MonitorWorkAreaBottom - MonitorWorkAreaTop - guiHeight) / 2
    
    ; 显示GUI并立即切回原窗口
    Gui, Show, x%centerX% y%centerY% w%guiWidth% h%guiHeight%, Stand Up
    if previousWindow    ; 如果之前有活动窗口，就切换回去
        WinActivate, %previousWindow%
    
    SetTimer, CheckMouse, 100
    SetTimer, MoveWindow, 10000
return

CheckMouse:    ; 检查鼠标是否在窗口上
    MouseGetPos,,, MouseWin
    WinGetTitle, CurrTitle, ahk_id %MouseWin%
    isMouseOver := (CurrTitle = "Stand Up")    ; 更新鼠标状态
return

MoveWindow:    ; 窗口随机移动
    if (!isMouseOver)    ; 仅在鼠标不在窗口上时移动
    {
        ; 使用之前定义的固定尺寸
        maxX := MonitorWorkAreaRight - guiWidth
        maxY := MonitorWorkAreaBottom - guiHeight
        Random, x, %MonitorWorkAreaLeft%, %maxX%
        Random, y, %MonitorWorkAreaTop%, %maxY%
        WinMove, Stand Up,, %x%, %y%    ; 移动到新位置
    }
return

YesButton:    ; 继续下一轮提醒
    SetTimer, CheckMouse, Off
    SetTimer, MoveWindow, Off
    Gui, Destroy
    Goto, wait
return

GuiClose:    ; 退出程序
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
    if (isDarkTheme)
    {
        Gui, 2:Color, 1C1C1C, 2D2D2D
        Gui, 2:Font, cWhite s10, Segoe UI
    }
    else
    {
        Gui, 2:Color, F0F0F0, FFFFFF
        Gui, 2:Font, c000000 s10, Segoe UI
    }
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

; 添加主题切换函数（放在文件末尾）
ToggleDarkTheme:
    Menu, ThemeMenu, Check, 深色主题
    Menu, ThemeMenu, Uncheck, 浅色主题
    isDarkTheme := true
return

ToggleLightTheme:
    Menu, ThemeMenu, Check, 浅色主题
    Menu, ThemeMenu, Uncheck, 深色主题
    isDarkTheme := false
return

; 添加托盘图标鼠标悬停处理函数（放在文件末尾）
AHK_NOTIFYICON(wParam, lParam) {    ; 托盘图标鼠标悬停处理函数
    if (lParam = 0x200) {    ; 当检测到鼠标移动到托盘图标上
        timeLeft := nextRemindTime - A_TickCount    ; 计算剩余时间（毫秒）
        if (timeLeft > 0) {    ; 如果还有剩余时间
            timeLeftMinutes := Round(timeLeft / 60000, 1)    ; 转换为分钟并保留一位小数
            ToolTip, 下次提醒还有 %timeLeftMinutes% 分钟    ; 显示提示
            SetTimer, RemoveToolTip, -3000    ; 3秒后自动移除提示
        }
    }
}

RemoveToolTip:    ; 移除提示的处理标签
    ToolTip    ; 清除当前显示的提示
return
