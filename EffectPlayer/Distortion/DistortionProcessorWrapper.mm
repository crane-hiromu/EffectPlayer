//
//  DistortionProcessorWrapper.m
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/08/21.
//

#import "DistortionProcessorWrapper.h"
#import "DistortionProcessor.h"

@implementation DistortionProcessorWrapper {
    DistortionProcessor *distortionProcessor;
}

- (id)init {
    self = [super init];
    if (self) {
        self.engine = [[AVAudioEngine alloc] init];
    }
    distortionProcessor = new DistortionProcessor();
    return self;
}

- (void)dealloc {
    delete distortionProcessor;
    [super dealloc];
}

- (void)applyDistortionToBuffer:(AVAudioPCMBuffer *)buffer {
    unsigned int channelCount = buffer.format.channelCount;
    unsigned int frameLength = (unsigned int)buffer.frameLength;
    
    // Convert AVAudioPCMBuffer to a format compatible with your C++ function
    float * const * floatChannelData = buffer.floatChannelData;
    float **data = new float*[channelCount];
    for (NSUInteger channel = 0; channel < channelCount; ++channel) {
        data[channel] = const_cast<float *>(floatChannelData[channel]);
    }
    
    distortionProcessor->applyDistortion(data,
                                         channelCount,
                                         frameLength,
                                         2.0,
                                         0.8);
    delete[] data;
}

//- (void)applyDistortionToBufferWithEngine {
//    AVAudioInputNode *input = self.engine.inputNode;
//    AVAudioOutputNode *output = self.engine.outputNode;
//    AVAudioFormat *format = [input inputFormatForBus:0];
//
//    AVAudioPlayerNode *player = [[AVAudioPlayerNode alloc] init];
//    [self.engine attachNode:player];
//
//    __weak DistortionProcessorWrapper *weakSelf = self;
//    [input installTapOnBus:0
//                bufferSize:1024
//                    format:format
//                     block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
//        [weakSelf applyDistortionToBuffer:buffer];
//        [player scheduleBuffer:buffer completionHandler:nil];
//    }];
//
//    AVAudioUnitEffect *comp = [[AVAudioUnitEffect alloc] initWithAudioComponentDescription:(AudioComponentDescription){
//        .componentType = kAudioUnitType_Effect,
//        .componentSubType = kAudioUnitSubType_DynamicsProcessor,
//        .componentManufacturer = kAudioUnitManufacturer_Apple
//    }];
//    [self.engine attachNode:comp];
//
//    [self.engine connect:input to:comp format:format];
//    [self.engine connect:player to:comp format:format];
//    [self.engine connect:comp to:output format:format];
//    [self.engine prepare];
//
//    NSError *error = nil;
//    if (![self.engine startAndReturnError:&error]) {
//        NSLog(@"Engine start failed: %@", error);
//    } else {
//        [player play];
//    }
//}

@end
