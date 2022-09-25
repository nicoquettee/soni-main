import flixel.util.FlxColor;
import GameJolt.GameJoltAPI;
import flixel.FlxG;
import Progression;

using StringTools;

/**
 * @author ROYAL
 */

class Achieve
{
	public var name:String;
	public var desc:String;
	public var id:Int;
    public var color:String;

	public function new(nm:String, dsc:String, id:Int, color:String)
	{
		name = nm;
		desc = dsc;
		this.id = id;
        this.color = color;
	}
}

class GJAchievements
{
	public static var achievements:Array<Achieve> =
		[
            // Week Achievements
            new Achieve("Not too fast!", "Beat the soni week", 166555, "#FEF200"),
            // Codes Achievements
            new Achieve("It's Morbin' Time!", "Beat the song unleashed in the codes section", 166557, "#797ABA"),
            new Achieve("ou", "Beat the song ou in the codes section", 166562, "#00A3E9"),
            new Achieve("Another reality", "Beat the song broken reality in the codes section", 166556, "#9EFF96"),
            new Achieve("Sastastic!1!1!", "Beat the song cheese in the codes section", 166558, "#FFA757"),
            new Achieve("Lies...", "Beat the song impersonation in the codes section", 166559, "#FF737A"),
            new Achieve("Sussy Hot Dog", "Beat the song spines in the codes section", 166560, "#02013A"),
            new Achieve("Decisions", "Beat the song dev troubles in the codes section", 166561, "#CB6EFF"),
            new Achieve("LETAL VICTORY", "Beat the song ovaloader star in the codes section", 169369, "#89CEFF"),
            new Achieve("Freezy Peasy", "Beat the song scrapped mouse in the codes section", 169371, "#99C5FF"),
            new Achieve("Get Scourged!", "Beat the song rude in the codes section", 169374, "#BBFFA4")
		];

	public static function unlockAchievement(name:String = "", ?hasSound:Bool = true):Void
	{
		var ID:Int = 0;

		for (i in 0...achievements.length)
		{
			if (achievements[i].name == name)
			{
				ID = i;
			}
		}

		if (!FlxG.save.data.achievementsSoni[achievements[ID].id])
		{
			FlxG.save.data.achievementsSoni[achievements[ID].id] = true;

			GameJoltAPI.getTrophy(achievements[ID].id);
			Main.gjToastManager.createToast(GJAchievements.achievements[ID].name, GJAchievements.achievements[ID].name, GJAchievements.achievements[ID].desc, hasSound, GJAchievements.achievements[ID].color);
	
			FlxG.save.flush();
		}
	}

	public static function gotAll():Bool
	{
		var unfinished:Int = 0;
		for (i in 0...achievements.length)
		{
			if (!FlxG.save.data.achievementsSoni[achievements[i].id])
			{
				trace('hasnt done ' + achievements[i].name);
				unfinished++;
			}
		}

		if (unfinished == 0)
		{
			trace('user has 100%d :D');
			return true;
		}
		else 
		{
			trace('user has not 100%d :(((');
			return false;
		}
	}

	public static function syncGJ():Void
	{
		for (i in 0...achievements.length)
		{
			if (FlxG.save.data.achievementsSoni[i])
			{
				GameJoltAPI.getTrophy(achievements[i].id);
			}
		}
	}

	public static function defaultAchievements()
	{
		FlxG.save.data.achievementsSoni = [];
		for (i in 0...achievements.length)
		{
			FlxG.save.data.achievementsSoni[achievements[i].id] = false;
		}
		FlxG.save.flush();
	}
}
