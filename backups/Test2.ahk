!q:: Main()
; 空间关联的变量必须是全局或者静态的
global MyListBox := ""
; 主入口
Main() {
	; 设置脚本是否可以 "看见" 隐藏的窗口.
	DetectHiddenWindows , On
	if (WinExist(A_ScriptName)) {	; 已存在只是隐藏起来了
		FileAppend , "将隐藏的GUI打开`n", A_WorkingDir "\log\HelpMouseinc.log"
		WinShow
		WinActivate
		Sleep , 50
		GuiControl , Focus, MyListBox
		ChangeIme(0)	; 切换成英文输入模式
		DetectHiddenWindows Off
	} else {	; 未生成，需要新建GUI
		FileAppend , "Create a New Window`n", A_WorkingDir "\log\HelpMouseinc.log"
		process := []
		process.Push({key: "G", value: "Google Chrome"}
			, {key: "F", value: "File Manager"}
			, {key: "V", value: "Visual Studio Code"}
			, {key: "E", value: "EditPlus"}
			, {key: "N", value: "Navicat"}
			, {key: "M", value: "MobaXterm"})
		CreateWindow(process)
	}
	return
}
CreateWindow(process) {
	processSize := process.MaxIndex()
	;Gui, OpenProcee:New, +AlwaysOnTop -MaximizeBox +ToolWindow +Owner
	Gui , +AlwaysOnTop - MaximizeBox + ToolWindow + Owner
	Gui , font, s15, Verdana
	; 隐藏窗口，只显示控件
	Gui , Color, EEAA99
	Gui +LastFound	; 让 GUI 窗口成为上次找到的窗口以用于下一行的命令.
	WinSet , TransColor, EEAA99
	Gui , -Caption
	; 第二个样式就是设置控件颜色
	Gui , Color, , eff0f1
	; ListBox是控件类型，vMyListBox是关联变量（静态或者全局），r是多少行（多少项）
	Gui , Add, ListBox, vMyListBox r%processSize%
	For index, obj in process
	{
		key := obj.key
		value := obj.value
		; 将新内容放入控件
		GuiControl , , MyListBox, %value%(%key%)
	}
	Gui , Show, xCenter y20
	GuiControl , Choose, MyListBox, 1
	GuiControl , Focus, MyListBox
	ChangeIme(0)	; 切换成英文输入模式
	OnMessage(0x001C, "WM_ACTIVATEAPP")	;当属于与活动窗口不同的应用程序的窗口即将激活时
	OnMessage(0x0100, "WM_KEYDOWN")
	OnMessage(0x0104, "WM_SYSKEYDOWN")
	OnMessage(0x0202, "WM_LBUTTONUP")
	return
}
; GUI失活激活
WM_ACTIVATEAPP(wParam, lParam, msg, hwnd) {
	FileAppend , "WM_ACTIVATEAPP：" %wParam% "，" %lParam% "，" %msg% "，" %hwnd% "`n", A_WorkingDir "\log\HelpMouseinc.log"
	if (wParam == 0) {	; 0是失活
		Gui , Cancel
	}

}
; 非系统按键，但要注意229问题（用强制英文输入环境避免）
WM_KEYDOWN(wParam, lParam, msg, hwnd) {
	FileAppend , "WM_KEYDOWN" %wParam% "，" %lParam% "，" %msg% "，" %hwnd% "`n", A_WorkingDir "\log\HelpMouseinc.log"
	if (wParam == 71) {	;G g chrome 229
		OpenWindow("Chrome", "C:\Program Files\Google\Chrome\Application\chrome.exe")
	} else if (wParam == 70) {	; F f filemanager
		Send "#e"
	} else if (wParam == 86) {	; V v vscode
		OpenWindow("Visual Studio Code", "D:\Microsoft VS Code\Code.exe")
	} else if (wParam == 69) {	; E e EditPlus
		OpenWindow("EditPlus", "D:\EditPlus\EditPlus.exe")
	} else if (wParam == 78) {	; E e EditPlus
		OpenWindow("Navicat", "D:\Navicat Premium 15\navicat.exe")
	} else if (wParam == 77) {	; M m MobaXterm
		OpenWindow("MobaXterm", "D:\MobaXterm_Portable_v21.4\MobaXterm_Personal_21.4.exe")
	} else if (wParam == 13) {	; Enter
		GuiControlGet , nowValue, , MyListBox	; 取出最新数据保存
		FileAppend , "nowValue1" %nowValue% `n, A_WorkingDir "\log\HelpMouseinc.log"
		GetItem(nowValue)
	} else if (wParam == 20 || wParam == 38 || wParam == 40) {
		return
	}
	Gui , Cancel
}
; 系统按键
WM_SYSKEYDOWN(wParam, lParam, msg, hwnd) {
	FileAppend , "WM_SYSKEYDOWN" %wParam% "，" %lParam% "，" %msg% "，" %hwnd% "`n", A_WorkingDir "\log\HelpMouseinc.log"
	Gui , Cancel
}
WM_LBUTTONUP(wParam, lParam, msg, hwnd) {
	;FileAppend, "WM_LBUTTONUP" %wParam% "，" %lParam% "，" %msg% "，" %hwnd% `n, E:\AhkWorkSpace\Lopen\log\HelpMouseinc.log, UTF-8
	GuiControlGet , nowValue, , MyListBox	; 取出最新数据保存
	FileAppend , "nowValue2" %nowValue% `n, A_WorkingDir "\log\HelpMouseinc.log"
	GetItem(nowValue)
}
; 回车得到的
GetItem(item) {
	FileAppend , "GetItem" %item% `n, A_WorkingDir "\log\HelpMouseinc.log"
	try {
		item := Trim(item)
		key := StrSplit(item, "(", ")")[2]
		if (key == "G") {	; G chrome
			OpenWindow("Chrome", "C:\Program Files\Google\Chrome\Application\chrome.exe")
		} else if (key == "F") {	; F filemanager
			Send "#e"
		} else if (key == "V") {	; V vscode
			OpenWindow("Visual Studio Code", "D:\Microsoft VS Code\Code.exe")
		} else if (key == "E") {	; E EditPlus
			OpenWindow("EditPlus", "D:\EditPlus\EditPlus.exe")
		} else if (key == "N") {	; N Navicat
			OpenWindow("Navicat", "D:\Navicat Premium 15\navicat.exe")
		} else if (key == "M") {	; M m MobaXterm
			OpenWindow("MobaXterm", "D:\MobaXterm_Portable_v21.4\MobaXterm_Personal_21.4.exe")
		} else {
		}
	} catch {
		MsgBox exePath . " run error."
	}
}
; 查看name所属的窗口是否存在，存在就激活，不存在就运行exePath
OpenWindow(name, exePath) {
	SetTitleMatchMode , 2	;窗口标题的任意位置包含 WinTitle 才能匹配
	if (WinExist(name)) {
		WinActivate
	} else {
		try {
			Run %exePath%
		} catch {
			MsgBox exePath . " run error."
		}
	}
}
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