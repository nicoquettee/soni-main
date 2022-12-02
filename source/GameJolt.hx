package;

// GameJolt things
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.ui.FlxUIState;
import haxe.iterators.StringIterator;
import tentools.api.FlxGameJolt as GJApi;

// Login things
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import lime.system.System;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.system.FlxSound;

// Toast things
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
import openfl.text.TextField;
import openfl.display.Bitmap;
import openfl.text.TextFormat;
import openfl.Lib;
import flixel.FlxG;
import openfl.display.Sprite;
import lime.system.Clipboard;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class GameJoltAPI // Connects to tentools.api.FlxGameJolt
{
    /**
     * Inline variable to see if the user has logged in.
     * True for logged in, false for not logged in.
     */
    static var userLogin:Bool = false;

    /**
     * Grabs user data and returns as a string, true for Username, false for Token
     * @param username Bool value
     * @return String 
     */
    public static function getUserInfo(username:Bool = true):String
    {
        if(username)return GJApi.username;
        else return GJApi.usertoken;
    }

    /**
     * Returns the user login status
     * @return Bool
     */
    public static function getStatus():Bool
    {
        return userLogin;
    }

    /**
     * Sets the game API key from GJKeys.api
     * Doesn't return anything
     */
    public static function connect() 
    {
        trace("Grabbing API keys...");
        GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), false);
    }

    /**
     * Inline function to auth the user. Shouldn't be used outside of GameJoltAPI things.
     * @param in1 username
     * @param in2 token
     * @param loginArg Used in only GameJoltLogin
     */
    public static function authDaUser(in1, in2, ?loginArg:Bool = false)
    {
       if (!userLogin)
		{
			GJApi.authUser(in1, in2, function(v:Bool)
			{
				trace("user: " + (in1 == "" ? "n/a" : in1));
				trace("token: " + in2);
				if (v)
				{
					trace("User authenticated!");
					FlxG.save.data.gjUser = in1;
					FlxG.save.data.gjToken = in2;
					FlxG.save.flush();
					userLogin = true;
					startSession();
					if (loginArg)
					{
						GameJoltLogin.login = true;
						FlxG.switchState(new GameJoltLogin());
					}
				}
				else
				{
					if (loginArg)
					{
						GameJoltLogin.login = true;
						FlxG.switchState(new GameJoltLogin());
					}
					trace("User login failure!");
				}
			});
		}
    }
    
    /**
     * Inline function to deauth the user, shouldn't be used out of GameJoltLogin state!
     * @return  Logs the user out and closes the game
     */
    public static function deAuthDaUser()
    {
        closeSession();
        userLogin = false;
        trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
        FlxG.save.data.gjUser = "";
        FlxG.save.data.gjToken = "";
        FlxG.save.flush();
        trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
        trace("Logged out!");
        TitleState.restart();
    }

    /**
     * Give a trophy!
     * @param trophyID Trophy ID. Check your game's API settings for trophy IDs.
     */
    public static function getTrophy(trophyID:Int) /* Awards a trophy to the user! */
    {
        if (userLogin)
		{
			GJApi.addTrophy(trophyID);
		}
    }

    /**
     * Checks a trophy to see if it was collected
     * @param id TrophyID
     * @return Bool (True for achieved, false for unachieved)
     */
    public static function checkTrophy(id:Int):Bool
    {
        var value:Bool = false;
        GJApi.fetchTrophy(id, function(data:Map<String, String>)
            {
                trace(data);
                if (data.get("achieved").toString() != "false")
                    value = true;
                trace(id+""+value);
            });
        return value;
    }

    public static function pullTrophy(?id:Int):Map<String,String>
    {
        var returnable:Map<String,String> = null;
        GJApi.fetchTrophy(id, function(data:Map<String,String>){
            trace(data);
            returnable = data;
        });
        return returnable;
    }

    /**
     * Return the highest score from a table!
     * 
     * Usable by pulling the data from the map by [function].get();
     * 
     * Values returned in the map: score, sort, user_id, user, extra_data, stored, guest, success
     * 
     * @param tableID The table you want to pull from
     * @return Map<String,String>
     */
    public static function pullHighScore(tableID:Int):Map<String,String>
    {
        var returnable:Map<String,String>;
        GJApi.fetchScore(tableID,1, function(data:Map<String,String>){
            trace(data);
            returnable = data;
        });
        return returnable;
    }

    /**
     * Inline function to start the session. Shouldn't be used out of GameJoltAPI
     * Starts the session
     */
    public static function startSession()
    {
        GJApi.openSession(function()
            {
                trace("Session started!");
                new FlxTimer().start(20, function(tmr:FlxTimer){pingSession();}, 0);
            });
    }

    /**
     * Tells GameJolt that you are still active!
     * Called every 20 seconds by a loop in startSession().
     */
    public static function pingSession()
    {
        GJApi.pingSession(true, function(){trace("Ping!");});
    }

    /**
     * Closes the session, used for signing out
     */
    public static function closeSession()
    {
        GJApi.closeSession(function(){trace('Closed out the session');});
    }
}

