//
//  AGDisplayLinkViewController.m
//  AirGuitarSDKDemo
//
//  Created by Ronald Mannak on 8/14/12.
//  Copyright (c) 2012 Yobble. All rights reserved.
//

#import "AGDisplayLinkViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AirGuitarSDK.h"

@interface AGDisplayLinkViewController ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) AGAccessory *accessory;
@property (nonatomic, strong) AGAccessoryManager *airGuitarManager;


@end

@implementation AGDisplayLinkViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set up Air Guitar accessory
    _airGuitarManager = [AGAccessoryManager sharedAccessoryManager];
    
    // Check if Air Guitar Move compatible devices are already connected
    // In theory, multiple Air Guitar Moves could be connected. Choose the first
    
    if ([_airGuitarManager.connectedAGAccessories count]) {
        NSArray *accessories = [_airGuitarManager.connectedAGAccessories allValues];
        self.accessory = [accessories objectAtIndex:0];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.viewX = nil;
    self.viewY = nil;
    self.viewZ = nil;
    _airGuitarManager = nil;
}

- (void)viewWillAppear:(BOOL)animated {

    [self setupGameLoop];
    
    // Register for Air Guitar connect and disconnect notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:@"AGAccessoryDidConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:@"AGAccessoryDidDisconnect" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self endGameLoop];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}

// ---------------------
#pragma mark - Game Loop

- (void)setupGameLoop {
    // Set up game loop. gameLoop will be called every frame refresh (60 times per seconds)
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop:)];
        [self.displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
    }
}

- (void)endGameLoop {
    [self.displayLink invalidate];
    self.displayLink = nil;
    
    // hide bars
    _viewX.frame = CGRectZero;
    _viewY.frame = CGRectZero;
    _viewZ.frame = CGRectZero;
}

- (void)gameLoop:(CADisplayLink *)sender {

    CMAcceleration acceleration = self.accessory.acceleration;
    
    double xAmplitude = fabs(acceleration.x * 480.f);
    double yAmplitude = fabs(acceleration.y * 480.f);
    double zAmplitude = fabs(acceleration.z * 480.f);
    NSLog(@"CADisplayLink: %f, %f, %f", xAmplitude, yAmplitude, zAmplitude);
    
    _viewX.frame = CGRectMake(0.f, 480.f - xAmplitude, 106, xAmplitude);
    _viewY.frame = CGRectMake(106.f, 480.f - yAmplitude, 106, yAmplitude);
    _viewZ.frame = CGRectMake(212.f, 480.f - zAmplitude, 108, zAmplitude);
}

// ------------------------------------
#pragma mark - Air Guitar Notifications

- (void)accessoryDidConnect: (NSNotification *)notification {    
    self.accessory = (AGAccessory *) notification.object;
    [self setupGameLoop];
}

- (void)accessoryDidDisconnect: (NSNotification *)notification {
    [self endGameLoop];
}


@synthesize displayLink = _displayLink;

@synthesize airGuitarManager = _airGuitarManager,
            accessory = _accessory;

@synthesize viewX = _viewX,
            viewY = _viewY,
            viewZ = _viewZ;
@end
