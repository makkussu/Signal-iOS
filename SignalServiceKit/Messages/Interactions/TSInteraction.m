//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "TSInteraction.h"
#import "TSThread.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

NSString *NSStringFromOWSInteractionType(OWSInteractionType value)
{
    switch (value) {
        case OWSInteractionType_Unknown:
            return @"OWSInteractionType_Unknown";
        case OWSInteractionType_IncomingMessage:
            return @"OWSInteractionType_IncomingMessage";
        case OWSInteractionType_OutgoingMessage:
            return @"OWSInteractionType_OutgoingMessage";
        case OWSInteractionType_Error:
            return @"OWSInteractionType_Error";
        case OWSInteractionType_Call:
            return @"OWSInteractionType_Call";
        case OWSInteractionType_Info:
            return @"OWSInteractionType_Info";
        case OWSInteractionType_ThreadDetails:
            return @"OWSInteractionType_ThreadDetails";
        case OWSInteractionType_TypingIndicator:
            return @"OWSInteractionType_TypingIndicator";
        case OWSInteractionType_UnreadIndicator:
            return @"OWSInteractionType_UnreadIndicator";
        case OWSInteractionType_DateHeader:
            return @"OWSInteractionType_DateHeader";
        case OWSInteractionType_UnknownThreadWarning:
            return @"OWSInteractionType_UnknownThreadWarning";
        case OWSInteractionType_DefaultDisappearingMessageTimer:
            return @"OWSInteractionType_DefaultDisappearingMessageTimer";
    }
}

// MARK: -

@interface TSInteraction ()

@property (nonatomic) uint64_t sortId;
@property (nonatomic) uint64_t receivedAtTimestamp;
@property (nonatomic) uint64_t timestamp;

@end

// MARK: -

@implementation TSInteraction

+ (NSString *)collection {
    return @"TSInteraction";
}

- (instancetype)initWithUniqueId:(NSString *)uniqueId thread:(TSThread *)thread
{
    return [self initWithUniqueId:uniqueId timestamp:NSDate.ows_millisecondTimeStamp thread:thread];
}

- (instancetype)initWithUniqueId:(NSString *)uniqueId timestamp:(uint64_t)timestamp thread:(TSThread *)thread
{
    OWSAssertDebug(timestamp > 0);
    OWSAssertDebug(thread);

    self = [super initWithUniqueId:uniqueId];

    if (!self) {
        return self;
    }

    _timestamp = timestamp;
    _uniqueThreadId = thread.uniqueId;

    return self;
}

- (instancetype)initWithUniqueId:(NSString *)uniqueId
                       timestamp:(uint64_t)timestamp
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          thread:(TSThread *)thread
{
    OWSAssertDebug(timestamp > 0);
    OWSAssertDebug(thread);

    self = [super initWithUniqueId:uniqueId];

    if (!self) {
        return self;
    }

    _timestamp = timestamp;
    _receivedAtTimestamp = receivedAtTimestamp;
    _uniqueThreadId = thread.uniqueId;

    return self;
}

- (instancetype)initInteractionWithTimestamp:(uint64_t)timestamp thread:(TSThread *)thread
{
    OWSAssertDebug(timestamp > 0);

    self = [super init];

    if (!self) {
        return self;
    }

    _timestamp = timestamp;
    _uniqueThreadId = thread.uniqueId;
    _receivedAtTimestamp = [NSDate ows_millisecondTimeStamp];

    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          sortId:(uint64_t)sortId
                       timestamp:(uint64_t)timestamp
                  uniqueThreadId:(NSString *)uniqueThreadId
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId];

    if (!self) {
        return self;
    }

    _receivedAtTimestamp = receivedAtTimestamp;
    _sortId = sortId;
    _timestamp = timestamp;
    _uniqueThreadId = uniqueThreadId;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) {
        return nil;
    }

    // Previously the receivedAtTimestamp field lived on TSMessage, but we've moved it up
    // to the TSInteraction superclass.
    if (_receivedAtTimestamp == 0) {
        // Upgrade from the older "TSMessage.receivedAtDate" and "TSMessage.receivedAt" properties if
        // necessary.
        NSDate *receivedAtDate = [coder decodeObjectForKey:@"receivedAtDate"];
        if (!receivedAtDate) {
            receivedAtDate = [coder decodeObjectForKey:@"receivedAt"];
        }

        if (receivedAtDate) {
            _receivedAtTimestamp = [NSDate ows_millisecondsSince1970ForDate:receivedAtDate];
        }

        // For TSInteractions which are not TSMessage's, the timestamp *is* the receivedAtTimestamp
        if (_receivedAtTimestamp == 0) {
            _receivedAtTimestamp = _timestamp;
        }
    }

    return self;
}

