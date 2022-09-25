package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.input.FlxAccelerometer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;
import openfl.Lib;

using StringTools;

class Codes extends MusicBeatState
{
    var nokiaBG:FlxSprite;
    var numbersSpr:FlxTypedGroup<FlxSprite>;
    var code:FlxText;
    var selection:Int;

    var canSelect:Bool = true;

    override function create()
    {
        FlxG.mouse.visible = true;

        PlayState.isStoryMode = false;
        PlayState.isCode = true;

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Codes Menu", null);
		#end

        Lib.application.window.title = 'Freaky Night With Soni - Codes Menu';

        nokiaBG = new FlxSprite().loadGraphic(Paths.image('menu_code/Nokia_png_full_hd'));
        nokiaBG.screenCenter();
        nokiaBG.antialiasing = ClientPrefs.globalAntialiasing;
        add(nokiaBG);

        numbersSpr = new FlxTypedGroup<FlxSprite>();
        add(numbersSpr);

        for (i in 0...10)
        {
            var button:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu_code/buttons/Boton_$i'));
            button.antialiasing = ClientPrefs.globalAntialiasing;
            switch(i)
            {
                case 0:
                    button.setPosition(617,617);
                    button.setGraphicSize(58,33);
                case 1:
                    button.setPosition(542,555);
                    button.setGraphicSize(56,40);
                case 2:
                    button.setPosition(617,570);
                    button.setGraphicSize(58,34);
                case 3:
                    button.setPosition(693,557);
                    button.setGraphicSize(55,38);
                case 4:
                    button.setPosition(540,512);
                    button.setGraphicSize(53,36);
                case 5:
                    button.setPosition(617,525);
                    button.setGraphicSize(57,33);
                case 6:
                    button.setPosition(697,511);
                    button.setGraphicSize(54,37);
                case 7:
                    button.setPosition(536,463);
                    button.setGraphicSize(57,39);
                case 8:
                    button.setPosition(616,476);
                    button.setGraphicSize(59,35);
                case 9:
                    button.setPosition(699,463);
                    button.setGraphicSize(56,39);
            }
            button.ID = i;
            button.updateHitbox();
            button.y -= 5;
            numbersSpr.add(button);
        }

        code = new FlxText(565, 231, 200, "", 80);
        code.setFormat(Paths.font("vcr.ttf"), 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        code.text = '';
        code.screenCenter(X);
        code.x += 3;
        add(code);

        super.create();
    }

    override function update(elapsed:Float)
    {
        numbersSpr.forEach(function(spr:FlxSprite)
        {
            if(FlxG.mouse.overlaps(spr))
                selection = spr.ID;
        });
        //trace(selection);

        super.update(elapsed);

        if ((controls.BACK || FlxG.mouse.justPressedRight) && canSelect) //me when the so
        {
            MusicBeatState.switchState(new MainMenuState());
            if(Progression.beatedSoni) FlxG.mouse.visible = false;
            Lib.application.window.title = 'Freaky Night With Soni';
        }

        for (i in numbersSpr)
            if(FlxG.mouse.overlaps(i) && canSelect)
                if(code.text.length < 4)
                    if(FlxG.mouse.justPressed)
                        code.text += selection;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //if you see this talk me to my discord: ROYAL#5081                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 :trollface:

        if(controls.ACCEPT)
        {
            switch(code.text)
            {
                case '1811': //Werhog code
                    enterToSong('unleashed');
                case '0907': //ou code (tgt shadow lmao)
                    enterToSong('ou');
                case '2012': //bil billetes cipher
                    enterToSong('broken-reality');
                case '0069': //sonibars (best song)
                    enterToSong('sonibars');
                case '1234': //old soni code
                    enterToSongWithCutscene('origishit');
                case '1994': //sas code
                    enterToSong('cheese');
                case '0998': //santiago code
                    enterToSong('impersonation');
                case '2307': //soni.apk code
                    FlxG.sound.pause();
                    enterToSong('spines');
                    var doxxString:String = "";
                    var defaultUser:Bool = getUsername() == 'Usuario' || getUsername() == 'User' || getUsername() == 'Usuário' || getUsername() == null
                        || getUsername() == 'null';
                    if (defaultUser)
                        doxxString = getPC().startsWith("DESKPOT") ? getUsername() : getPC();
                    CppUse.messageBox('SONI', "BAD DECISION, "+doxxString+". YOU CAN'T GO BACK", 32);
                case '0841': //jp vs royal code
                    enterToSong('dev-troubles');
                case '3201': //letal soni code
                    enterToSong('ovaloader-star');
                case '5030': //shawn code
                    enterToSong('scrapped-mouse');
                case '0161': //scourg code
                    enterToSong('rude');
                case '1809': //metal sonic chileno xd
                    enterToSong('pico');
                case '7545': //Shadow fucking die bruhhh
                    startDaVideo('die');
                case '6969': //Funni peter griffin running code
                    startDaVideo('Peter Griffin in City Escape');
                case '1984': //Soni Real Life OMGG
                    startDaVideo('Soni Real');
                case '1993': //Hola amigos estoy aqui con mis amigos
                    startDaVideo('holamigos');
                default: //Nothing lol
                    code.text = '';
                    if(canSelect)
                    {
                        if(ClientPrefs.shake)
                            FlxG.camera.shake(0.008, 0.08);
				        FlxG.sound.play(Paths.sound('cancelMenu'));
                    }
            }
        }
    }

    function enterToSong(song:String, ?hasLoad = true)
    {
        PlayState.SONG = Song.loadFromJson(song, song);
        LoadingState.loadAndSwitchState(new PlayState(), true, hasLoad);
        Lib.application.window.title = 'Freaky Night With Soni';
        FlxG.mouse.visible = false;
    }
    function startDaVideo(vid:String)
    {
        FlxG.mouse.visible = false;
        FlxG.sound.pause();
        canSelect = false;
        (new FlxVideo(Paths.video(vid))).finishCallback = function() {
            FlxG.sound.resume();
            FlxG.mouse.visible = true;
            canSelect = true;
        }
        code.text = '';
    }
    function enterToSongWithCutscene(song:String) //In PlayState the cutscenes crash the game so uhh
    {
        PlayState.SONG = Song.loadFromJson(song, song);
        LoadingState.loadAndSwitchState(new StoryVideo(), true);
        Lib.application.window.title = 'Freaky Night With Soni';
        FlxG.mouse.visible = false;
    }
    function getUsername()
	{
		var envs = Sys.environment();
		if (envs.exists("USERNAME"))
		{
			return envs["USERNAME"];
		}
		if (envs.exists("USER"))
		{
			return envs["USER"];
		}
		return null;
	}
	function getPC()
	{
		var envs = Sys.environment();
		if (envs.exists("COMPUTERNAME"))
		{
			return envs["COMPUTERNAME"];
		}
		else
		{
			return null;
		}
	}
}