; ----------------------------------------------------------------------------------------------------------------------
; Name ..........: TrayIcon library
; Description ...: Provide some useful functions to deal with Tray icons.
; AHK Version ...: AHK_L 1.1.22.02 x32/64 Unicode
; Original Author: Sean (http://goo.gl/dh0xIX) (http://www.autohotkey.com/forum/viewtopic.php?t=17314)
; Update Author .: Cyruz (http://ciroprincipe.info) (http://ahkscript.org/boards/viewtopic.php?f=6&t=1229)
; Mod Author ....: Fanatic Guru
; License .......: WTFPL - http://www.wtfpl.net/txt/copying/
; Version Date...: 2019 04 04
; Note ..........: Many people have updated Sean's original work including me but Cyruz's version seemed the most straight
; ...............: forward update for 64 bit so I adapted it with some of the features from my Fanatic Guru version.
; Update 20160120: Went through all the data types in the DLL and NumGet and matched them up to MSDN which fixed IDcmd.
; Update 20160308: Fix for Windows 10 NotifyIconOverflowWindow
; Update 20180313: Fix problem with "VirtualFreeEx" pointed out by nnnik
; Update 20180313: Additional fix for previous Windows 10 NotifyIconOverflowWindow fix breaking non-hidden icons
; Update 20190404: Added TrayIcon_Set by Cyruz
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function ......: TrayIcon_GetInfo
; Description ...: Get a series of useful information about tray icons.
; Parameters ....: sExeName  - The exe for which we are searching the tray icon data. Leave it empty to receive data for
; ...............:             all tray icons.
; Return ........: oTrayIcon_GetInfo - An array of objects containing tray icons data. Any entry is structured like this:
; ...............:             oTrayIcon_GetInfo[A_Index].idx     - 0 based tray icon index.
; ...............:             oTrayIcon_GetInfo[A_Index].IDcmd   - Command identifier associated with the button.
; ...............:             oTrayIcon_GetInfo[A_Index].pID     - Process ID.
; ...............:             oTrayIcon_GetInfo[A_Index].uId     - Application defined identifier for the icon.
; ...............:             oTrayIcon_GetInfo[A_Index].msgId   - Application defined callback message.
; ...............:             oTrayIcon_GetInfo[A_Index].hIcon   - Handle to the tray icon.
; ...............:             oTrayIcon_GetInfo[A_Index].hWnd    - Window handle.
; ...............:             oTrayIcon_GetInfo[A_Index].Class   - Window class.
; ...............:             oTrayIcon_GetInfo[A_Index].Process - Process executable.
; ...............:             oTrayIcon_GetInfo[A_Index].Tray    - Tray Type (Shell_TrayWnd or NotifyIconOverflowWindow).
; ...............:             oTrayIcon_GetInfo[A_Index].tooltip - Tray icon tooltip.
; Info ..........: TB_BUTTONCOUNT message - http://goo.gl/DVxpsg
; ...............: TB_GETBUTTON message   - http://goo.gl/2oiOsl
; ...............: TBBUTTON structure     - http://goo.gl/EIE21Z
; ----------------------------------------------------------------------------------------------------------------------

TrayIcon_GetInfo(sExeName := "") {
    Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    oTrayIcon_GetInfo := []
    For key, sTray in ["Shell_TrayWnd", "NotifyIconOverflowWindow"] {
        idxTB := TrayIcon_GetTrayBar(sTray)
        pidTaskbar := WinGetPID("ahk_class " sTray)

        hProc := DllCall("OpenProcess", "UInt", 0x38, "Int", 0, "UInt", pidTaskbar)
        pRB := DllCall("VirtualAllocEx", "Ptr", hProc, "Ptr", 0, "UPtr", 20, "UInt", 0x1000, "UInt", 0x4)

        res := SendMessage(0x418, 0, 0, "ToolbarWindow32" idxTB, "ahk_class " sTray)	; TB_BUTTONCOUNT

        btn := Buffer(A_Is64bitOS ? 32 : 20, 0)
        nfo := Buffer(A_Is64bitOS ? 32 : 24, 0)
        tip := Buffer(128 * 2, 0)

        Loop res {
            SendMessage(0x417, A_Index - 1, pRB, "ToolbarWindow32" idxTB, "ahk_class " sTray) ; TB_GETBUTTON 
            DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", pRB, "Ptr", btn.Ptr, "UPtr", btn.Size, "UPtr", 0)

            iBitmap := NumGet(btn, 0, "Int")
            IDcmd := NumGet(btn, 4, "Int")
            ;statyle := NumGet(btn, 8, "UPtr")
            dwData := NumGet(btn, (A_Is64bitOS ? 16 : 12), "UPtr")
            iString := NumGet(btn, (A_Is64bitOS ? 24 : 16), "Ptr")

            DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", dwData, "Ptr", nfo.Ptr, "UPtr", nfo.Size, "UPtr", 0)

            hWnd := NumGet(nfo, 0, "Ptr")
            uId := NumGet(nfo, (A_Is64bitOS ? 8 : 4), "UInt")
            msgId := NumGet(nfo, (A_Is64bitOS ? 12 : 8), "UPtr")
            hIcon := NumGet(nfo, (A_Is64bitOS ? 24 : 20), "Ptr")

            pID := WinGetPID("ahk_id " hWnd)
            sProcess := WinGetProcessName("ahk_id " hWnd)
            sClass := WinGetClass("ahk_id " hWnd)

            If !sExeName || (sExeName = sProcess) || (sExeName = pID) {
                DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", iString, "Ptr", tip.Ptr, "UPtr", tip.Size, "UPtr", 0)
                oTrayIcon_GetInfo.Push(Map("idx", A_Index - 1
                    , "idcmd", idCmd
                    , "pid", pID
                    , "uid", uId
                    , "msgid", msgId
                    , "hicon", hIcon
                    , "hwnd", hWnd
                    , "class", sClass
                    , "process", sProcess
                    , "tooltip", StrGet(tip.Ptr, "UTF-16")
                    , "tray", sTray))
            }
        }
        DllCall("VirtualFreeEx", "Ptr", hProc, "Ptr", pRB, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hProc)
    }
    DetectHiddenWindows(Setting_A_DetectHiddenWindows)
    Return oTrayIcon_GetInfo
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Hide
; Description ..: Hide or unhide a tray icon.
; Parameters ...: IDcmd - Command identifier associated with the button.
; ..............: bHide - True for hide, False for unhide.
; ..............: sTray - 1 or Shell_TrayWnd || 0 or NotifyIconOverflowWindow.
; Info .........: TB_HIDEBUTTON message - http://goo.gl/oelsAa
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Hide(IDcmd, sTray := "Shell_TrayWnd", bHide := True)
{
    ; (sTray == 0 ? sTray := "NotifyIconOverflowWindow" : sTray == 1 ? sTray := "Shell_TrayWnd" : )
    if (sTray == 0) {
        sTray := "NotifyIconOverflowWindow"
    } else if (sTray == 1) {
        sTray := "Shell_TrayWnd"
    }
    Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    idxTB := TrayIcon_GetTrayBar()
    SendMessage(0x0404, idCmd, bHide, "ToolbarWindow32" idxTB, "ahk_class " sTray) ; TB_HIDEBUTTON
    SendMessage(0x001A, 0, 0, , "ahk_class " sTray)
    DetectHiddenWindows(Setting_A_DetectHiddenWindows)
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Delete
; Description ..: Delete a tray icon.
; Parameters ...: idx - 0 based tray icon index.
; ..............: sTray - 1 or Shell_TrayWnd || 0 or NotifyIconOverflowWindow.
; Info .........: TB_DELETEBUTTON message - http://goo.gl/L0pY4R
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Delete(idx, sTray := "Shell_TrayWnd")
{
    ; (sTray == 0 ? sTray := "NotifyIconOverflowWindow" : sTray == 1 ? sTray := "Shell_TrayWnd" : )
    if (sTray == 0) {
        sTray := "NotifyIconOverflowWindow"
    } else if (sTray == 1) {
        sTray := "Shell_TrayWnd"
    }
    Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    idxTB := TrayIcon_GetTrayBar()
    SendMessage(0x0416, idx, 0, "ToolbarWindow32" idxTB, "ahk_class " sTray) ; TB_DELETEBUTTON
    SendMessage(0x001A, 0, 0, , "ahk_class " sTray)
    DetectHiddenWindows(Setting_A_DetectHiddenWindows)
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Remove
; Description ..: Remove a tray icon.
; Parameters ...: hWnd, uId.
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Remove(hWnd, uId) {
    NID := Buffer(2 * 384 + A_PtrSize * 5 + 40, 0)
    NumPut("UPtr", NID.Size, NID)
    NumPut("UPtr", hWnd, NID, A_PtrSize)
    NumPut("UPtr", uId, NID, A_PtrSize * 2)
    return DllCall("Shell32.dll\Shell_NotifyIcon", "UInt", 0x2, "UInt", NID.Ptr)
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Move
; Description ..: Move a tray icon.
; Parameters ...: idxOld - 0 based index of the tray icon to move.
; ..............: idxNew - 0 based index where to move the tray icon.
; ..............: sTray - 1 or Shell_TrayWnd || 0 or NotifyIconOverflowWindow.
; Info .........: TB_MOVEBUTTON message - http://goo.gl/1F6wPw
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Move(idxOld, idxNew, sTray := "Shell_TrayWnd")
{
    ; (sTray == 0 ? sTray := "NotifyIconOverflowWindow" : sTray == 1 ? sTray := "Shell_TrayWnd" : )
    if (sTray == 0) {
        sTray := "NotifyIconOverflowWindow"
    } else if (sTray == 1) {
        sTray := "Shell_TrayWnd"
    }
    Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    idxTB := TrayIcon_GetTrayBar()
    SendMessage(0x452, idxOld, idxNew, "ToolbarWindow32" idxTB, "ahk_class " sTray) ; TB_MOVEBUTTON
    DetectHiddenWindows(Setting_A_DetectHiddenWindows)
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Set
; Description ..: Modify icon with the given index for the given window.
; Parameters ...: hWnd       - Window handle.
; ..............: uId        - Application defined identifier for the icon.
; ..............: hIcon      - Handle to the tray icon.
; ..............: hIconSmall - Handle to the small icon, for window menubar. Optional.
; ..............: hIconBig   - Handle to the big icon, for taskbar. Optional.
; Return .......: True on success, false on failure.
; Info .........: NOTIFYICONDATA structure  - https://goo.gl/1Xuw5r
; ..............: Shell_NotifyIcon function - https://goo.gl/tTSSBM
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Set(hWnd, uId, hIcon, hIconSmall := 0, hIconBig := 0)
{
    d := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    ; WM_SETICON = 0x0080
    If (hIconSmall)
        SendMessage(0x0080, 0, hIconSmall, , "ahk_id " hWnd) ; WM_SETICON
    If (hIconBig)
        SendMessage(0x0080, 1, hIconBig, , "ahk_id " hWnd) ; WM_SETICON
    DetectHiddenWindows(d)

    NID := Buffer(2 * 384 + A_PtrSize * 5 + 40, 0)
    NumPut("UPtr", NID.Size, NID, 0)
    NumPut("UPtr", hWnd, NID, (A_PtrSize == 4) ? 4 : 8)
    NumPut("UPtr", uId, NID, (A_PtrSize == 4) ? 8 : 16)
    NumPut("UPtr", 2, NID, (A_PtrSize == 4) ? 12 : 20)
    NumPut("UPtr", hIcon, NID, (A_PtrSize == 4) ? 20 : 32)

    ; NIM_MODIFY := 0x1
    return DllCall("Shell32.dll\Shell_NotifyIcon", "UInt", 0x1, "Ptr", NID.Ptr)
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_GetTrayBar
; Description ..: Get the tray icon handle.
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_GetTrayBar(Tray := "Shell_TrayWnd") {
    nTB := ""
    idxTB := ""
    Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    ControlList := WinGetControls("ahk_class " Tray)
    for str in ControlList {
        if RegExMatch(str, "(?<=ToolbarWindow32)\d+(?!.*ToolbarWindow32)", &nTB) {
            loop nTB[] {
                hWnd := ControlGetHwnd("ToolbarWindow32" A_Index, "ahk_class " Tray)
                hParent := DllCall("GetParent", "Ptr", hWnd)
                sClass := WinGetClass("ahk_id " hParent)
                If !(sClass == "SysPager" || sClass = "NotifyIconOverflowWindow")
                    Continue
                idxTB := A_Index
                Break
            }
        }
    }
    DetectHiddenWindows(Setting_A_DetectHiddenWindows)
    Return idxTB
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_GetHotItem
; Description ..: Get the index of tray's hot item.
; Info .........: TB_GETHOTITEM message - http://goo.gl/g70qO2
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_GetHotItem()
{
    idxTB := TrayIcon_GetTrayBar()
    ; TB_GETHOTITEM
    rlt := SendMessage(0x0447, 0, 0, "ToolbarWindow32" idxTB, "ahk_class Shell_TrayWnd")
    return  rlt << 32 >> 32
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Button
; Description ..: Simulate mouse button click on a tray icon.
; Parameters ...: sExeName - Executable Process Name of tray icon.
; ..............: sButton  - Mouse button to simulate (L, M, R).
; ..............: bDouble  - True to double click, false to single click.
; ..............: index    - Index of tray icon to click if more than one match.
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Button(sExeName, sButton := "L", bDouble := false, index := 1)
{
    Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    actions := Map("WM_MOUSEMOVE", 0x0200, "WM_LBUTTONDOWN", 0x0201, "WM_LBUTTONUP", 0x0202
            , "WM_LBUTTONDBLCLK", 0x0203, "WM_RBUTTONDOWN", 0x0204, "WM_RBUTTONUP", 0x0205
            , "WM_RBUTTONDBLCLK", 0x0206, "WM_MBUTTONDOWN", 0x0207, "WM_MBUTTONUP", 0x0208
            , "WM_MBUTTONDBLCLK", 0x0209)
    sButton := "WM_" sButton "BUTTON" ; 将L或者R拼进来
    oIcons := TrayIcon_GetInfo(sExeName)
    if (!oIcons.Length) {
        LogWrite.Error("TrayIcon_Button Error oIcons is []")
        DetectHiddenWindows(Setting_A_DetectHiddenWindows)
        return false
    }
    msgId := oIcons[index]["msgid"]
    uId := oIcons[index]["uid"]
    hWnd := oIcons[index]["hwnd"]
    if (bDouble) {
        ; 将后缀再拼进来
        PostMessage(msgId, uId, actions[sButton "DBLCLK"], , "ahk_id " hWnd)
    } else {
        PostMessage(msgId, uId, actions[sButton "DOWN"], , "ahk_id " hWnd)
        PostMessage(msgId, uId, actions[sButton "UP"], , "ahk_id " hWnd)
    }
    DetectHiddenWindows(Setting_A_DetectHiddenWindows)
    return true
}