class GameJoltInfo extends MusicBeatSubstate
{    
    /**
     * Variable to change which state to go to by hitting ESCAPE or the CONTINUE buttons.
     */
    public static var changeState:FlxUIState = new MainMenuState();
    /**
    * Inline variable to change the font for the GameJolt API elements.
    * @param font You can change the font by doing **Paths.font([Name of your font file])** or by listing your file path.
    * If *null*, will default to the normal font.
    */
    public static var font:String = null; /* Example: Paths.font("vcr.ttf"); */
    /**
    * Inline variable to change the font for the notifications made by Firubii.
    * 
    * Don't make it a NULL variable. Worst mistake of my life.
    */
    public static var fontPath:String = "assets/fonts/#44.ttf";
    /**
    * Image to show for notifications. Leave NULL for no image, it's all good :)
    * 
    * Example: Paths.getLibraryPath("images/stepmania-icon.png")
    */
    public static var imagePath:String = "sign"; 

    /* Other things that shouldn't be messed with are below this line! */

    /**
    * GameJolt + FNF version.
    */
    public static var version:String = "1.1";
    /**
     * Random quotes I got from other people. Nothing more, nothing less. Just for funny.
     */
}

class GameJoltLogin extends MusicBeatState
{
    var loginTexts:FlxTypedGroup<FlxText>;
    var loginBoxes:FlxTypedGroup<FlxUIInputText>;
    var loginButtons:FlxTypedGroup<FlxButton>;

    var buttons:FlxTypedSpriteGroup<FlxSprite>;
    var buttonsSpr:FlxTypedSpriteGroup<FlxSprite>;

    var usernameText:FlxText;
    var tokenText:FlxText;
    var usernameBox:FlxUIInputText;
    var tokenBox:FlxUIInputText;
    var signInBox:FlxButton;
    var helpBox:FlxButton;
    var logOutBox:FlxButton;
    var cancelBox:FlxButton;
    // var profileIcon:FlxSprite;
    var username1:FlxText;
    var username2:FlxText;
    // var gamename:FlxText;
    // var trophy:FlxBar;
    // var trophyText:FlxText;
    // var missTrophyText:FlxText;
    public static var charBop:FlxSprite;
    // var icon:FlxSprite;
    var baseX:Int = -190;
    public static var login:Bool = false;
    // static var trophyCheck:Bool = false;
    public static var fromOptions:Bool = false;

    var buttonsName:Array<String> = [
        'si',
        'gt'
    ];

