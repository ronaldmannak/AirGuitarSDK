#import "BoardMessage.h"
@implementation BoardMessage

@synthesize messageId;
@synthesize dataLength;
@synthesize messageType;


+ (id) parse: (u_int8_t *) data length: (u_int8_t) length {
  if (length >= 2) {
    BoardMessage *message = [[BoardMessage alloc] init];
    message.messageId = data[1];
    if (message.messageId == 0x04) {
      [message addDataByte: data[2]];
    }
	else if (message.messageId == BOARD_DIN_VALUES){
		[message addDataByte: data[2]];  //just sets data[0]=data[2] and datalength=1?
	}
	else if (message.messageId == BOARD_AIN_VALUES){
		int parseLoop=2;
		for (parseLoop=2; parseLoop<length; parseLoop++) {
			[message addDataByte: data[parseLoop]];
		}
	}
	else if (message.messageId == BOARD_AIN_RECORD_DATA){
		int parseLoop=2;
		for (parseLoop=2; parseLoop<length; parseLoop++) {
			[message addDataByte: data[parseLoop]];
		}
	}
      return message;
  } 
  else {
    return nil;
  }
}
- (u_int8_t*) getMsgDataPtr{
    return msgDataPtr;
}
- (u_int8_t*) getDataPtr{
    return data;
}

+ (id) accelSens: (NSUInteger) sens{
	BoardMessage *message = [[BoardMessage alloc] init];
	message.messageId = BOARD_ACCEL_SENS;
	[message buildMessage: sens];
    
	return message;   
}

+ (id) digitalInEnable: (BOOL) enable{
	BoardMessage *message = [[BoardMessage alloc] init];
	message.messageId = BOARD_DIN_ENABLE;
	[message buildMessage: enable];
	return message;
}
+ (id) analogInLiveEnable: (BOOL) enable{
	BoardMessage *message = [[BoardMessage alloc] init];
	message.messageId = BOARD_AIN_LIVE_ENABLE;
	[message buildMessage: enable];
	return message; 
	
}
+ (id) digitalOutValues: (u_int8_t) digOutValues{
	BoardMessage *message = [[BoardMessage alloc] init];
	message.messageId = BOARD_DOUT_VALUES;
	[message buildMessage: digOutValues];
	return message;
}
+ (id) analogInEnable: (u_int8_t) analogInEnableValues{
	BoardMessage *message = [[BoardMessage alloc] init];
	message.messageId = BOARD_AIN_ENABLE;

	[message buildMessage: analogInEnableValues];
	return message; 
	
}
+ (id) counterLimit: (int) limit{
	BoardMessage *message = [[BoardMessage alloc] init];
	message.messageId = BOARD_SAMPLE_RATE;
	
	[message buildMessage: limit>>8];
	
	return message; 
}

- (id) init {
  if ( self = [super init] ) {
    messageType = BOARD_MESSAGE;
    messageId = -1;
    dataLength = 0;
  }
  return self;
}

- (u_int8_t) length {
  return 2 + dataLength;
}

- (void) buildMessage: (u_int8_t) d {
    data[dataLength] = d;             //datalenght is 1
    dataLength+=1;                    //datalenght is 2
    msgDataPtr[0] = messageType;
    msgDataPtr[1] = messageId;
    msgDataPtr[2] = d;

    
}
- (void) addDataByte: (u_int8_t) d{
    data[dataLength] = d;             //datalenght is 1
    dataLength+=1;                    //datalenght is 2
}

- (void) dataFromBuf: (u_int8_t *) dataToSend{
    
}


- (u_int8_t) getByte: (u_int8_t) index{
	return data[index];
}
- (u_int8_t) rdata {
  return data[0];
}

@end
