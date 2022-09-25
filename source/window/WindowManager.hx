package window;

import openfl.display.Window;
import lime.ui.WindowAttributes;
import openfl.Lib;

class WindowManager // Esto es para manejar ventanas por un mapa de IDs
{
	/**
	 * Map para manejar las ventanas
	 */
	public static var windows:Map<String, Window> = [];

	/**
	 * Cierra todas las ventanas creadas (solo deja la principal del juego)
	 */
	public static function closeAllWindows()
	{
		for (windowID in windows.keys())
		{
			removeWindow(windowID);
		}
	}

	/**
	 * Crea una ventana manejable (hace return de la instance de la ventana)
	 * @param stringID      el ID usado dentro del mapa de ventanas
	 * @param attributes    Window Attributes 
	 * @return Ventana
	 */
	public static function addWindow(stringID:String, attributes:WindowAttributes):Window
	{
		if (windows.exists(stringID))
			removeWindow(stringID);

		var window:Window = Lib.application.createWindow(attributes);

		window.onClose.add(function()
		{
			removeWindow(getWindowId(window));
		});

		windows.set(stringID, window);

		return windows[stringID];
	}

	/**
	 * Elimina una ventana del map de ventanas y ya xd
	 * @param stringID      el ID de la ventana
	 */
	public static function removeWindow(stringID:String)
	{
		if (windows.exists(stringID))
		{
			if (windows[stringID] != null)
			{
				windows[stringID].close();
			}

			windows.remove(stringID);
		}
	}

	/**
	 * Consigue una ventana por el ID (si no existe hara un return null)
	 * @param stringID      ID de la ventana
	 * @return Ventana
	 */
	public static function getWindow(stringID:String):Window
	{
		return windows[stringID];
	}

	/**
	 * Encuentra la ID de la ventana (si no lo encuentra sera null)
	 * @param window    la instancia de la ventana
	 * @return String
	 */
	public static function getWindowId(window:Window):Null<String>
	{
		for (id in windows.keys())
		{
			if (windows[id] == window)
				return id;
		}
		return null;
	}
}