    override function create()
    {
        //FlxG.sound.playMusic(Paths.music('freakyMenu'));
        super.create();

		persistentUpdate = true;

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Gamejolt Menu", null);
		#end
        Lib.application.window.title = 'Freaky Night With Soni - Gamejolt Menu';

        trace(GJApi.initialized);
        FlxG.mouse.visible = true;

        Conductor.changeBPM(102);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		bg.setGraphicSize(FlxG.width);
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.alpha = 0.25;
		add(bg);

        /*charBop = new FlxSprite(FlxG.width - 400, 250);
		charBop.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared', false);
		charBop.animation.addByPrefix('idle', 'BF idle dance', 24, false);
        charBop.animation.addByPrefix('loggedin', 'BF HEY', 24, false);
        charBop.setGraphicSize(Std.int(charBop.width * 1.4));
		charBop.antialiasing = true;
        charBop.flipX = false;
		add(charBop);*/

        loginTexts = new FlxTypedGroup<FlxText>(2);
        add(loginTexts);

        buttons = new FlxTypedSpriteGroup<FlxSprite>();
        add(buttons);
        for(i in 0...1){}

        usernameText = new FlxText(0, 125, 300, "Username:", 20);

        tokenText = new FlxText(0, 225, 300, "Token:", 20);

        loginTexts.add(usernameText);
        loginTexts.add(tokenText);
        loginTexts.forEach(function(item:FlxText){
            item.screenCenter(X);
            item.x += baseX;
            item.font = GameJoltInfo.font;
        });

        loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
        add(loginBoxes);

        usernameBox = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
        tokenBox = new FlxUIInputText(0, 275, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);

        loginBoxes.add(usernameBox);
        loginBoxes.add(tokenBox);
        loginBoxes.forEach(function(item:FlxUIInputText){
            item.screenCenter(X);
            item.font = GameJoltInfo.font;
        });

        if(GameJoltAPI.getStatus())
        {
            remove(loginTexts);
            remove(loginBoxes);
        }

        loginButtons = new FlxTypedGroup<FlxButton>(3);
        add(loginButtons);

        signInBox = new FlxButton(0, 475, "Sign In", function()
        {
            trace(usernameBox.text);
            trace(tokenBox.text);
            GameJoltAPI.authDaUser(usernameBox.text,tokenBox.text,true);
        });

        helpBox = new FlxButton(0, 550, "GameJolt Token", function()
        {
            if (!GameJoltAPI.getStatus())
                openLink('https://youtu.be/FAz-hu1oebs');
        });
        helpBox.color = FlxColor.fromRGB(84,155,149);

        logOutBox = new FlxButton(0, 550, "Log Out", function()
        {
            GameJoltAPI.deAuthDaUser();
        });
        logOutBox.color = FlxColor.RED;

        cancelBox = new FlxButton(0,625, "Not Right Now", function()
        {
            FlxG.save.flush();
            FlxG.sound.play(Paths.sound('cancelMenu'));
            var durag:Float = 0;
            if (GameJoltLogin.fromOptions)
            {
                durag = 0.5;
            }
            new FlxTimer().start(durag, (tmr)->{
                GameJoltLogin.fromOptions = false;
                Lib.application.window.title = 'Freaky Night With Soni';
                MusicBeatState.switchState(new MainMenuState());
            });
        });

        if(!GameJoltAPI.getStatus())
        {
            loginButtons.add(signInBox);
            loginButtons.add(helpBox);
            #if desktop
            // Updating Discord Rich Presence
            DiscordClient.changePresence("In the Gamejolt Menu - Login", null);
            #end
            Lib.application.window.title = 'Freaky Night With Soni - Gamejolt Menu - Login';
        }
        else
        {
            cancelBox.y = 475;
            cancelBox.text = "Continue";
            loginButtons.add(logOutBox);
            #if desktop
            // Updating Discord Rich Presence
            DiscordClient.changePresence("In the Gamejolt Menu - Loged", null);
            #end
            Lib.application.window.title = 'Freaky Night With Soni - Gamejolt Menu - Loged';
        }
        loginButtons.add(cancelBox);

        loginButtons.forEach(function(item:FlxButton){
            item.screenCenter(X);
            item.setGraphicSize(Std.int(item.width) * 3);
            item.x += baseX;
        });

        if(GameJoltAPI.getStatus())
        {
            username1 = new FlxText(0, 95, 0, "Signed in as:", 40);
            username1.alignment = CENTER;
            username1.screenCenter(X);
            username1.x += baseX;
            add(username1);

            username2 = new FlxText(0, 145, 0, "" + GameJoltAPI.getUserInfo(true) + "", 40);
            username2.alignment = CENTER;
            username2.screenCenter(X);
            username2.x += baseX;
            add(username2);
        }

        if(GameJoltInfo.font != null)
        {       
            username1.font = GameJoltInfo.font;
            username2.font = GameJoltInfo.font;
            loginBoxes.forEach(function(item:FlxUIInputText){
                item.font = GameJoltInfo.font;
            });
            loginTexts.forEach(function(item:FlxText){
                item.font = GameJoltInfo.font;
            });
        }
    }

    override function update(elapsed:Float)
    {
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }
        
        var inputTexts:Array<FlxUIInputText> = [usernameBox, tokenBox];
        for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null) {
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.save.flush();
            GameJoltLogin.fromOptions = false;
            Lib.application.window.title = 'Freaky Night With Soni';
            MusicBeatState.switchState(GameJoltInfo.changeState);
        }

        /*loginButtons.forEach(function(item:FlxButton){
            trace('w: '+item.width);
            trace('h: '+item.height);
        });*/

        super.update(elapsed);
    }

    function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}

    override function beatHit()
    {
        super.beatHit();
       // charBop.animation.play((GameJoltAPI.getStatus() ? "loggedin" : "idle"));
    }
    function openLink(url:String)
    {
        #if linux
        Sys.command('/usr/bin/xdg-open', [url, "&"]);
        #else
        FlxG.openURL(url);
        #end
    }
}

/* The toast things, pulled from Hololive Funkin
* Thank you Firubii for the code for this!
* https://twitter.com/firubiii
* https://github.com/firubii
* ILYSM
*/

class GJToastManager extends Sprite
{
    public static var ENTER_TIME:Float = 0.5;
	public static var DISPLAY_TIME:Float = 2.0;
	public static var LEAVE_TIME:Float = 0.5;
	public static var TOTAL_TIME:Float = ENTER_TIME + DISPLAY_TIME + LEAVE_TIME;
    public static var leSound:FlxSound;

    var playTime:FlxTimer = new FlxTimer();

    public function new()
    {
        super();
        FlxG.signals.postStateSwitch.add(onStateSwitch);
        FlxG.signals.gameResized.add(onWindowResized);
        leSound = new FlxSound().loadEmbedded(Paths.sound('confirmMenu'));
		leSound.persist = true;
		leSound.volume = 1;
    }

