;------------------------------------
;  简单可视化鼠标手势 v1.5  By FeiYue
;------------------------------------

#NoEnv
#SingleInstance, force
SetWinDelay -1
SetBatchLines , -1
CoordMode , Mouse
CoordMode , ToolTip
生成画板()
tip := {0: 0, "上": "上翻页", "下": "下翻页", "左": "后退", "右": "前进", "右下左": "退出", 0: 0}
return

上: 下: 左: 右: k := A_ThisLabel
MsgBox , 4096, , % k " > " tip[k], 1
return

右下左: ExitApp

Esc:: ExitApp

start_01()
{
    static init := start_01()
    SetTitleMatchMode , 2	;//匹配部分标题
    GroupAdd , MyBrowser, 360安全浏览器
    GroupAdd , MyBrowser, 360极速浏览器
    GroupAdd , MyBrowser, 搜狗高速浏览器
    GroupAdd , MyBrowser, 世界之窗浏览器
    GroupAdd , MyBrowser, 2345加速浏览器
    GroupAdd , MyBrowser, GreenBrowser
    GroupAdd , MyBrowser, Firefox
    GroupAdd , MyBrowser, Chrome
    GroupAdd , MyBrowser, ahk_class IEFrame
    GroupAdd , MyBrowser, ahk_class 360se5_Frame
    GroupAdd , MyBrowser, ahk_class 360se6_Frame
    GroupAdd , MyBrowser, ahk_class Chrome_WidgetWin_1
    GroupAdd , MyBrowser, ahk_class ShockwaveFlashFullScreen
}

#if !WinActive("ahk_group MyBrowser")

RButton::
显示画板(), 轨迹 := 方向 := 上次方向 := "", arr := []
MouseGetPos , x1, y1
while GetKeyState("RButton", "P") {
    Sleep , 10
    MouseGetPos , x2, y2
    loop , % (i := arr.MaxIndex()) > 10 ? 10 : i
        if ((dx := x2 - arr[i].3) * 0 + (dy := y2 - arr[i--].4) * 0 + Abs(dx) > 5 or Abs(dy) > 5) {
            r := (dx = 0) ? 90 : Round(ATan(Abs(dy / dx)) / (ATan(1) / 45), 1)
            r := (dx >= 0) ? (dy <= 0 ? r : 360 - r) : (dy <= 0 ? 180 - r : 180 + r)
            方向 := (r >= 360 - 30 || r <= 30) ? "右"
                : (r >= 90 - 30 && r <= 90 + 30) ? "上"
                : (r >= 180 - 30 && r <= 180 + 30) ? "左"
                : (r >= 270 - 30 && r <= 270 + 30) ? "下" : 方向
            Break
        }
    if (方向 != 上次方向) 轨迹 .= 方向, 上次方向 := 方向if (x1 != x2 or y1 != y2) {
        arr.Push([x1, y1, x2, y2]), x1 := x2, y1 := y2
        ToolTip , % 轨迹 " > " (tip[轨迹] ? tip[轨迹] : "没有设置动作")
    }
    color := A_MSec < 500 ? 0xFF9050 : 0x5090FF
    for k, v in arr划线(v.1, v.2, v.3, v.4, color) 更新()
}
ToolTip清空(), 更新(), 隐藏画板() if (轨迹 = "") {
    Click , R
    return
}
if IsLabel(轨迹) Goto, %轨迹%
else
    MsgBox , 4096, , % 轨迹 " > 没有设置动作", 1
return

#If

;========== 下面是函数 ==========

生成画板()
{
    global my_gdi
    Gui , My_DrawingBoard: New
    Gui , +LastFound + AlwaysOnTop - Caption + ToolWindow
        + E0x80000 + OwnDialogs + Hwndmy_id + E0x20
    ; 下面两行结合Bitblt更新与UpdateLayeredWindow更新互斥
    ; Gui, Color, 0x000000
    ; WinSet, TransColor, 0x000000
    w := A_ScreenWidth, h := A_ScreenHeight
    Gui , Show, Hide x0 y0 w%w% h%h%, 画板
    my_gdi := new GDI(my_id, w, h), 清空()
    return
}

显示画板()
{
    Gui , My_DrawingBoard: Show, NA
}

隐藏画板()
{
    Gui , My_DrawingBoard: Hide
}

划线(x, y, x2, y2, color = 0xFF0000)
{
    global my_gdi
    my_gdi.DrawLine(x, y, x2, y2, Color, 4)
}

更新(color = 0x000000)
{
    global my_gdi
    ; my_gdi.Bitblt()
    my_gdi.UpdateLayeredWindow(0, 0, 0, 0, color)
}

清空(color = 0x000000)
{
    global my_gdi
    my_gdi.FillRectangle(0, 0, my_gdi.CliWidth, my_gdi.CliHeight, color)
}

