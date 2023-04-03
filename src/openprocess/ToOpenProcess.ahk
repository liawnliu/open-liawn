; 基本要依赖exePath来打开程序窗口或者启动程序，name只是备用
OpenWindow(name, exePath) {
    exeNameArr := StrSplit(exePath, "\")
    ; 它带上了.exe后缀
    exeName := (exeNameArr.Length ? exeNameArr[exeNameArr.Length] : exePath)
    LogWrite.Info("exeName: " exeName " , name: " name " , exePath: " exePath)
    SetTitleMatchMode(2)	;窗口标题的任意位置包含 WinTitle 才能匹配
    ; 打开窗口，如果异常就尝试下一种方式
    OpenWindowByWinActivate(exeName, exePath, true)
}
OpenWindowByWinActivate(exeName, exePath, replayTrayIcon := false) {
    try {
        ; 资源管理器比较特殊
        if (RegExMatch(exeName, "i)^explorer")) {	; i)表示不区分大小写，^表示开头
            Send("#e")	; 如果是explorer，就直接Win+E生成新窗口，用WinActivate可能把电源窗口激活
        } else {
            WinActivate("ahk_exe " exePath)
        }
    } catch Error As e {
        LogWrite.Error("异常消息: " e.Message "`n 异常原因: " e.What "`n Specifically: " e.Extra "`n 异常发生所在文件: " e.File "`n 异常发生所在行数: " e.Line "`n 异常有关调用栈: " e.Stack)
        if (replayTrayIcon) {
            OpenWindowByTrayIcon(exeName, exePath, true)
        }
    }
}
OpenWindowByTrayIcon(exeName, exePath, replayRun := false) {
    try {
        TrayIconRlt := TrayIcon_Button(exeName)
        if (!TrayIconRlt && replayRun) {
            OpenWindowByRun(exePath)
        }
    } catch Error As e {
        LogWrite.Error("异常消息: " e.Message "`n 异常原因: " e.What "`n Specifically: " e.Extra "`n 异常发生所在文件: " e.File "`n 异常发生所在行数: " e.Line "`n 异常有关调用栈: " e.Stack)
        if (replayRun) {
            OpenWindowByRun(exePath)
        }
    }
}
OpenWindowByRun(exePath) {
    try {
        Run(exePath)
    } catch Error As e {
        LogWrite.Error("异常消息: " e.Message "`n 异常原因: " e.What "`n Specifically: " e.Extra "`n 异常发生所在文件: " e.File "`n 异常发生所在行数: " e.Line "`n 异常有关调用栈: " e.Stack)
    }
}