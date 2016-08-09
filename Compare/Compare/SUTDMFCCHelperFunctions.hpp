//
//  SUTDMFCCHelperFunctions.h
//  MFCCDemo
//
//  Created by Hans on 14/4/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#ifndef SUTDMFCCHelperFunctions_h
#define SUTDMFCCHelperFunctions_h

#include "MFCCUtils.h"

void filterSound(float *data, size_t len, const char*outPath);
void writeToAudioFile(const char *fName,int mChannels,bool compress_with_m4a, UInt64 frames, float* data);

float euclideanDistance(const FeatureTypeDTW::FeatureVector& a, const FeatureTypeDTW::FeatureVector& b);

void genSimilarityMatrix(const FeatureTypeDTW::Features& userVoice, const FeatureTypeDTW::Features& databaseVoice, std::vector< std::vector<float> >& M);

void normaliseMatrix(std::vector< std::vector<float> >& M);

void bestMatchLocation(const std::vector< std::vector<float> >& M, size_t startColumn, size_t endColumn, size_t& startRow, size_t& endRow, bool splitRegion);

float matchScoreSingleRegion(const std::vector< std::vector<float> >& M,
                 size_t startColumn, size_t endColumn,
                 size_t startRow, size_t endRow, bool emphasizeDiagonal=true);

float matchScoreSplitRegion(const std::vector< std::vector<float> >& M,
                 size_t startColumn, size_t endColumn,
                 size_t startRow, size_t endRow);

#endif /* SUTDMFCCHelperFunctions_h */
