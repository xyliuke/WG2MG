//
//  WG2MG.m
//  Antilost
//
//  Created by liuke on 15/9/1.
//  Copyright (c) 2015年 liuke. All rights reserved.
//

#import "WG2MG.h"

static double casm_rr = 0;
static double casm_t1 = 0;
static double casm_t2 = 0;
static double casm_x1 = 0;
static double casm_y1 = 0;
static double casm_x2 = 0;
static double casm_y2 = 0;
static double casm_f = 0;

@implementation WG2MG

+ (CLLocationCoordinate2D) WG2MG:(double)lat lon:(double)lon
{
    casm_rr = 0;
    casm_t1 = 0;
    casm_t2 = 0;
    casm_x1 = 0;
    casm_y1 = 0;
    casm_x2 = 0;
    casm_y2 = 0;
    casm_f = 0;
    
    double x1, tempx;
    double y1, tempy;
    x1 = lon * 3686400.0;
    y1 = lat * 3686400.0;
    double gpsWeek = 0;
    double gpsWeekTime = 0;
    double gpsHeight = 0;
    
    CLLocationCoordinate2D point = [WG2MG wgtochina_lb:1 wgLat:(int)y1 wgLon:(int)x1 wgHeight:(int)gpsHeight wgWeek:(int)gpsWeek wgTime:(int)gpsWeekTime];
    
    tempx = point.longitude;
    tempy = point.latitude;
    tempx = tempx / 3686400.0;
    tempy = tempy / 3686400.0;
    
    CLLocationCoordinate2D newPoint = CLLocationCoordinate2DMake(tempy, tempx);
    return newPoint;
}

+ (CLLocationCoordinate2D) wgtochina_lb:(int)wg_flag wgLat:(int)wgLat wgLon:(int)wgLon wgHeight:(int)h wgWeek:(int)week wgTime:(int)wg_time
{
    double  x_add;
    double  y_add;
    double  h_add;
    double  x_l;
    double  y_l;
    double  casm_v;
    double  t1_t2;
    double  x1_x2;
    double  y1_y2;
    
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(0, 0);
    
    if (h > 5000) {
        return point;
    }
    
    x_l = wgLon / 3686400.0;
    y_l = wgLat / 3686400.0;
    
    if (x_l < 72.004 || x_l > 137.8347) {
        return point;
    }
    if (y_l < 0.8293 || y_l > 55.8271) {
        return point;
    }

    if (wg_flag == 0) {
        [WG2MG IniCasm:wg_time lon:wgLon lat:wgLat];
        point.latitude = wgLat;
        point.longitude = wgLon;
        return point;
    }
    
    casm_t2 = wg_time;
    
    t1_t2 = (casm_t2 - casm_t1) / 1000.0;
    if (t1_t2 <= 0)
    {
        casm_t1 = casm_t2;
        casm_f = casm_f + 1;
        casm_x1 = casm_x2;
        casm_f = casm_f + 1;
        casm_y1 = casm_y2;
        casm_f = casm_f + 1;
    }
    else
    {
        if (t1_t2 > 120)
        {
            if (casm_f == 3)
            {
                casm_f = 0;
                casm_x2 = wgLon;
                casm_y2 = wgLat;
                x1_x2 = casm_x2 - casm_x1;
                y1_y2 = casm_y2 - casm_y1;
                casm_v = sqrt(x1_x2 * x1_x2 + y1_y2 * y1_y2) / t1_t2;
                if (casm_v > 3185)
                {
                    return (point);
                }
            }
            casm_t1 = casm_t2;
            casm_f = casm_f + 1;
            casm_x1 = casm_x2;
            casm_f = casm_f + 1;
            casm_y1 = casm_y2;
            casm_f = casm_f + 1;
        }
    }
    x_add = [WG2MG Transform_yj5:x_l - 105 y:y_l - 35];
    y_add = [WG2MG Transform_yjy5:x_l - 105 y:y_l - 35];
    h_add = h;
    x_add = x_add + h_add * 0.001 + [WG2MG yj_sin2:wg_time * 0.0174532925199433] + [WG2MG random_yj];
    y_add = y_add + h_add * 0.001 + [WG2MG yj_sin2:wg_time * 0.0174532925199433] + [WG2MG random_yj];

    point.longitude = (x_l + [WG2MG Transform_jy5:y_l xx:x_add]) * 3686400;
    point.latitude = (y_l + [WG2MG Transform_jyj5:y_l yy:y_add]) * 3686400;
    return point;

    
    return point;
}

