//
//  AGAccessory.m
//  AirGuitarSDK
//
//  Created by Ronald Mannak on 7/21/12.
//  Copyright (c) 2012 Yobble. All rights reserved.
//

#import "AGAccessory.h"
#import "AGAccessoryManager.h"
#import "BoardMessage.h"

#define MAX_MESSAGE_LENGTH      1024
#define RECEIVE_BUFFER_LENGTH   1024*4

@interface AGAccessory () {
    NSMutableData *_writeData;
    NSMutableData *_readData;
}
@end

@implementation AGAccessory

- (id)initWithAccessory: (EAAccessory *)accessory protocol: (NSString *) protocolString {
    self = [super init];
    if (self) {
        
        // Open session
        _session = [[EASession alloc] initWithAccessory:accessory forProtocol:protocolString];
        _accessory = accessory;
        
        if (_session) {
            [[_session inputStream] setDelegate:self];
            [[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[_session inputStream] open];
            
            [[_session outputStream] setDelegate:self];
            [[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[_session outputStream] open];
            
            [self enableAccelerometerData: YES];
        }
        else NSLog(@"creating session failed");
        
    }
    return self;    
}

- (void)dealloc {
    DLog(@"deallocing AGAccessory");
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];    
    _session = nil;
    
    _writeData = nil;
    _readData = nil;
}


#pragma mark - Setting Air Guitar accessory


- (void) enableAccelerometerData:(BOOL)enable{
	BoardMessage * message = [BoardMessage analogInLiveEnable:enable];
    if ([[_session outputStream] hasSpaceAvailable]) {
        [[_session outputStream] write: [message getMsgDataPtr] maxLength: [message length]];
    }
} 

#pragma mark - NSStream functions

// low level write method - write data to the accessory while there is space available and data to write
- (void)_writeData {
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeData length] > 0))
    {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeData bytes] maxLength:[_writeData length]];
        if (bytesWritten == -1)
        {
            NSLog(@"write error");
            break;
        }
        else if (bytesWritten > 0)
        {
            [_writeData replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}

// low level read method - read data while there is data and space available in the input buffer
- (void)_readData {
    
/*    #define EAD_INPUT_BUFFER_SIZE 128
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
    while ([[_session inputStream] hasBytesAvailable])
    {
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        if (_readData == nil) {
            _readData = [[NSMutableData alloc] init];
        }
        [_readData appendBytes:(void *)buf length:bytesRead];
        //NSLog(@"read %d bytes from input stream", bytesRead);
    }
    DLog(@"reading data: %@", _readData); */
    
    
    
    u_int8_t buffer[MAX_MESSAGE_LENGTH];
	NSInteger length = 0;
	BoardMessage *message;
    static u_int8_t receiveBufferLength = 0;
    static u_int8_t receiveBuffer[RECEIVE_BUFFER_LENGTH];
    
    // needs to be read
    // read into a buffer first as there is no guarantee this will land on a message boundry
    if (receiveBufferLength + MAX_MESSAGE_LENGTH <= RECEIVE_BUFFER_LENGTH) {
        length = [[_session inputStream] read:buffer maxLength:MAX_MESSAGE_LENGTH];
        if (length) {
            memcpy(receiveBuffer+receiveBufferLength, buffer, length);
            receiveBufferLength = receiveBufferLength + length;
        }
    } 
    
    // parse the message buffer for as long as possible
    do {
        message = [BoardMessage parse:receiveBuffer length:receiveBufferLength];
        if (message) {
            receiveBufferLength = receiveBufferLength - message.length;
            if (receiveBufferLength > 0) {
                memmove(receiveBuffer, receiveBuffer+message.length, receiveBufferLength);
            }
            [self parseAccessoryAcceleremeterMessage:message];
        }
    } while (message != nil);
} 

- (void) parseAccessoryAcceleremeterMessage: (BoardMessage *) message {

	BoardMessage *boardMessage = (BoardMessage *)message; // TODO

    int analogChannelsToRead=[boardMessage getByte:0];
    int dataIndex;
    int x,y,z;
    dataIndex=1;
    
    if (analogChannelsToRead==3){
        u_int8_t channelNumber=[boardMessage getByte:dataIndex++];
        x=([boardMessage getByte:dataIndex++]<<8) + [boardMessage getByte:dataIndex++];
                
        channelNumber = [boardMessage getByte:dataIndex++];
        y=([boardMessage getByte:dataIndex++]<<8) + [boardMessage getByte:dataIndex++];
                
        channelNumber = [boardMessage getByte:dataIndex++];
        z=([boardMessage getByte:dataIndex++]<<8) + [boardMessage getByte:dataIndex++];
        
        float rawX =(x-512.f)/64.f;
        float rawY =(y-512.f)/64.f;
        float rawZ =(z-512.f)/64.f;
        
        [_delegate accessory: self x: rawX y:rawY z:rawZ];
    }
}

#pragma mark NSStreamDelegateEventExtensions

// asynchronous NSStream handleEvent method
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            [self _writeData];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}


@synthesize delegate = _delegate,
            session = _session,
            accessory = _accessory;
@end
