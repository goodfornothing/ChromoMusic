//
//  ToneGeneratorViewController.m
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

#import "ToneGeneratorViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "TBPlotView.h"

OSStatus RenderTone(
	void *inRefCon, 
	AudioUnitRenderActionFlags 	*ioActionFlags, 
	const AudioTimeStamp 		*inTimeStamp, 
	UInt32 						inBusNumber, 
	UInt32 						inNumberFrames, 
	AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 0.25;

	// Get the tone parameters out of the view controller
	ToneGeneratorViewController *viewController =
		(__bridge ToneGeneratorViewController *)inRefCon;
	double theta = viewController->theta;
	double theta_increment = 2.0 * M_PI * viewController->frequency / viewController->sampleRate;

	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	viewController->theta = theta;

	return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	ToneGeneratorViewController *viewController =
		(__bridge ToneGeneratorViewController *)inClientData;
	
	[viewController stop];
}

@implementation ToneGeneratorViewController

//@synthesize frequencySlider;
//@synthesize playButton;
//@synthesize frequencyLabel;

/*
- (IBAction)sliderChanged:(UISlider *)slider
{
	frequency = slider.value;
	frequencyLabel.text = [NSString stringWithFormat:@"%4.1f Hz", frequency];
    
       
    
}
*/



- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert1(toneUnit, @"Error creating unit: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = self;
	err = AudioUnitSetProperty(toneUnit, 
		kAudioUnitProperty_SetRenderCallback, 
		kAudioUnitScope_Input,
		0, 
		&input, 
		sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
		kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;	
	streamFormat.mBytesPerFrame = four_bytes_per_float;		
	streamFormat.mChannelsPerFrame = 1;	
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
		kAudioUnitProperty_StreamFormat,
		kAudioUnitScope_Input,
		0,
		&streamFormat,
		sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %ld", err);
}


- (void)playTone {
	if (toneUnit)
	{
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
		toneOn = false;
		//[selectedButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
	}
	
    [self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(toneUnit);
		NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
		
		// Start playback
		err = AudioOutputUnitStart(toneUnit);
		NSAssert1(err == noErr, @"Error starting unit: %ld", err);
		
        //if(err!=noErr){
        toneOn = true;
        //}
		//[selectedButton setTitle:NSLocalizedString(@"Stop", nil) forState:0];
	
}

- (void)stopTone{
    if (toneUnit)
	{
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
		toneOn = false;
		//[selectedButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
	}
}



- (void)togglePlay {
	if (toneUnit)
	{
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
		toneOn = false;
		//[selectedButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
	}
	else
	{
		[self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(toneUnit);
		NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
		
		// Start playback
		err = AudioOutputUnitStart(toneUnit);
		NSAssert1(err == noErr, @"Error starting unit: %ld", err);
		
        //if(err!=noErr){
        toneOn = true;
        //}
		//[selectedButton setTitle:NSLocalizedString(@"Stop", nil) forState:0];
	}
}

- (void)stop
{
	if (toneUnit)
	{
		[self togglePlay];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];

    
    
	//[self sliderChanged:frequencySlider];
    frequency =  523.251;	//261.626; //Middle C
	sampleRate = 44100;
    
    notes = [[NSArray arrayWithObjects:
                      [NSNumber numberWithFloat:261.262], //C4
                      [NSNumber numberWithFloat:329.628], //E4
                      [NSNumber numberWithFloat:391.995], //G4
                      [NSNumber numberWithFloat:523.251], //C5
                      [NSNumber numberWithFloat:659.255], //E5
                      [NSNumber numberWithFloat:783.991], //G5
                      [NSNumber numberWithFloat:1046.50], //C6
                      [NSNumber numberWithFloat:1318.51], //E6
                      [NSNumber numberWithFloat:1567.98], //G6
                      [NSNumber numberWithFloat:2093.00], //C7
                      //[NSNumber numberWithFloat:2637.02], //E7
                      //[NSNumber numberWithFloat:3135.96], //G7
                      //[NSNumber numberWithFloat:4186.01], //C8
                      //[NSNumber numberWithFloat:4978.03], //E8
                      //[NSNumber numberWithFloat:
                      //[NSNumber numberWithFloat:8372.0192], //C9
                      //[NSNumber numberWithFloat:
                      nil] retain];

                       
                       
	OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, self);
	if (result == kAudioSessionNoError)
	{
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	}
	AudioSessionSetActive(true);
    
    
    plotView = [[TBPlotView alloc]initWithFrame:CGRectMake(0,0,480,320)];
    [self.view addSubview:plotView];
    
    toneOn = false;
    playing  = false;
    noteCount = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    
    musicX = 50;
    musicY = 10;
    musicSkip = false;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(10.0f, 10.0f, 100.0f, 30.0f)];
    [button setTitle:@"play" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(handleClick:) forControlEvents:UIControlEventTouchUpInside];
    
    bar = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 2.0, 320.0)];
    bar.backgroundColor = [UIColor redColor];
    [self.view addSubview:bar];
}

- (void)handleTimer:(NSTimer *)aTimer{
   
    if(playing){
        if(!musicSkip){
            [self stopTone];
            
            //Calculate Next Note
            musicY -= 1;
            if(musicY < 0){
                musicY = 9;
                musicX += 1;
            }
        
            bar.center = CGPointMake(musicX,160.0f);
            
            frequency = [[notes objectAtIndex:9-musicY]floatValue];
            
            noteCount += 1;
            
            
            
        } else {
            int red = [plotView getPixelRedAt:CGPointMake(musicX, musicY)];
            
           // NSLog(@"%d %d %d",musicX,musicY,red);
            
            if(red<100){
                //NSLog(@"%d PLAY",musicY);
                [self playTone];
            } else {
                //NSLog(@"%d NONE",musicY);
                [self stopTone];
            }
        }
        musicSkip = !musicSkip;
    } else {
        [self stopTone];
    }
   
    
}

- (void)handleClick:(id)button{
    NSLog(@"Click");
    playing = !playing;
    //[self togglePlay];
}

- (void)viewDidUnload {
	//self.frequencyLabel = nil;
	//self.playButton = nil;
	//self.frequencySlider = nil;
    
	AudioSessionSetActive(false);
    
    [plotView removeFromSuperview];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        
        return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
                (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
    } else {
        return YES;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    
    for(int y=10;y>=0;y--){
        int redVal = [plotView getPixelRedAt:CGPointMake(pt.x,y)];
        
        NSLog(@"%d,%d : %d",(int)pt.x,y,redVal);
        
    }
    
    
}


@end
