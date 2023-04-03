Class OpenProcessGui extends Gui {
    ; 静态属性
    static hwnd := ""
    static selectItem := ""
    ; 成员属性
    myListBox := ""	; OpenProcessGuiL里只用了一个ListBox控件
    inHook := ""
    ; 构造函数
    __New(inHook) {
        ; 调用父类构造函数，只初始化最简单的配置
        Super.__New("+AlwaysOnTop -MaximizeBox +ToolWindow +Owner")
        this.inHook := inHook
        ; 一些稍微麻烦点的配置就不在父类里初始化了
        this.__InitWindow()
        ; OpenProcessInputHook可能需要这个GUI的hwnd
        OpenProcessGui.hwnd := this.hwnd
        ; 开启关联的InputHook
        this.inHook.Start()
    }
    ; 初始化配置，添加控件。process快捷打开哪些程序
    __InitWindow() {
        ; 设置字体
        this.SetFont("s15", "Verdana")
        ; 窗口透明只显示里面的控件
        this.BackColor := "EEAA99"
        WinSetTransColor("EEAA99", this)
        this.Opt("-Caption")
        ; 窗口透明结束
        ; 添加一个ListBox控件，r是多少行，r必须在这里指定，不能单独用Opt()来设置，并且受窗口Font的影响
        this.myListBox := this.Add("ListBox", "r" . OpenProcess.processArr.Length)
        ; 添加条目
        this.myListBox.Add(OpenProcess.processArr)
        ; 显示窗口
        this.Show()
        ; 外界想关闭窗口时，直接销毁而不是隐藏，因为我们的窗口时即用即删
        this.OnEvent("Close", this.ToDestroy)
        ; 控件失去焦点时隐藏OpenProcessGui
        this.myListBox.OnEvent("LoseFocus", this.ListLoseFocus)
        ; 控件值发生变化，要保存一下，InputHook在按下Enter时需要取它的值
        this.myListBox.OnEvent("Change", this.ListBoxChange)
        ; ListBox对于点击而言，单击事件没有，只有双击事件
        this.myListBox.OnEvent("DoubleClick", this.ListBoxDoubleClick)
    }
    ; 控件失去焦点时隐藏OpenProcessGui，不带param参数可能会报错
    ListLoseFocus(param) {
        ; 此时的this不是窗口了，而是控件，因为该事件是控件本身触发的而不是窗口
        if (this.Gui) {
            this.Gui.ToDestroy()
        }
    }
    ListBoxDoubleClick(param) {
        ; 此时的this不是窗口了，而是控件，因为该事件是控件本身触发的而不是窗口
        if (this.Gui) {
            this.Gui.inHook.HandleEnterAndClick()
        }
    }
    ListBoxChange(*) {
        ; 此时的this不是窗口了，而是控件，因为该事件是控件本身触发的而不是窗口
        OpenProcessGui.selectItem := this.Value
    }
    ToDestroy() {
        ; 关闭关联的InputHook
        this.inHook.Stop()
        this.Destroy()
    }
}
