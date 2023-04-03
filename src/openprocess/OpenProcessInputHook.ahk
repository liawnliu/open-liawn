class OpenProcessInputHook extends InputHook {
    __New() {
        super.__New()
        ; 监听所有的按键
        this.KeyOpt("{All}", "+N")
        ; 按下键时的回调
        this.OnKeyDown := this.HandleKeyDown
    }
    HandleKeyDown(vk, sc) {
        if (vk == 13) {	; Enter
            this.HandleEnterAndClick()
        } else if (vk == 20 || vk == 160 || vk == 40 || vk == 38) {
            return
        } else {
            if (vk || sc) {
                this.handleInputKey(vk, sc)
            }
        }
        this.Stop()
        if (WinExist(OpenProcessGui.hwnd)) {
            WinKill
        }
    }
    handleInputKey(vk := "", sc := "") {
        For key, value in OpenProcess.processHotKeyArr {
            processVk := vk ? GetKeyVK(key) : 0
            processSc := sc ? GetKeySC(key) : 0
            if (processVk == vk || processSc == sc) {
                this.getProcessNameAndPath(value)
                break
            }
        }
    }
    HandleEnterAndClick() {
        this.getProcessNameAndPath(OpenProcessGui.selectItem)
    }
    getProcessNameAndPath(index) {
        LogWrite.Info("getProcessNameAndPath: " index)
        tempObj := OpenProcess.openProcessConfig[index]
        ; 这里处理时不要带上.exe后缀也不要带上()，因为窗口标题一般不带这些
        processName := StrSplit(tempObj["processName"], "(", ")")[1]
        processPath := tempObj["processPath"]
        OpenWindow(processName, processPath)
    }
    
}
