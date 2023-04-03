class GestureGui extends GUI {
    ; 文字固定到面板显示keepTime就自动关闭画板，只执行一次所以是负数
    keepTime := Gesture.gestureIniConfig["keepTime"] * (-1)
    ; 画笔颜色
    penColor := Gesture.gestureIniConfig["penColor"]
    ; 画笔粗细
    penWidth := Gesture.gestureIniConfig["penWidth"]
    ; 是添加手势模式还是识别手势去打开程序模式
    addGestureMode := Gesture.gestureIniConfig["addGestureMode"]
    ; 画线过程中，旧有的那个点
    pointOne := Map("x", 0, "y", 0)
    ; 画线过程中，最新的那个点；pointOne和pointTwo只用于画线
    pointTwo := Map("x", 0, "y", 0)
    ; 所有画在图上的坐标
    drawPoints := []
    width := A_ScreenWidth
    height := A_ScreenHeight
    ; 手势分析器
    analyze := ""
    ; 添加新手势的询问框
    askNewGestureGui := ""
    __New() {
        ; 调用父类构造函数，只初始化最简单的配置，E0x80000表示它是一个分层窗口
        Super.__New("-Caption +E0x80000 +AlwaysOnTop +ToolWindow +OwnDialogs")
        
        ; 解决画线与实际鼠标位置错开的问题
        CoordMode("Mouse")
        ; 脚本退出时销户画板有关工具
        OnExit(ObjBindMethod(this, "toDestroy"))
        ; 使用ObjBindMethod能单独把timer给拎出来，那就可以使用定时器重置了
        this.startTimer := ObjBindMethod(this, "startTimerFun")
        this.closePanelTimer := ObjBindMethod(this, "closePanelTimerFun")
        ; 初始化画板
        this.initDrawBoard()
    }
    toHide() {
        UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, 0, 0)
        ; 不用的时候删除笔
        Gdip_DeletePen(this.pPen)
        ; 不用的时候隐藏GUI
        this.hide()
    }
    toDestroy() {
        ; 画板工具清空
        SelectObject(this.hdc, this.obm)
        DeleteDC(this.hdc)
        Gdip_DeleteGraphics(this.G1)
        Gdip_DeleteGraphics(this.G2)
        DeleteObject(this.hbm)
        DeleteObject(this.pBitmap)
        Gdip_Shutdown(this.pToken)
    }
    initDrawBoard() {
        ; 不调Gdip_Startup可能会没反应
        this.pToken := Gdip_Startup()
        ;this.Show("NA")
        ; 创建一个 gdi 位图，其宽度和高度与我们要绘制的内容相同。 这是所有东西的整个绘图区域
        this.hbm := CreateDIBSection(this.width, this.height)
        ; 单独创建一个pBitmap，用于解决Gdip_CreateBitmapFromHBITMAP转换背景是黑色的问题
        this.pBitmap := Gdip_CreateBitmap(this.width, this.height)
        ; 获取与屏幕兼容的设备上下文
        this.hdc := CreateCompatibleDC()
        ; 选择位图进入设备上下文
        this.obm := SelectObject(this.hdc, this.hbm)
        ; 获取指向位图图形的指针，用于绘图函数
        this.G1 := Gdip_GraphicsFromHDC(this.hdc)
        ; Gdip_CreateARGBBitmapFromHBITMAP转换为黑色的缘故，不得不给新建的pBitmap加Graphics
        this.G2 := Gdip_GraphicsFromImage(this.pBitmap)
        ; 将平滑模式设置为 antialias = 4 使形状看起来更平滑（仅用于矢量绘制和填充）
        Gdip_SetSmoothingMode(this.G1, 4)
        Gdip_SetSmoothingMode(this.G2, 4)
        ; 画笔
        this.pPen := Gdip_CreatePen(this.penColor, this.penWidth)
        ; 让画板在多少毫秒后消失
        ; SetTimer(this.closePanelTimer, this.keepTime)
    }
    drawLine() {
        x := 0, y := 0
        ; 将RBUTTON按住状态，将最新坐标赋给pointTwo；上一次的pointTwo在每轮循环结束前交给了pointOne
        if (GetKeyState("RButton", "P")) {
            MouseGetPos(&x, &y)
            this.pointTwo["x"]:= x
            this.pointTwo["y"] := y
        } else {
            ; 按键已释放，pointOne和pointTwo要进行重置。后面可能要接着画，所以数据得清干净
            this.pointOne["x"] := 0
            this.pointOne["y"] := 0
            this.pointTwo["x"] := 0
            this.pointTwo["y"] := 0
        }
        ; 坐标不合法就跳过这一次
        if ((!this.pointOne["x"] && !this.pointOne["y"]) || (!this.pointTwo["x"] && !this.pointTwo["y"])) {
            this.pointOne["x"] := this.pointTwo["x"]
            this.pointOne["y"] := this.pointTwo["y"]
            return
        }
        ; 两个坐标合法并且它们不一样，就画线
        if (this.pointOne["x"] != this.pointTwo["x"] || this.pointOne["y"] != this.pointTwo["y"]) {
            ; pointOne是老坐标，pointTwo是新坐标，由老坐标指向新坐标
            Gdip_DrawLine(this.G1, this.pPen, this.pointOne["x"], this.pointOne["y"], this.pointTwo["x"], this.pointTwo["y"])
            Gdip_DrawLine(this.G2, this.pPen, this.pointOne["x"], this.pointOne["y"], this.pointTwo["x"], this.pointTwo["y"])
            ; 使用位图 (hdc) 的句柄更新我们创建的指定窗口 (hwnd)，指定 x,y,w,h 我们希望它定位在我们的屏幕上
            ; 所以这会将我们的 gui 定位在 (0,0) 与之前指定的宽度和高度
            UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, this.width, this.height)
            this.Show()
            ; 将新坐标放到drawPoints
            this.drawPoints.Push(Map("x", this.pointOne["x"], "y", this.pointOne["y"]))
            ; 画出新线时重置画板消失的时间
            if (!this.closePanelTimer) {
                ; 对应的timer要是不见了就重新绑定
                this.closePanelTimer := ObjBindMethod(this, "closePanelTimerFun")
            }
            ; 重置画板消失的时间
            SetTimer(this.closePanelTimer, this.keepTime)
        }
        ; 老坐标在每轮循环结束前交给了pointOne
        this.pointOne["x"] := this.pointTwo["x"]
        this.pointOne["y"] := this.pointTwo["y"]
    }
    ; 销毁画板，下次启动再新建就好了
    closePanelTimerFun() {
        LogWrite.Info("收尾")
        Gesture.drawFlag := 0
        ; 正常的情况并且划线足够长，就分析手势
        ; 询问窗口是不会让执行流程停下来的，所以SimilarityRltFlag为true时还不能立即清理
        SimilarityRltFlag := false
        if (this.drawPoints.length > 2) {
            ; 初始化分析器
            this.analyze := GestureAnalyze()
            ; 获取有效区域的具体边界信息
            checkAreaRlt := this.analyze.checkAreaByDrawPoints(this.drawPoints)
            ; 判断有效区域是否足够大，标准暂时是150
            checkEnougRlt := this.analyze.isEnoughArea(checkAreaRlt)
            ; 足够大就分析轨迹
            if (checkEnougRlt) {
                ; 分析轨迹，获取当前画线的手势信息
                gestureMsg := this.analyze.analysisDrawPoints(this.drawPoints)
                ; gestureMsg要有效
                if (gestureMsg) {
                    ; 让当前的手势信息与本地存储的所有手势信息进行一一比对
                    SimilarityRlt := this.analyze.checkSimilarity(gestureMsg)
                    ; 相似的话
                    if (SimilarityRlt) {
                        ; 打开对应的程序
                        this.toOpenProcess(SimilarityRlt)
                        LogWrite.Info("匹配成功")
                    } else {
                        ; 没有一个相似的，并且开启了手势保存，就保存它
                        if (this.addGestureMode) {
                            ; 询问状态，为true表示正在询问，面板要等询问完之后才能清理
                            SimilarityRltFlag := true
                            ; 询问是否添加新手势弹窗
                            this.askNewGesture()
                        } else {
                            LogWrite.Info("没有相似的，并且也没有开启保存新手势功能")
                        }
                    }
                }
            }
        }
        ; 除了询问，其他情况都要立即销毁画板
        if (!SimilarityRltFlag) {
            this.toClosePanel()
        }
    }
    toClosePanel() {
        this.Show("NA")
        ; 坐标相关内容清空
        this.drawPoints := []
        this.pointOne.x := 0
        this.pointOne.y := 0
        this.pointTwo.x := 0
        this.pointTwo.y := 0
        ; 画板工具清空
        SelectObject(this.hdc, this.obm)
        DeleteDC(this.hdc)
        Gdip_DeleteGraphics(this.G1)
        Gdip_DeleteGraphics(this.G2)
        ; Now the bitmap may be deleted
        DeleteObject(this.hbm)
        DeleteObject(this.pBitmap)
        Gdip_Shutdown(this.pToken)
        SetTimer(this.closePanelTimer, 0)
        LogWrite.Info("已收尾")
        this.Destroy()
    }
    ; 询问是否增加新手势
    askNewGesture() {
        this.askNewGestureGui := Gui("+AlwaysOnTop -MaximizeBox +ToolWindow +Owner +OwnDialogs", "请输入新手势的keyName")
        MyEdit := this.askNewGestureGui.AddEdit("Limit10 -Multi Uppercase")
        MyEdit.Name := "MyEdit"
        MyBtn := this.askNewGestureGui.AddButton("Default w80", "OK")
        MyBtn.OnEvent("Click", ObjBindMethod(this, "askNewGestureOkBtn")) 
        this.askNewGestureGui.OnEvent("Close", ObjBindMethod(this, "askNewGestureCloseBtn")) 
        this.askNewGestureGui.Show()
    }
    ; 不增加新手势
    askNewGestureCloseBtn(*) {
        this.askNewGestureGui.destroy()
        ; 解决点击OK报0xc000005的问题，也就是询问时还不能删除画板
        this.toClosePanel()
    }
    ; 同意增加新手势
    askNewGestureOkBtn(*) {
        ; 还得检查重名
        newKeyName := this.askNewGestureGui["MyEdit"].value
        if (newKeyName) {
            ; 保存新手势信息
            this.analyze.toSaveMsg(newKeyName, this.analyze.gestureMsg)
            ; 以及保存新手势图
            newBitmap := this.analyze.handleGestureImg(this.pBitmap, this.analyze.checkAreaRlt)
            this.analyze.toSaveImg(newBitmap, A_WorkingDir "\image\gesture\" newKeyName ".png")
            LogWrite.Info("新手势保存成功")
        } else {
            LogWrite.Info("新手势保存失败")
        }
        this.askNewGestureGui.destroy()
        ; 解决点击OK报0xc000005的问题，也就是询问时还不能删除画板
        this.toClosePanel()
    }
    ; 匹配成功，去打开相应的程序
    toOpenProcess(key) {
        ; 匹配成功，拿到了gesture数据表里的key，再通过key去拿openProcess表里的程序启动路径
        processArr := config["openProcess"]
        Loop processArr.Length {
            processName := processArr[A_Index]["processName"]
            strArr := StrSplit(processName, "(", ")")
            ; 该程序有对应的hotkey（按理说不应是hotkey，待优化）
            if (strArr.length == 2 && strArr[2]) {
                str1 := StrUpper(strArr[2])
                str2 := StrUpper(key)
                if (str1 == str2) {
                    processPath := processArr[A_Index]["processPath"]
                    OpenWindow(processName, processPath)
                }
            }
        }
    }
}