//
//  AGAccessory.h
//  AirGuitarSDK
//
//  Created by Ronald Mannak on 7/21/12.
//  Copyright (c) 2012 Yobble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@class AGAccessory;

@protocol AGAccessoryProtocol
- (void) accessory: (AGAccessory *) accessory x: (double) x y: (double) y z: (double) z;
@end

@interface AGAccessory : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <AGAccessoryProtocol> delegate;

// Add XYZ acceleration data

@property (nonatomic, strong) EASession *session;
@property (nonatomic, weak) EAAccessory *accessory;

- (id)initWithAccessory: (EAAccessory *)accessory protocol: (NSString *) protocolString; 

@end
