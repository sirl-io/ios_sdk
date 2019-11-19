#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if !defined(IBSegueAction)
# define IBSegueAction
#endif
#if __has_feature(modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import CoreBluetooth;
@import CoreData;
@import CoreLocation;
@import Foundation;
@import ObjectiveC;
@import UIKit;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="SIRLCore",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

@class NSEntityDescription;
@class NSManagedObjectContext;

SWIFT_CLASS_NAMED("AisleRegions")
@interface AisleRegions : NSManagedObject
- (void)willSave;
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class NSDate;

@interface AisleRegions (SWIFT_EXTENSION(SIRLCore))
@property (nonatomic) int32_t mlId;
@property (nonatomic, copy) NSString * _Nullable jsonStr;
@property (nonatomic, strong) NSDate * _Nullable cacheDate;
@end




SWIFT_CLASS_NAMED("NodeBlackList")
@interface NodeBlackList : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface NodeBlackList (SWIFT_EXTENSION(SIRLCore))
@property (nonatomic, strong) NSDate * _Nullable cacheDate;
@property (nonatomic, copy) NSString * _Nullable macAddress;
@end


SWIFT_CLASS("_TtC8SIRLCore10NodeConfig")
@interface NodeConfig : NSManagedObject
- (void)willSave;
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class NodeConfigTable;

@interface NodeConfig (SWIFT_EXTENSION(SIRLCore))
@property (nonatomic) int32_t mlId;
@property (nonatomic) int32_t roomId;
@property (nonatomic) int32_t nodeId;
@property (nonatomic, copy) NSString * _Nullable macAddress;
@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double z;
@property (nonatomic) double xMinimum;
@property (nonatomic) double yMinimum;
@property (nonatomic) double zMinimum;
@property (nonatomic) double xMaximum;
@property (nonatomic) double yMaximum;
@property (nonatomic) double zMaximum;
@property (nonatomic) double xa;
@property (nonatomic) double ya;
@property (nonatomic) double za;
@property (nonatomic) int32_t rotationOrder;
@property (nonatomic) double pathLoss;
@property (nonatomic) int32_t id;
@property (nonatomic) int32_t installationAisleId;
@property (nonatomic, strong) NodeConfigTable * _Nullable relaventTable;
@property (nonatomic, strong) NSDate * _Nullable cacheDate;
@end


SWIFT_CLASS("_TtC8SIRLCore15NodeConfigTable")
@interface NodeConfigTable : NSManagedObject
- (void)willSave;
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class NSSet;

SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface NodeConfigTable (SWIFT_EXTENSION(SIRLCore))
- (void)addNodeConfigObject:(NodeConfig * _Nonnull)value;
- (void)removeNodeConfigObject:(NodeConfig * _Nonnull)value;
- (void)addNodeConfig:(NSSet * _Nonnull)values;
- (void)removeNodeConfig:(NSSet * _Nonnull)values;
@end


@interface NodeConfigTable (SWIFT_EXTENSION(SIRLCore))
@property (nonatomic) int32_t mlId;
@property (nonatomic) int32_t custId;
@property (nonatomic) int32_t appId;
@property (nonatomic) int32_t locId;
@property (nonatomic) int32_t bldId;
@property (nonatomic, strong) NSSet * _Nullable nodeConfig;
@property (nonatomic, strong) NSDate * _Nullable cacheDate;
@end


SWIFT_CLASS("_TtC8SIRLCore4PIPS") SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface PIPS : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS_NAMED("SessionToken") SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SessionToken : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end




SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SessionToken (SWIFT_EXTENSION(SIRLCore))
@property (nonatomic, copy) NSString * _Nullable tripID;
@property (nonatomic, strong) NSDate * _Nullable timeStamp;
@property (nonatomic, copy) NSString * _Nullable token;
@property (nonatomic) int32_t mlID;
@end


SWIFT_CLASS_NAMED("Settings")
@interface Settings : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface Settings (SWIFT_EXTENSION(SIRLCore))
@property (nonatomic) BOOL backgroundMode;
@property (nonatomic) BOOL regionLocking;
@property (nonatomic) BOOL prediction;
@property (nonatomic, copy) NSString * _Nonnull apiKey;
@end


SWIFT_CLASS("_TtC8SIRLCore14SirlBLEAdapter") SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SirlBLEAdapter : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class CLLocationManager;
@class CLLocation;

SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SirlBLEAdapter (SWIFT_EXTENSION(SIRLCore)) <CLLocationManagerDelegate>
- (void)locationManager:(CLLocationManager * _Nonnull)manager didUpdateLocations:(NSArray<CLLocation *> * _Nonnull)locations;
- (void)locationManager:(CLLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
@end

@class CBCentralManager;
@class CBPeripheral;
@class NSNumber;

SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SirlBLEAdapter (SWIFT_EXTENSION(SIRLCore)) <CBCentralManagerDelegate>
- (void)centralManagerDidUpdateState:(CBCentralManager * _Nonnull)central;
- (void)centralManager:(CBCentralManager * _Nonnull)central didDiscoverPeripheral:(CBPeripheral * _Nonnull)peripheral advertisementData:(NSDictionary<NSString *, id> * _Nonnull)advertisementData RSSI:(NSNumber * _Nonnull)RSSI;
@end


SWIFT_CLASS("_TtC8SIRLCore13SirlBLEPacket") SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SirlBLEPacket : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class SirlGeoFence;
@protocol SirlCoreDelegate;

SWIFT_CLASS("_TtC8SIRLCore8SirlCore")
@interface SirlCore : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) SirlCore * _Nonnull shared;)
+ (SirlCore * _Nonnull)shared SWIFT_WARN_UNUSED_RESULT;
@property (nonatomic) BOOL autoDetectMainLocation;
- (void)setML_IDWithMlID:(uint32_t)mlID;
- (void)updateSettingWithBackgroundMode:(BOOL)backgroundMode apiKey:(NSString * _Nonnull)apiKey;
- (void)updateSettingWithApiKey:(NSString * _Nonnull)apiKey;
- (void)updateSettingWithBackgroundMode:(BOOL)backgroundMode regionLocking:(BOOL)regionLocking prediction:(BOOL)prediction apiKey:(NSString * _Nonnull)apiKey;
- (BOOL)registerGeoFenceWithGeoFences:(NSArray<SirlGeoFence *> * _Nonnull)geoFences SWIFT_WARN_UNUSED_RESULT;
- (void)addDelegateWithDelegate:(id <SirlCoreDelegate> _Nonnull)delegate;
- (void)setTestLocation;
- (void)setTestUserLocation:(double)x :(double)y :(double)z;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class sirlLocation;

SWIFT_PROTOCOL("_TtP8SIRLCore16SirlCoreDelegate_")
@protocol SirlCoreDelegate
@optional
- (void)didStartSirlNodeScan;
- (void)didStopSirlNodeScan;
- (void)didGetNewPosition:(sirlLocation * _Nonnull)position;
- (void)didChangeBLEAvalibility:(BOOL)blePowerOn;
- (void)didReceiveDebugMessage:(NSString * _Nonnull)msg;
- (void)didDetectMapLocationWithMlId:(uint32_t)mlId;
- (void)didChangeLocationServiceAuthorization:(NSString * _Nonnull)status;
- (void)didEnteredSirlRegion;
- (void)didExitedSirlRegion;
- (void)didInitializedSirlRegion;
- (void)didEnterGeoFenceWithId:(NSString * _Nonnull)id;
@end


SWIFT_CLASS("_TtC8SIRLCore12SirlCoreImpl") SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SirlCoreImpl : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end




SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SirlCoreImpl (SWIFT_EXTENSION(SIRLCore))
- (void)setTestLocation:(uint32_t)mlid;
@end






SWIFT_CLASS("_TtC8SIRLCore13SirlDataCache") SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface SirlDataCache : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC8SIRLCore12SirlGeoFence")
@interface SirlGeoFence : NSObject
- (nonnull instancetype)initWithDwellDuration:(NSInteger)dwellDuration margin:(double)margin id:(NSString * _Nonnull)id center:(sirlLocation * _Nonnull)center;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC8SIRLCore10SirlLogger")
@interface SirlLogger : NSObject
+ (void)recordProductCollectedWithUpc:(NSString * _Nonnull)upc;
+ (void)recordExternalTripId:(NSString * _Nonnull)id;
+ (void)recordExternalUserId:(NSString * _Nonnull)id;
+ (void)recordTransactionLog:(NSString * _Nonnull)data;
+ (void)recordTransactionLogWithUpc:(NSString * _Nonnull)upc name:(NSString * _Nonnull)name qty:(NSInteger)qty totalPrice:(double)totalPrice;
+ (void)recordMetaInformation:(NSString * _Nonnull)data;
+ (void)recordCustomEntryWithTag:(NSString * _Nonnull)tag data:(NSString * _Nonnull)data;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_PROTOCOL("_TtP8SIRLCore16SirlUserDelegate_")
@protocol SirlUserDelegate
@optional
- (void)didChangeLoginStatusWithStatus:(BOOL)status;
@end


SWIFT_CLASS_NAMED("TripData") SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface TripData : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface TripData (SWIFT_EXTENSION(SIRLCore))
@property (nonatomic) BOOL completed;
@property (nonatomic, copy) NSString * _Nullable tripID;
@property (nonatomic, copy) NSString * _Nullable fileName;
@property (nonatomic, strong) NSDate * _Nullable timeUpdate;
@property (nonatomic, copy) NSString * _Nullable type;
@end




SWIFT_CLASS("_TtC8SIRLCore12sirlLocation")
@interface sirlLocation : NSObject
@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double z;
- (nonnull instancetype)initWithX:(double)x y:(double)y z:(double)z OBJC_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly, copy) NSArray<NSNumber *> * _Nonnull ArrayValue;
@property (nonatomic, readonly, copy) NSString * _Nonnull xyString;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop

