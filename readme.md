Air Guitar SDK for Air Guitar Move 
===

## What's new

###1.1 (August 10, 2012)
* Added acceleration property to AGAccessory (of type CMAccelerometer) as alternative to delegate
* Corrected error in read me (thanks [Alex](https://github.com/minichrispy)!)

###1.0 (iOSDevCamp San Jose, CA July 22, 2012)
* Handles connecting and disconnecting Air Guitar accessories
* Sends raw accelerometer data to your app

## What it does

![](http://www.airguitarmove.com/images/github/airguitar.png)  
In the summer of 2012 we launched Air Guitar Move, a rhythm game and iPhone accessory. I received many requests from developers who wanted to use the Air Guitar Move hardware in their own apps and games. With Air Guitar SDK it's now possible to add support for the Air Guitar Move hardware to any app.

Before submitting to the App Store, please see the note below.

##System Requirements
* Air Guitar Move accessory. ([Buy online](https://www.wepay.com/stores/airguitar))
* iOS 4 or higher for using the library in you apps
* iOS 5 to run the included demo app

## Building the Demo App

Open AirGuitarSDKDemo.xcodeproj and build the app for iPhone or iPod touch. Make sure AirGuitarSDKDemo is selected in the scheme selection (and not AirGuitarSDK).

![](http://www.airguitarmove.com/images/github/builddemo.png)

## Using AirGuitarSDK in your own projects:
Before you start you will need:  

* libAirGuitarSDK.a (created in AirGuitarSDK.xproj -> Products. See Building the Demo App above. If the filename is red, repeat building the demo app)  
* AirGuitarSDK.h, AGAccessory.h and AGAccessoryManager.h (AirGuitarSDK -> frameworks)  

![Create libAirGuitarSDK.a and locate header files](http://www.airguitarmove.com/images/github/products.png)

1. Add libAirGuitarSDK.a to your project by dragging the file from the demo project to your project.

	![Add libAirGuitarSDK.a](http://www.airguitarmove.com/images/github/libairguitar.png)

* Add Apple's ExternalAccessory.framework to your project by going to Project -> Target -> Link Binary With Libraries and press the + button (note that libAirGuitarSDK.a we added in step 1 should also listed here)

	![Add ExternalAccessory.framework](http://www.airguitarmove.com/images/github/externalframework.png)

* Drag AirGuitarSDK.h, AGAccessory.h and AGAccessoryManager.h (under Framworks) to your project. (You don't need to copy AGMotionManager.h , that is still a work in progress)

	![Add header files to project](http://www.airguitarmove.com/images/github/headerfiles.png)

* Edit the info.plist by going to Project -> Target -> Info. Right click anywhere in the list and Add Row. Enter 'Supported External Accessory Protocol' and add 'com.yobble.airguitar' as protocol

	![Add Supported External Accessory Protocol in info.plist](http://www.airguitarmove.com/images/github/protocol1.png)
	![Add com.yobble.airguitar to Supported External Accessory Protocol](http://www.airguitarmove.com/images/github/protocol2.png)

* Add delegate and notification observer in your code
	
	Your app needs to implement:  
	1. A delegate to receive accelerometer data from Air Guitar Move 
	2. A notification observer to receive connect and disconnect notifications

	In header file or class extension:
		
		@property (nonatomic, strong) AGAccessoryManager *airGuitarManager;

	In .m file (e.g. ViewController or AppDelegate):

		- (void)viewDidLoad {
    		[super viewDidLoad];
    
		    // Set up Air Guitar accessory
	    	_airGuitarManager = [AGAccessoryManager sharedAccessoryManager];
		}

		- (void)viewWillAppear:(BOOL)animated {

		    // Receive notifications when Air Guitar connects or disconnects
	    	_airGuitarManager.shouldSendNotifications = YES;    
    
		    // We don't receive a notification if Air Guitar Move was already connected when the app started or view was loaded,
			// so check for already connected accessories

    		if ([_airGuitarManager.connectedAGAccessories count]) {
	        	NSArray *accessories = [_airGuitarManager.connectedAGAccessories allValues];        
		        for (AGAccessory *accessory in accessories) {
    		        accessory.delegate = self;
		        }        
    		}
    
		    // Register for Air Guitar connect and disconnect notifications
    		[[NSNotificationCenter defaultCenter] addObserver:self
										 	  	     selector:@selector(accessoryDidConnect:)
	 				 						  	         name:@"AGAccessoryDidConnect" 
												       object:nil];

		    [[NSNotificationCenter defaultCenter] addObserver:self 
												     selector:@selector(accessoryDidDisconnect:) 
											   	         name:@"AGAccessoryDidDisconnect" 
												       object:nil];  
		}

		- (void)viewWillDisappear:(BOOL)animated {
    
		    if ([_airGuitarManager.connectedAGAccessories count]) {

    		    NSArray *accessories = [_airGuitarManager.connectedAGAccessories allValues];
        		for (AGAccessory *accessory in accessories) accessory.delegate = nil;
		    }
    		[[NSNotificationCenter defaultCenter] removeObserver:self];
		}

		#pragma mark - Air Guitar Delegate

		- (void) accessory: (AGAccessory *)accessory x:(double)x y:(double)y z:(double)z {

    		// delegate method gets called every time the iPhone receives data from the Air Guitar accessory.
    
	    	NSLog(@"%f, %f, %f", x, y, z);
		}

		#pragma mark - Air Guitar Notifications

		- (void)accessoryDidConnect: (NSNotification *)notification { 
    		AGAccessory *connectedAccessory = (AGAccessory *) notification.object;
		    connectedAccessory.delegate = self;    
		}

		- (void)accessoryDidDisconnect: (NSNotification *)notification {
    		// Air Guitar was disconnected, pause the game
		}

## Problems & Bugs
Air Guitar SDK was built in one weekend at the iOSDevCamp hackathon. There will be bugs. Please use the [Github Issue tracker](https://github.com/ronaldmannak/AirGuitarSDK/issues) to commit bugs.

## Author and Contributors
Air Guitar SDK was developed at [iOSDevCamp 2012](http://iodevcamp.org) in San Jose by [Ronald Mannak](https://github.com/ronaldmannak)  
BoardMessage code by [Colin Karpfinger](https://github.com/colinkarpfinger)

## Used in
* DogFight (iOS game developed by [Sage Herron](https://github.com/Drekknni) at [iOSDevCamp 2012](http://iodevcamp.org))

## BEFORE SUBMITTING YOUR APP TO THE APP STORE

You can use Air Guitar SDK in any way you like. However, Apple might have additional requirements when submitting an Air Guitar enabled app to the App Store, such as that your app must be a guitar app. Please contact the author before submitting apps.

## License
Air Guitar SDK is licensed under the [Apache Software License, 2.0 ("Apache 2.0")](http://www.apache.org/licenses/LICENSE-2.0)

