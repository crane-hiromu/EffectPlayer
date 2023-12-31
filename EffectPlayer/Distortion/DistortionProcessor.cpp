//
//  DistortionProcessor.cpp
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/08/21.
//

#include "DistortionProcessor.h"
#include <cmath>
#include <thread>

void DistortionProcessor::applyDistortion(float** data,
                                          unsigned int channelCount,
                                          unsigned int frameLength,
                                          float gain,
                                          float level)
{
    if (data == nullptr || channelCount == 0 || frameLength == 0) {
        throw std::invalid_argument("Invalid data or parameters");
    }
    
    std::vector<std::thread> threads;
    unsigned int numThreads = channelCount;
    
    for (unsigned int thread = 0; thread < numThreads; ++thread) {
        threads.emplace_back([&, thread]() {
            float* channelData = data[thread];
            
            for (unsigned int frame = 0; frame < frameLength; ++frame) {
                float sample = channelData[frame];
                float distortedSample = sigmoidDistortion(sample, gain, level);
                channelData[frame] = distortedSample;
            }
        });
    }
    
    for (auto& thread : threads) {
        thread.join();
    }
}

float DistortionProcessor::sigmoidDistortion(float sample, float gain, float level) {
    return tanh(5 * sample * gain / 2) * level;
}
