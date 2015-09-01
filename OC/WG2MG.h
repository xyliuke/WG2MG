//
//  WG2MG.h
//  Antilost
//
//  Created by liuke on 15/9/1.
//  Copyright (c) 2015年 liuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WG2MG : NSObject

+ (CLLocationCoordinate2D) WG2MG:(double)lat lon:(double)lon;

@end