class GDI	; thanks dwitter, RUNIE, FeiYue
{
    __New(hWnd, CliWidth = 0, CliHeight = 0)
    {
        if !(CliWidth && CliHeight)
        {
            VarSetCapacity(Rect, 16, 0)
            DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &Rect)
            CliWidth := NumGet(Rect, 8, "Int")
            CliHeight := NumGet(Rect, 12, "Int")
        }
        this.hWnd := hWnd
        this.CliWidth := CliWidth
        this.CliHeight := CliHeight
        this.hDC := DllCall("GetDC", "UPtr", this.hWnd, "UPtr")
        this.hMemDC := DllCall("CreateCompatibleDC", "UPtr", this.hDC, "UPtr")
        this.hBitmap := DllCall("CreateCompatibleBitmap", "UPtr", this.hDC, "Int", CliWidth, "Int", CliHeight, "UPtr")
        this.hOriginalBitmap := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", this.hBitmap)
        DllCall("ReleaseDC", "UPtr", this.hWnd, "UPtr", this.hDC)
    }

    __Delete()
    {
        DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", this.hOriginalBitmap)
        DllCall("DeleteObject", "UPtr", this.hBitmap)
        DllCall("DeleteObject", "UPtr", this.hMemDC)
    }

    Resize(w, h)
    {
        this.CliWidth := w
        this.CliHeight := h
        this.hDC := DllCall("GetDC", "UPtr", this.hWnd, "UPtr")
        this.hBitmap := DllCall("CreateCompatibleBitmap", "UPtr", this.hDC, "Int", w, "Int", h, "UPtr")
        hPrevBitmap := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", this.hBitmap)
        DllCall("DeleteObject", "UPtr", hPrevBitmap)
        DllCall("ReleaseDC", "UPtr", this.hWnd, "UPtr", this.hDC)
    }

    BitBlt(x = 0, y = 0, w = 0, h = 0)
    {
        w := w ? w : this.CliWidth
        h := h ? h : this.CliHeight
        this.hDC := DllCall("GetDC", "UPtr", this.hWnd, "UPtr")
        DllCall("BitBlt", "UPtr", this.hDC, "Int", x, "Int", y
            , "Int", w, "Int", h, "UPtr", this.hMemDC, "Int", 0, "Int", 0, "UInt", 0xCC0020)	;SRCCOPY
        DllCall("ReleaseDC", "UPtr", this.hWnd, "UPtr", this.hDC)
    }

    UpdateLayeredWindow(x = 0, y = 0, w = 0, h = 0, color = 0, Alpha = 255)
    {
        w := w ? w : this.CliWidth
        h := h ? h : this.CliHeight
        DllCall("UpdateLayeredWindow", "UPtr", this.hWnd, "UPtr", 0
            , "Int64*", x | y << 32, "Int64*", w | h << 32
            , "UPtr", this.hMemDC, "Int64*", 0, "UInt", color
            , "UInt*", Alpha << 16 | 1 << 24, "UInt", 1)
    }

    DrawLine(x, y, x2, y2, Color, Width = 1)
    {
        Pen := new GDI.Pen(Color, Width)
        DllCall("MoveToEx", "UPtr", this.hMemDC, "Int", this.TranslateX(x), "Int", this.TranslateY(y), "UPtr", 0)
        hOriginalPen := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Pen.Handle, "UPtr")
        DllCall("LineTo", "UPtr", this.hMemDC, "Int", this.TranslateX(x2), "Int", this.TranslateY(y2))
        DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalPen, "UPtr")
    }

    SetPixel(x, y, Color)
    {
        x := this.TranslateX(x)
        y := this.TranslateY(y, this.Invert)	; Move up 1 px if inverted (drawing "up" instead of down)DllCall("SetPixelV", "UPtr", this.hMemDC, "Int", x, "Int", y, "UInt", Color)}FillRectangle(x, y, w, h, Color, BorderColor=-1) {
        if (w == 1 && h == 1) return this.SetPixel(x, y, Color) Pen := new this.Pen(BorderColor < 0 ? Color : BorderColor) Brush := new this.Brush(Color)	; Replace the original pen and brush with our own
            hOriginalPen := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Pen.Handle, "UPtr") hOriginalBrush := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Brush.Handle, "UPtr") x1 := this.TranslateX(x) y1 := this.TranslateY(y) x2 := this.TranslateX(x + w) y2 := this.TranslateY(y + h) DllCall("Rectangle", "UPtr", this.hMemDC, "Int", x1, "Int", y1, "Int", x2, "Int", y2)	; Reselect the original pen and brush
            DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalPen, "UPtr") DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalBrush, "UPtr")
        }
        FillEllipse(x, y, w, h, Color, BorderColor = -1)
        {
            Pen := new this.Pen(BorderColor < 0 ? Color : BorderColor)
            Brush := new this.Brush(Color)

            ; Replace the original pen and brush with our own
            hOriginalPen := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Pen.Handle, "UPtr")
            hOriginalBrush := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Brush.Handle, "UPtr")

            x1 := this.TranslateX(x)
            y1 := this.TranslateY(y)
            x2 := this.TranslateX(x + w)
            y2 := this.TranslateY(y + h)

            DllCall("Ellipse", "UPtr", this.hMemDC
                , "Int", x1, "Int", y1
                , "Int", x2, "Int", y2)

            ; Reselect the original pen and brush
            DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalPen, "UPtr")
            DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalBrush, "UPtr")
        }

        TranslateX(X)
        {
            return Floor(X)
        }

        TranslateY(Y, Offset = 0)
        {
            if this.Invert
                return this.CliHeight - Floor(Y) - Offset
            return Floor(Y)
        }

        class Pen
        {
            __New(Color, Width = 1, Style = 0)
            {
                this.Handle := DllCall("CreatePen", "Int", Style, "Int", Width, "UInt", Color, "UPtr")
            }

            __Delete()
            {
                DllCall("DeleteObject", "UPtr", this.Handle)
            }
        }

        class Brush
        {
            __New(Color)
            {
                this.Handle := DllCall("CreateSolidBrush", "UInt", Color, "UPtr")
            }

            __Delete()
            {
                DllCall("DeleteObject", "UPtr", this.Handle)
            }
        }
    }