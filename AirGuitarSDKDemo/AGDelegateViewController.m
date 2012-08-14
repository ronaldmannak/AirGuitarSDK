//
//  AGViewController.m
//  AirGuitarSDKDemo
//
//  Created by Ronald Mannak on 7/20/12.
//  Copyright (c) 2012 Yobble. All rights reserved.
//

#import "AGDelegateViewController.h"

@interface AGDelegateViewController () 

@property (nonatomic, strong) UIView *viewX;
@property (nonatomic, strong) UIView *viewY;
@property (nonatomic, strong) UIView *viewZ;

@property (nonatomic, strong) AGAccessoryManager *airGuitarManager;
@property (nonatomic, strong) UIAccelerometer *iPhoneAccelerometer;

@end

@implementation AGDelegateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up Air Guitar accessory
    _airGuitarManager = [AGAccessoryManager sharedAccessoryManager];
    
    _viewX = [[UIView alloc] initWithFrame:CGRectZero];
    _viewX.backgroundColor = [UIColor redColor];
    _viewX.alpha = 0.5;
    [self.view addSubview:_viewX];
    
    _viewY = [[UIView alloc] initWithFrame:CGRectZero];
    _viewY.backgroundColor = [UIColor yellowColor];
    _viewY.alpha = 0.5;
    [self.view addSubview:_viewY];
    
    _viewZ = [[UIView alloc] initWithFrame:CGRectZero];
    _viewZ.backgroundColor = [UIColor greenColor];
    _viewZ.alpha = 0.5;
    [self.view addSubview:_viewZ];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _airGuitarManager = nil;
    _viewX = nil;
    _viewY = nil;
    _viewZ = nil;
}

- (void)viewWillAppear:(BOOL)animated {
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
    
    // Set up the iPhone accelerometer for demo purposes. The Air Guitar acccessory works fine if you don't initiate the iPhone's accelerometer.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    _iPhoneAccelerometer = [UIAccelerometer sharedAccelerometer];
    _iPhoneAccelerometer.updateInterval = 1.f / 60.f;
    _iPhoneAccelerometer.delegate = self;
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


// -------------------------------
#pragma mark - Air Guitar Delegate

- (void) accessory: (AGAccessory *) accessory x: (double) x y: (double) y z: (double) z {
    
    static double maxX = 0, maxY = 0, maxZ = 0;
    if (x > maxX) maxX = x;
    if (y > maxY) maxY = y;
    if (z > maxZ) maxZ = z;
    
    int tag = accessory.accessory.connectionID;
    
    UITableViewCell *cell = (UITableViewCell *) [self.view viewWithTag: tag];    
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%.2f,%.2f,%.2f Max: %.2f,%.2f,%.2f", x, y, z, maxX, maxY, maxZ];

    double xAmplitude = fabs(x * 480.f);
    double yAmplitude = fabs(y * 480.f);
    double zAmplitude = fabs(z * 480.f);
    NSLog(@"Delegate: %f, %f, %f", xAmplitude, yAmplitude, zAmplitude);
    
    _viewX.frame = CGRectMake(0.f, 480.f - xAmplitude, 106, xAmplitude);
    _viewY.frame = CGRectMake(106.f, 480.f - yAmplitude, 106, yAmplitude);
    _viewZ.frame = CGRectMake(212.f, 480.f - zAmplitude, 108, zAmplitude);
}
 
// ------------------------------------
#pragma mark - Air Guitar Notifications

- (void)accessoryDidConnect: (NSNotification *)notification {    
    AGAccessory *connectedAccessory = (AGAccessory *) notification.object;
    connectedAccessory.delegate = self;
    
    [self.tableView reloadData];
}

- (void)accessoryDidDisconnect: (NSNotification *)notification {
    [self.tableView reloadData];
} 

// -----------------------------------------
#pragma mark - iPhone accelerometer delegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    static double maxX = 0, maxY = 0, maxZ = 0;
    if (acceleration.x > maxX) maxX = acceleration.x;
    if (acceleration.y > maxY) maxY = acceleration.y;
    if (acceleration.z > maxZ) maxZ = acceleration.z;
    
    UITableViewCell *cell = (UITableViewCell *) [self.view viewWithTag:-1];    
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%.2f,%.2f,%.2f Max: %.2f,%.2f,%.2f", acceleration.x, acceleration.y, acceleration.z, maxX, maxY, maxZ];
} 

// ------------------------------
#pragma mark - tableView delegate



// --------------------------------
#pragma mark - tableView datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accelerometerCellId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"accelerometerCellId"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (0 == indexPath.section) {
        cell.textLabel.text = @"iPhone Accelerometer";
        cell.detailTextLabel.text = @"Receiving no acceleration data.";
        cell.tag = -1;
    }
    else if (1 == indexPath.section && indexPath.row < [_airGuitarManager.connectedAGAccessories count]) {
        NSArray *connectedAirGuitarAccessories = [_airGuitarManager.connectedAGAccessories allValues];
        AGAccessory *connectedAccessory = [connectedAirGuitarAccessories objectAtIndex:indexPath.row];
        
        cell.textLabel.text = @"Air Guitar Move";
        cell.detailTextLabel.text = @"Receiving no acceleration data.";
        cell.tag = connectedAccessory.accessory.connectionID;                    
    }
    else NSAssert(NO, @"indexPath out of bounds");

    return cell;
} 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) return 1;
    else return [_airGuitarManager.connectedAGAccessories count];    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
} 

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (0 == section) return @"iPhone Internal Accelerometer";
    else return @"Air Guitar Compatible Accessories";
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (0 == index) return 0;
    else return 1;
}


@synthesize viewX = _viewX,
            viewY = _viewY,
            viewZ = _viewZ;

@synthesize airGuitarManager = _airGuitarManager,
            iPhoneAccelerometer = _iPhoneAccelerometer;
@end
