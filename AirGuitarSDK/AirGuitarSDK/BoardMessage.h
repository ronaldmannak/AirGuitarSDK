#import <Foundation/Foundation.h>
//#import "Message.h"

#define BOARD_MESSAGE ((u_int8_t)0x00)
#define BOARD_MAX_MESSAGE_DATA_LENGTH 1024



#define BOARD_ERROR_BAD_MESSAGE       0x01
#define BOARD_MESSAGE_PROCESSED       0x02
#define BOARD_MESSAGE_NOT_PROCESSED   0x03
#define BOARD_HELLO                   0x04

#define BOARD_DIN_ENABLE              0x05      //IOTouch messages
#define BOARD_DIN_VALUES              0x06
#define BOARD_DOUT_VALUES             0x07
#define BOARD_AIN_ENABLE              0x08
#define BOARD_AIN_VALUES              0x09
#define BOARD_AOUT_VALUES             0x0A
#define BOARD_IMA_ENABLE              0x0B
#define BOARD_IMA_VALUES              0x0C
#define BOARD_IA_ENABLE               0x0D
#define BOARD_IA_VALUES               0x0F
#define BOARD_R_ENABLE                0x10
#define BOARD_R_VALUES                0x11
#define BOARD_SAMPLE_RATE			  0x12
#define BOARD_AIN_RECORD_START		  0x13
#define BOARD_AIN_RECORD_DATA		  0x14
#define BOARD_AIN_LIVE_ENABLE		  0x15
#define BOARD_AIN_RECORD_DATA_BUFFER_SIZE 144
#define BOARD_ACCEL_SENS              0x16

@interface BoardMessage : NSObject {
  u_int8_t messageId;
  u_int8_t dataLength;
  u_int8_t data[BOARD_MAX_MESSAGE_DATA_LENGTH];
  u_int8_t msgDataPtr[BOARD_MAX_MESSAGE_DATA_LENGTH];
  u_int8_t messageType;
}
@property(assign) u_int8_t messageType;
@property u_int8_t dataLength;
@property(assign) u_int8_t messageId;

- (id) init;
+ (id) parse: (u_int8_t *) data length: (u_int8_t) length;

//message types:
+ (id) accelSens: (NSUInteger) sens;
+ (id) digitalInEnable: (BOOL) enable;
+ (id) analogInLiveEnable: (BOOL) enable;
+ (id) digitalOutValues: (u_int8_t) digOutValues;
+ (id) analogInEnable: (u_int8_t) analogInEnableValues;
+ (id) counterLimit: (int) limit;

//- (u_int8_t) writeBytesToMessage: (u_int8_t *)bytesToWrite :(u_int8_t)numBytes;
    
- (u_int8_t) length;
- (void) buildMessage: (u_int8_t) d ;
- (void) addDataByte: (u_int8_t) d;

- (u_int8_t*) getMsgDataPtr;
- (u_int8_t*) getDataPtr;


- (u_int8_t) getByte: (u_int8_t) index;

- (u_int8_t) rdata;

@end
