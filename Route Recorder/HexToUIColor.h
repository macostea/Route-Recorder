//
//  HexToUIColor.h
//  Route Recorder
//
//  Created by skobbler on 7/18/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#ifndef Route_Recorder_HexToUIColor_h
#define Route_Recorder_HexToUIColor_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#endif