#pragma mark Thread

- (nullable TSThread *)threadWithTx:(SDSAnyReadTransaction *)tx
{
    if (self.uniqueThreadId == nil) {
        // This might be true for a few legacy interactions enqueued in the message
        // sender. The message sender will handle this case.
        return nil;
    }

    // However, it's also possible that the thread doesn't exist.
    return [TSThread anyFetchWithUniqueId:self.uniqueThreadId transaction:tx];
}

#pragma mark Date operations

- (NSDate *)receivedAtDate
{
    return [NSDate ows_dateWithMillisecondsSince1970:self.receivedAtTimestamp];
}

- (NSDate *)timestampDate
{
    return [NSDate ows_dateWithMillisecondsSince1970:self.timestamp];
}

- (OWSInteractionType)interactionType
{
    OWSFailDebug(@"unknown interaction type.");

    return OWSInteractionType_Unknown;
}

- (NSString *)description
{
    return [NSString
        stringWithFormat:@"%@ in thread: %@ timestamp: %llu", [super description], self.uniqueThreadId, self.timestamp];
}

#pragma mark - Any Transaction Hooks

- (void)anyDidInsertWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidInsertWithTransaction:transaction];

    TSThread *fetchedThread = [self threadWithTx:transaction];
    [fetchedThread updateWithInsertedMessage:self transaction:transaction];

    // Don't update interactionReadCache; this instance's sortId isn't
    // populated yet.
}

- (void)anyWillRemoveWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [SDSDatabaseStorage.shared updateIdMappingWithInteraction:self transaction:transaction];

    [super anyWillRemoveWithTransaction:transaction];
}

- (void)anyDidUpdateWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidUpdateWithTransaction:transaction];

    TSThread *fetchedThread = [self threadWithTx:transaction];
    [fetchedThread updateWithUpdatedMessage:self transaction:transaction];

    [self.modelReadCaches.interactionReadCache didUpdateInteraction:self transaction:transaction];
}

- (void)anyDidRemoveWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidRemoveWithTransaction:transaction];

    if (![transaction shouldIgnoreInteractionUpdatesForThreadUniqueId:self.uniqueThreadId]) {
        TSThread *fetchedThread = [self threadWithTx:transaction];
        [fetchedThread updateWithRemovedMessage:self transaction:transaction];
    }

    [MessageSendLogObjC deleteAllPayloadsForInteraction:self tx:transaction];
    [self.modelReadCaches.interactionReadCache didRemoveInteraction:self transaction:transaction];
}

#pragma mark -

- (BOOL)isDynamicInteraction
{
    return NO;
}

#pragma mark - sorting migration

- (void)replaceSortId:(uint64_t)sortId {
    _sortId = sortId;
}

#if TESTABLE_BUILD

- (void)replaceTimestamp:(uint64_t)timestamp transaction:(SDSAnyWriteTransaction *)transaction
{
    [self anyUpdateWithTransaction:transaction
                             block:^(TSInteraction *interaction) { interaction.timestamp = timestamp; }];
}

- (void)replaceReceivedAtTimestamp:(uint64_t)receivedAtTimestamp
{
    self.receivedAtTimestamp = receivedAtTimestamp;
}

- (void)replaceReceivedAtTimestamp:(uint64_t)receivedAtTimestamp transaction:(SDSAnyWriteTransaction *)transaction
{
    [self anyUpdateWithTransaction:transaction
                             block:^(TSInteraction *interaction) {
                                 interaction.receivedAtTimestamp = receivedAtTimestamp;
                             }];
}
#endif

@end

NS_ASSUME_NONNULL_END