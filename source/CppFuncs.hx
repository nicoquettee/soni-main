#if cpp
import cpp.ConstCharStar;
#end

//When yoshicrafter engine
#if windows
@:buildXml('
<compilerflag value="/DelayLoad:ComCtl32.dll"/>

<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
    <lib name="shell32.lib" if="windows" />
    <lib name="gdi32.lib" if="windows" />
</target>
')

@:headerCode('
#pragma comment(linker,"/manifestdependency:\\"type=\'win32\' name=\'Microsoft.Windows.Common-Controls\' " "version=\'6.0.0.0\' processorArchitecture=\'*\' publicKeyToken=\'6595b64144ccf1df\' language=\'*\'\\"")
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <Shlobj.h>
#include <wingdi.h>
#include <shellapi.h>

#define IDD_CRASHDIALOG                 103
#define IDC_ERRORBOX                    1002
#define IDC_BUTTON1                     1003
#define IDC_GOOFYAHHMESSAGE2            1004
#define IDC_SYSLINK1                    1005
')

@:cppFileCode('

::String errMessage;
::String silly;
::String errStack;
::String titlebarText;

bool transparencyEnabled = false;
bool uCanDieNow = false;
HINSTANCE hInstance = NULL;

HFONT font;
HFONT stackFont;
HFONT bigFont;
HWND closeButton;
HWND bigLabel;
HWND goofyMessage;
HWND errorInfoBox;
HWND stackTraceLabel;
HWND reportIssue;
HWND githubLink;

HICON errorIcon;

// handler for da error dialogue
INT_PTR CALLBACK ErrorBoxProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{

	HWND hwndOwner; 
	RECT rc, rcDlg, rcOwner; 
    PAINTSTRUCT ps;
    HDC hdc;
    switch(Message)
    {
        case WM_CLOSE:
            EndDialog(hwnd, IDOK);
            exit(1);
            return TRUE;

        case WM_DESTROY:
            EndDialog(hwnd, IDOK);
            exit(1);
            return TRUE;

        case WM_CREATE:
            return TRUE;

        case WM_CTLCOLORSTATIC:
            if ((HWND)lParam == githubLink) {
                SetBkMode((HDC)wParam,TRANSPARENT);
                SetTextColor((HDC)wParam, RGB(0,128,255));
                return (BOOL)GetSysColorBrush(COLOR_MENU);
            }
            break;
        case WM_INITDIALOG:
            SetWindowText(hwnd, (LPCSTR)titlebarText.c_str());
            // Segoe UI, 18
            font = CreateFont(16, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Segoe UI");
            stackFont = CreateFont(14, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Consolas");
            bigFont = CreateFont(28, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Segoe UI");

            // Big Label
            bigLabel = CreateWindow("static", errMessage.c_str(),
                WS_CHILD | WS_VISIBLE,
                52, 10, 700 - 62, 28,
                hwnd, NULL, hInstance, NULL);
            SendMessage(bigLabel, WM_SETFONT, (WPARAM) bigFont, TRUE);

            // Goofy Message
            goofyMessage = CreateWindow("static", silly.c_str(),
                WS_CHILD | WS_VISIBLE,
                52, 43, 700 - 62, 16,
                hwnd, NULL, hInstance, NULL);
            SendMessage(goofyMessage, WM_SETFONT, (WPARAM) font, TRUE);

            // Error Info
            errorInfoBox = CreateWindow("BUTTON", "Error Info",
                WS_CHILD | WS_VISIBLE | BS_GROUPBOX,
                10, 58 + 16, 700 - 20, 400 - 46 - 58 - 16,
                hwnd, (HMENU) -1, hInstance, NULL);
            SendMessage(errorInfoBox, WM_SETFONT, (WPARAM) font, TRUE);

            // Error Info
            stackTraceLabel = CreateWindow("static", errStack.c_str(),
                WS_CHILD | WS_VISIBLE,
                10, 26, 700 - 40, 400 - 46 - 58 - 60,
                errorInfoBox, (HMENU) -1, hInstance, NULL);
            SendMessage(stackTraceLabel, WM_SETFONT, (WPARAM) stackFont, TRUE);

            // Close Button
            closeButton = CreateWindow("BUTTON", "Close",
                WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
                690 - 88, 390 - 26, 88, 26,
                hwnd, NULL, hInstance, NULL);
            SendMessage(closeButton, WM_SETFONT, (WPARAM) font, TRUE);
            
            // Report Issue
            reportIssue = CreateWindow("static",
                "We recommend reporting the issue to the GitHub page:", // A copy of the error has been saved in \"crash.txt\" https://github.com/YoshiCrafter29/YoshiCrafterEngine/issues
                WS_VISIBLE | WS_CHILD | WS_TABSTOP,
                10, 380 - 18, 690 - 108, 16,
                hwnd, NULL, hInstance, NULL);
            SendMessage(reportIssue, WM_SETFONT, (WPARAM) font, TRUE);

            // Report Issue Link
            githubLink = CreateWindow("static",
                "https://github.com/YoshiCrafter29/YoshiCrafterEngine/issues", // A copy of the error has been saved in \"crash.txt\"
                WS_VISIBLE | WS_CHILD | WS_TABSTOP | SS_NOTIFY,
                10, 380, 690 - 108, 16,
                hwnd, NULL, hInstance, NULL);
            SendMessage(githubLink, WM_SETFONT, (WPARAM) font, TRUE);
            SetClassLongPtr(githubLink, -12, (LONG_PTR)LoadCursor(NULL, IDC_HAND));

            // SendMessage(hwnd, WM_SETICON, ICON_SMALL, (LPARAM)LoadImage(NULL, MAKEINTRESOURCE(IDI_ERROR), IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR | LR_SHARED));
            HICON largeIcons[1];
            HICON smallIcons[1];
            ExtractIconEx("imageres.dll", 93, largeIcons, smallIcons, 1);
            SendMessage(hwnd, WM_SETICON, ICON_SMALL, (LPARAM)smallIcons[0]);
            errorIcon = largeIcons[0];
            MessageBeep(MB_ICONERROR);

            // FROM MICROSOFT THEMSELVES
            // IF IT DOESNT WORK ITS THEIR FAULT!!!
            // Get the owner window and dialog box rectangles. 

            HWND hwndOwner;
            if ((hwndOwner = GetActiveWindow()) == NULL) 
                hwndOwner = GetDesktopWindow(); 
        
            GetWindowRect(hwndOwner, &rcOwner); 
            GetWindowRect(hwnd, &rcDlg); 
            CopyRect(&rc, &rcOwner); 
        
            // Offset the owner and dialog box rectangles so that right and bottom 
            // values represent the width and height, and then offset the owner again 
            // to discard space taken up by the dialog box. 
        
            OffsetRect(&rcDlg, -rcDlg.left, -rcDlg.top); 
            OffsetRect(&rc, -rc.left, -rc.top); 
            OffsetRect(&rc, -rcDlg.right, -rcDlg.bottom); 
        
            // The new position is the sum of half the remaining space and the owner\'s 
            // original position. 
        
            SetWindowPos(hwnd, 
                         HWND_TOP, 
                         rcOwner.left + (rc.right / 2), 
                         rcOwner.top + (rc.bottom / 2), 
                         0, 0,          // Ignores size arguments. 
                         SWP_NOSIZE); 

    	    return TRUE;
            break;
        case WM_COMMAND:
            if ((HWND)lParam == githubLink) {
                ShellExecute(NULL, "open", "https://github.com/YoshiCrafter29/YoshiCrafterEngine/issues", NULL, NULL, SW_SHOWNORMAL);
                return TRUE;
            } else if ((HWND)lParam == closeButton) {
                EndDialog(hwnd, IDOK);
                return TRUE;
            }
            break;

        case WM_PAINT:
            hdc = BeginPaint(hwnd, &ps);

            DrawIconEx(hdc, 10, 10, errorIcon, 32, 32, 0, NULL, DI_NORMAL);

            EndPaint(hwnd, &ps);
            break;
    }
    return FALSE;
}
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
    #end
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

    #if windows
    @:functionCode('
	HWND window = GetActiveWindow();
	SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
	')
    #end
	@:noCompletion
	public static function _setWindowLayered()
	{
	}

    #if windows
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
    #end
	public static function setWindowAlpha(alpha:Float)
	{
		return alpha;
    } // thanks lunarclient for this
    
    #if windows
    @:functionCode('
        HWND window = GetActiveWindow();

        // make window layered
        alpha = SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        SetLayeredWindowAttributes(window, 0, 0, 0x00000001);
    ')
    #end
    public static function setWindowTransparencyColor(red:Int, green:Int, blue:Int, alpha:Int) {
        return alpha;
    }

    #if windows
    @:functionCode('
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PVOID(p), SPIF_UPDATEINIFILE);
    ') 
    #end
    public static function systemParametersInfo(p:ConstCharStar):Bool { 
        return true; 
    }

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

    #if windows
    @:functionCode('
        // https://stackoverflow.com/questions/4308503/how-to-enable-visual-styles-without-a-manifest
        // dumbass windows

        TCHAR dir[MAX_PATH];
        ULONG_PTR ulpActivationCookie = FALSE;
        ACTCTX actCtx =
        {
            sizeof(actCtx),
            ACTCTX_FLAG_RESOURCE_NAME_VALID
                | ACTCTX_FLAG_SET_PROCESS_DEFAULT
                | ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID,
            TEXT("manifesthelper.dll"), 0, 0, dir, (LPCTSTR)2
        };
        UINT cch = GetCurrentDirectory(sizeof(dir) / sizeof(*dir), (LPSTR) &dir);
        if (cch >= sizeof(dir) / sizeof(*dir)) { return FALSE; /*shouldn\'t happen*/ }
        dir[cch] = TEXT(\'\\0\');
        ActivateActCtx(CreateActCtx(&actCtx), &ulpActivationCookie);
        return ulpActivationCookie;
    ')
    #end
    public static function enableVisualStyles() {
        return false;
    }

    #if windows
    @:functionCode('
        return MessageBox(GetActiveWindow(), text, title, icon | MB_SETFOREGROUND);
    ')
    #end
    public static function showMessagePopup(title:String, text:String, icon:MessageBoxIcon):Int {
        lime.app.Application.current.window.alert(title, text);
        return 0;
    }

    #if windows
    @:functionCode('
        errMessage = _exception;
        errStack = _stack;
        silly = _silly;
        titlebarText = _caption;

        uCanDieNow = false;

        int result = 0;
        DLGTEMPLATE dlgTemplate{};
        dlgTemplate.style = WS_CAPTION|WS_SYSMENU;
        dlgTemplate.dwExtendedStyle = 0;
        dlgTemplate.cdit = 0;
        dlgTemplate.x = 0;
        dlgTemplate.y = 0;
        dlgTemplate.cx = 350;
        dlgTemplate.cy = 200;

        hInstance = GetModuleHandle(NULL);
        HWND window = GetActiveWindow();
        INT_PTR dialog = DialogBoxIndirect(hInstance, &dlgTemplate, window, ErrorBoxProc);
        EnableWindow(window, FALSE);

        MSG uGotMail{};
        while (GetMessage(&uGotMail, nullptr, 0, 0)) {
            TranslateMessage(&uGotMail);
            DispatchMessage(&uGotMail);
        }
        exit(1);
    ')
    public static function showErrorHandler(_caption:String, _silly:String, _exception:String, _stack:String) {
        // import WindowsAPI;WindowsAPI.showErrorHandler("", "", "");
    }
    #else
    public static function showErrorHandler(caption:String, exception:String, stack:String) {
        showMessagePopup('$exception\n\n$stack', caption, MSG_ERROR);
    }
    #end
    
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
        } //i made this code like 3 months ago pls don't kill me -ROYAL
		return true;
		#else
		lime.app.Application.current.window.alert(cast msg, cast title);
		return true;
		#end
    }
}

@:enum abstract MessageBoxIcon(Int) {
    var MSG_ERROR:MessageBoxIcon = 0x00000010;
    var MSG_QUESTION:MessageBoxIcon = 0x00000020;
    var MSG_WARNING:MessageBoxIcon = 0x00000030;
    var MSG_INFORMATION:MessageBoxIcon = 0x00000040;
}

@:enum abstract WindowColorMode(Int)
{
	var DARK:WindowColorMode = 1;
	var LIGHT:WindowColorMode = 0;
}