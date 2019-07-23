//
//  PIPS_static_lib.h
//  PIPS_static_lib
//
//  Copyright © 2019 SIRL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIRLPosition : NSObject

@property (nonatomic) NSString* getVersion;

- (BOOL) initAisleRegions:(NSString *) aisleRegionsJsonStr;
- (NSDictionary<NSString*,NSNumber*>*) adjustPosition: (double) x andY:(double) y;
- (NSDictionary<NSString*,NSNumber*>*) predictPositions: (double) x andY: (double) y andVx: (double)vx andVy: (double)vy confident:(double) con;

@end
