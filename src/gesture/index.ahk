#Include ./GestureGui.ahk
#Include ./GestureAnalyze.ahk

class Gesture {
    static gestureIniConfig := ""
    static gestureMsgConfig := ""
    ; 0原始状态，1正在画
    static drawFlag := 0
    ; 0原始状态，1正在正在检查，2检查完
    static isChcking := 0
    ; 鼠标按下启动画板，最初的那个点；pointStart和pointTemp是主要用于判断是否要“放行”原始鼠标右键
    pointStart := Map("x", 0, "y", 0)
    ; 临时的坐标
    pointTemp := Map("x", 0, "y", 0)
    ; 每隔penInterval检查现在坐标和上一个坐标的差，千万不要取0，会报错
    penInterval := 0
    lengthStandard := 0
    ; 右键按下checkTime后，如果长度还小于lenStan（40）就结束画板，“放行”原始鼠标右键
    checkTime := 0
    gestureGuiIns := ""
    __New() {
        this.initData()
        ; 先准备好画板，让它隐藏，在热键触发时才可能出现；当然，它本身是透明的，只说能否画线取决于某些条件
        this.gestureGuiIns := GestureGui()
        this.createHotKey()
    }
    initData() {
        Gesture.gestureIniConfig := config["gesture"]
        Gesture.gestureMsgConfig := gestureConfig["gesture"]
        this.penInterval := Gesture.gestureIniConfig["penInterval"]
        this.checkTime := Gesture.gestureIniConfig["checkTime"]
        this.lengthStandard := Gesture.gestureIniConfig["lengthStandard"]
    }
    createHotKey() {
        Hotkey("RButton", ObjBindMethod(this, "mouseRDown"))
    }
    mouseRDown(*) {
        LogWrite.Info("mouseRDown Gesture.drawFlag" Gesture.drawFlag "Gesture.isChcking" Gesture.isChcking)
        if (!Gesture.drawFlag && !Gesture.isChcking) {
            LogWrite.Info("1mouseRDown" Gesture.drawFlag "Gesture.drawFlag" Gesture.isChcking)
            x := 0, y := 0
            if (GetKeyState("RButton", "P")) { ; 还是按住的状态
                MouseGetPos(&x, &y)
            }
            if (!x && !y) { ; 位置不对
                Send("{RButton}")
                LogWrite.Info("没有按住，打断while")
                return
            }
            ; 前面正常，那就保存最初的这个点
            this.pointStart["x"] := x
            this.pointStart["y"] := y
            ; 到了第几次检查长度
            tempNum := Ceil(this.checkTime / this.penInterval)
            ; 用while循环来画线
            while (true) {
                LogWrite.Info("mouseRDown while" Gesture.drawFlag "Gesture.drawFlag" Gesture.isChcking "tempNum" tempNum "A_Index" A_Index)
                
                ; 到了指定时间需要进行检查长度，从开始到检查这段时间还不能画线
                if (!Gesture.isChcking && tempNum == A_Index) {
                    Gesture.isChcking := 1 ; 置为1，表示正在检查
                    x := 0, y := 0
                    if (GetKeyState("RButton", "P")) { ; 还是按住的状态
                        MouseGetPos(&x, &y)
                    }
                    if (!x && !y) { ; 没有按住了，就提前打断while，并把右击发送出去，两个状态重置为0
                        Send("{RButton}")
                        Gesture.isChcking := 0 ; 已经检查完毕，重置为0
                        Gesture.drawFlag := 0 ; 检查没通过，重置为0
                        LogWrite.Info("后续没有按住了，打断while")
                        break
                    } else { ; 是按住的，那就进一步检查长度
                        ; 前面正常，那就保存目前的这个点
                        this.pointTemp["x"] := x
                        this.pointTemp["y"] := y
                        LogWrite.Info("检查长度1 this.pointStart X" this.pointStart["x"] "this.pointStart Y" this.pointStart["y"])
                        LogWrite.Info("检查长度2 this.pointTemp X" this.pointTemp["x"] "this.pointTemp Y" this.pointTemp["y"])
                        absX := Abs(this.pointStart["x"] - this.pointTemp["x"])
                        absY := Abs(this.pointStart["y"] - this.pointTemp["y"])
                        absL := Sqrt(absX * absX + absY * absY)
                        LogWrite.Info("检查长度3 absL2" absL "lengthStandard" this.lengthStandard)
                        ; 直线距离还小于lengthStandard就提前打断while，并把右击发送出去，两个状态重置为0
                        if (absL < this.lengthStandard) { 
                            Send("{RButton}")
                            Gesture.isChcking := 0 ; 已经检查完毕，重置为0
                            Gesture.drawFlag := 0 ; 检查没通过，重置为0
                            LogWrite.Info("还是按住的，但长度不够，打断while")
                            break
                        } else { ; 还是按住的，并且长度也合适
                            Gesture.isChcking := 2 ; 已经检查完毕，重置为2
                            Gesture.drawFlag := 1 ; 检查通过，状态置为1，表示正在画（包括启动画板和drawLine）
                            ; 启动画板、画笔等，准备画线
                            this.gestureGuiIns := GestureGui()                                                                                                                                         
                        }
                    }
                }
                ; 检查完了并且是正在画的状态
                if (Gesture.isChcking == 2 && Gesture.drawFlag == 1 && this.gestureGuiIns) {
                    LogWrite.Info("检查完了并且是正在画的状态 Gesture.drawFlag" Gesture.drawFlag "Gesture.isChcking" Gesture.isChcking)
                    ; 去画
                    this.gestureGuiIns.drawLine()
                }
                ; 检查完了也画完了就打断while
                if (Gesture.isChcking == 2 && !Gesture.drawFlag) {
                    Gesture.isChcking := 0
                    LogWrite.Info("画完了，打断while")
                    break
                }
                Sleep(this.penInterval) ; 每隔penInterval就循环一次
            }
        }
    }
}