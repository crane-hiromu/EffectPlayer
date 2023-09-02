//
//  DistortionProcessorWrapper.h
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/08/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface DistortionProcessorWrapper : NSObject

@property (nonatomic, strong) AVAudioEngine *engine;

- (void)applyDistortionToBuffer:(AVAudioPCMBuffer *)buffer;
//- (void)applyDistortionToBufferWithEngine;

@end
