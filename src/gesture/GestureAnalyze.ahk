class GestureAnalyze {
    threshold := 100 ; 手势相似的阈值，现在是100；数值越大越难判定是相似的
    gestureMsg := ""
    checkAreaRlt := ""
    ; 查看
    checkAreaByDrawPoints(DrawPoints) {
        x1 := 0, x2 := 99999, y1 := 0, y2 := 99999
        Loop DrawPoints.Length {
            point := DrawPoints[A_Index]
            x := point["x"]
            y := point["y"]
            if (x > x1) 
                x1 := x ; 右边界
            if (x < x2) 
                x2 := x ; 左边界
            if (y > y1) 
                y1 := y ; 下边界
            if (y < y2) 
                y2 := y ; 上边界
        }
        this.checkAreaRlt := { left: x2, right: x1, top: y2, down: y1 }
        ; LogWrite.Info("checkAreaByBitmap 左边界: " x2 ", 右边界: " x1 ", 上边界: " y2 ", 下边界: " y1)
        return this.checkAreaRlt
    }
    isEnoughArea(checkAreaRlt) {
        ; 效图形的边界信息
        left := checkAreaRlt.left, right := checkAreaRlt.right
        top := checkAreaRlt.top, down := checkAreaRlt.down
        absX := Abs(left - right)
        absY := Abs(top - down)
        ; 取最长边
        len := absX > absY ? absX : absY
        if (len >= 150) {
            return true
        }
        return false
    }
    ; 分析轨迹
    analysisDrawPoints(DrawPoints) {
        LogWrite.Info("DrawPoints length: " DrawPoints.Length)
        len := DrawPoints.Length
        if (len < 2)
            return 0

        ; 去掉重复的
        indexOne := len
        Loop len {
            indexTwo := indexOne - 1
            if (!indexTwo)
                break
            Point := DrawPoints[indexOne]
            PointTwo := DrawPoints[indexTwo]
            if (Point["x"] == PointTwo["x"] && Point["y"] == PointTwo["y"]) {
                DrawPoints.RemoveAt(indexOne)
            }
            indexOne := indexOne - 1
        }
        len := DrawPoints.Length
        if (len < 2)
            return 0
        
        arr := Array(), arr.Length := len
        course := Array(), course.Length := len
        length := 0
        Loop len {
            if (A_Index == 1) {
                continue
            }
        
            lastPoint := DrawPoints[A_Index-1]
            Point := DrawPoints[A_Index]
            x := Point["x"] - lastPoint["x"]
            y := Point["y"] - lastPoint["y"]
            distance := Sqrt(x*x + y*y)
            length := length + distance
            course[A_Index-1] := length
            arr[A_Index-1] := Map("x", Round(x * 127 / distance), "y", Round(y * 127 / distance))
        }

        gestureMsg := Array(), gestureMsg.length := 128
        j := 1
        Loop 128 {
            i := A_Index
            while ((i - 1) > (course[j] * 128 / length)) {
                j := j + 1
            }
            gestureMsg[i] := arr[j]
        }
        this.gestureMsg := gestureMsg
        return gestureMsg
    }
    ; 单对单进行比较
    Similarity(arr, targetArr) {
        if (!arr.Length || !targetArr.Length) 
            return 0
        
        similarity := 0
        Loop 128 { ; 32258 = 127 * 127 * 2
            similarity := similarity + (32258 - ((arr[A_Index]["x"] - targetArr[A_Index]["x"])**2 + (arr[A_Index]["y"] - targetArr[A_Index]["y"])**2)) / 32258
        }
        return Round(similarity)
    }
    ; 逐一与本地数据进行比对
    checkSimilarity(gestureMsg) {
        gestureArr := Gesture.gestureMsgConfig
        if (!gestureArr)
            return ""
        SimilarityValue := -1
        keyName := ""
        Loop gestureArr.Length {
            tempGestureObj := gestureArr[A_Index]
            ; 逐个去比较
            SimilarityValue := this.Similarity(gestureMsg, tempGestureObj["gestureMsg"])
            ; 暂时认为大于100就很相似了
            if (SimilarityValue > this.threshold) {
                keyName := tempGestureObj["keyName"]
                break
            }
        }
        return keyName
    }
    toSaveMsg(newKeyName, tempArr) {
        if (!DirExist(A_WorkingDir "\config")) {
            DirCreate(A_WorkingDir "\config")
        }
        fileRlt := FileExist(A_WorkingDir "\config\gesture.ini")
        if (fileRlt) {
            gestureConStr := FileRead(A_WorkingDir "\config\gesture.ini")
            gestureCon := Jxon_load(gestureConStr)
            if (!gestureCon || !gestureCon["gesture"]) {
                gestureCon := Map("gesture", [])
                gestureCon["gesture"].push(Map("keyName", newKeyName, "gestureMsg", tempArr))
            } else {
                if (!gestureCon["gesture"].Length) {
                    gestureCon["gesture"] := []
                    gestureCon["gesture"].push(Map("keyName", newKeyName, "gestureMsg", tempArr))
                } else {
                    gestureCon["gesture"].push(Map("keyName", newKeyName, "gestureMsg", tempArr))
                }
            }
            gestureConStr := Jxon_Dump(gestureCon)
            FileObj := FileOpen(A_WorkingDir "\config\gesture.ini", "w", "UTF-8")
            FileObj.Write(gestureConStr)
            FileObj.Close()
        } else {
            gestureCon := Map("gesture", [])
            gestureCon["gesture"].push(Map("keyName", newKeyName, "gestureMsg", tempArr))
            gestureConStr := Jxon_Dump(gestureCon)
            FileAppend(gestureConStr, A_WorkingDir "\config\gesture.ini", "UTF-8")
        }
    }
    ; 将Bitmap保存到saveFilePath
    toSaveImg(Bitmap, saveFilePath) {
        Gdip_SaveBitmapToFile(Bitmap, saveFilePath)
        Gdip_DisposeImage(Bitmap)
    }
    ; 从oldBitmap提取有效图形，最后得到一个宽高都是standardLen的
    ; checkAreaRlt是oldBitmap里的有效区域，得事先用checkArea()进行查询
    handleGestureImg(oldBitmap, checkAreaRlt, padding := 25, standardLen := 200) {
        ; 效图形的边界信息
        left := checkAreaRlt.left, right := checkAreaRlt.right
        top := checkAreaRlt.top, down := checkAreaRlt.down
        absX := Abs(left - right) 
        absY := Abs(top - down) 
        ; 取最长边最为有效图形的宽高
        len := absX > absY ? absX : absY
        ; len不再是新宽高，新宽是newLen
        newLen := len + padding * 2
        ; 保证x/y方向都在矩形内，并且还要加上“填充”，最后还要让短的那一侧显示在中央
        if (absX > absY) { 
            x := left * (-1) + padding ; x,y 在下面有解释
            y := top * (-1) + (Round(newLen/2) -  Round(absY/2))
        } else if (absX < absY){
            y := top * (-1) + padding
            x := left * (-1) + (Round(newLen/2) -  Round(absX/2))
        }
        ;LogWrite.Info("absX: " absX ", absY: " absY ", x: " x ", y: " y)
        ; 以newLen的矩形去裁剪oldBitmap
        newBitmap := this.createBitmapFromBitmap(oldBitmap, x, y, newLen, newLen)
        ; 如果newLen不符合最终标准，resize到宽高都是standardLen
        if (newLen != standardLen) {
            newBitmap := this.resizeBitmap(newBitmap, standardLen, standardLen)
        }
        return newBitmap
    }
    createBitmapFromBitmap(oldBitmap, x, y, nWidth, nHeight) {
        oldWidth := Gdip_GetImageWidth(oldBitmap), oldHeight := Gdip_GetImageHeight(oldBitmap)
        newBitmap := Gdip_CreateBitmap(nWidth, nHeight, 0)
        G := Gdip_GraphicsFromImage(newBitmap, 5)
        ; newBitmap的左上角将于oldBitmap的(x,y)重合，以此达到“裁剪”目的
        Gdip_DrawImageRect(G, oldBitmap, x, y, oldWidth, oldHeight) ; 5\6两个参数一定是oldBitmap原来的宽高
        Gdip_DeleteGraphics(G)
        return newBitmap
    }
    resizeBitmap(oldBitmap, width, height) {
        newBitmap := Gdip_CreateBitmap(width, height, 0)
        G := Gdip_GraphicsFromImage(newBitmap, 5)
        ; 压缩核心所在，oldBitmap和newBitmap左上角重合，但新的Bitmap宽高要是新宽高
        Gdip_DrawImageRect(G, oldBitmap, 0, 0, width, height)
        Gdip_DeleteGraphics(G)
        return newBitmap
    }
    checkAreaByBitmap(Bitmap, bgColor := 0x00000000) {
        width := 0, height := 0
        Gdip_GetImageDimensions(Bitmap, &width, &height)
        Stride := "", Scan0 := "", BitmapData := ""
        E := Gdip_LockBits(Bitmap, 0, 0, width, height, &Stride, &Scan0, &BitmapData)
        x1 := 0, x2 := width - 1, y1 := 0, y2 := height - 1
        Loop width {
            x := A_Index
            Loop height {
                y := A_Index
                argb := Gdip_GetLockBitPixel(Scan0, x-1, y-1, Stride)
                if (argb != bgColor) { ; GestureGui里的背景颜色暂时是0x00000000
                    if (x > x1) 
                        x1 := x ; 右边界
                    if (x < x2) 
                        x2 := x ; 左边界
                    if (y > y1) 
                        y1 := y ; 下边界
                    if (y < y2) 
                        y2 := y ; 上边界
                }
            }
        }
        ; LogWrite.Info("checkAreaByBitmap 左边界: " x2 ", 右边界: " x1 ", 上边界: " y2 ", 下边界: " y1)
        Gdip_UnlockBits(Bitmap, &BitmapData)
        return { left: x2, right: x1, top: y2, down: y1 }
    }
}