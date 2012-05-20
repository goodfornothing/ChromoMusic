//
//  TBPlotModel.h
//  ToneGenerator
//
//  Created by Administrator on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBJsonParser;

@interface TBPlotModel : NSObject {
    SBJsonParser *jsonParser;
    NSMutableArray *data;
    float maxX;
    float minX;
    float maxY;
    float minY;
    CGRect _bounds; 
}
-(id)initWithNoSamples:(int)numSamples;
-(CGRect)getRectAtIndex:(int)n;
-(CGRect)bounds;
@end
