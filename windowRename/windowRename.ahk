; 按下 Ctrl+Alt+N 为当前活动窗口重命名
^!n::
    InputBox, newTitle, 重命名窗口, 输入新的窗口标题:, , 300, 150
    If (newTitle != "")
        WinSetTitle, A, , %newTitle%
return