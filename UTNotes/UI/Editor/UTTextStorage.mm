//
//  UTTextStorage.m
//  UTNotes
//
//  Created by 倪可塑 on 2021/10/24.
//

#import "UTTextStorage.h"
#import "tree_sitter/api.h"
#import "UTNotes-Swift.h"

#ifdef __cplusplus
extern "C" {
#endif
TSLanguage *tree_sitter_markdown(void);
#ifdef __cplusplus
}
#endif

static NSDictionary<NSString *, NSString *> *patterns = @{
    @"h1": @"(atx_heading (atx_h1_marker))",
    @"h2": @"(atx_heading (atx_h2_marker))",
    @"h3": @"(atx_heading (atx_h3_marker))",
    @"h4": @"(atx_heading (atx_h4_marker))",
    @"h5": @"(atx_heading (atx_h5_marker))",
    @"italic": @"(emphasis)",
    @"bold": @"(strong_emphasis)",
    @"strikethrough": @"(strikethrough)",
    @"inlineCode": @"(code_span)",
    @"codeBlock1": @"(fenced_code_block)",
    @"codeBlock2": @"(indented_code_block)",
    @"table": @"(table)",
    @"listMarker": @"(list_marker)",
    @"link": @"(link)",
};

NodeType nodeTypeForCaptureName(const char *name) {
    NSString *nsName = [NSString stringWithFormat:@"%s", name];
    static NSDictionary<NSString *, NSNumber *> *dic = @{
        @"h1": @(NodeTypeH1),
        @"h2": @(NodeTypeH2),
        @"h3": @(NodeTypeH3),
        @"h4": @(NodeTypeH4),
        @"h5": @(NodeTypeH5),
        @"italic": @(NodeTypeItalic),
        @"bold": @(NodeTypeBold),
        @"strikethrough": @(NodeTypeStrikethrough),
        @"inlineCode": @(NodeTypeInlineCode),
        @"codeBlock1": @(NodeTypeBlockCode),
        @"codeBlock2": @(NodeTypeBlockCode),
        @"table": @(NodeTypeTable),
        @"listMarker": @(NodeTypeListMarker),
        @"link": @(NodeTypeLink),
    };
    return (NodeType)[dic objectForKey:nsName].unsignedIntValue;
}

static char *querySource;

void getQuerySource() {
    NSMutableString *queryString = @"".mutableCopy;
    for (NSString *name in patterns) {
        NSString *query = [patterns objectForKey:name];
        [queryString appendFormat:@"%@ @%@ ", query, name];
    }

    querySource = (char *)malloc(sizeof(char) * strlen([queryString cStringUsingEncoding:NSUTF8StringEncoding]));
    strcpy(querySource, [queryString cStringUsingEncoding:NSUTF8StringEncoding]);
}

const char *readString16(void *payload, uint32_t byte_offset, TSPoint position, uint32_t *bytes_read) {
    NSData *data = (__bridge NSData *)(payload);

    if (byte_offset >= data.length) {
        *bytes_read = 0;
        return NULL;
    }

    uint32_t end_byte = byte_offset + 32;
    if (end_byte > data.length) {
        end_byte = (uint32_t)data.length;
    }
    *bytes_read = end_byte - byte_offset;

    return (const char *)data.bytes + byte_offset;
}

@interface UTTextStorage () {
    TSParser *m_parser;
    TSTree *m_tree;
    NSData *m_data;
}

@property (nonatomic, strong) NSTextStorage *imp;
@end

@implementation UTTextStorage

+ (void)initialize {
    getQuerySource();
}

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

- (void)dealloc {
    ts_tree_delete(m_tree);
    ts_parser_delete(m_parser);
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
    NSLog(@"----begin process editing----");
    m_data = [self.string dataUsingEncoding:NSUTF16StringEncoding];

    if (m_tree == NULL) {
        NSTimeInterval startTime = NSDate.timeIntervalSinceReferenceDate;
        m_tree = ts_parser_parse(m_parser, NULL, self.getTSInput);
        [self updateAttributesForStartByte:0 endByte:self.string.length * 2];
        NSTimeInterval endTime = NSDate.timeIntervalSinceReferenceDate;
        NSLog(@"first time parse: %f", endTime - startTime);
    } else {
        NSTimeInterval startTime = NSDate.timeIntervalSinceReferenceDate;

        uint32_t start_byte = (uint32_t)self.editedRange.location * 2 + 2;
        uint32_t new_end_byte = start_byte + (uint32_t)self.editedRange.length * 2;
        uint32_t old_end_byte = new_end_byte - (uint32_t)self.changeInLength * 2;

        TSInputEdit edit;
        edit.start_byte = start_byte;
        edit.new_end_byte = new_end_byte;
        edit.old_end_byte = old_end_byte;

        ts_tree_edit(m_tree, &edit);
        TSTree *newTree = ts_parser_parse(m_parser, m_tree, self.getTSInput);

        uint32_t rangeCount;

        TSRange *editedRanges = ts_tree_get_changed_ranges(m_tree, newTree, &rangeCount);
        ts_tree_delete(m_tree);
        m_tree = newTree;

        NSTimeInterval endTime = NSDate.timeIntervalSinceReferenceDate;
        NSLog(@"incremental parse: %f", endTime - startTime);

        startTime = NSDate.timeIntervalSinceReferenceDate;
        for (int i = 0; i < rangeCount; i++) {
            [self updateAttributesForStartByte:editedRanges[i].start_byte endByte:editedRanges[i].end_byte];
        }
        endTime = NSDate.timeIntervalSinceReferenceDate;
        NSLog(@"update attributes: %f", endTime - startTime);

        free(editedRanges);
    }

    NSLog(@"%s", ts_node_string(ts_tree_root_node(m_tree)));
    NSLog(@"----end process editing----");

    [super processEditing];
}

