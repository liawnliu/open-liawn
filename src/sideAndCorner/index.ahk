class SideAndcorner {
    margin := 30
    sideFlag := 1
    __New() {
        this.CornerTimer := ObjBindMethod(this, "CornerTimerFunc")
        ;ProcessSetPriority("B")
        SetTimer(this.CornerTimer, 200)
        this.createHotKey()
    }
    createHotKey() {
        HotIf (*) => (this.sideFlag != 0)
        Hotkey("WheelDown", ObjBindMethod(this, "wheelDownFunc"))
        Hotkey("WheelUp", ObjBindMethod(this, "wheelUpFunc"))

        /* HotIf (*) => this.sideFlag == 0
         * Hotkey("WheelDown", "Off")
         Hotkey("WheelUp", "Off") */
    }
    CornerTimerFunc() {
        CoordMode("Mouse")
        x := 0, y := 0
        MouseGetPos(&x, &y)
        if (x < this.margin) {	; 靠近左边界了
            if (y < this.margin) {	; 左上角
                this.leftTopFunc()
                this.sideFlag := 0
            } else if (y > (A_ScreenHeight - this.margin)) {	; 左下角
                this.leftDownFunc()
                this.sideFlag := 0
            } else {	; 只在左边界
                this.sideFlag := 1
            }
        } else if (x > (A_ScreenWidth - this.margin)) {	; 靠近右边界了
            if (y < this.margin) {	; 右上角
                this.rightTopFunc()
                this.sideFlag := 0
            } else if (y > (A_ScreenHeight - this.margin)) {	; 右下角
                this.rightDownFunc()
                this.sideFlag := 0
            } else {	; 只在右边界
                this.sideFlag := 2
            }
        } else {
            if (y < this.margin) {	; 只在上边界
                this.sideFlag := 3
            } else if (y > (A_ScreenHeight - this.margin)) {	; 只在下边界
                this.sideFlag := 4
            } else {
                this.sideFlag := 0
            }
        }
    }
    ; 左上角
    leftTopFunc() {
        Send("#{Tab}")
    }
    ; 左下角
    leftDownFunc() {
        Send("^{Esc}")
    }
    ; 右上角
    rightTopFunc() {

    }
    ; 右下角
    rightDownFunc() {
        Send("#d")
    }
    wheelDownFunc(*) {
        sideFlag := this.sideFlag
        switch sideFlag {
            case 2: Send("{Volume_Down}")
            case 3:
                this.ChangeBrightness(this.GetCurrentBrightness() - 5)
            case 4: Send("^!{Tab}")
        }
    }
    wheelUpFunc(*) {
        sideFlag := this.sideFlag
        switch sideFlag {
            case 2: Send("{Volume_Up}")
            case 3:
                this.ChangeBrightness(this.GetCurrentBrightness() + 5)
            case 4: Send("^!+{Tab}")
        }
    }
    ; 改变亮度
    ChangeBrightness(brightness, timeout := 1) {
        brightness := Max(0, Min(brightness, 100))
        For property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
            property.WmiSetBrightness(timeout, brightness)
    }
    ; 获取目前亮度
    GetCurrentBrightness() {
        For property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness")
            Return property.CurrentBrightness
    }
}