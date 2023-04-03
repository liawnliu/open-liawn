Gdip_Startup(multipleInstances := 0) {
    Static Ptr := "UPtr"
    pToken := 0
    If (multipleInstances = 0)
    {
        if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
            DllCall("LoadLibrary", "str", "gdiplus")
    } Else DllCall("LoadLibrary", "str", "gdiplus")

    si := Buffer((A_PtrSize = 8) ? 24 : 16, 0)	; , si := Chr(1)
    NumPut("UInt", 1, si)
    DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken, Ptr, si.ptr, Ptr, 0)
    return pToken
}
GetDC(hwnd := 0) {
    return DllCall("GetDC", "UPtr", hwnd)
}

CreateDIBSection(w, h, hdc := "", bpp := 32, &ppvBits := 0, Usage := 0, hSection := 0, Offset := 0) {
    ; A GDI function that creates a new hBitmap,
    ; a device-independent bitmap [DIB].
    ; A DIB consists of two distinct parts:
    ; a BITMAPINFO structure describing the dimensions
    ; and colors of the bitmap, and an array of bytes
    ; defining the pixels of the bitmap.

    Static Ptr := "UPtr"
    hdc2 := hdc ? hdc : GetDC()
    bi := Buffer(40, 0)
    NumPut("UInt", 40, bi, 0)
    NumPut("UInt", w, bi, 4)
    NumPut("UInt", h, bi, 8)
    NumPut("UShort", 1, bi, 12)
    NumPut("UShort", bpp, bi, 14)
    NumPut("UInt", 0, bi, 16)

    hbm := DllCall("CreateDIBSection"
        , Ptr, hdc2
        , Ptr, bi.ptr	; BITMAPINFO
        , "uint", Usage
        , "UPtr*", &ppvBits
        , Ptr, hSection
        , "uint", OffSet, Ptr)

    if !hdc
        ReleaseDC(hdc2)
    return hbm
}
CreateCompatibleDC(hdc := 0) {
    return DllCall("CreateCompatibleDC", "UPtr", hdc)
}
SelectObject(hdc, hgdiobj) {
    Static Ptr := "UPtr"
    return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
}
Gdip_CreatePen(ARGB, w, Unit := 2) {
    pPen := 0
    E := DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", Unit, "UPtr*", &pPen)
    return pPen
}
Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h) {
    Static Ptr := "UPtr"
    return DllCall("gdiplus\GdipDrawRectangle", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}
Gdip_DeletePen(pPen) {
    return DllCall("gdiplus\GdipDeletePen", "UPtr", pPen)
}
Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h) {
    Static Ptr := "UPtr"
    return DllCall("gdiplus\GdipDrawEllipse", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}
Gdip_GraphicsFromHDC(hDC, hDevice := "", InterpolationMode := "", SmoothingMode := "", PageUnit := "", CompositingQuality := "") {
    pGraphics := 0
    If hDevice
        DllCall("Gdiplus\GdipCreateFromHDC2", "UPtr", hDC, "UPtr", hDevice, "UPtr*", &pGraphics)
    Else
        DllCall("gdiplus\GdipCreateFromHDC", "UPtr", hdc, "UPtr*", &pGraphics)

    If pGraphics
    {
        If (InterpolationMode != "")
            Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
        If (SmoothingMode != "")
            Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
        If (PageUnit != "")
            Gdip_SetPageUnit(pGraphics, PageUnit)
        If (CompositingQuality != "")
            Gdip_SetCompositingQuality(pGraphics, CompositingQuality)
    }

    return pGraphics
}
Gdip_SetInterpolationMode(pGraphics, InterpolationMode) {
    ; InterpolationMode options:
    ; Default = 0
    ; LowQuality = 1
    ; HighQuality = 2
    ; Bilinear = 3
    ; Bicubic = 4
    ; NearestNeighbor = 5
    ; HighQualityBilinear = 6
    ; HighQualityBicubic = 7
    return DllCall("gdiplus\GdipSetInterpolationMode", "UPtr", pGraphics, "int", InterpolationMode)
}
Gdip_SetPageUnit(pGraphics, Unit) {
    ; Sets the unit of measurement for a pGraphics object.
    ; Unit of measuremnet options:
    ; 0 - World coordinates, a non-physical unit
    ; 1 - Display units
    ; 2 - A unit is 1 pixel
    ; 3 - A unit is 1 point or 1/72 inch
    ; 4 - A unit is 1 inch
    ; 5 - A unit is 1/300 inch
    ; 6 - A unit is 1 millimeter

    Static Ptr := "UPtr"
    return DllCall("gdiplus\GdipSetPageUnit", Ptr, pGraphics, "int", Unit)
}
Gdip_SetSmoothingMode(pGraphics, SmoothingMode) {
    ; SmoothingMode options:
    ; Default = 0
    ; HighSpeed = 1
    ; HighQuality = 2
    ; None = 3
    ; AntiAlias = 4
    ; AntiAlias8x4 = 5
    ; AntiAlias8x8 = 6
    return DllCall("gdiplus\GdipSetSmoothingMode", "UPtr", pGraphics, "int", SmoothingMode)
}
Gdip_SetCompositingQuality(pGraphics, CompositionQuality) {
    ; CompositionQuality options:
    ; 0 - Gamma correction is not applied.
    ; 1 - Gamma correction is not applied. High speed, low quality.
    ; 2 - Gamma correction is applied. Composition of high quality and speed.
    ; 3 - Gamma correction is applied.
    ; 4 - Gamma correction is not applied. Linear values are used.

    Static Ptr := "UPtr"
    return DllCall("gdiplus\GdipSetCompositingQuality", Ptr, pGraphics, "int", CompositionQuality)
}
Gdip_BrushCreateSolid(ARGB := 0xff000000) {
    pBrush := 0
    E := DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, "UPtr*", &pBrush)
    return pBrush
}
Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h) {
    Static Ptr := "UPtr"
    return DllCall("gdiplus\GdipFillEllipse", Ptr, pGraphics, Ptr, pBrush, "float", x, "float", y, "float", w, "float", h)
}
Gdip_DeleteBrush(pBrush) {
    return DllCall("gdiplus\GdipDeleteBrush", "UPtr", pBrush)
}
Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h) {
    Static Ptr := "UPtr"
    return DllCall("gdiplus\GdipFillRectangle"
        , Ptr, pGraphics
        , Ptr, pBrush
        , "float", x, "float", y
        , "float", w, "float", h)
}
UpdateLayeredWindow(hwnd, hdc, x := "", y := "", w := "", h := "", Alpha := 255) {
    Static Ptr := "UPtr"
    if ((x != "") && (y != ""))
        pt := Buffer(8), NumPut("UInt", x, pt, 0), NumPut("UInt", y, pt, 4)

    if (w = "") || (h = "")
        GetWindowRect(hwnd, &W, &H)

    return DllCall("UpdateLayeredWindow"
        , Ptr, hwnd	; layered window hwnd
        , Ptr, 0	; hdcDst (screen) - usually 0
        , Ptr, ((x = "") && (y = "")) ? 0 : pt.ptr	; POINT x,y of layered window
        , "int64*", w | h << 32	; SIZE w,h of layered window
        , Ptr, hdc	; hdcSrc - source bitmap to be drawn on to layered window - NULL if not changing
        , "int64*", 0	; x,y offset of bitmap to be drawn
        , "uint", 0	; crKey - bgcolor to use?  meaningless when using full alpha
        , "UInt*", Alpha << 16 | 1 << 24	;
        , "uint", 2)
}
GetWindowRect(hwnd, &W, &H) {
    ; function by GeekDude: https://gist.github.com/G33kDude/5b7ba418e685e52c3e6507e5c6972959
    ; W10 compatible function to find a window's visible boundaries
    ; modified by Marius Șucanto return an array
    rect := Buffer(size := 16, 0)
    er := DllCall("dwmapi\DwmGetWindowAttribute"
        , "UPtr", hWnd	; HWND  hwnd
        , "UInt", 9	; DWORD dwAttribute (DWMWA_EXTENDED_FRAME_BOUNDS)
        , "UPtr", rect.ptr	; PVOID pvAttribute
        , "UInt", size	; DWORD cbAttribute
        , "UInt")	; HRESULT

    If er
        DllCall("GetWindowRect", "UPtr", hwnd, "UPtr", rect.ptr, "UInt")

    r := {}
    r.x1 := NumGet(rect, 0, "Int"), r.y1 := NumGet(rect, 4, "Int")
    r.x2 := NumGet(rect, 8, "Int"), r.y2 := NumGet(rect, 12, "Int")
    r.w := Abs(max(r.x1, r.x2) - min(r.x1, r.x2))
    r.h := Abs(max(r.y1, r.y2) - min(r.y1, r.y2))
    W := r.w
    H := r.h
    ; ToolTip, % r.w " --- " r.h , , , 2
    Return r
}
DeleteObject(hObject) {
    return DllCall("DeleteObject", "UPtr", hObject)
}
ReleaseDC(hdc, hwnd := 0) {
    Static Ptr := "UPtr"
    return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
}
DeleteDC(hdc) {
    return DllCall("DeleteDC", "UPtr", hdc)
}
Gdip_DeleteGraphics(pGraphics) {
    return DllCall("gdiplus\GdipDeleteGraphics", "UPtr", pGraphics)
}
Gdip_Shutdown(pToken) {
    Static Ptr := "UPtr"

    DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
    hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
    if hModule
        DllCall("FreeLibrary", Ptr, hModule)
    return 0
}