- (void)updateAttributesForStartByte:(NSUInteger)startByte endByte:(NSUInteger)endByte {
    if (startByte >= endByte) {
        return;
    }

    TSNode currentNode = ts_node_descendant_for_byte_range(ts_tree_root_node(m_tree), (uint32_t)startByte, (uint32_t)endByte);

    uint32_t nodeStartByte = ts_node_start_byte(currentNode);
    uint32_t nodeEndByte = ts_node_end_byte(currentNode);
    NSRange nodeRange = [self nsRangeForStartByte:nodeStartByte endByte:nodeEndByte];

    if (nodeRange.length == 0) {
        return;
    }

    NSLog(@"update attributes for startByte %lu, endByte %lu", startByte, endByte);

    NSMutableDictionary<NSAttributedStringKey, id> *attributes = [Theme.defaultTheme attributesFor:NodeTypeText].mutableCopy;
    [attributes setValue:Theme.defaultTheme.defaultFount forKey:NSFontAttributeName];
    [self setAttributes:attributes range:nodeRange];

    uint32_t error_offset;
    TSQueryError error_type;
    TSQuery *query = ts_query_new(ts_parser_language(m_parser), querySource, (uint32_t)strlen(querySource), &error_offset, &error_type);

    if (query == NULL) {
        return;
    }

    TSQueryCursor *queryCursor = ts_query_cursor_new();
    ts_query_cursor_set_byte_range(queryCursor, (uint32_t)nodeStartByte, (uint32_t)nodeEndByte);
    ts_query_cursor_exec(queryCursor, query, ts_tree_root_node(m_tree));

    TSQueryMatch match;
    while (ts_query_cursor_next_match(queryCursor, &match)) {
        uint32_t length;
        const char *name = ts_query_capture_name_for_id(query, match.pattern_index, &length);
        NodeType nodeType = nodeTypeForCaptureName(name);

        NSDictionary<NSAttributedStringKey, id> *attributes = [Theme.defaultTheme attributesFor:nodeType];
        UIFontDescriptor *fontDescriptor = [Theme.defaultTheme fontDescriptorFor:nodeType];

        for (int i = 0; i < match.capture_count; i++) {
            TSNode node = match.captures[i].node;
            uint32_t nodeStartByte = ts_node_start_byte(node);
            uint32_t nodeEndByte = ts_node_end_byte(node);
            NSRange range = [self nsRangeForStartByte:nodeStartByte endByte:nodeEndByte];

            CGFloat fontSize = fontDescriptor.pointSize;
            if (fontDescriptor.pointSize == 0.0) {
                UIFont *currentFont = [self attribute:NSFontAttributeName atIndex:range.location effectiveRange:nil];
                if (currentFont == nil) {
                    currentFont = Theme.defaultTheme.defaultFount;
                }
                fontSize = currentFont.pointSize;
            }

            NSMutableDictionary<NSAttributedStringKey, id> *mutableAttributes = attributes.mutableCopy;
            [mutableAttributes setValue:[UIFont fontWithDescriptor:fontDescriptor size:fontSize] forKey:NSFontAttributeName];

            if (nodeType == NodeTypeInlineCode) {
                NSString *subString = [self.string substringWithRange:range];
                if ([subString hasPrefix:@"$"]) {
                    if ([subString hasPrefix:@"$$"]) {
                        [mutableAttributes setValue:subString forKey:@"InlineBlockFormula"];
                    } else {
                        [mutableAttributes setValue:subString forKey:@"InlineFormula"];
                    }
                }
            }

            if (nodeType == NodeTypeInlineCode || nodeType == NodeTypeBlockCode || nodeType == NodeTypeLink) {
                [mutableAttributes setValue:@(1) forKey:@"CodeNode"];
            }

            [self addAttributes:mutableAttributes range:range];
        }
    }

    ts_query_cursor_delete(queryCursor);
    ts_query_delete(query);
}

- (NSRange)nsRangeForStartByte:(NSUInteger)startByte endByte:(NSUInteger)endByte {
    startByte -= 2;
    endByte -= 2;
    NSUInteger location = startByte / 2;
    NSUInteger length = (endByte - startByte) / 2;

    if (startByte % 2 == 1 || endByte % 2 == 1 || length < 0 || location + length > self.string.length) {
        return NSMakeRange(0, 0);
    }

    return NSMakeRange(startByte / 2, length);
}

- (TSInput)getTSInput {
    TSInput input;
    input.payload = (__bridge void *)(m_data);
    input.encoding = TSInputEncodingUTF16;
    input.read = readString16;
    return input;
}

@end
