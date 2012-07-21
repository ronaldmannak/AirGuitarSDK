//
//  AGAccessoryManager.h
//  AirGuitarSDK
//
//  Created by Ronald Mannak on 7/21/12.
//  Copyright (c) 2012 Yobble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@interface AGAccessoryManager : NSObject

@property (nonatomic, readonly) NSMutableArray *connectedAGAccessories;

/* If YES, AGAccessoryManager will send our connect and disconnect notications to app. */ 
@property (nonatomic) BOOL shouldSendNotifications;

+ (id)sharedAccessoryManager;
@end
