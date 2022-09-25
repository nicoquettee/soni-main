class CppUse {
    #if cpp
    public static function darkMode() {
		CppFuncs.setWindowColorMode(DARK);
	}
	public static function lightMode() {
		CppFuncs.setWindowColorMode(LIGHT);
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
    #end
    public static function obtainRAM():Int {
        return CppFuncs.obtainRAM();
    }
}