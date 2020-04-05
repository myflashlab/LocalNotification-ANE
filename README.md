# Local Notification ANE for Android+iOS
This AIR Native Extension will let you schedule and send local notifications even if your app is closed completely. It's supported on both Android and iOS with an identical API on the ActionScript side.

**Main Features:**

* Schedule notifications to be fired by the device in future.
* Scheduled events will remain active even after device reboot.
* If your app is in foreground, notifications will be dispatched to your app instead of the status bar. This gives you highly flexibility in your app.
* Every notification can have a payload data attached to it so when it is fired, you can do your app logic based on the payload String.
* The ANE has helpful methods to let you unset/override/dismiss schedules and already dispatched notifications from the status bar.
* For Android 8+ it supports [NotificationChannels](https://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/localNotifi/Notification.html#registerChannel()).

[find the latest **asdoc** for this ANE here.](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/localNotifi/package-detail.html)

# AIR Usage
For the complete AS3 code usage, see the [demo project here](https://github.com/myflashlab/LocalNotification-ANE/blob/master/AIR/src/Main.as).

```actionscript
import com.myflashlab.air.extensions.localNotifi.*;

// this is the first thing you should do to initialize the notification ANE
Notification.init();

// channels are required on Android only
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

// Start listening to this event as soon as possible. If your app opens because of the notification has been
// touched from the status bar, this listener will be called to let you know about it.
Notification.listener.addEventListener(NotificationEvents.NOTIFICATION_INVOKED, onNotifiInvoked);
     
// For iOS, create a NotificationIosSettings and for Android create a NotificationAndroidSettings instance
var setting:NotificationIosSettings = new NotificationIosSettings();
setting.notificationId = 3; // setting new notifications with the same id will override the old one
setting.payload = "payload data";
setting.title = "the title";
setting.message = "the message";
setting.time = new Date().getTime() + 5000; // means 5 seconds from now
setting.sound = "iosSound.caf"; // the sound file which must be packaged in your .ipa file

/*
	On Android, you must use NotificationAndroidSettings and set the channelId property
	setting.channelId = "myChannelId"; // make sure the channel is already created
*/

// when adjusting a notification, its alarm id is returned. Use this id to unset a schedule before it happens.
var alarmId:int = Notification.adjust(setting);
function onNotifiInvoked(e:NotificationEvents):void
{
	// When app is in foreground, notification will not be generated. however, you can check
	// if e.isAppActive is true or not Then you can manually update your UI design.
	trace("was app active when notification was dispatched? " + e.isAppActive);
	trace("notificationId: " + e.notificationId);
	trace("payload: " + e.payload);
}
```

# Air .xml manifest
```xml
<!--
FOR ANDROID:
-->
<manifest android:installLocation="auto">
	
	<uses-permission android:name="com.android.alarm.permission.SET_ALARM" />
	<uses-permission android:name="android.permission.VIBRATE" />
	<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
	<uses-sdk android:targetSdkVersion="28"/>
	
	<!--
		Required if you want to play a custom notification sound on File.DocumentsDirectory
		If you are doing this, make sure you have asked for the permission from users using
		our permissionCheck ANE. http://bit.ly/2u4q6Vv
	-->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
	
	<application android:hardwareAccelerated="true" android:allowBackup="true">
		
		<activity>
			<intent-filter>
				<action android:name="android.intent.action.MAIN" />
				<category android:name="android.intent.category.LAUNCHER" />
			</intent-filter>
			<intent-filter>
				<action android:name="android.intent.action.VIEW" />
				<category android:name="android.intent.category.BROWSABLE" />
				<category android:name="android.intent.category.DEFAULT" />
					
				<!-- Change the scheme value to your own app package name -->
				<data android:scheme="air.com.site.app" />
			</intent-filter>
		</activity>
		
		<receiver android:name="com.myflashlabs.localNotifi.Alarm" />
		<receiver android:name="com.myflashlabs.localNotifi.RebootRescheduleNotifications">
			<intent-filter>
					<action android:name="android.intent.action.BOOT_COMPLETED" />
			</intent-filter>
		</receiver>
		
	</application>
</manifest>






<!--
FOR iOS:
-->
	<key>MinimumOSVersion</key>
	<string>10.0</string>
	
	<key>UIBackgroundModes</key>
	<array>
		<string>remote-notification</string>
	</array>
	
	
	
	
	
<!--
Embedding the ANE:
-->
  <extensions>
	<extensionID>com.myflashlab.air.extensions.localNotification</extensionID>
	
	<!-- Download dependency ANEs from https://github.com/myflashlab/common-dependencies-ANE -->
	<extensionID>com.myflashlab.air.extensions.dependency.overrideAir</extensionID>
	<extensionID>com.myflashlab.air.extensions.dependency.androidx.core</extensionID>
	<extensionID>com.myflashlab.air.extensions.dependency.androidx.lifecycle</extensionID>
  </extensions>
-->
```

# Requirements
* Android API 19+
* iOS SDK 10.0+
* AIR SDK 33.0+

# Permissions
Below are the list of Permissions this ANE might require. Check out the demo project available at this repository to see how we have used the [PermissionCheck ANE](http://www.myflashlabs.com/product/native-access-permission-check-settings-menu-air-native-extension/) to ask for the permissions.

Necessary | Optional
--------------------------- | ---------------------------
. | [SOURCE_STORAGE](https://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/nativePermissions/PermissionCheck.html#SOURCE_STORAGE)

# Commercial Version
https://www.myflashlabs.com/product/local-notification-ane-adobe-air-native-extension/

[![local-notification ANE](https://www.myflashlabs.com/wp-content/uploads/2017/07/product_adobe-air-ane-local-notification-2018-595x738.jpg)](https://www.myflashlabs.com/product/local-notification-ane-adobe-air-native-extension/)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  

# Premium Support #
[![Premium Support package](https://www.myflashlabs.com/wp-content/uploads/2016/06/professional-support.jpg)](https://www.myflashlabs.com/product/myflashlabs-support/)
If you are an [active MyFlashLabs club member](https://www.myflashlabs.com/product/myflashlabs-club-membership/), you will have access to our private and secure support ticket system for all our ANEs. Even if you are not a member, you can still receive premium help if you purchase the [premium support package](https://www.myflashlabs.com/product/myflashlabs-support/).