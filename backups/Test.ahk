; AHK v2
; gdi+ ahk tutorial 2 written by tic (Tariq Porter)
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
;
; Tutorial to draw a single ellipse and rectangle to the screen, but just the outlines of these shapes

#SingleInstance Force
;#NoEnv
;SetBatchLines -1

; Uncomment if Gdip.ahk is not in your standard library
#Include Gdip_All.ahk


; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
	ExitApp
}
OnExit(ExitFunc)

; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
Width := 600, Height := 400

; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
;AHK v1
;Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
;Gui, 1: Show, NA
Gui1 := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
Gui1.OnEvent("escape",gui_esc)
Gui1.Show("NA")

gui_esc(*) {
    ExitApp
}

; Get a handle to this window we have created in order to update it later
hwnd1 := Gui1.hwnd

; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
hbm := CreateDIBSection(Width, Height)

; Get a device context compatible with the screen
hdc := CreateCompatibleDC()

; Select the bitmap into the device context
obm := SelectObject(hdc, hbm)

; Get a pointer to the graphics of the bitmap, for use with drawing functions
G := Gdip_GraphicsFromHDC(hdc)

; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
Gdip_SetSmoothingMode(G, 4)

; Create a fully opaque red pen (ARGB = Transparency, red, green, blue) of width 3 (the thickness the pen will draw at) to draw a circle
pPen := Gdip_CreatePen(0xffff0000, 3)

; 椭圆
Gdip_DrawEllipse(G, pPen, 100, 50, 200, 300)

; 画完销毁笔
Gdip_DeletePen(pPen)

; 再生成一个笔
pPen := Gdip_CreatePen(0x660000ff, 10)

; 画矩形
Gdip_DrawRectangle(G, pPen, 250, 80, 300, 200)

; Delete the brush as it is no longer needed and wastes memory
Gdip_DeletePen(pPen)

; 使用位图 (hdc) 的句柄更新我们创建的指定窗口 (hwnd1)，指定 x,y,w,h 我们希望它定位在我们的屏幕上
; 所以这会将我们的 gui 定位在 (0,0) 与之前指定的宽度和高度
UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)


; Select the object back into the hdc
;SelectObject(hdc, obm)

; Now the bitmap may be deleted
;DeleteObject(hbm)

; Also the device context related to the bitmap may be deleted
;DeleteDC(hdc)

; The graphics may now be deleted
;Gdip_DeleteGraphics(G)
Return

;#######################################################################

ExitFunc(ExitReason, ExitCode)
{
   global
   ; gdi+ may now be shutdown on exiting the program
   Gdip_Shutdown(pToken)
}
