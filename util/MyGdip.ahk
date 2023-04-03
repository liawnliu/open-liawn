try {
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
    Gdip_ToARGB(A, R, G, B) {
        return (A << 24) | (R << 16) | (G << 8) | B
     }
     Gdip_FromARGB(ARGB, &A, &R, &G, &B) {
        A := (0xff000000 & ARGB) >> 24
        R := (0x00ff0000 & ARGB) >> 16
        G := (0x0000ff00 & ARGB) >> 8
        B := 0x000000ff & ARGB
     }
     Gdip_AFromARGB(ARGB) {
        return (0xff000000 & ARGB) >> 24
     }
     Gdip_RFromARGB(ARGB) {
        return (0x00ff0000 & ARGB) >> 16
     }
     Gdip_GFromARGB(ARGB) {
        return (0x0000ff00 & ARGB) >> 8
     }
     Gdip_BFromARGB(ARGB) {
        return 0x000000ff & ARGB
     }
    GetDC(hwnd := 0) {
        return DllCall("GetDC", "UPtr", hwnd)
    }
    CreateDIBSection(w, h, hdc := "", bpp := 32, &ppvBits := 0, Usage := 0, hSection := 0, Offset := 0) {
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
    Gdip_DrawImageRect(pGraphics, pBitmap, X, Y, W, H) {
        Static Ptr := "UPtr"
        _E := DllCall("gdiplus\GdipDrawImageRect"
            , Ptr, pGraphics
            , Ptr, pBitmap
            , "float", X, "float", Y
            , "float", W, "float", H)
        return _E
    }
    Gdip_GraphicsFromHDC(hDC, hDevice := "", InterpolationMode := "", SmoothingMode := "", PageUnit := "", CompositingQuality := "") {
        pGraphics := 0
        If hDevice
            DllCall("Gdiplus\GdipCreateFromHDC2", "UPtr", hDC, "UPtr", hDevice, "UPtr*", &pGraphics)
        Else
            DllCall("gdiplus\GdipCreateFromHDC", "UPtr", hdc, "UPtr*", &pGraphics)
        If pGraphics {
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
        return DllCall("gdiplus\GdipSetInterpolationMode", "UPtr", pGraphics, "int", InterpolationMode)
    }
    Gdip_SetPageUnit(pGraphics, Unit) {
        Static Ptr := "UPtr"
        return DllCall("gdiplus\GdipSetPageUnit", Ptr, pGraphics, "int", Unit)
    }
    Gdip_SetSmoothingMode(pGraphics, SmoothingMode) {
        return DllCall("gdiplus\GdipSetSmoothingMode", "UPtr", pGraphics, "int", SmoothingMode)
    }
    Gdip_SetCompositingQuality(pGraphics, CompositionQuality) {
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
    Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2) {
        Static Ptr := "UPtr"
        return DllCall("gdiplus\GdipDrawLine"
            , Ptr, pGraphics
            , Ptr, pPen
            , "float", x1, "float", y1
            , "float", x2, "float", y2)
    }
    Gdip_GetPixel(pBitmap, x, y) {
        ARGB := 0
        DllCall("gdiplus\GdipBitmapGetPixel", "UPtr", pBitmap, "int", x, "int", y, "uint*", &ARGB)
        return ARGB
    }
    Gdip_CreateBitmapFromHBITMAP(hBitmap, hPalette := 0) {
        Static Ptr := "UPtr"
        pBitmap := 0
        DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, hPalette, "UPtr*", &pBitmap)
        return pBitmap
    }
    Gdip_GetImageWidth(pBitmap) {
        Width := 0
        DllCall("gdiplus\GdipGetImageWidth", "UPtr", pBitmap, "uint*", &Width)
        return Width
    }
    Gdip_GetImageHeight(pBitmap) {
        Height := 0
        DllCall("gdiplus\GdipGetImageHeight", "UPtr", pBitmap, "uint*", &Height)
        return Height
    }
    Gdip_GetImageDimensions(pBitmap, &Width, &Height) {
        If StrLen(pBitmap) < 3
            Return -1

        Width := 0, Height := 0
        E := Gdip_GetImageDimension(pBitmap, &Width, &Height)
        Width := Round(Width)
        Height := Round(Height)
        return E
    }
    Gdip_GetImageDimension(pBitmap, &w, &h) {
        Static Ptr := "UPtr"
        return DllCall("gdiplus\GdipGetImageDimension", Ptr, pBitmap, "float*", &w, "float*", &h)
    }
    Gdip_GetLockBitPixel(Scan0, x, y, Stride) {
        return NumGet(Scan0 + 0, (x * 4) + (y * Stride), "UInt")
    }
    Gdip_LockBits(pBitmap, x, y, w, h, &Stride, &Scan0, &BitmapData, LockMode := 3, PixelFormat := 0x26200a) {
        Static Ptr := "UPtr"
        CreateRect(&_Rect, x, y, w, h)
        BitmapData := Buffer(16 + 2 * A_PtrSize, 0)
        _E := DllCall("Gdiplus\GdipBitmapLockBits", Ptr, pBitmap, Ptr, _Rect.ptr, "uint", LockMode, "int", PixelFormat, Ptr, BitmapData.ptr)
        Stride := NumGet(BitmapData, 8, "Int")
        Scan0 := NumGet(BitmapData, 16, "UPtr")
        return _E
    }
    Gdip_UnlockBits(pBitmap, &BitmapData) {
        Static Ptr := "UPtr"
        return DllCall("Gdiplus\GdipBitmapUnlockBits", Ptr, pBitmap, Ptr, BitmapData.ptr)
    }
    CreateRect(&Rect, x, y, x2, y2) {
        Rect := Buffer(16)
        NumPut("UInt", x, Rect, 0), NumPut("UInt", y, Rect, 4)
        NumPut("UInt", x2, Rect, 8), NumPut("UInt", y2, Rect, 12)
    }
    Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality := 75, toBase64 := 0) {
        Static Ptr := "UPtr"
        nCount := 0
        nSize := 0
        _p := 0
        SplitPath sOutput, , , &Extension
        If !RegExMatch(Extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")
            Return -1
        Extension := "." Extension
        DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount, "uint*", &nSize)
        ci := Buffer(nSize)
        DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, ci.ptr)
        If !(nCount && nSize)
            Return -2
        Static IsUnicode := StrLen(Chr(0xFFFF))
        If (IsUnicode)
        {
            StrGet_Name := "StrGet"
            N := (SubStr(A_AhkVersion, 1, 1) < 2) ? nCount : "nCount"
            Loop %N%
            {
                sString := %StrGet_Name%(NumGet(ci, (idx := (48 + 7 * A_PtrSize) * (A_Index - 1)) + 32 + 3 * A_PtrSize, "UPtr"), "UTF-16")
                If !InStr(sString, "*" Extension)
                    Continue

                pCodec := ci.ptr + idx
                Break
            }
        } Else {
            N := (SubStr(A_AhkVersion, 1, 1) < 2) ? nCount : "nCount"
            Loop %N%
            {
                Location := NumGet(ci, 76 * (A_Index - 1) + 44, "UPtr")
                nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int", 0, "uint", 0, "uint", 0)
                sString := Buffer(nSize)
                DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
                If !InStr(sString, "*" Extension)
                    Continue

                pCodec := ci.ptr + 76 * (A_Index - 1)
                Break
            }
        }
        If !pCodec
            Return -3
        If (Quality != 75){
            Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
            If (quality > 90 && toBase64 = 1)
                Quality := 90
            If RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$"){
                DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", &nSize)
                EncoderParameters := Buffer(nSize, 0)
                DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, EncoderParameters.ptr)
                nCount := NumGet(EncoderParameters, "UInt")
                N := (SubStr(A_AhkVersion, 1, 1) < 2) ? nCount : "nCount"
                Loop %N% {
                    elem := (24 + A_PtrSize) * (A_Index - 1) + 4 + (pad := (A_PtrSize = 8) ? 4 : 0)
                    If (NumGet(EncoderParameters, elem + 16, "UInt") = 1) && (NumGet(EncoderParameters, elem + 20, "UInt") = 6){
                        _p := elem + EncoderParameters.ptr - pad - 4
                        NumPut(Quality, NumGet(NumPut(4, NumPut(1, _p + 0, "UPtr") + 20, "UInt"), "UPtr"), "UInt")
                        Break
                    }
                }
            }
        }
        If (toBase64 = 1){
            DllCall("ole32\CreateStreamOnHGlobal", "ptr", 0, "int", true, "ptr*", &pStream := 0)
            _E := DllCall("gdiplus\GdipSaveImageToStream", "ptr", pBitmap, "ptr", pStream, "ptr", pCodec, "uint", _p ? _p : 0)
            If _E
                Return -6

            DllCall("ole32\GetHGlobalFromStream", "ptr", pStream, "uint*", &hData)
            pData := DllCall("GlobalLock", "ptr", hData, "ptr")
            nSize := DllCall("GlobalSize", "uint", pData)

            bin := Buffer(nSize, 0)
            DllCall("RtlMoveMemory", "ptr", bin.ptr, "ptr", pData, "uptr", nSize)
            DllCall("GlobalUnlock", "ptr", hData)
            ObjRelease(pStream)
            DllCall("GlobalFree", "ptr", hData)

            DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr", bin.ptr, "uint", nSize, "uint", 0x40000001, "ptr", 0, "uint*", &base64Length := 0)
            base64 := Buffer(base64Length, 0)
            _E := DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr", bin.ptr, "uint", nSize, "uint", 0x40000001, "ptr", &base64, "uint*", base64Length)
            If !_E
                Return -7

            bin := Buffer(0)
            Return StrGet(base64, base64Length, "CP0")
        }

        _E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, "WStr", sOutput, Ptr, pCodec, "uint", _p ? _p : 0)
        Return _E ? -5 : 0
    }
    Gdip_DisposeImage(pBitmap, noErr := 0) {
        If (StrLen(pBitmap) <= 2 && noErr = 1)
            Return 0

        r := DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
        If (r == 2 || r == 1) && (noErr = 1)
            r := 0
        Return r
    }
    DestroyIcon(hIcon) {
        return DllCall("DestroyIcon", "UPtr", hIcon)
    }
    Gdip_CreateBitmapFromFile(sFile, IconNumber := 1, IconSize := "", useICM := 0) {
        Static Ptr := "UPtr"
        PtrA := "UPtr*"
        pBitmap := 0
        pBitmapOld := 0
        hIcon := 0

        SplitPath sFile, , , &Extension
        if RegExMatch(Extension, "^(?i:exe|dll)$"){
            Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
            BufSize := 16 + (2 * A_PtrSize)

            buf := Buffer(BufSize, 0)
            For eachSize, Size in StrSplit(Sizes, "|"){
                DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber - 1, "int", Size, "int", Size, PtrA, &hIcon, PtrA, 0, "uint", 1, "uint", 0)
                if !hIcon
                    continue

                if !DllCall("GetIconInfo", Ptr, hIcon, Ptr, buf.ptr){
                    DestroyIcon(hIcon)
                    continue
                }

                hbmMask := NumGet(buf, 12 + (A_PtrSize - 4), "UPtr")
                hbmColor := NumGet(buf, 12 + (A_PtrSize - 4) + A_PtrSize, "UPtr")
                if !(hbmColor && DllCall("GetObject", Ptr, hbmColor, "int", BufSize, Ptr, buf.ptr)){
                    DestroyIcon(hIcon)
                    continue
                }
                break
            }
            if !hIcon
                return -1

            Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
            hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
            if !DllCall("DrawIconEx", Ptr, hdc, "int", 0, "int", 0, Ptr, hIcon, "uint", Width, "uint", Height, "uint", 0, Ptr, 0, "uint", 3){
                DestroyIcon(hIcon)
                return -2
            }

            dib := Buffer(104)
            DllCall("GetObject", Ptr, hbm, "int", (A_PtrSize = 8) ? 104 : 84, Ptr, dib.ptr)
            Stride := NumGet(dib, 12, "Int")
            Bits := NumGet(dib, 20 + ((A_PtrSize = 8) ? 4 : 0), "UPtr")	; padding
            pBitmapOld := Gdip_CreateBitmap(Width, Height, 0, Stride, Bits)
            pBitmap := Gdip_CreateBitmap(Width, Height)
            _G := Gdip_GraphicsFromImage(pBitmap)
            Gdip_DrawImage(_G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
            SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
            Gdip_DeleteGraphics(_G), Gdip_DisposeImage(pBitmapOld)
            DestroyIcon(hIcon)
        } else{
            function2call := (useICM = 1) ? "GdipCreateBitmapFromFileICM" : "GdipCreateBitmapFromFile"
            E := DllCall("gdiplus\" function2call, "WStr", sFile, PtrA, &pBitmap)
        }
        return pBitmap
    }
    Gdip_DrawImage(pGraphics, pBitmap, dx := "", dy := "", dw := "", dh := "", sx := "", sy := "", sw := "", sh := "", Matrix := 1, Unit := 2, ImageAttr := 0) {
        Static Ptr := "UPtr"
        usrImageAttr := 0
        If !ImageAttr{
            if !IsNumber(Matrix)
                ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
            else if (Matrix != 1)
                ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
        } Else usrImageAttr := 1

        If (dx != "" && dy != "" && dw = "" && dh = "" && sx = "" && sy = "" && sw = "" && sh = ""){
            sx := sy := 0
            sw := dw := Gdip_GetImageWidth(pBitmap)
            sh := dh := Gdip_GetImageHeight(pBitmap)
        } Else If (sx = "" && sy = "" && sw = "" && sh = ""){
            If (dx = "" && dy = "" && dw = "" && dh = ""){
                sx := dx := 0, sy := dy := 0
                sw := dw := Gdip_GetImageWidth(pBitmap)
                sh := dh := Gdip_GetImageHeight(pBitmap)
            } Else{
                sx := sy := 0
                Gdip_GetImageDimensions(pBitmap, &sw, &sh)
            }
        }
        _E := DllCall("gdiplus\GdipDrawImageRectRect"
            , Ptr, pGraphics
            , Ptr, pBitmap
            , "float", dX, "float", dY
            , "float", dW, "float", dH
            , "float", sX, "float", sY
            , "float", sW, "float", sH
            , "int", Unit
            , Ptr, ImageAttr ? ImageAttr : 0
            , Ptr, 0, Ptr, 0)
        if (ImageAttr && usrImageAttr != 1)
            Gdip_DisposeImageAttributes(ImageAttr)
        return _E
    }
    Gdip_DisposeImageAttributes(ImageAttr) {
        return DllCall("gdiplus\GdipDisposeImageAttributes", "UPtr", ImageAttr)
    }
    Gdip_SetImageAttributesColorMatrix(clrMatrix, ImageAttr := 0, grayMatrix := 0, ColorAdjustType := 1, fEnable := 1, ColorMatrixFlag := 0) {
        Static Ptr := "UPtr"
        GrayscaleMatrix := 0
        If (StrLen(clrMatrix) < 5 && ImageAttr)
            Return -1
        If StrLen(clrMatrix) < 5
            Return
        ColourMatrix := Buffer(100, 0)
        Matrix := RegExReplace(RegExReplace(clrMatrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
        Matrix := StrSplit(Matrix, "|")
        Loop 25 {
            M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index - 1, 6) ? 0 : 1
            NumPut("Float", M, ColourMatrix, (A_Index - 1) * 4)
        }
        Matrix := ""
        Matrix := RegExReplace(RegExReplace(grayMatrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
        Matrix := StrSplit(Matrix, "|")
        If (StrLen(Matrix) > 2 && ColorMatrixFlag = 2){
            GrayscaleMatrix := Buffer(100, 0)
            Loop 25{
                M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index - 1, 6) ? 0 : 1
                NumPut("Float", M, GrayscaleMatrix, (A_Index - 1) * 4)
            }
        }

        If !ImageAttr {
            created := 1
            ImageAttr := Gdip_CreateImageAttributes()
        }
        E := DllCall("gdiplus\GdipSetImageAttributesColorMatrix"
            , Ptr, ImageAttr
            , "int", ColorAdjustType
            , "int", fEnable
            , Ptr, ColourMatrix.ptr
            , Ptr, GrayscaleMatrix ? GrayscaleMatrix.ptr : 0
            , "int", ColorMatrixFlag)
        E := created = 1 ? ImageAttr : E
        return E
    }
    Gdip_CreateImageAttributes() {
        ImageAttr := 0
        DllCall("gdiplus\GdipCreateImageAttributes", "UPtr*", &ImageAttr)
        return ImageAttr
    }
    Gdip_GraphicsFromImage(pBitmap, InterpolationMode := "", SmoothingMode := "", PageUnit := "", CompositingQuality := "") {
        pGraphics := 0
        DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", &pGraphics)
        If pGraphics {
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
    Gdip_CreateBitmap(Width, Height, PixelFormat := 0, Stride := 0, Scan0 := 0) {
        pBitmap := 0
        If !PixelFormat
            PixelFormat := 0x26200A	; 32-ARGB

        DllCall("gdiplus\GdipCreateBitmapFromScan0"
            , "int", Width
            , "int", Height
            , "int", Stride
            , "int", PixelFormat
            , "UPtr", Scan0
            , "UPtr*", &pBitmap)
        Return pBitmap
    }
    Gdip_GetImagePixelFormat(pBitmap, mode := 0) {
        Static PixelFormatsList := Map("0x30101", "1-INDEXED", "0x30402", "4-INDEXED", "0x30803", "8-INDEXED", "0x101004", "16-GRAYSCALE", "0x21005", "16-RGB555", "0x21006", "16-RGB565", "0x61007", "16-ARGB1555", "0x21808", "24-RGB", "0x22009", "32-RGB", "0x26200A", "32-ARGB", "0xE200B", "32-PARGB", "0x10300C", "48-RGB", "0x34400D", "64-ARGB", "0x1A400E", "64-PARGB")
        PixelFormat := 0
        E := DllCall("gdiplus\GdipGetImagePixelFormat", "UPtr", pBitmap, "UPtr*", &PixelFormat)
        If E
            Return -1

        If (mode = 0)
            Return PixelFormat

        inHEX := Format("0x{:X}", PixelFormat)
        If (PixelFormatsList.Has(inHEX) && mode = 2)
            result := PixelFormatsList[inHEX]
        Else
            result := inHEX
        return result
    }
    ; 用于裁剪，但xy不能是负数
    Gdip_CloneBitmapArea(pBitmap, x := "", y := "", w := 0, h := 0, PixelFormat := 0, KeepPixelFormat := 0) {
        pBitmapDest := 0
        If !PixelFormat
            PixelFormat := 0x26200A	; 32-ARGB
        If (KeepPixelFormat = 1)
            PixelFormat := Gdip_GetImagePixelFormat(pBitmap, 1)
        If (y = "")
            y := 0
        If (x = "")
            x := 0
        If (!w && !h)
            Gdip_GetImageDimensions(pBitmap, &w, &h)

        E := DllCall("gdiplus\GdipCloneBitmapArea"
            , "float", x, "float", y
            , "float", w, "float", h
            , "int", PixelFormat
            , "UPtr", pBitmap
            , "UPtr*", &pBitmapDest)
        return pBitmapDest
    }
     
} catch Error As e {
    ;LogWrite.Info("MyGdip2 Error" e.Message)
    MsgBox("异常消息: " e.Message "`n 异常原因: " e.What "`n Specifically: " e.Extra "`n 异常发生所在文件: " e.File "`n 异常发生所在行数: " e.Line "`n 异常有关调用栈: " e.Stack)
}