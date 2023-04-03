; 以管理员权限运行脚本
/* full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
} */


; 所在版本AutoHotkey_2.0-beta.3
; 引入库、工具文件
#Include .\util\JSON.ahk
#Include .\util\LogWrite.ahk
#Include .\util\TrayIcon.ahk
#Include .\util\MyGdip.ahk
; 引入业务入口文件
#Include .\src\openprocess\index.ahk
#Include .\src\gesture\index.ahk
#Include .\src\sideAndCorner\index.ahk

#SingleInstance Force
A_FileEncoding := "UTF-8"

; 每次程序启动，都默认清空一个星期前的日志
try {
    LogWrite.ClearWeekLog()
    ; 全局变量。当被赋值的局部变量的名称与全局变量的名称重合时, 可以保护脚本免受意外的副作用
    configFileObj := FileOpen(A_WorkingDir "\config\config.ini", "r", "UTF-8")
    global configStr := configFileObj.Read() ; FileRead(A_WorkingDir "\config\config.ini")
    global config := Jxon_load(configStr)
    gestureFileObj := FileOpen(A_WorkingDir "\config\gesture.ini", "r", "UTF-8")
    global gestureConfigStr := gestureFileObj.read() ; FileRead(A_WorkingDir "\config\gesture.ini")
    global gestureConfig := Jxon_load(gestureConfigStr)
    OpenProcess()
    Gesture()
    SideAndcorner()
} catch Error As e {
    LogWrite.ErrorBox(e)
}
