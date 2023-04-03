#SingleInstance Force
#Include ../../util/JSON.ahk
#Include ../../util/LogWrite.ahk
#Include ../../util/MyGdip.ahk
#Include GestureAnalyze.ahk

If !pToken := Gdip_Startup()
{
   MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
   ExitApp
}
OnExit(ExitFunc)

v := 0, dir := ""
Gui1 := Gui("-Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop")
Gui1.Show("NA")
hwnd1 := Gui1.hwnd
gui_esc(*) {
    ExitApp
}
pBitmapT1 := ""
pBitmapT2 := ""
pBitmapT3 := ""
pBitmapT4 := ""
; Get a bitmap from the image
If FileExist("E:\AhkWorkSpace\Lopen\image\gesture\test2.png")
   pBitmapT1 := Gdip_CreateBitmapFromFile("E:\AhkWorkSpace\Lopen\image\gesture\test2.png")

; gan := GestureAnalyze()

pBitmapT2 := Gdip_CloneBitmapArea(pBitmapT1, 25, 25, 150, 150)
Gdip_SaveBitmapToFile(pBitmapT2, "E:\AhkWorkSpace\Lopen\image\gesture\test7.png")

return


; On exit, dispose of everything created
Esc::{
   ExitApp
}

ExitFunc(ExitReason, ExitCode)
{
   global
   Gdip_DisposeImage(pBitmapT1)
   ;SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
   ;Gdip_DeleteGraphics(G)
   Gdip_Shutdown(pToken)
}


