#Include .\OpenProcessGui.ahk
#Include .\OpenProcessInputHook.ahk
#Include .\ToOpenProcess.ahk

class OpenProcess {
    static openProcessConfig := ""
    static processArr := ""
    static processHotKeyArr := ""
    __New() {
        this.initData()
        this.createHotKey()
    }
    initData() {
        OpenProcess.openProcessConfig := config["openProcess"]
        OpenProcess.processArr := []
        OpenProcess.processHotKeyArr := Map()
        
        For key, value in OpenProcess.openProcessConfig {
            processName := value["processName"]
            OpenProcess.processArr.Push(processName)
            ; 以"("分隔字符串，并清除首尾的")"
            nameArr := StrSplit(processName, "(", ")")
            if (nameArr.Length == 2) {
                processHotKey := nameArr[2]
                OpenProcess.processHotKeyArr[processHotKey] := A_Index
            }
        }
    }
    createHotKey() {
        ; 热键Alt + q
        Hotkey("!q", this.windowAndInputHook)
    }
    windowAndInputHook() {
        ; 预先创建一个InputHook；当OpenProcessGui创建并显示时加载这个InputHook，当OpenProcessGui销毁时卸载这个InputHook
        inHook := OpenProcessInputHook()
        ; 弹出OpenProcessGui界面
        OpenProcessGui(inHook)
    }
}
