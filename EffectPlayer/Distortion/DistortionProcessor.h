//
//  DistortionProcessor.h
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/08/21.
//

#include <stdio.h>

class DistortionProcessor {
public:
    void applyDistortion(float** data,
                         unsigned int channelCount,
                         unsigned int frameLength,
                         float gain,
                         float level);

    float sigmoidDistortion(float sample, float gain, float level);
    
private:
    float gain_;
};
