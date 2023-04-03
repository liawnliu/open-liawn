Class LogWrite {
    static path := A_WorkingDir "\log"
    static Error(msg, fileName := "RunMsg", lineFile := "", lineNum := "", encode := "UTF-8") {
        LogWrite.ToWrite("ERROR", msg, fileName, lineFile, lineNum, encode)
    }
    static Log(msg, fileName := "RunMsg", lineFile := "", lineNum := "", encode := "UTF-8") {
        LogWrite.ToWrite("INFO", msg, fileName, lineFile, lineNum, encode)
    }
    static Info(msg, fileName := "RunMsg", lineFile := "", lineNum := "", encode := "UTF-8") {
        LogWrite.ToWrite("INFO", msg, fileName, lineFile, lineNum, encode)
    }
    static Warn(msg, fileName := "RunMsg", lineFile := "", lineNum := "", encode := "UTF-8") {
        LogWrite.ToWrite("WARN", msg, fileName, lineFile, lineNum, encode)
    }
    static ToWrite(level, msg, fileName := "", lineFile := "", lineNum := "", encode := "UTF-8") {
        If (A_IsCompiled)
            return
        levelAndFileMsg := ""
        if (lineFile) {
            if (lineNum) {
                levelAndFileMsg := "[" . level . "] " . "[" . lineFile . "(" . lineNum . ")]: "
            } else {
                levelAndFileMsg := "[" . level . "] " . "[" . lineFile . "]: "
            }
        }
        try {
            msgStr := msg
            if (IsObject(msg)) {
                msgStr := Jxon_dump(msg)
            }
            msgStr := levelAndFileMsg . msgStr
            timeStr := LogWrite.GetTimeAllStr()
            ; 如果log文件夹不存在就先创建文件夹
            if (!DirExist(LogWrite.path)) {
                DirCreate(LogWrite.path)
            }
            fileName := LogWrite.path . "\" . fileName . "." . LogWrite.GetTimeStr() . ".log"
            FileObj := FileOpen(fileName, "a", "UTF-8")
            FileObj.Write("[" . timeStr . "] " . msgStr "`n")
            FileObj.Close()
        } catch Error As e {
            LogWrite.ErrorBox(e)
        }
    }
    static ErrorBox(Error) {
        MsgBox("异常消息: " Error.Message "`n 异常原因: " Error.What "`n Specifically: " Error.Extra "`n 异常发生所在文件: " Error.File "`n 异常发生所在行数: " Error.Line "`n 异常有关调用栈: " Error.Stack)
    }
    ; 清空所有的日志
    static ClearAllLog() {
        LogWrite.ClearLog(0)
    }
    ; 清空七天前的日志
    static ClearWeekLog() {
        LogWrite.ClearLog(7)
    }
    ; 清空三十天前的日志
    static ClearMonthLog() {
        LogWrite.ClearLog(30)
    }
    static ClearLog(param) {
        try {
            Loop Files LogWrite.path "\*.log" {
                rlt := DateDiff(A_Now, A_LoopFileTimeCreated, "D")
                if (rlt > param) {
                    FileDelete(A_LoopFilePath)
                }
            }
        } catch Error As e{
            MsgBox(e.Message)
        }
    }
    static GetTimeAllStr() {
        return FormatTime(, "yyyy-MM-dd HH:mm:ss")
    }
    static GetTimeStr() {
        return FormatTime(, "yyyy-MM-dd")
    }
}