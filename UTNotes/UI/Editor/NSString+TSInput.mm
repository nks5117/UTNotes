//
//  NSString+TSInput.m
//  UTNotes
//
//  Created by 倪可塑 on 2021/10/24.
//

#import "NSString+TSInput.h"

const char *readString16(void *payload, uint32_t byte_offset, TSPoint position, uint32_t *bytes_read) {
    NSString *str = (__bridge NSString *)(payload);
    NSData *data = [str dataUsingEncoding:NSUTF16StringEncoding];
    
    uint32_t end_byte = byte_offset + 32;
    if (end_byte > data.length) {
        end_byte = (uint32_t)data.length;
    }
    
    *bytes_read = end_byte - byte_offset;
    
    void *buffer = malloc(*bytes_read);
    
    memcpy(buffer, (char *)data.bytes + byte_offset, *bytes_read);
    
    return (const char *)buffer;
}

@implementation NSString (TSInput)
- (TSInput)getTSInput {
    TSInput input;
    input.payload = (__bridge void *)(self);
    input.encoding = TSInputEncodingUTF16;
    input.read = readString16;
    return input;
}
@end
