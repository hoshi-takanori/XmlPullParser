//
//  XmlPullParser.m
//  XmlPullParser
//
//  Created by Hoshi Takanori on 11/12/07.
//  Copyright (c) 2011 -. All rights reserved.
//

#import "XmlPullParser.h"

enum {
    XmlPullParserConditionNormal,
    XmlPullParserConditionEvent,
};

@interface XmlPullParser () <NSXMLParserDelegate>

@property (nonatomic, copy) NSString *elementName;
@property (nonatomic, copy) NSDictionary *attributes;
@property (nonatomic, copy) NSString *text;

- (void)setEventType:(XmlPullParserEventType)newEventType;

@end

@implementation XmlPullParser {
    NSXMLParser *parser;
    NSConditionLock *conditionLock;
}

@synthesize eventType;
@synthesize depth;
@synthesize elementName;
@synthesize attributes;
@synthesize text;

#pragma mark -

- (id)initWithXMLParser:(NSXMLParser *)theParser
{
    self = [super init];
    if (self != nil) {
        parser = [theParser retain];
        parser.delegate = self;
    }
    return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    return [self initWithXMLParser:[[[NSXMLParser alloc] initWithContentsOfURL:url] autorelease]];
}

- (id)initWithData:(NSData *)data
{
    return [self initWithXMLParser:[[[NSXMLParser alloc] initWithData:data] autorelease]];
}

- (id)initWithStream:(NSInputStream *)stream
{
    return [self initWithXMLParser:[[[NSXMLParser alloc] initWithStream:stream] autorelease]];
}

- (NSInteger)lineNumber
{
    return parser.lineNumber;
}

- (NSInteger)columnNumber
{
    return parser.columnNumber;
}

- (BOOL)next
{
    if (eventType != XmlPullParserEndDocument) {
        // start or resume the coroutine.
        if (conditionLock == nil) {
            conditionLock = [[NSConditionLock alloc] initWithCondition:XmlPullParserConditionNormal];
            [self performSelectorInBackground:@selector(parse) withObject:nil];
        } else {
            [conditionLock unlockWithCondition:XmlPullParserConditionNormal];
        }

        // wait for the coroutine to yield.
        [conditionLock lockWhenCondition:XmlPullParserConditionEvent];

        if (eventType == XmlPullParserEndDocument) {
            [conditionLock unlock];
        }
    }

    return eventType != XmlPullParserEndDocument;
}

- (NSString *)nextText
{
    [self next];
    return text;
}

- (BOOL)isStartTag
{
    return eventType == XmlPullParserStartTag;
}

- (BOOL)isStartTagWithName:(NSString *)name
{
    return eventType == XmlPullParserStartTag && [elementName isEqual:name];
}

- (BOOL)isEndTagWithName:(NSString *)name
{
    return eventType == XmlPullParserEndTag && [elementName isEqual:name];
}

#pragma mark -

- (void)parse
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [conditionLock lockWhenCondition:XmlPullParserConditionNormal];
    [parser parse];
    self.eventType = XmlPullParserEndDocument;

    [pool release];
}

- (void)setEventType:(XmlPullParserEventType)newEventType
{
    if (eventType != XmlPullParserEndDocument) {
        eventType = newEventType;

        // yield the coroutine.
        [conditionLock unlockWithCondition:XmlPullParserConditionEvent];

        if (eventType != XmlPullParserEndDocument) {
            // wait to be resumed.
            [conditionLock lockWhenCondition:XmlPullParserConditionNormal];
        }

        self.elementName = nil;
        self.attributes = nil;
        self.text = nil;
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.eventType = XmlPullParserStartDocument;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)theElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.elementName = theElementName;
    if (attributeDict.count > 0) {
        self.attributes = attributeDict;
    }
    depth++;
    self.eventType = XmlPullParserStartTag;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)theElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    self.elementName = theElementName;
    depth--;
    self.eventType = XmlPullParserEndTag;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"ERROR %@", parseError);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.text = string;
    self.eventType = XmlPullParserText;
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    // this delegate method is never called because of issues related to libxml2.
    // https://devforums.apple.com/message/40425#40425
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    // ignore comments.
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    self.text = [[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] autorelease];
    self.eventType = XmlPullParserText;
}

#pragma mark -

- (void)dealloc
{
    [parser release];
    [conditionLock release];
    [elementName release];
    [attributes release];
    [text release];
    [super dealloc];
}

@end
