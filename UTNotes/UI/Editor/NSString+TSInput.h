//
//  NSString+TSInput.h
//  UTNotes
//
//  Created by 倪可塑 on 2021/10/24.
//

#import <Foundation/Foundation.h>
#include <tree_sitter/api.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TSInput)
- (TSInput)getTSInput;
@end

NS_ASSUME_NONNULL_END