+ (void) IniCasm:(double)time lon:(double)lon lat:(double)lat
{
    double tt;
    casm_t1 = time;
    casm_t2 = time;
    tt = (int)(time / 0.357);
    casm_rr = time - tt * 0.357;
    if (time == 0)
        casm_rr = 0.3;
    casm_x1 = lon;
    casm_y1 = lat;
    casm_x2 = lon;
    casm_y2 = lat;
    casm_f = 3;
}

+ (double) Transform_yj5:(double) x y:(double)y
{
    double tt;
    tt = 300 + 1 * x + 2 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(sqrt(x * x));
    tt = tt + (20 * [WG2MG yj_sin2:(18.849555921538764 * x)] + 20 * [WG2MG yj_sin2:(6.283185307179588 * x)]) * 0.6667;
    tt = tt + (20 * [WG2MG yj_sin2:(3.141592653589794 * x)] + 40 * [WG2MG yj_sin2:(1.047197551196598 * x)]) * 0.6667;
    tt = tt + (150 * [WG2MG yj_sin2:(0.2617993877991495 * x)] + 300 * [WG2MG yj_sin2:(0.1047197551196598 * x)]) * 0.6667;
    return tt;
}

+ (double) Transform_yjy5:(double)x y:(double) y
{
    double tt;
    tt = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(sqrt(x * x));
    tt = tt + (20 * [WG2MG yj_sin2:(18.849555921538764 * x)] + 20 * [WG2MG yj_sin2:(6.283185307179588 * x)]) * 0.6667;
    tt = tt + (20 * [WG2MG yj_sin2:(3.141592653589794 * y)] + 40 * [WG2MG yj_sin2:(1.047197551196598 * y)]) * 0.6667;
    tt = tt + (160 * [WG2MG yj_sin2:(0.2617993877991495 * y)] + 320 * [WG2MG yj_sin2:(0.1047197551196598 * y)]) * 0.6667;
    return tt;
}

+ (double) yj_sin2:(double) x
{
    double tt;
    double ss;
    double ff;
    double s2;
    int cc;
    ff = 0;
    if (x < 0)
    {
        x = -x;
        ff = 1;
    }
    
    cc = (int)(x / 6.28318530717959);
    
    tt = x - cc * 6.28318530717959;
    if (tt > 3.1415926535897932)
    {
        tt = tt - 3.1415926535897932;
        if (ff == 1)
        {
            ff = 0;
        }
        else if (ff == 0)
        {
            ff = 1;
        }
    }
    x = tt;
    ss = x;
    s2 = x;
    tt = tt * tt;
    s2 = s2 * tt;
    ss = ss - s2 * 0.166666666666667;
    s2 = s2 * tt;
    ss = ss + s2 * 8.33333333333333E-03;
    s2 = s2 * tt;
    ss = ss - s2 * 1.98412698412698E-04;
    s2 = s2 * tt;
    ss = ss + s2 * 2.75573192239859E-06;
    s2 = s2 * tt;
    ss = ss - s2 * 2.50521083854417E-08;
    if (ff == 1)
    {
        ss = -ss;
    }
    return ss;
}

+ (double) random_yj
{
    double t;
    double casm_a = 314159269;
    double casm_c = 453806245;
    casm_rr = casm_a * casm_rr + casm_c;
    t = (int)(casm_rr / 2);
    casm_rr = casm_rr - t * 2;
    casm_rr = casm_rr / 2;
    return (casm_rr);
}

+ (double) Transform_jy5:(double)x xx:(double)xx
{
    double n;
    double a;
    double e;
    a = 6378245;
    e = 0.00669342;
    n = sqrt(1 - e * [WG2MG yj_sin2:x * 0.0174532925199433] * [WG2MG yj_sin2:x * 0.0174532925199433]);
    n = (xx * 180) / (a / n * cos(x * 0.0174532925199433) * 3.1415926);
    return n;
}

+ (double) Transform_jyj5:(double)x yy:(double) yy
{
    double m;
    double a;
    double e;
    double mm;
    a = 6378245;
    e = 0.00669342;
    mm = 1 - e * [WG2MG yj_sin2:(x * 0.0174532925199433)] * [WG2MG yj_sin2:(x * 0.0174532925199433)];
    m = (a * (1 - e)) / (mm * sqrt(mm));
    return (yy * 180) / (m * 3.1415926);
}


@end
