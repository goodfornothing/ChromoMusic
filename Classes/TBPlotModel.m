//
//  TBPlotModel.m
//  ToneGenerator
//
//  Created by Administrator on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBPlotModel.h"
#import "SBJsonParser.h"

@implementation TBPlotModel

-(id)init{
    self = [self initWithNoSamples:50000];
    return self;
}

-(id)initWithNoSamples:(int)numSamples{
    if((self=[super init])){
        jsonParser = [[SBJsonParser alloc] init];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://brightpoint.herokuapp.com/api/v1/data_points.json?size=%d",numSamples]];
        NSError *error;
        NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
        id jsonObject = [jsonParser objectWithString:jsonString error:&error];
        if ([jsonObject isKindOfClass:[NSDictionary class]]){
            // treat as a dictionary, or reassign to a dictionary ivar
            NSLog(@"Dictionary");
        }
        else if ([jsonObject isKindOfClass:[NSArray class]]){
            NSLog(@"Array");
            [self parseData:jsonObject];
        }
    }
    return self;
}

-(void)parseData:(NSArray *)jsonArray {
    data = [[NSMutableArray alloc]init];
    NSDictionary *dict1,*dict2;
    float x1,y1,x2,y2;
    maxX = 0.0f;
    minX = 99999999.0f;
    maxY = -10.0f;
    minY = 99999999.0f;
    for(int i=0;i<[jsonArray count];i+=2){
        if((i+1)<[jsonArray count]){
            dict1 = [jsonArray objectAtIndex:i];
            dict2 = [jsonArray objectAtIndex:i+1];
            x1 = [[dict1 objectForKey:@"start"]floatValue];
            x2 = [[dict1 objectForKey:@"end"]floatValue];
            y1 = [[dict1 objectForKey:@"y"]floatValue];
            y2 = [[dict2 objectForKey:@"y"]floatValue];
            minX = MIN(minX,MAX(x1,x2));
            maxX = MAX(maxX,MAX(x1,x2));
            minY = MIN(minY,MAX(y1,y2));
            maxY = MAX(maxY,MAX(y1,y2));
            [data addObject:[NSValue valueWithCGRect:CGRectMake(x1, y1, x2 - x1, y2-y1)]]; 
        }
    }
    _bounds = CGRectMake(minX, minY, maxX-minY, maxY-minY);
}

-(CGRect)bounds{
    return _bounds;
}

-(CGRect)getRectAtIndex:(int)n{
    if(n < [data count]){
        return [[data objectAtIndex:n]CGRectValue];
    } else {
        return CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
}

@end
