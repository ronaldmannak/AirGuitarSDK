Air Guitar SDK - 
===

## What it does
The Made for iPhone accessory Air Guitar Move was developed for the Air Guitar Move game. I received many requests from developers to use the Air Guitar Move hardware. Before submitting apps using Air Guitar SDK to the App Store, see note below.

## Features
* Handles connecting and deconnecting Air Guitar accessories
* Sends raw accelerometer data to your app

## Todo
* high pass and low pass filters 
* predefined air guitar motions

##System Requirements
* Air Guitar Move accessory. If you don't have one, see our [online store](https://www.wepay.com/stores/airguitar)
* iOS 4 or higher for using the library in you apps
* iOS 5 to run the included demo app

## How to use it
### iOS

#### Demo app:
* Open AirGuitarSDKDemo.xcodeproj and build the app for iPhone or iPod touch. Make sure AirGuitarSDKDemo is selected in the scheme selection (and not AirGuitarSDK).

#### Using AirGuitarSDK in your own projects:
* By building the demo app in the previous step, libAirGuitarSDK.a was be created in AirGuitarSDK.xproj -> Products (see Xcode Project Navigator). In case the file is red, repeat previous step.

* Either create a new project, open an existing project.

* Drag libAirGuitarSDK.a to your project and make sure libAirGuitarSDK.a is listed in your Project -> Target -> Link Binary With Libraries

* Press the + sign in the Link Binary With Libraries and add ExternalAccessory.framework

* Drag AirGuitarSDK.h, AGAccessory.h and AGAccessoryManager.h (under Framworks) to your project. (You don't need to copy AGMotionManager.h , that is still a work in progress)

* Go to Project -> Target -> Info. Right click anywhere in the list and Add Row. Enter 'Supported External Accessory Protocol' and add 'com.yobble.me' as protocol

#### Adding code in a view controller

(See AGViewController for example code)

* Handling connecting and deconnecting accessories:
AirGuitarSDK sends notifications when an Air Guitar compatible accessory connects and disconnects. In case an Air Guitar accessory was already connected before the view loaded or app started, we need to check the already connected devices in viewDidLoad or init.

* Getting accelerometer data:
Set delegate of AGAccessory to view controller t

In header file or class extension:
@property (nonatomic, strong) AGAccessoryManager *airGuitarManager;

In .m file:

@synthesize airGuitarManager = _airGuitarManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up Air Guitar accessory
    _airGuitarManager = [AGAccessoryManager sharedAccessoryManager];

}

- (void)viewWillAppear:(BOOL)animated {

    // Handling connecting and deconnecting accessories

    // Receive notifications when Air Guitar connects or deconnects
    _airGuitarManager.shouldSendNotifications = YES;    
    
    // Check if Air Guitar Move compatible devices are already connected
    if ([_airGuitarManager.connectedAGAccessories count]) {
        NSArray *accessories = [_airGuitarManager.connectedAGAccessories allValues];        
        for (AGAccessory *accessory in accessories) {
            accessory.delegate = self;
        }        
    }
    
    // Register for Air Guitar connect and disconnect notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:@"AGAccessoryDidConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:@"AGAccessoryDidDisconnect" object:nil];  
}

- (void)viewWillDisappear:(BOOL)animated {
    
    _iPhoneAccelerometer.delegate = nil;
    if ([_airGuitarManager.connectedAGAccessories count]) {
        NSArray *accessories = [_airGuitarManager.connectedAGAccessories allValues];
        
        for (AGAccessory *accessory in accessories) {
            accessory.delegate = nil;
        }        
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void) accessory: (AGAccessory *) accessory x: (double) x y: (double) y z: (double) z {

    // delegate method gets called every time the iPhone receives data from the Air Guitar accessory. Raw data only for now.
    
    NSLog(@"%f, %f, %f", x, y, z);
}

// ------------------------------------
#pragma mark - Air Guitar Notifications

- (void)accessoryDidConnect: (NSNotification *)notification { 
   
    AGAccessory *connectedAccessory = (AGAccessory *) notification.object;
    connectedAccessory.delegate = self;    
}

- (void)accessoryDidDisconnect: (NSNotification *)notification {

    // Do something, like pause the game
} 


#### Android
Go to shop. Buy iPhone. Air Guitar SDK is iPhone and iPod touch only for now.

#### Commodore 64
Change Project -> Build Settings -> Architectures setting to MOS 6502
Force Air Guitar accessory in any port
Enter:
10 PRINT "Air Guitar is working. Really"
20 PRINT INT(RND(1)*10)
30 GOTO 20

#### ZX Spectrum
Change Project -> Build Settings -> Architectures setting to Z80A
Force Air Guitar accessory in any port
Enter:
10 PRINT "Air Guitar is working. Really"
20 PRINT RND*10
30 GOTO 20

## Problems & Bugs
Air Guitar SDK was built in one weekend at the iOSDevCamp hackathon. There will be bugs.Please use the [Github Issue tracker](https://github.com/ronaldmannak/AirGuitarSDK/issues) to commit bugs

## License
Air Guitar SDK is licensed under the [Apache Software License, 2.0 ("Apache 2.0")](http://www.apache.org/licenses/LICENSE-2.0)

## Author
Air Guitar SDK was developed at [iOSDevCamp 2012](http://iodevcamp.org) in San Jose by [Ronald Mannak](https://github.com/ronaldmannak)

## Contributors
BoardMessage code by [Colin Karpfinger](https://github.com/colinkarpfinger)

## Used by
* DogFight (iOS game developed at [iOSDevCamp 2012](http://iodevcamp.org)
* Soon to used in Air Guitar Move game, our original Air Guitar Game

## IMPORTANT NOTICE BEFORE SUBMITTING YOUR APP TO THE APP STORE
You are free to use Air Guitar SDK in any developer version of your app. No third party apps using Air Guitar SDK have been submitted to the App Store yet, and there is no guarantee Apple will approve apps using the SDK. Please contact the author before submitting apps.

