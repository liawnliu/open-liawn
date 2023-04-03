~^c::
{
	FileAppend, "剪切板1：" %clipboard% `n, D:\MouseInc2.11.6\MouseInc\Script\log\HelpMouseinc.log, UTF-8
	Sleep 300
	FileAppend, "剪切板2：" %clipboard% `n, D:\MouseInc2.11.6\MouseInc\Script\log\HelpMouseinc.log, UTF-8
	; 临时存储剪切板内容
	tempClipboard := clipboard
	;MsgBox %tempClipboard%
	if (A_PriorHotkey == "~Ctrl & ~c" && A_TimeSincePriorHotkey < 800)
	{
		
		FileAppend, "剪切板内容：" %tempClipboard% `n, D:\MouseInc2.11.6\MouseInc\Script\log\HelpMouseinc.log, UTF-8
		if (tempClipboard == "") {
			clipboard := "1"
			FileAppend, "剪切板新内容：" %clipboard% `n, D:\MouseInc2.11.6\MouseInc\Script\log\HelpMouseinc.log, UTF-8
		}
	}
}
