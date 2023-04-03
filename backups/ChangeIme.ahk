; 中英文输入环境切换
ChangeIme(state)
{
	hwnd := WinExist("A")
	DllCall("SendMessage"
		, Ptr, DllCall("imm32\ImmGetDefaultIMEWnd", Ptr, hwnd)
		, UInt, 0x0283	;Message : WM_IME_CONTROL
		, UPtr, 0x0006	;wParam  : IMC_SETOPENSTATUS
		, Ptr, state)	;lParam  : 0 or 1
}