    /**
     * Create a toast!
     * 
     * Usage: **Main.gjToastManager.createToast(iconPath, title, description);**
     * @param iconPath Path for the image **Paths.getLibraryPath("image/example.png")**
     * @param title Title for the toast
     * @param description Description for the toast
     * @param sound Want to have an alert sound? Set this to **true**! Defaults to **false**.
     */
    public function createToast(iconPath:String, title:String, description:String, ?sound:Bool = false, ?color:String = '#3848CC'):Void
    {
        var toast = new Toast(iconPath, title, description, color);
        addChild(toast);

        if (sound)
		{
			leSound.play();
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				loadToast();
			});
		}
		else
		{
			loadToast();
		}
    }

    function loadToast()
	{
		playTime.start(TOTAL_TIME);
		playToasts();
	}

    public function playToasts():Void
    {
        for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			FlxTween.cancelTweensOf(child);
			FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME, {
				ease: FlxEase.quadOut,
				onComplete: function(tween:FlxTween)
				{
					FlxTween.cancelTweensOf(child);
					FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren), {
						ease: FlxEase.quadIn,
						startDelay: DISPLAY_TIME,
						onComplete: function(tween:FlxTween)
						{
							cast(child, Toast).removeChildren();
							removeChild(child);
						}
					});
				}
			});
		}
    }

    public function collapseToasts():Void
    {
        for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren), {
				ease: FlxEase.quadIn,
				onComplete: function(tween:FlxTween)
				{
					cast(child, Toast).removeChildren();
					removeChild(child);
				}
			});
		}
    }

    public function onStateSwitch():Void
    {
        if (!playTime.active)
			return;

		var elapsedSec = playTime.elapsedTime / 1000;
		if (elapsedSec < ENTER_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.cancelTweensOf(child);
				FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME - elapsedSec, {
					ease: FlxEase.quadOut,
					onComplete: function(tween:FlxTween)
					{
						FlxTween.cancelTweensOf(child);
						FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren), {
							ease: FlxEase.quadIn,
							startDelay: DISPLAY_TIME,
							onComplete: function(tween:FlxTween)
							{
								cast(child, Toast).removeChildren();
								removeChild(child);
							}
						});
					}
				});
			}
		}
		else if (elapsedSec < DISPLAY_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.cancelTweensOf(child);
				FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren), {
					ease: FlxEase.quadIn,
					startDelay: DISPLAY_TIME - (elapsedSec - ENTER_TIME),
					onComplete: function(tween:FlxTween)
					{
						cast(child, Toast).removeChildren();
						removeChild(child);
					}
				});
			}
		}
		else if (elapsedSec < LEAVE_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren) - (elapsedSec - ENTER_TIME - DISPLAY_TIME), {
					ease: FlxEase.quadIn,
					onComplete: function(tween:FlxTween)
					{
						cast(child, Toast).removeChildren();
						removeChild(child);
					}
				});
			}
		}
    }

    public function onWindowResized(x:Int, y:Int):Void
    {
        for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			child.x = Lib.current.stage.stageWidth - child.width;
		}
    }
}

class Toast extends Sprite
{
    var back:Bitmap;
    var icon:Bitmap;
    var title:TextField;
    var desc:TextField;

    public function new(iconPath:String, titleText:String, description:String, ?color:String = '#3848CC')
    {
        super();
        back = new Bitmap(new BitmapData(500, 125, true, 0xFF000000));
        back.alpha = 0.9;
        back.x = 0;
        back.y = 0;
            
        if(iconPath != null)
        {
            icon = new Bitmap(BitmapData.fromFile("assets/achievements/images/" + iconPath + ".png"));
            icon.x = 10;
            icon.y = 10;
            icon.width = 100;
            icon.height = 100;
        }

        title = new TextField();
        title.text = titleText.toUpperCase();
        title.setTextFormat(new TextFormat(openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName, 30, FlxColor.fromString(color), true));
        title.wordWrap = true;
        title.width = 360;
        if(iconPath!=null){title.x = 120;}
        else{title.x = 5;}
        title.y = 5;

        desc = new TextField();
        desc.text = description.toUpperCase();
        desc.setTextFormat(new TextFormat(openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName, 24, FlxColor.WHITE));
        desc.wordWrap = true;
        desc.width = 360;
        desc.height = 95;
        if(iconPath!=null){desc.x = 120;}
        else{desc.x = 5;}
        desc.y = 35;
        if (titleText.length >= 25 || titleText.contains("\n"))
        {   
            desc.y += 25;
            desc.height -= 25;
        }

        addChild(back);
        if(iconPath!=null){addChild(icon);}
        addChild(title);
        addChild(desc);

        width = back.width;
        height = back.height;
        x = Lib.current.stage.stageWidth - width;
        y = -height;
    }
}