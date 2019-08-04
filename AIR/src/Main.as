package
{
import com.doitflash.consts.Direction;
import com.doitflash.consts.Orientation;
import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
import com.doitflash.starling.utils.list.List;
import com.doitflash.text.modules.MySprite;
import com.myflashlab.air.extensions.localNotifi.NotificationAndroidSettings;
import com.myflashlab.air.extensions.dependency.OverrideAir;

import com.luaye.console.C;
import com.myflashlab.air.extensions.localNotifi.*;

import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

import com.myflashlab.air.extensions.localNotifi.Notification;


/**
 * ...
 * @author Hadi Tavakoli - 7/24/2016 11:25 AM
 */
public class Main extends Sprite
{
	private var _alarmId:int;
	
	private const BTN_WIDTH:Number = 150;
	private const BTN_HEIGHT:Number = 60;
	private const BTN_SPACE:Number = 2;
	private var _txt:TextField;
	private var _body:Sprite;
	private var _list:List;
	private var _numRows:int = 1;
	
	public function Main():void
	{
		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
		NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate);
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		C.startOnStage(this, "`");
		C.commandLine = false;
		C.commandLineAllowed = false;
		C.x = 20;
		C.width = 250;
		C.height = 150;
		C.strongRef = true;
		C.visible = true;
		C.scaleX = C.scaleY = DeviceInfo.dpiScaleMultiplier;
		
		_txt = new TextField();
		_txt.autoSize = TextFieldAutoSize.LEFT;
		_txt.antiAliasType = AntiAliasType.ADVANCED;
		_txt.multiline = true;
		_txt.wordWrap = true;
		_txt.embedFonts = false;
		_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Local Notification ANE for AIR V" + Notification.VERSION + "</font>";
		_txt.scaleX = _txt.scaleY = DeviceInfo.dpiScaleMultiplier;
		this.addChild(_txt);
		
		_body = new Sprite();
		this.addChild(_body);
		
		_list = new List();
		_list.holder = _body;
		_list.itemsHolder = new Sprite();
		_list.orientation = Orientation.VERTICAL;
		_list.hDirection = Direction.LEFT_TO_RIGHT;
		_list.vDirection = Direction.TOP_TO_BOTTOM;
		_list.space = BTN_SPACE;
		
		init();
		onResize();
	}
	
	private function onInvoke(e:InvokeEvent):void
	{
		NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
	}
	
	private function handleActivate(e:Event):void
	{
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
	}
	
	private function handleDeactivate(e:Event):void
	{
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
	}
	
	private function handleKeys(e:KeyboardEvent):void
	{
		if(e.keyCode == Keyboard.BACK)
		{
			e.preventDefault();
			NativeApplication.nativeApplication.exit();
		}
	}
	
	private function onResize(e:* = null):void
	{
		if(_txt)
		{
			_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
			
			C.x = 0;
			C.y = _txt.y + _txt.height + 0;
			C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
			C.height = 300 * (1 / DeviceInfo.dpiScaleMultiplier);
		}
		
		if(_list)
		{
			_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
			_list.row = _numRows;
			_list.itemArrange();
		}
		
		if(_body)
		{
			_body.y = stage.stageHeight - _body.height;
		}
	}
	
	private function init():void
	{
		// Remove OverrideAir debugger in production builds
		OverrideAir.enableDebugger(function ($ane:String, $class:String, $msg:String):void
		{
			trace($ane+" ("+$class+") "+$msg);
		});
		
		Notification.init();
		Notification.listener.addEventListener(NotificationEvents.NOTIFICATION_INVOKED, onNotifiInvoked);
		
		// channels are required on Android 8+ only
		if(OverrideAir.os == OverrideAir.ANDROID)
		{
			// create a new channel with a unique id
			var channel:NotificationChannel = new NotificationChannel("myChannelId", "channel name");
			
			/*
				you can add your own sound files into the "res/raw" using the resourceManager tool
				available in the ANELAB software: https://github.com/myflashlab/ANE-LAB/
			*/
			channel.rawSound = "myflashlab_toy"; // this is myflashlab_toy.mp3 file placed inside Android "res/raw"
			channel.showBadge = true;
			channel.importance = NotificationChannel.NOTIFICATION_IMPORTANCE_DEFAULT;
			channel.isLightsEnabled = true;
			channel.isVibrationEnabled = true;
			channel.lightColor = "#990000";
			channel.lockscreenVisibility = NotificationChannel.VISIBILITY_PUBLIC;
			channel.vibrationPattern = [10, 100, 100, 200, 100, 300, 100, 400, 100, 500, 100, 600, 100, 700, 100, 800];
			channel.description = "channel description";
			
			// finally register the channel.
			Notification.registerChannel(channel);
		}
		
		//----------------------------------------------------------------------
		var btn1:MySprite = createBtn("set Android Notification");
		btn1.addEventListener(MouseEvent.CLICK, setAndroidNotification);
		if(OverrideAir.os == OverrideAir.ANDROID) _list.add(btn1);
		
		function setAndroidNotification(e:MouseEvent):void
		{
			var setting:NotificationAndroidSettings = new NotificationAndroidSettings();
			setting.notificationId = 3;
			setting.payload = "payload data";
			setting.title = "the title";
			setting.message = "the message";
			setting.time = new Date().getTime() + 5000; // means 5 seconds from now
			setting.sound = "myflashlab_toy"; // to play a sound from res/raw on older Android versions. works on AIR SDK 33+
			setting.vibrate = true;
			setting.channelId = "myChannelId"; // channels must be created on Android 8+
			
			_alarmId = Notification.adjust(setting);
		}
		
		//---------------------------------------------------------------------
		var btn2:MySprite = createBtn("set iOS Notification");
		btn2.addEventListener(MouseEvent.CLICK, setiOSNotification);
		if(OverrideAir.os == OverrideAir.IOS) _list.add(btn2);
		
		function setiOSNotification(e:MouseEvent):void
		{
			var setting:NotificationIosSettings = new NotificationIosSettings();
			setting.notificationId = 3; // setting new notifications with the same id will override the old one
			setting.payload = "payload data";
			setting.title = "the title";
			setting.message = "the message";
			setting.time = new Date().getTime() + 5000; // means 5 seconds from now
			setting.sound = "iosSound.caf";
			
			_alarmId = Notification.adjust(setting);
		}
		
		//---------------------------------------------------------------------
		var btn3:MySprite = createBtn("unset scheduled Notification");
		btn3.addEventListener(MouseEvent.CLICK, unsetNotification);
		_list.add(btn3);
		
		function unsetNotification(e:MouseEvent):void
		{
			// unset a notification which is still in schedule
			Notification.unset(_alarmId);
		}
		
		//---------------------------------------------------------------------
		var btn4:MySprite = createBtn("dismiss All from status bar");
		btn4.addEventListener(MouseEvent.CLICK, dismissAll);
		_list.add(btn4);
		
		function dismissAll(e:MouseEvent):void
		{
			// removes all notifications from the status bar
			Notification.dismissAll();
		}
		
		//---------------------------------------------------------------------
		var btn5:MySprite = createBtn("unset All");
		btn5.addEventListener(MouseEvent.CLICK, unsetAll);
		_list.add(btn5);
		
		function unsetAll(e:MouseEvent):void
		{
			// removes all notification schedules
			Notification.unsetAll();
		}
	}
	
	
	private function onNotifiInvoked(e:NotificationEvents):void
	{
		C.log("(" + e.notificationId + ") was app active when notifi was dispatched? " + e.isAppActive + ". payload=" + e.payload);
		trace("(" + e.notificationId + ") was app active when notifi was dispatched? " + e.isAppActive + ". payload=" + e.payload);
		
		// When app is in foreground, notification will not be generated. however, you can check
		// if e.isAppActive is true or not Then you can manually update your UI design.
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	private function createBtn($str:String):MySprite
	{
		var sp:MySprite = new MySprite();
		sp.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		sp.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		sp.addEventListener(MouseEvent.CLICK, onOut);
		sp.bgAlpha = 1;
		sp.bgColor = 0xDFE4FF;
		sp.drawBg();
		sp.width = BTN_WIDTH * DeviceInfo.dpiScaleMultiplier;
		sp.height = BTN_HEIGHT * DeviceInfo.dpiScaleMultiplier;
		
		function onOver(e:MouseEvent):void
		{
			sp.bgAlpha = 1;
			sp.bgColor = 0xFFDB48;
			sp.drawBg();
		}
		
		function onOut(e:MouseEvent):void
		{
			sp.bgAlpha = 1;
			sp.bgColor = 0xDFE4FF;
			sp.drawBg();
		}
		
		var format:TextFormat = new TextFormat("Arimo", 16, 0x666666, null, null, null, null, null, TextFormatAlign.CENTER);
		
		var txt:TextField = new TextField();
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.antiAliasType = AntiAliasType.ADVANCED;
		txt.mouseEnabled = false;
		txt.multiline = true;
		txt.wordWrap = true;
		txt.scaleX = txt.scaleY = DeviceInfo.dpiScaleMultiplier;
		txt.width = sp.width * (1 / DeviceInfo.dpiScaleMultiplier);
		txt.defaultTextFormat = format;
		txt.text = $str;
		
		txt.y = sp.height - txt.height >> 1;
		sp.addChild(txt);
		
		return sp;
	}
}
	
}