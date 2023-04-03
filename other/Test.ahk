^q::IME_SET(0)
^w::IME_SET(1)

IME_SET(state)
{
	hwnd := WinExist("A")
	DllCall("SendMessage"
          , Ptr, DllCall("imm32\ImmGetDefaultIMEWnd", Ptr, hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          , UPtr, 0x0006   ;wParam  : IMC_SETOPENSTATUS
          ,  Ptr, state) ;lParam  : 0 or 1

}

/*
GetGUIThreadInfo_hwndActive(WinTitle="A")
{
	ControlGet, hwnd, HWND,,, %WinTitle%
	if (WinActive(WinTitle)) {
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
		VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
		NumPut(cbSize, stGTI,  0, "UInt")
		return hwnd := DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", &stGTI)
				 ? NumGet(stGTI, 8+PtrSize, "Ptr") : hwnd
	}
	else {
		return hwnd
	}
}
IME_SET(SetSts, WinTitle="A")    {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    MsgBox %hwnd%
    return DllCall("SendMessage"
          , Ptr, DllCall("imm32\ImmGetDefaultIMEWnd", Ptr, hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          , UPtr, 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  Ptr, SetSts) ;lParam  : 0 or 1
}
*/