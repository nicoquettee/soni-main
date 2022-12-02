import CppFuncs.MessageBoxIcon;
class CppUse {
    public static function darkMode() {
		CppFuncs.setWindowColorMode(DARK);
	}
	public static function lightMode() {
		CppFuncs.setWindowColorMode(LIGHT);
	}
    public static function enableVisualStyles() {
        CppFuncs.enableVisualStyles();
    }
    public static function transWindowColor(r:Int, g:Int, b:Int, alpha:Int) {
        CppFuncs.setWindowTransparencyColor(r, g, b, alpha);
    }
    public static function messageBox(title:String, msg:String, type:Int) {
        CppFuncs.messageBox(title, msg, type);
    }
    public static function setWindowOppacity(a:Float) {
		CppFuncs.setWindowAlpha(a);
	}
	public static function _setWindowLayered() {
		CppFuncs._setWindowLayered();
    }
    public static function wallpaper(p:String) {
		CppFuncs.systemParametersInfo(p);
	}
    public static function obtainRAM():Int {
        return CppFuncs.obtainRAM();
    }
    public static function showMessagePopup(title:String, text:String, icon:MessageBoxIcon):Int {
        return CppFuncs.showMessagePopup(title, text, icon);
    }
    public static function showErrorHandler(_caption:String, _silly:String, _exception:String, _stack:String) {
        CppFuncs.showErrorHandler(_caption, _silly, _exception, _stack);
    }
}