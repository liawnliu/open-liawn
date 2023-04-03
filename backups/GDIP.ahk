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
        ; should use Format("{1:#x}", ARGB)
    }
    Gdip_CreateBitmapFromHBITMAP(hBitmap, hPalette := 0) {
        ; Creates a Bitmap GDI+ object from a GDI bitmap handle.
        ; hPalette - Handle to a GDI palette used to define the bitmap colors
        ; if the hBitmap is a device-dependent bitmap [DDB].

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
        } Else
        {
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

        If (Quality != 75)
        {
            Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
            If (quality > 90 && toBase64 = 1)
                Quality := 90

            If RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$")
            {
                DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", &nSize)
                EncoderParameters := Buffer(nSize, 0)
                DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, EncoderParameters.ptr)
                nCount := NumGet(EncoderParameters, "UInt")
                N := (SubStr(A_AhkVersion, 1, 1) < 2) ? nCount : "nCount"
                Loop %N%
                {
                    elem := (24 + A_PtrSize) * (A_Index - 1) + 4 + (pad := (A_PtrSize = 8) ? 4 : 0)
                    If (NumGet(EncoderParameters, elem + 16, "UInt") = 1) && (NumGet(EncoderParameters, elem + 20, "UInt") = 6)
                    {
                        _p := elem + EncoderParameters.ptr - pad - 4
                        NumPut(Quality, NumGet(NumPut(4, NumPut(1, _p + 0, "UPtr") + 20, "UInt"), "UPtr"), "UInt")
                        Break
                    }
                }
            }
        }

        If (toBase64 = 1)
        {
            ; part of the function extracted from ImagePut by iseahound
            ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=76301&sid=bfb7c648736849c3c53f08ea6b0b1309
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

            ; Using CryptBinaryToStringA saves about 2MB in memory.
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
        ; modified by Marius Șucan to help avoid crashes
        ; by disposing a non-existent pBitmap

        If (StrLen(pBitmap) <= 2 && noErr = 1)
            Return 0

        r := DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
        If (r = 2 || r = 1) && (noErr = 1)
            r := 0
        Return r
    }
    Gdip_CompareBitmaps(pBitmapA, pBitmapB, accuracy := 25) {
        ; On success, it returns the percentage of similarity between the given pBitmaps.
        ; If the given pBitmaps do not have the same resolution,
        ; the return value is -1.
        ;
        ; Function by Tic, from June 2010
        ; Source: https://autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/page-27
        ;
        ; Warning: it can be very slow with really large images and high accuracy.
        ;
        ; Updated and modified by Marius Șucan in September 2019.
        ; Added accuracy factor.

        If (accuracy > 99)
            accuracy := 100
        Else If (accuracy < 5)
            accuracy := 5

        Gdip_GetImageDimensions(pBitmapA, &WidthA, &HeightA)
        Gdip_GetImageDimensions(pBitmapB, &WidthB, &HeightB)
        If (accuracy != 100)
        {
            pBitmap1 := Gdip_ResizeBitmap(pBitmapA, Floor(WidthA * (accuracy / 100)), Floor(HeightA * (accuracy / 100)), 0, 5)
            pBitmap2 := Gdip_ResizeBitmap(pBitmapB, Floor(WidthB * (accuracy / 100)), Floor(HeightB * (accuracy / 100)), 0, 5)
        } Else
        {
            pBitmap1 := pBitmapA
            pBitmap2 := pBitmapB
        }

        Gdip_GetImageDimensions(pBitmap1, &Width1, &Height1)
        Gdip_GetImageDimensions(pBitmap2, &Width2, &Height2)
        if (!Width1 || !Height1 || !Width2 || !Height2
            || Width1 != Width2 || Height1 != Height2)
            Return -1

        E1 := Gdip_LockBits(pBitmap1, 0, 0, Width1, Height1, &Stride1, &Scan01, &BitmapData1)
        E2 := Gdip_LockBits(pBitmap2, 0, 0, Width2, Height2, &Stride2, &Scan02, &BitmapData2)
        z := 0, y := 0
        Loop Height1
        {
            y++
            Loop Width1
            {
                Gdip_FromARGB(Gdip_GetLockBitPixel(Scan01, A_Index - 1, y - 1, Stride1), &A1, &R1, &G1, &B1)
                Gdip_FromARGB(Gdip_GetLockBitPixel(Scan02, A_Index - 1, y - 1, Stride2), &A2, &R2, &G2, &B2)
                z += Abs(A2 - A1) + Abs(R2 - R1) + Abs(G2 - G1) + Abs(B2 - B1)
            }
        }

        Gdip_UnlockBits(pBitmap1, &BitmapData1), Gdip_UnlockBits(pBitmap2, &BitmapData2)
        If (accuracy != 100)
        {
            Gdip_DisposeImage(pBitmap1)
            Gdip_DisposeImage(pBitmap2)
        }
        Return z / (Width1 * Width2 * 3 * 255 / 100)
    }
    Gdip_GetLockBitPixel(Scan0, x, y, Stride) {
        return NumGet(Scan0 + 0, (x * 4) + (y * Stride), "UInt")
    }
    Gdip_UnlockBits(pBitmap, &BitmapData) {
        Static Ptr := "UPtr"
        return DllCall("Gdiplus\GdipBitmapUnlockBits", Ptr, pBitmap, Ptr, BitmapData.ptr)
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
    DestroyIcon(hIcon) {
        return DllCall("DestroyIcon", "UPtr", hIcon)
    }
    CreateRect(&Rect, x, y, x2, y2) {
        ; modified by Marius Șucan according to dangerdogL2121
        ; found on https://autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/page-93

        Rect := Buffer(16)
        NumPut("UInt", x, Rect, 0), NumPut("UInt", y, Rect, 4)
        NumPut("UInt", x2, Rect, 8), NumPut("UInt", y2, Rect, 12)
    }
    Gdip_FromARGB(ARGB, &A, &R, &G, &B) {
        A := (0xff000000 & ARGB) >> 24
        R := (0x00ff0000 & ARGB) >> 16
        G := (0x0000ff00 & ARGB) >> 8
        B := 0x000000ff & ARGB
    }
    ; KeepPixelFormat can receive a specific PixelFormat.
    Gdip_ResizeBitmap(pBitmap, givenW, givenH, KeepRatio, InterpolationMode := "", KeepPixelFormat := 0, checkTooLarge := 0) {
        ; The function returns a pointer to a new pBitmap.
        ; Default is 0 = 32-ARGB.
        ; For maximum speed, use 0xE200B - 32-PARGB pixel format.

        Gdip_GetImageDimensions(pBitmap, &Width, &Height)
        If (KeepRatio = 1)
        {
            calcIMGdimensions(Width, Height, givenW, givenH, &ResizedW, &ResizedH)
        } Else
        {
            ResizedW := givenW
            ResizedH := givenH
        }

        If (((ResizedW * ResizedH > 536848912) || (ResizedW > 32100) || (ResizedH > 32100)) && checkTooLarge = 1)
            Return

        PixelFormat := ""
        PixelFormatReadable := Gdip_GetImagePixelFormat(pBitmap, 2)
        If (KeepPixelFormat = 1)
            PixelFormat := Gdip_GetImagePixelFormat(pBitmap, 1)
        Else If (KeepPixelFormat = -1)
            PixelFormat := "0xE200B"
        Else If Strlen(KeepPixelFormat) > 3
            PixelFormat := KeepPixelFormat

        If InStr(PixelFormatReadable, "indexed")
        {
            hbm := CreateDIBSection(ResizedW, ResizedH, , 24)
            hdc := CreateCompatibleDC()
            obm := SelectObject(hdc, hbm)
            G := Gdip_GraphicsFromHDC(hdc, InterpolationMode, 4)
            Gdip_DrawImageRect(G, pBitmap, 0, 0, ResizedW, ResizedH)
            newBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
            If (KeepPixelFormat = 1)
                Gdip_BitmapSetColorDepth(newBitmap, SubStr(PixelFormatReadable, 1, 1), 1)
            SelectObject(hdc, obm)
            DeleteObject(hbm)
            DeleteDC(hdc)
            Gdip_DeleteGraphics(G)
        } Else
        {
            newBitmap := Gdip_CreateBitmap(ResizedW, ResizedH, PixelFormat)
            G := Gdip_GraphicsFromImage(newBitmap, InterpolationMode)
            Gdip_DrawImageRect(G, pBitmap, 0, 0, ResizedW, ResizedH)
            Gdip_DeleteGraphics(G)
        }

        Return newBitmap
    }
    Gdip_GraphicsFromImage(pBitmap, InterpolationMode := "", SmoothingMode := "", PageUnit := "", CompositingQuality := "") {
        pGraphics := 0
        DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", &pGraphics)
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
    Gdip_CreateBitmap(Width, Height, PixelFormat := 0, Stride := 0, Scan0 := 0) {
        ; By default, this function creates a new 32-ARGB bitmap.
        ; modified by Marius Șucan

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
    Gdip_BitmapSetColorDepth(pBitmap, bitsDepth, useDithering := 1) {
        ; Return 0 = OK - Success

        ditheringMode := (useDithering = 1) ? 9 : 1
        If (useDithering = 1 && bitsDepth = 16)
            ditheringMode := 2

        Colors := 2 ** bitsDepth
        If (bitsDepth >= 2) and (bitsDepth <= 4)
            bitsDepth := "40s"
        If (bitsDepth >= 5) and (bitsDepth <= 8)
            bitsDepth := "80s"

        If (bitsDepth = "BW")
            E := Gdip_BitmapConvertFormat(pBitmap, 0x30101, ditheringMode, 2, 2, 2, 2, 0, 0)
        Else If (bitsDepth = 1)
            E := Gdip_BitmapConvertFormat(pBitmap, 0x30101, ditheringMode, 1, 2, 1, 2, 0, 0)
        Else If (bitsDepth = "40s")
            E := Gdip_BitmapConvertFormat(pBitmap, 0x30402, ditheringMode, 1, Colors, 1, Colors, 0, 0)
        Else If (bitsDepth = "80s")
            E := Gdip_BitmapConvertFormat(pBitmap, 0x30803, ditheringMode, 1, Colors, 1, Colors, 0, 0)
        Else If (bitsDepth = 16)
            E := Gdip_BitmapConvertFormat(pBitmap, 0x21005, ditheringMode, 1, Colors, 1, Colors, 0, 0)
        Else If (bitsDepth = 24)
            E := Gdip_BitmapConvertFormat(pBitmap, 0x21808, 2, 1, 0, 0, 0, 0, 0)
        Else If (bitsDepth = 32)
            E := Gdip_BitmapConvertFormat(pBitmap, 0x26200A, 2, 1, 0, 0, 0, 0, 0)
        Else
            E := -1
        Return E
    }
    Gdip_BitmapConvertFormat(pBitmap, PixelFormat, DitherType, DitherPaletteType, PaletteEntries, PaletteType, OptimalColors, UseTransparentColor := 0, AlphaThresholdPercent := 0) {
        ; pBitmap - Handle to a pBitmap object on which the color conversion is applied.

        ; PixelFormat options: see Gdip_GetImagePixelFormat()
        ; Pixel format constant that specifies the new pixel format.

        ; PaletteEntries    Number of Entries.
        ; OptimalColors   - Integer that specifies the number of colors you want to have in an optimal palette based on a specified pBitmap.
        ;                   This parameter is relevant if PaletteType parameter is set to PaletteTypeOptimal [1].
        ; UseTransparentColor     Boolean value that specifies whether to include the transparent color in the palette.
        ; AlphaThresholdPercent - Real number in the range 0.0 through 100.0 that specifies which pixels in the source bitmap will map to the transparent color in the converted bitmap.
        ;
        ; PaletteType options:
        ; Custom = 0   ; Arbitrary custom palette provided by caller.
        ; Optimal = 1   ; Optimal palette generated using a median-cut algorithm.
        ; FixedBW = 2   ; Black and white palette.
        ;
        ; Symmetric halftone palettes. Each of these halftone palettes will be a superset of the system palette.
        ; e.g. Halftone8 will have its 8-color on-off primaries and the 16 system colors added. With duplicates removed, that leaves 16 colors.
        ; FixedHalftone8 = 3   ; 8-color, on-off primaries
        ; FixedHalftone27 = 4   ; 3 intensity levels of each color
        ; FixedHalftone64 = 5   ; 4 intensity levels of each color
        ; FixedHalftone125 = 6   ; 5 intensity levels of each color
        ; FixedHalftone216 = 7   ; 6 intensity levels of each color
        ;
        ; Assymetric halftone palettes. These are somewhat less useful than the symmetric ones, but are included for completeness.
        ; These do not include all of the system colors.
        ; FixedHalftone252 = 8   ; 6-red, 7-green, 6-blue intensities
        ; FixedHalftone256 = 9   ; 8-red, 8-green, 4-blue intensities
        ;
        ; DitherType options:
        ; None = 0
        ; Solid = 1
        ; - it picks the nearest matching color with no attempt to halftone or dither. May be used on an arbitrary palette.
        ;
        ; Ordered dithers and spiral dithers must be used with a fixed palette.
        ; NOTE: DitherOrdered4x4 is unique in that it may apply to 16bpp conversions also.
        ; Ordered4x4 = 2
        ; Ordered8x8 = 3
        ; Ordered16x16 = 4
        ; Ordered91x91 = 5
        ; Spiral4x4 = 6
        ; Spiral8x8 = 7
        ; DualSpiral4x4 = 8
        ; DualSpiral8x8 = 9
        ; ErrorDiffusion = 10   ; may be used with any palette
        ; Return 0 = OK - Success

        hPalette := Buffer(4 * PaletteEntries + 8, 0)

        ; tPalette := DllStructCreate("uint Flags; uint Count; uint ARGB[" & $iEntries & "];")
        NumPut("UInt", PaletteType, hPalette, 0)
        NumPut("UInt", PaletteEntries, hPalette, 4)
        NumPut("UInt", 0, hPalette, 8)

        Static Ptr := "UPtr"
        E1 := DllCall("gdiplus\GdipInitializePalette", "UPtr", hPalette.ptr, "uint", PaletteType, "uint", OptimalColors, "Int", UseTransparentColor, Ptr, pBitmap)
        E2 := DllCall("gdiplus\GdipBitmapConvertFormat", Ptr, pBitmap, "uint", PixelFormat, "uint", DitherType, "uint", DitherPaletteType, "uPtr", hPalette.ptr, "float", AlphaThresholdPercent)
        E := E1 ? E1 : E2
        Return E
    }
    Gdip_DrawImageRect(pGraphics, pBitmap, X, Y, W, H) {
        ; X, Y - the coordinates of the destination upper-left corner
        ; where the pBitmap will be drawn.
        ; W, H - the width and height of the destination rectangle, where the pBitmap will be drawn.

        Static Ptr := "UPtr"
        _E := DllCall("gdiplus\GdipDrawImageRect"
            , Ptr, pGraphics
            , Ptr, pBitmap
            , "float", X, "float", Y
            , "float", W, "float", H)
        return _E
    }
    calcIMGdimensions(imgW, imgH, givenW, givenH, &ResizedW, &ResizedH) {
        ; This function calculates from original imgW and imgH
        ; new image dimensions that maintain the aspect ratio
        ; and are within the boundaries of givenW and givenH.
        ;
        ; imgW, imgH         - original image width and height [in pixels]
        ; givenW, givenH     - the width and height to adapt to [in pixels]
        ; ResizedW, ResizedH - the width and height resulted from adapting imgW, imgH to givenW, givenH
        ;                      by keeping the aspect ratio

        PicRatio := Round(imgW / imgH, 5)
        givenRatio := Round(givenW / givenH, 5)
        If (imgW <= givenW) && (imgH <= givenH)
        {
            ResizedW := givenW
            ResizedH := Round(ResizedW / PicRatio)
            If (ResizedH > givenH)
            {
                ResizedH := (imgH <= givenH) ? givenH : imgH
                ResizedW := Round(ResizedH * PicRatio)
            }
        } Else If (PicRatio > givenRatio)
        {
            ResizedW := givenW
            ResizedH := Round(ResizedW / PicRatio)
        } Else
        {
            ResizedH := (imgH >= givenH) ? givenH : imgH	;set the maximum picture height to the original height
            ResizedW := Round(ResizedH * PicRatio)
        }
    }
    Gdip_GetImagePixelFormat(pBitmap, mode := 0) {
        ; Mode options
        ; 0 - in decimal
        ; 1 - in hex
        ; 2 - in human readable format
        ;
        ; PXF01INDEXED = 0x00030101  ; 1 bpp, indexed
        ; PXF04INDEXED = 0x00030402  ; 4 bpp, indexed
        ; PXF08INDEXED = 0x00030803  ; 8 bpp, indexed
        ; PXF16GRAYSCALE = 0x00101004; 16 bpp, grayscale
        ; PXF16RGB555 = 0x00021005   ; 16 bpp; 5 bits for each RGB
        ; PXF16RGB565 = 0x00021006   ; 16 bpp; 5 bits red, 6 bits green, and 5 bits blue
        ; PXF16ARGB1555 = 0x00061007 ; 16 bpp; 1 bit for alpha and 5 bits for each RGB component
        ; PXF24RGB = 0x00021808   ; 24 bpp; 8 bits for each RGB
        ; PXF32RGB = 0x00022009   ; 32 bpp; 8 bits for each RGB, no alpha.
        ; PXF32ARGB = 0x0026200A  ; 32 bpp; 8 bits for each RGB and alpha
        ; PXF32PARGB = 0x000E200B ; 32 bpp; 8 bits for each RGB and alpha, pre-mulitiplied
        ; PXF48RGB = 0x0010300C   ; 48 bpp; 16 bits for each RGB
        ; PXF64ARGB = 0x0034400D  ; 64 bpp; 16 bits for each RGB and alpha
        ; PXF64PARGB = 0x001A400E ; 64 bpp; 16 bits for each RGB and alpha, pre-multiplied

        ; INDEXED [1-bits, 4-bits and 8-bits] pixel formats rely on color palettes.
        ; The color information for the pixels is stored in palettes.
        ; Indexed images always contain a palette - a special table of colors.
        ; Each pixel is an index in this table. Usually a palette contains 256
        ; or less entries. That's why the maximum depth of an indexed pixel is 8 bpp.
        ; Using palettes is a common practice when working with small color depths.

        ; modified by Marius Șucan

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

    Gdip_CreateBitmapFromFile(sFile, IconNumber := 1, IconSize := "", useICM := 0) {
        Static Ptr := "UPtr"
        PtrA := "UPtr*"
        pBitmap := 0
        pBitmapOld := 0
        hIcon := 0

        SplitPath sFile, , , &Extension
        if RegExMatch(Extension, "^(?i:exe|dll)$")
        {
            Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
            BufSize := 16 + (2 * A_PtrSize)

            buf := Buffer(BufSize, 0)
            For eachSize, Size in StrSplit(Sizes, "|")
            {
                DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber - 1, "int", Size, "int", Size, PtrA, &hIcon, PtrA, 0, "uint", 1, "uint", 0)
                if !hIcon
                    continue

                if !DllCall("GetIconInfo", Ptr, hIcon, Ptr, buf.ptr)
                {
                    DestroyIcon(hIcon)
                    continue
                }

                hbmMask := NumGet(buf, 12 + (A_PtrSize - 4), "UPtr")
                hbmColor := NumGet(buf, 12 + (A_PtrSize - 4) + A_PtrSize, "UPtr")
                if !(hbmColor && DllCall("GetObject", Ptr, hbmColor, "int", BufSize, Ptr, buf.ptr))
                {
                    DestroyIcon(hIcon)
                    continue
                }
                break
            }
            if !hIcon
                return -1

            Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
            hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
            if !DllCall("DrawIconEx", Ptr, hdc, "int", 0, "int", 0, Ptr, hIcon, "uint", Width, "uint", Height, "uint", 0, Ptr, 0, "uint", 3)
            {
                DestroyIcon(hIcon)
                return -2
            }

            dib := Buffer(104)
            DllCall("GetObject", Ptr, hbm, "int", (A_PtrSize = 8) ? 104 : 84, Ptr, dib.ptr)	; sizeof(DIBSECTION) = 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize
            Stride := NumGet(dib, 12, "Int")
            Bits := NumGet(dib, 20 + ((A_PtrSize = 8) ? 4 : 0), "UPtr")	; padding
            pBitmapOld := Gdip_CreateBitmap(Width, Height, 0, Stride, Bits)
            pBitmap := Gdip_CreateBitmap(Width, Height)
            _G := Gdip_GraphicsFromImage(pBitmap)
            Gdip_DrawImage(_G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
            SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
            Gdip_DeleteGraphics(_G), Gdip_DisposeImage(pBitmapOld)
            DestroyIcon(hIcon)
        } else
        {
            function2call := (useICM = 1) ? "GdipCreateBitmapFromFileICM" : "GdipCreateBitmapFromFile"
            E := DllCall("gdiplus\" function2call, "WStr", sFile, PtrA, &pBitmap)
        }

        return pBitmap
    }
    Gdip_DrawImage(pGraphics, pBitmap, dx:="", dy:="", dw:="", dh:="", sx:="", sy:="", sw:="", sh:="", Matrix:=1, Unit:=2, ImageAttr:=0) {
        Static Ptr := "UPtr"
        usrImageAttr := 0
        If !ImageAttr
        {
           if !IsNumber(Matrix)
              ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
           else if (Matrix!=1)
              ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
        } Else usrImageAttr := 1
     
        If (dx!="" && dy!="" && dw="" && dh="" && sx="" && sy="" && sw="" && sh="")
        {
           sx := sy := 0
           sw := dw := Gdip_GetImageWidth(pBitmap)
           sh := dh := Gdip_GetImageHeight(pBitmap)
        } Else If (sx="" && sy="" && sw="" && sh="")
        {
           If (dx="" && dy="" && dw="" && dh="")
           {
              sx := dx := 0, sy := dy := 0
              sw := dw := Gdip_GetImageWidth(pBitmap)
              sh := dh := Gdip_GetImageHeight(pBitmap)
           } Else
           {
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
     
        if (ImageAttr && usrImageAttr!=1)
           Gdip_DisposeImageAttributes(ImageAttr)
     
        return _E
     }
     
    Gdip_DisposeImageAttributes(ImageAttr) {
        return DllCall("gdiplus\GdipDisposeImageAttributes", "UPtr", ImageAttr)
    }
     Gdip_SetImageAttributesColorMatrix(clrMatrix, ImageAttr:=0, grayMatrix:=0, ColorAdjustType:=1, fEnable:=1, ColorMatrixFlag:=0) {
        Static Ptr := "UPtr"
        GrayscaleMatrix := 0
        
        If (StrLen(clrMatrix)<5 && ImageAttr)
           Return -1
     
        If StrLen(clrMatrix)<5
           Return
     
        ColourMatrix := Buffer(100, 0)
        Matrix := RegExReplace(RegExReplace(clrMatrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
        Matrix := StrSplit(Matrix, "|")
        Loop 25
        {
           M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1, 6) ? 0 : 1
           NumPut("Float", M, ColourMatrix, (A_Index-1)*4)
        }
     
        Matrix := ""
        Matrix := RegExReplace(RegExReplace(grayMatrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
        Matrix := StrSplit(Matrix, "|")
        If (StrLen(Matrix)>2 && ColorMatrixFlag=2)
        {
           GrayscaleMatrix := Buffer(100, 0)
           Loop 25
           {
              M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1, 6) ? 0 : 1
              NumPut("Float", M, GrayscaleMatrix, (A_Index-1)*4)
           }
        }
     
        If !ImageAttr
        {
           created := 1
           ImageAttr := Gdip_CreateImageAttributes()
        }
     
        E := DllCall("gdiplus\GdipSetImageAttributesColorMatrix"
              , Ptr, ImageAttr
              , "int", ColorAdjustType
              , "int", fEnable
              , Ptr, ColourMatrix.ptr
              , Ptr, GrayscaleMatrix?GrayscaleMatrix.ptr:0
              , "int", ColorMatrixFlag)
     
        E := created=1 ? ImageAttr : E
        return E
     }
      
 Gdip_CreateImageAttributes() {
    ImageAttr := 0
    DllCall("gdiplus\GdipCreateImageAttributes", "UPtr*", &ImageAttr)
    return ImageAttr
 }
} catch Error As e {
    ;LogWrite.Info("MyGdip2 Error" e.Message)
    MsgBox("异常消息: " e.Message "`n 异常原因: " e.What "`n Specifically: " e.Extra "`n 异常发生所在文件: " e.File "`n 异常发生所在行数: " e.Line "`n 异常有关调用栈: " e.Stack)
}