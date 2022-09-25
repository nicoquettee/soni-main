#if cpp
import cpp.ConstCharStar;
#end

#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')

@:headerCode('
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
')
#elseif linux
@:headerCode("#include <stdio.h>")
#end

class CppFuncs {
    
    #if windows
	@:functionCode('
        int darkMode = mode;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
	@:noCompletion
	public static function _setWindowColorMode(mode:Int)
	{
	}

	public static function setWindowColorMode(mode:WindowColorMode)
	{
		var darkMode:Int = cast(mode, Int);

		if (darkMode > 1 || darkMode < 0)
		{
			trace("WindowColorMode Not Found...");

			return;
		}

		_setWindowColorMode(darkMode);
    }

    @:functionCode('
	HWND window = GetActiveWindow();
	SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
	')
	@:noCompletion
	public static function _setWindowLayered()
	{
	}

	@:functionCode('
        HWND window = GetActiveWindow();

		float a = alpha;

		if (alpha > 1) {
			a = 1;
		} 
		if (alpha < 0) {
			a = 0;
		}

       	SetLayeredWindowAttributes(window, 0, (255 * (a * 100)) / 100, LWA_ALPHA);

    ')
	public static function setWindowAlpha(alpha:Float)
	{
		return alpha;
    } // thanks lunarclient for this
    
    @:functionCode('
        HWND window = GetActiveWindow();

        // make window layered
        alpha = SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        SetLayeredWindowAttributes(window, 0, 0, 0x00000001);
    ')
    public static function setWindowTransparencyColor(red:Int, green:Int, blue:Int, alpha:Int) {
        return alpha;
    }

    @:functionCode('
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PVOID(p), SPIF_UPDATEINIFILE);
    ') 
    public static function systemParametersInfo(p:ConstCharStar):Bool { 
        return true; 
    }
    #end

    #if windows
	@:functionCode("
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);

		return (allocatedRAM / 1024);
	")
	#elseif linux
	@:functionCode('
		FILE *meminfo = fopen("/proc/meminfo", "r");

    	if(meminfo == NULL)
			return -1;

    	char line[256];
    	while(fgets(line, sizeof(line), meminfo))
    	{
        	int ram;
        	if(sscanf(line, "MemTotal: %d kB", &ram) == 1)
        	{
            	fclose(meminfo);
            	return (ram / 1024);
        	}
    	}

    	fclose(meminfo);
    	return -1;
	')
	#end
	public static function obtainRAM()
	{
		return 0;
    }
    
    public static function messageBox(title:ConstCharStar = null, msg:ConstCharStar = null, type:Int = null)
	{
        #if windows
        switch(type)
        {
            case 0: //HAND - OK
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONHAND | MB_OK"));
            case 1: //HAND - OK CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONHAND | MB_OKCANCEL"));
            case 2: //HAND - ABORT RETRY IGNORE
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONHAND | MB_ABORTRETRYIGNORE"));
            case 3: //HAND - YES NO CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONHAND | MB_YESNOCANCEL"));
            case 4: //HAND - YES NO
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONHAND | MB_YESNO"));
            case 5: //HAND - RETRY CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONHAND | MB_RETRYCANCEL"));
            case 6: //QUESTION - OK
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONQUESTION | MB_OK"));
            case 7: //QUESTION - OK CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONQUESTION | MB_OKCANCEL"));
            case 8: //QUESTION - ABORT RETRY IGNORE
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONQUESTION | MB_ABORTRETRYIGNORE"));
            case 9: //QUESTION - YES NO CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONQUESTION | MB_YESNOCANCEL"));
            case 10: //QUESTION - YES NO
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONQUESTION | MB_YESNO"));
            case 11: //QUESTION - RETRY CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONQUESTION | MB_RETRYCANCEL"));
            case 12: //EXCLAMATION - OK
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONEXCLAMATION | MB_OK"));
            case 13: //EXCLAMATION - OK CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONEXCLAMATION | MB_OKCANCEL"));
            case 14: //EXCLAMATION - ABORT RETRY IGNORE
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE"));
            case 15: //EXCLAMATION - YES NO CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONEXCLAMATION | MB_YESNOCANCEL"));
            case 16: //EXCLAMATION - YES NO
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONEXCLAMATION | MB_YESNO"));
            case 17: //EXCLAMATION - RETRY CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONEXCLAMATION | MB_RETRYCANCEL"));
            case 18: //ASTERISK - OK
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONASTERISK | MB_OK"));
            case 19: //ASTERISK - OK CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONASTERISK | MB_OKCANCEL"));
            case 20: //ASTERISK - ABORT RETRY IGNORE
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONASTERISK | MB_ABORTRETRYIGNORE"));
            case 21: //ASTERISK - YES NO CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONASTERISK | MB_YESNOCANCEL"));
            case 22: //ASTERISK - YES NO
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONASTERISK | MB_YESNO"));
            case 23: //ASTERISK - RETRY CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONASTERISK | MB_RETRYCANCEL"));
            case 24: //STOP - OK
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONSTOP | MB_OK"));
            case 25: //STOP - OK CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONSTOP | MB_OKCANCEL"));
            case 26: //STOP - ABORT RETRY IGNORE
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONSTOP | MB_ABORTRETRYIGNORE"));
            case 27: //STOP - YES NO CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONSTOP | MB_YESNOCANCEL"));
            case 28: //STOP - YES NO
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONSTOP | MB_YESNO"));
            case 29: //STOP - RETRY CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONSTOP | MB_RETRYCANCEL"));
            case 30: //ERROR - OK
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONERROR | MB_OK"));
            case 31: //ERROR - OK CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONERROR | MB_OKCANCEL"));
            case 32: //ERROR - ABORT RETRY IGNORE
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONERROR | MB_ABORTRETRYIGNORE"));
            case 33: //ERROR - YES NO CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONERROR | MB_YESNOCANCEL"));
            case 34: //ERROR - YES NO
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONERROR | MB_YESNO"));
            case 35: //ERROR - RETRY CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONERROR | MB_RETRYCANCEL"));
            case 36: //WARNING - OK
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONWARNING | MB_OK"));
            case 37: //WARNING - OK CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONWARNING | MB_OKCANCEL"));
            case 38: //WARNING - ABORT RETRY IGNORE
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONWARNING | MB_ABORTRETRYIGNORE"));
            case 39: //WARNING - YES NO CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONWARNING | MB_YESNOCANCEL"));
            case 40: //WARNING - YES NO
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONWARNING | MB_YESNO"));
            case 41: //WARNING - RETRY CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONWARNING | MB_RETRYCANCEL"));
            case 42: //INFORMATION - OK
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONINFORMATION | MB_OK"));
            case 43: //INFORMATION - OK CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONINFORMATION | MB_OKCANCEL"));
            case 44: //INFORMATION - ABORT RETRY IGNORE
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONINFORMATION | MB_ABORTRETRYIGNORE"));
            case 45: //INFORMATION - YES NO CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONINFORMATION | MB_YESNOCANCEL"));
            case 46: //INFORMATION - YES NO
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONINFORMATION | MB_YESNO"));
            case 47: //INFORMATION - RETRY CANCEL
                var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONINFORMATION | MB_RETRYCANCEL"));
        } //yeah... 
        //var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICON | MB_"));
		return true;
		#else
		lime.app.Application.current.window.alert(cast msg, cast title);
		return true;
		#end
    }
}

@:enum abstract WindowColorMode(Int)
{
	var DARK:WindowColorMode = 1;
	var LIGHT:WindowColorMode = 0;
}