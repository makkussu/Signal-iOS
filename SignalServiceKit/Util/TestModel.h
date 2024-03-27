//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/BaseModel.h>

NS_ASSUME_NONNULL_BEGIN

NSUInteger NSUIntegerMaxValue(void);

@interface TestModel : BaseModel

@property (nonatomic) double doubleValue;
@property (nonatomic) float floatValue;
@property (nonatomic) uint64_t uint64Value;
@property (nonatomic) int64_t int64Value;
@property (nonatomic) NSUInteger nsuIntegerValue;
@property (nonatomic) NSInteger nsIntegerValue;
@property (nonatomic, nullable) NSNumber *nsNumberValueUsingInt64;
@property (nonatomic, nullable) NSNumber *nsNumberValueUsingUInt64;
@property (nonatomic, nullable) NSDate *dateValue;

- (instancetype)initWithUniqueId:(NSString *)uniqueId NS_UNAVAILABLE;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithGrdbId:(int64_t)grdbId uniqueId:(NSString *)uniqueId NS_UNAVAILABLE;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
                       dateValue:(nullable NSDate *)dateValue
                     doubleValue:(double)doubleValue
                      floatValue:(float)floatValue
                      int64Value:(int64_t)int64Value
                  nsIntegerValue:(NSInteger)nsIntegerValue
         nsNumberValueUsingInt64:(nullable NSNumber *)nsNumberValueUsingInt64
        nsNumberValueUsingUInt64:(nullable NSNumber *)nsNumberValueUsingUInt64
                 nsuIntegerValue:(NSUInteger)nsuIntegerValue
                     uint64Value:(uint64_t)uint64Value
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:dateValue:doubleValue:floatValue:int64Value:nsIntegerValue:nsNumberValueUsingInt64:nsNumberValueUsingUInt64:nsuIntegerValue:uint64Value:));

// clang-format on

// --- CODE GENERATION MARKER

@end

NS_ASSUME_NONNULL_END