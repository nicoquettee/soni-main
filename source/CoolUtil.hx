package;

import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	inline public static function scale(x:Float,l1:Float,h1:Float,l2:Float,h2:Float):Float
		return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function wrapFloat(value:Float, min:Float, max:Float) {
		if (value < min)
			return min;
		if (value > max)
			return max;
		return value;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		precacheSoundFile(Paths.sound(sound, library));
	}

	public static function precacheImage(image:String, ?library:String = null):Void
	{
		precacheImageFile(Paths.image(image, library));
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		precacheSoundFile(Paths.music(sound, library));
	}

	private static function precacheSoundFile(file:Dynamic):Void
	{
		if (Assets.exists(file, SOUND) || Assets.exists(file, MUSIC))
			Assets.getSound(file, true);
	}

	private static function precacheImageFile(file:Dynamic):Void
	{
		if (Assets.exists(file, IMAGE))
			LimeAssets.getImage(file, true);
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function joinFrames(joinedSprites:Array<String>, ?directory:String):flixel.graphics.frames.FlxAtlasFrames
	{
		var framesArray:Array<flixel.graphics.frames.FlxAtlasFrames> = [];
		var returnFrames = Paths.getSparrowAtlas(joinedSprites[0], directory);
		joinedSprites.remove(joinedSprites[0]);
		for (sprite in joinedSprites)
			framesArray.push(Paths.getSparrowAtlas(sprite, directory));

		for (sprite in framesArray)
		{
			for (frame in sprite.frames)
				returnFrames.pushFrame(frame);
		}

		return returnFrames;
	}

	public static function getDataTypeStringArray():Array<String>
	{
		var enums:Array<DataType> = DataType.createAll();
		var strs:Array<String> = [];

		for (_enum in enums)
		{
			strs[enums.indexOf(_enum)] = Std.string(_enum);
		}

		return strs;
	}
}
