//
//  TBPlotView.h
//  ToneGenerator
//
//  Created by Administrator on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBPlotModel;

@interface TBPlotView : UIView {
    UIImageView *imageView;
    TBPlotModel *model;
    unsigned char * rawData;
    int scaledImageWidth;
    int scaledImageHeight;
    UIImageView *scaledImageView;
}

- (int)getPixelRedAt:(CGPoint)pt;
@end
