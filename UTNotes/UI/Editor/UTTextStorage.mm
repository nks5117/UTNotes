//
//  UTTextStorage.m
//  UTNotes
//
//  Created by 倪可塑 on 2021/10/24.
//

#import "UTTextStorage.h"
#import <tree_sitter/api.h>
#import "NSString+TSInput.h"

#ifdef __cplusplus
extern "C" {
#endif
TSLanguage *tree_sitter_markdown(void);
#ifdef __cplusplus
}
#endif

@interface UTTextStorage () {
    TSParser *m_parser;
    TSTree *m_tree;
}
@property (nonatomic, strong) NSTextStorage *imp;
@end

@implementation UTTextStorage

- (instancetype)init {
    if (self = [super init]) {
        self.imp = [[NSTextStorage alloc] init];
        [self initParser];
    }
    return self;
}

- (void)initParser {
    TSParser *parser = ts_parser_new();
    ts_parser_set_language(parser, tree_sitter_markdown());
    m_parser = parser;
}

- (NSString *)string {
    return self.imp.string;
}

- (NSDictionary<NSAttributedStringKey,id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [self.imp attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [self.imp replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
}

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)attrs range:(NSRange)range {
    [self.imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)processEditing {
    if (m_tree == NULL) {
        m_tree = ts_parser_parse(m_parser, NULL, self.string.getTSInput);
    } else {
        uint32_t start_byte = (uint32_t)self.editedRange.location * 2;
        uint32_t new_end_byte = start_byte + (uint32_t)self.editedRange.length * 2;
        uint32_t old_end_byte = (uint32_t)new_end_byte - (uint32_t)self.changeInLength * 2;

        TSInputEdit edit;
        edit.start_byte = start_byte;
        edit.new_end_byte = new_end_byte;
        edit.old_end_byte = old_end_byte;

        ts_tree_edit(m_tree, &edit);
        TSTree *newTree = ts_parser_parse(m_parser, m_tree, self.string.getTSInput);

        uint32_t rangeCount;
        TSRange *editedRanges = ts_tree_get_changed_ranges(m_tree, newTree, &rangeCount);
        for (int i = 0; i < rangeCount; i++) {
            NSLog(@"(%d, %d)", editedRanges[i].start_byte, editedRanges[i].end_byte);
        }

        ts_tree_delete(m_tree);
        m_tree = newTree;
    }

    [super processEditing];
}

@end
