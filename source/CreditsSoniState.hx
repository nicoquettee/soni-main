package;

import openfl.Lib;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
#if desktop
import Discord.DiscordClient;
#end
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class CreditsSoniState extends MusicBeatState
{
    var bg:FlxSprite;
    var nameTxt:FlxText;
    var descTxt:FlxText;
    var intendedColor:Int;
    var colorTween:FlxTween;
    var curSelected:Int = 0;
    var selected:Bool = false;
    var creditsSprite:FlxTypedGroup<FlxSprite>;
    var creditsArray:Array<Array<String>> = [];

    var causa:Int = FlxG.random.int(1,80); //una entre 80 probabilidades de sugar canon (causa)
    var giansona:Int = FlxG.random.int(1,80); //una entre 80 probabilidades de max giansona

    override function create()
    {
        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits Menu", null);
        #end

        Lib.application.window.title = 'Freaky Night With Soni - Credits';
        FlxG.mouse.visible = true;
        
        persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('credits/menuDesatCredits'));
		add(bg);
        bg.screenCenter();

        var sexo:Array<Array<String>> = [
            ['Drawe', 'Drawe', 'Creator of all the mod characters', 'https://www.youtube.com/c/BaldiSans/featured', 'C75824'],
            ['JP13XD', 'Jp', 'Owner of the mod and animator', 'https://twitter.com/XdJp13', '6D4FDA'],
            ['ROYAL', 'Royal', 'Main Coder and sound effects supporter', 'https://twitter.com/CoderRoyal', '6412BB'],
            ['LuisF', 'Luis', 'Cool artist and animator', 'https://twitter.com/LuisF_0506', 'F13C35'],
            ['Sly Uva', 'Sly', 'artist, animator and atsuover clone', 'https://twitter.com/SlyOverxd', 'F3FD83'],
            ['Toxxer', 'Toxxer', 'So cool fnf style artist', 'https://twitter.com/T0xx3r', '13A34D'],
            ['Monki Alias', 'Monki', 'Cool artist and animator (he is not a monke)', 'https://twitter.com/Monki_Al', '8A2225'],
            ['Jesux', 'Jesux', 'Epic Sprite Artist', 'https://twitter.com/Jesux_Art', 'FACF4F'],
            ['Donut', 'Donut', 'All character icons artist and ui artist', 'https://twitter.com/ColorousDonut', '8DE0AE'],
            ['MaxDemon', giansona == 69 ? 'MaxGiansona' : 'Max', 'Sprites and ui artist and animator', 'https://twitter.com/MaxDemon_', 'E1014A'],
            ['DonAlgo', 'DonAlgo', 'Artist, Animator, Musician, vs homr creator and cactus', 'https://twitter.com/DonAlgoXD', '6BF654'],
            ['4RN4Uxd', '4rn4uxd', 'Cool Musician', 'https://twitter.com/Rn4Uxd', '6B95E5'],
            ['FrankitoLQ4001', 'Frankito', 'Cool Musician but green', 'https://twitter.com/FrankitoLQ4001', '09AE64'],
            ['Fabi', 'Fabi', 'Cool Dubstep Musician and ROYAL clone', 'https://twitter.com/Fabicholas', 'FDBCA4'],
            ['Yiter', 'Yiter', 'Cool Musician but from madness combat', 'https://twitter.com/sameyiter', '763ABC'],
            [causa == 69 ? 'SugarCausa' : 'SugarMoon', causa == 69 ? 'SugarCausa' : 'Sugar', causa == 69 ? 'pe' : 'Cool Musician and the mother of all the devs', 'https://twitter.com/sugarcoatedOwO', 'F20D5A'],
            ['Farsy', 'Farsy', 'Epic Charter with a gun, wow', 'https://twitter.com/Farsyyyyy', 'F19B4F'],
            ['ManDuz', 'ManDuz', 'Soni and a lot of more characters voice', 'https://twitter.com/ManDuzSoni', 'BEC5E2'],
            ['Yina', 'Yina', 'a lot of chromatics scales creator', 'https://twitter.com/Yina_Tilin', 'C2645D'],
            ['Dylan', 'Dylan', 'same as yina but he likes pennis', 'https://twitter.com/LabanDylan', 'FCA063']
        ];
        for(i in sexo) creditsArray.push(i);
        
        creditsSprite = new FlxTypedGroup<FlxSprite>();
        for(i in 0...creditsArray.length)
        {
            var sprite:FlxSprite = new FlxSprite(-100 * (i * 578), 0).loadGraphic(Paths.image('credits/v2 credits/${creditsArray[i][1]}_Credits'));
			sprite.alpha = 0.6;
            sprite.setGraphicSize(429,429);
            sprite.updateHitbox();
            sprite.screenCenter(Y);
            sprite.y += 33;
            sprite.antialiasing = ClientPrefs.globalAntialiasing;
            sprite.ID = i;
            creditsSprite.add(sprite);
        }
        add(creditsSprite);

        var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 97, FlxColor.BLACK);
        add(black);

        nameTxt = new FlxText(0, 0, FlxG.width, '', 44);
        nameTxt.setFormat(Paths.font('#44.ttf'), 44, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        nameTxt.y = 0;
        nameTxt.antialiasing = ClientPrefs.globalAntialiasing;
        nameTxt.screenCenter(X);
        add(nameTxt);

        descTxt = new FlxText(0, 0, FlxG.width, '', 34);
        descTxt.setFormat(Paths.font('#44.ttf'), 34, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        descTxt.y = 55;
        descTxt.antialiasing = ClientPrefs.globalAntialiasing;
        descTxt.screenCenter(X);
        add(descTxt);

        bg.color = getCurrentBGColor();
		intendedColor = bg.color;
        changeSelection(0,false);
        super.create();
    }

    var canChange:Bool = true;
    override function update(elapsed:Float)
    {
        var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
        var accepted = controls.ACCEPT || FlxG.mouse.justPressed;
        var back = controls.BACK || FlxG.mouse.justPressedRight;
        
        if(canChange)
        {
            if(leftP) changeSelection(-1);
            if(rightP) changeSelection(1);
            if(FlxG.mouse.wheel != 0) changeWithWheel();
        }
        if(accepted) CoolUtil.browserLoad('${creditsArray[curSelected][3]}');
        if(back && !selected) goBack();

        super.update(elapsed);
        creditsSprite.forEach(function(spr:FlxSprite)
		{
		});
    }

    function goBack()
    {
        selected = true;
        persistentUpdate = false;
		if(colorTween != null) colorTween.cancel();
        FlxG.sound.play(Paths.sound('cancelMenu'));
        Lib.application.window.title = 'Freaky Night With Soni';
        MusicBeatState.switchState(new MainMenuState());
    }

    function changeWithWheel()
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		changeSelection(-FlxG.mouse.wheel, false);
    }

    function changeSelection(change:Int = 0, playSound:Bool = true)
    {
        if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'));

        var oldWeek:Int = curSelected;

        do {
			curSelected += change;
            if (curSelected >= creditsArray.length) curSelected = 0;
            else if (curSelected < 0) curSelected = creditsArray.length - 1;
		} while(unselectableCheck(curSelected));

        var newColor:Int = getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 0.5, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
        }
        
        nameTxt.text = '${creditsArray[curSelected][0]}';
        descTxt.text = '${creditsArray[curSelected][2]}';
        Lib.application.window.title = 'Freaky Night With Soni - Credits - ${creditsArray[curSelected][0]}';
        
        creditsSprite.forEach(function(spr:FlxSprite)
		{
			if(spr.ID == curSelected)
			{
				spr.alpha = 1;
				FlxTween.tween(spr, {"scale.x": 0.352666666666667, "scale.y": 0.352666666666667}, 0.2, {ease: FlxEase.expoOut});
			} else 
			{
				spr.alpha = 0.6;
				FlxTween.tween(spr, {"scale.x": 0.286, "scale.y": 0.286}, 0.2, {ease: FlxEase.expoOut});
			}
        });
        
        if (change > 0)
        {
            canChange = false;
			var previous2:Int = curSelected - 2;
			if (previous2 < 0)
			{
				previous2 = creditsArray.length + previous2;
			}
			var previous:Int = curSelected - 1;
			if (previous < 0)
			{
				previous = creditsArray.length - 1;
			}
			var next:Int = curSelected + 1;
			if (next >= creditsArray.length)
			{
				next = 0;
			}

			FlxTween.tween(creditsSprite.members[previous2], {x: -creditsSprite.members[previous2].width-578}, 0.2, {ease: FlxEase.expoOut});
			FlxTween.tween(creditsSprite.members[previous], {x: -100}, 0.2, {ease: FlxEase.expoOut});
			FlxTween.tween(creditsSprite.members[curSelected], {x: 425}, 0.2, {ease: FlxEase.expoOut, onComplete: (twn)->{canChange=true;}});
			creditsSprite.members[next].x = FlxG.width+creditsSprite.members[next].width+578;
			FlxTween.tween(creditsSprite.members[next], {x: 957}, 0.2, {ease: FlxEase.expoOut});
		}
		else
		{
            canChange = false;
			var previous:Int = curSelected - 1;
			if (previous < 0)
			{
				previous = creditsArray.length - 1;
			}
			var next:Int = curSelected + 1;
			if (next >= creditsArray.length)
			{
				next = 0;
			}
			var next2:Int = curSelected + 2;
			if (next2 >= creditsArray.length)
			{
				next2 = next2 - creditsArray.length;
			}

            creditsSprite.members[previous].x = -creditsSprite.members[previous].width-578;
			FlxTween.tween(creditsSprite.members[previous], {x: -100}, 0.2, {ease: FlxEase.expoOut});
			FlxTween.tween(creditsSprite.members[curSelected], {x: 425}, 0.2, {ease: FlxEase.expoOut, onComplete: (twn)->{canChange=true;}});
			FlxTween.tween(creditsSprite.members[next], {x: 957}, 0.2, {ease: FlxEase.expoOut});
            FlxTween.tween(creditsSprite.members[next2], {x: FlxG.width+creditsSprite.members[next].width+578}, 0.2, {ease: FlxEase.expoOut});
        }
    }

    function getCurrentBGColor() {
		var bgColor:String = creditsArray[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
    }
    
    private function unselectableCheck(num:Int):Bool {
		return creditsArray[num].length <= 1;
	}
}