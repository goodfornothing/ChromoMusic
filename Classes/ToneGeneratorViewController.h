//
//  ToneGeneratorViewController.h
//  ToneGenerator
//
//  Created by Matt Gallagher on 2010/10/20.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

@class TBPlotView;

@interface ToneGeneratorViewController : UIViewController
{
	UILabel *frequencyLabel;
	UIButton *playButton;
	UISlider *frequencySlider;
	AudioComponentInstance toneUnit;
    
    TBPlotView *plotView;
    NSTimer *timer;
    NSArray *notes;
    bool playing;
    int noteCount;
    bool toneOn;
    
    int musicX;
    int musicY;
    bool musicSkip;
    
    UIImageView *bar;

@public
	double frequency;
	double sampleRate;
	double theta;
    
}

//@property (nonatomic, retain) IBOutlet UISlider *frequencySlider;
//@property (nonatomic, retain) IBOutlet UIButton *playButton;
//@property (nonatomic, retain) IBOutlet UILabel *frequencyLabel;

//- (IBAction)sliderChanged:(UISlider *)frequencySlider;
- (void)togglePlay;
- (void)stop;

@end

