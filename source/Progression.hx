package;

import flixel.FlxG;

class Progression
{
	public static var weekProgress:Map<String, {song:String, weekScore:Int, weekMisses:Int}> = [];

	public static var beatedSoni:Bool = false;
	public static var beatedTaisandnuckles:Bool = false;
	public static var beatedWerhog:Bool = false;
	public static var beatedOu:Bool = false;
	public static var beatedBil:Bool = false;
	public static var beatedSonibars:Bool = false;
	public static var beatedOrigishit:Bool = false;
	public static var beatedSas:Bool = false;
	public static var beatedSantiago:Bool = false;
	public static var beatedApk:Bool = false;
	public static var beatedRoyal:Bool = false;
	public static var beatedLetal:Bool = false;
	public static var beatedShawn:Bool = false;
	public static var beatedScourg:Bool = false;
	public static var beatedChile:Bool = false;
	public static var beatedHxSoni:Bool = false;
	public static var beatedSolean:Bool = false;
	public static var beatedHalloween:Bool = false;
	public static var beatedTM:Bool = false;

	public static function load()
	{
		if (FlxG.save.data.weekProgress != null)
		{
			weekProgress = FlxG.save.data.weekProgress;
		}
		if (FlxG.save.data.beatedSoni != null)
		{
			beatedSoni = FlxG.save.data.beatedSoni;
		}
		if (FlxG.save.data.beatedTaisandnuckles != null)
		{
			beatedTaisandnuckles = FlxG.save.data.beatedTaisandnuckles;
		}
		if (FlxG.save.data.beatedWerhog != null)
		{
			beatedWerhog = FlxG.save.data.beatedWerhog;
		}
		if (FlxG.save.data.beatedOu != null)
		{
			beatedOu = FlxG.save.data.beatedOu;
		}
		if (FlxG.save.data.beatedBil != null)
		{
			beatedBil = FlxG.save.data.beatedBil;
		}
		if (FlxG.save.data.beatedSonibars != null)
		{
			beatedSonibars = FlxG.save.data.beatedSonibars;
		}
		if (FlxG.save.data.beatedOrigishit != null)
		{
			beatedOrigishit = FlxG.save.data.beatedOrigishit;
		}
		if (FlxG.save.data.beatedSas != null)
		{
			beatedSas = FlxG.save.data.beatedSas;
		}
		if (FlxG.save.data.beatedSantiago != null)
		{
			beatedSantiago = FlxG.save.data.beatedSantiago;
		}
		if (FlxG.save.data.beatedApk != null)
		{
			beatedApk = FlxG.save.data.beatedApk;
		}
		if (FlxG.save.data.beatedRoyal != null)
		{
			beatedRoyal = FlxG.save.data.beatedRoyal;
		}
		if (FlxG.save.data.beatedLetal != null)
		{
			beatedLetal = FlxG.save.data.beatedLetal;
		}
		if (FlxG.save.data.beatedShawn != null)
		{
			beatedShawn = FlxG.save.data.beatedShawn;
		}
		if (FlxG.save.data.beatedScourg != null)
		{
			beatedScourg = FlxG.save.data.beatedScourg;
		}
		if (FlxG.save.data.beatedChile != null)
		{
			beatedChile = FlxG.save.data.beatedChile;
		}
		if (FlxG.save.data.beatedHxSoni != null)
		{
			beatedHxSoni = FlxG.save.data.beatedHxSoni;
		}
		if (FlxG.save.data.beatedSolean != null)
		{
			beatedSolean = FlxG.save.data.beatedSolean;
		}
		if (FlxG.save.data.beatedHalloween != null)
		{
			beatedHalloween = FlxG.save.data.beatedHalloween;
		}
		if (FlxG.save.data.beatedTM != null)
		{
			beatedTM = FlxG.save.data.beatedTM;
		}
	}

	public static function save()
	{
		FlxG.save.data.weekProgress = weekProgress;
		FlxG.save.data.beatedSoni = beatedSoni;
		FlxG.save.data.beatedTaisandnuckles = beatedTaisandnuckles;
		FlxG.save.data.beatedWerhog = beatedWerhog;
		FlxG.save.data.beatedOu = beatedOu;
		FlxG.save.data.beatedBil = beatedBil;
		FlxG.save.data.beatedSonibars = beatedSonibars; 
		FlxG.save.data.beatedOrigishit = beatedOrigishit;
		FlxG.save.data.beatedSas = beatedSas;
		FlxG.save.data.beatedSantiago = beatedSantiago;
		FlxG.save.data.beatedApk = beatedApk;
		FlxG.save.data.beatedRoyal = beatedRoyal;
		FlxG.save.data.beatedLetal = beatedLetal;
		FlxG.save.data.beatedShawn = beatedShawn;
		FlxG.save.data.beatedScourg = beatedScourg;
		FlxG.save.data.beatedChile = beatedChile;
		FlxG.save.data.beatedHxSoni = beatedHxSoni;
		FlxG.save.data.beatedSolean = beatedSolean;
		FlxG.save.data.beatedTM = beatedTM;
		FlxG.save.data.beatedHalloween = beatedHalloween;

		FlxG.save.flush();
	}

	public static function reset()
	{
		weekProgress = [];
		beatedSoni = false;
		beatedTaisandnuckles = false;
		beatedWerhog = false;
		beatedOu = false;
		beatedBil = false;
		beatedSonibars = false;
		beatedOrigishit = false;
		beatedSas = false;
		beatedSantiago = false;
		beatedApk = false;
		beatedRoyal = false;
		beatedLetal = false;
		beatedShawn = false;
		beatedScourg = false;
		beatedChile = false;
		beatedHxSoni = false;
		beatedSolean = false;
		beatedTM = false;
		beatedHalloween = false;

		save();
	}

	public static function all()
	{
		beatedSoni = true;
		beatedTaisandnuckles = true;
		beatedWerhog = true;
		beatedOu = true;
		beatedBil = true;
		beatedSonibars = true;
		beatedOrigishit = true;
		beatedSas = true;
		beatedSantiago = true;
		beatedApk = true;
		beatedRoyal = true;
		beatedLetal = true;
		beatedShawn = true;
		beatedScourg = true;
		beatedChile = true;
		beatedHxSoni = true;
		beatedSolean = true;
		beatedTM = true;
		beatedHalloween = true;

		save();
	}
}