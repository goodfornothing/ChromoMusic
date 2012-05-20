//
//  TBPlotView.m
//  ToneGenerator
//
//  Created by Administrator on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBPlotView.h"
#import "TBPlotModel.h"

@implementation TBPlotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        model = [[TBPlotModel alloc]initWithNoSamples:16000];
        [self createImageOfPlot];
    }
    return self;
}

- (void)dealloc{
    [super dealloc];
    free(rawData);
}

- (void)createImageOfPlot{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    [self drawImage];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(imageView!=nil){
        [imageView removeFromSuperview];
    }
    imageView = [[UIImageView alloc]initWithImage:image];
    [self addSubview:imageView];
    
    UIImage *scaledImage = [TBPlotView scaleImage:image];
    scaledImageView = [[UIImageView alloc] initWithImage:scaledImage];
    CGAffineTransform t = CGAffineTransformMakeScale(1.0, 16.0);
    [scaledImageView setTransform:t];
    [scaledImageView setCenter:CGPointMake(240.0f, 200.0f)];
    //[self addSubview:scaledImageView];
    
    rawData = [self createDataFrom:scaledImage];
    
}

- (void)drawImage{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextSetLineWidth(context, 2.0);
    //CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGRect rectangle = self.frame; //CGRectMake(0,0,320,220);
    //CGContextAddRect(context, rectangle);
    //CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rectangle);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"gradient" ofType:@"jpg"];
    UIImage *backImage = [UIImage imageWithContentsOfFile:path];
    //UIImageView *backIV = [[UIImageView alloc]initWithImage:backImage];
    
    [backImage drawInRect:CGRectMake(0, 0, 480, 320)];
    
    CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, 160.0);
    t = CGAffineTransformScale(t,0.00002, -40.0);
    CGRect r,rOrig;
    for(int i=0;i<16000;i++){
        rOrig = [model getRectAtIndex:i];
        r = CGRectApplyAffineTransform(rOrig, t);
        //NSLog(@"rect:%f %f %f %f",r.origin.x,r.origin.y,r.size.width,r.size.height);
        r.size.width = MAX(r.size.width,1.0);
        r.size.height = MAX(r.size.width,1.0);
        CGContextFillRect(context, r);
    }
}

- (int)getPixelRedAt:(CGPoint)pt{
    if((pt.x < scaledImageWidth)&&(pt.y<scaledImageHeight)){
        int index = ((int)floorf(pt.x) + ((int)floorf(pt.y) * scaledImageWidth)) * 4;
        int red = rawData[index];
        return red;
    } else {
        return 0;
    }
}

-(unsigned char *)createDataFrom:(UIImage*)image{
    
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData2 = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData2, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    scaledImageWidth = width;
    scaledImageHeight = height;
    
    return rawData2;
}

+ (UIImage *)scaleImage:(UIImage*)image {
    
    int nuWidth = image.size.width;
    int nuHeight = 10; //image.size.height;
    CGSize nuSize = CGSizeMake(nuWidth, nuHeight);
    
    UIGraphicsBeginImageContext(nuSize);
    [image drawInRect:CGRectMake(0.0, 0.0, nuSize.width, nuSize.height)];
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:scaledImageView];
    int redVal = [self getPixelRedAt:pt];
    NSLog(@"Point %f,%f  %d",pt.x,pt.y,redVal);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:scaledImageView];
    int redVal = [self getPixelRedAt:pt];
    NSLog(@"Point %f,%f  %d",pt.x,pt.y,redVal);
}
*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
