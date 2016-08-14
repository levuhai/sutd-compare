//
//  ViewController.m
//  Compare
//
//  Created by Hai Le on 8/6/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

#import "ViewController.h"
#include "SUTDMFCCHelperFunctions.hpp"
#import "DataManager.h"
// TAAE headers
#import "TheAmazingAudioEngine.h"
#import "AERecorder.h"
#import "NSFileManager+SUTD.h"
#import "MatrixController.h"

#include <algorithm>
#include <stdexcept>
#include <vector>
#include <math.h>

#define MAX_NUM_FRAMES 500
#define SUTDMFCC_FEATURE_LENGTH 12

const float kDefaultTrimBeginThreshold = -200.0f;
const float kDefaultTrimEndThreshold = -200.0f;

@interface ViewController ()

@property (nonatomic, strong) AEAudioController* audioController;
@property (nonatomic, strong) AERecorder *recorder;
@property (nonatomic, strong) AEAudioFilePlayer *player;

@end

@implementation ViewController {
    NSString* _recordingPath;
    
    std::vector<float> centroids; // dataY
    std::vector<float> indices; // dataX
    std::vector<float> matchedFrameQuality;
    std::vector< std::vector<float> > normalisedOutput;
    std::vector< std::vector<float> > trimmedNormalisedOutput;
    std::vector< std::vector<float> > similarityMatrix;
    std::vector< std::vector<float> > bestFitLine;
    std::vector< std::vector<float> > nearLineMatrix;
    std::vector<float> fitQuality;
    
    WMAudioFilePreProcessInfo _userVoiceFileInfo;
    WMAudioFilePreProcessInfo _databaseVoiceFileInfo;
    
    MatrixController* _matrixVC;

}

AudioStreamBasicDescription AEAudioStreamBasicDescriptionMono = {
    .mFormatID          = kAudioFormatLinearPCM,
    .mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
    .mChannelsPerFrame  = 1,
    .mBytesPerPacket    = sizeof(float),
    .mFramesPerPacket   = 1,
    .mBytesPerFrame     = sizeof(float),
    .mBitsPerChannel    = 8 * sizeof(float),
    .mSampleRate        = 44100.0,
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recordingPath = [[NSFileManager documentFolder] stringByAppendingPathComponent:@"r.wav"];
    NSLog(@"%@",_recordingPath);
    
    [self _setupAudioController];
    
    _btnRecord.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // Storyboard
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // Add Matrix VC
    _matrixVC = [storyboard instantiateViewControllerWithIdentifier:@"MatrixController"];
    _matrixVC.view.frame = _vContainer.bounds ;
    [self.vContainer addSubview:_matrixVC.view];
    [self addChildViewController:_matrixVC];
    [_matrixVC didMoveToParentViewController:self];
}

// Setup AEAudioController
- (void)_setupAudioController {
    // Amazing Audio Controller
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:AEAudioStreamBasicDescriptionMono inputEnabled:YES];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.useMeasurementMode = YES;
    [_audioController start:NULL];
}

// Start recording
- (IBAction)startRecording:(id)sender {
    _lbResult.text = @"";
    [self _setStatus:@"Recording..."];
    
    if ( _recorder ) return;
    
    _recorder = [[AERecorder alloc] initWithAudioController:_audioController];
    
    NSError *error = nil;
    if (![_recorder beginRecordingToFileAtPath:_recordingPath
                                       fileType:kAudioFileWAVEType
                                       bitDepth:32
                                       channels:1
                                          error:&error]) {
        [self _setStatus:[error localizedDescription]];
        _recorder = nil;
        return;
    }
    
    [_audioController addOutputReceiver:_recorder];
    [_audioController addInputReceiver:_recorder];
}

// Stop recording
- (IBAction)stopRecording:(id)sender {
    [self _setStatus:@"Calculating..."];
    if ( !_recorder ) return;
    
    [_recorder finishRecording];
    [_audioController removeOutputReceiver:_recorder];
    [_audioController removeInputReceiver:_recorder];
    self.recorder = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self _comparePath:_recordingPath];
    });
}

- (void)_setStatus:(NSString*)stt {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lbStatus.text = stt;
        [self.lbStatus setNeedsDisplay];
    });
}

- (void)_comparePath:(NSString*)recordPath {
    
    NSMutableArray* arr = [[DataManager shared] files];
    float score = 0;
    int index = 0;
//    recordPath = [[DataManager shared] files][0]; // 0.1
//    recordPath = [[DataManager shared] files][1]; // 0.032
//    recordPath = [[DataManager shared] files][2]; // 0.052
    // User feature
    NSURL *userVoiceURL = [NSURL URLWithString:[recordPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    FeatureTypeDTW::Features userVoiceFeatures = [self _getPreProcessInfo:userVoiceURL
                                                           beginThreshold:kDefaultTrimBeginThreshold
                                                             endThreshold:kDefaultTrimEndThreshold
                                                                     info:&_userVoiceFileInfo];
    
    
    for (int i = 0; i< arr.count; i++) {
        NSString* dbPath = arr[i];

        float s = [self _scoring:userVoiceFeatures databaseVoice:dbPath]; // or filteredFilePath
        if (s > score) {
            score = s;
            index = i;
        }
    }
    
    NSLog(@"%.3f %@ %@",score,recordPath.lastPathComponent, [arr[index] lastPathComponent]);
    if ((roundf(score*1000.0f)/1000.0f) >= 0.000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _draw:userVoiceFeatures databaseVoice:arr[index]];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _lbResult.text = [arr[index] lastPathComponent];
            
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            _lbResult.text = @"File not match";
            
        });
    }
    [self _setStatus:@"Finished"];
}

- (float)_scoring:(FeatureTypeDTW::Features)userVoiceFeatures databaseVoice:(NSString*)databaseVoicePath {
    if (userVoiceFeatures.size() == 0) {
        return -1;
    }
    NSURL *databaseVoiceURL = [NSURL URLWithString:[databaseVoicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    FeatureTypeDTW::Features databaseVoiceFeatures = [self _getPreProcessInfo:databaseVoiceURL
                                                               beginThreshold:kDefaultTrimBeginThreshold
                                                                 endThreshold:kDefaultTrimEndThreshold
                                                                         info:&_databaseVoiceFileInfo];
    
    
    
    // where does the target phoneme start and end in the database word?
    size_t targetPhonemeStartInDB = 0;
    size_t targetPhonemeEndInDB = databaseVoiceFeatures.size();
    
    
    
    // Clamp the target phoneme location within the valid range of indices.
    // Note that the size_t type is not signed so we don't need to clamp at
    // zero.
    if(targetPhonemeStartInDB >= databaseVoiceFeatures.size())
        targetPhonemeStartInDB = databaseVoiceFeatures.size()-1;
    if(targetPhonemeEndInDB >= databaseVoiceFeatures.size())
        targetPhonemeEndInDB = databaseVoiceFeatures.size()-1;
    
    
    
    // if the user voice recording is shorter than the target phoneme, we  pad it with copies of its last element to get a square match region.
    size_t targetPhonemeLength = 1 + targetPhonemeEndInDB - targetPhonemeStartInDB;
    if(userVoiceFeatures.size() < targetPhonemeLength) {
        for(size_t i=0; i<userVoiceFeatures[0].size(); i++) {
            userVoiceFeatures[userVoiceFeatures.size()-1][i] = MAXFLOAT;
        }
        userVoiceFeatures.resize(targetPhonemeLength,userVoiceFeatures.back());
    }
    
    
    /*
     * ensure that the similarity matrix arrays have enough space to store
     * the matrix
     */
    if(similarityMatrix.size() != userVoiceFeatures.size())
        similarityMatrix.resize(userVoiceFeatures.size());
    for(size_t i=0; i<userVoiceFeatures.size(); i++)
        if(similarityMatrix[i].size() != databaseVoiceFeatures.size())
            similarityMatrix[i].resize(databaseVoiceFeatures.size());
    
    
    // calculate the matrix of similarity
    genSimilarityMatrix(userVoiceFeatures, databaseVoiceFeatures, similarityMatrix);
    
    
    // normalize the output
    normaliseMatrix(similarityMatrix);
    
    // TODO: change this value
    /*
     * Phonemes that depend on the vowel sounds before and after do
     * better with split-region scoring
     */
    bool splitRegionScoring = NO;// for S this is false, for K it is true.
    
    
    // find the vertical location of a square match region, centred on the
    // target phoneme and the rows in the user voice that best match it.
    size_t matchRegionStartInUV, matchRegionEndInUV;
    bestMatchLocation(similarityMatrix, targetPhonemeStartInDB, targetPhonemeEndInDB, matchRegionStartInUV, matchRegionEndInUV, splitRegionScoring);
    
    
    
    // make sure nearLineMatrix has the right size
    if(nearLineMatrix.size() != similarityMatrix.size())
        nearLineMatrix.resize(similarityMatrix.size());
    for(size_t i=0; i<nearLineMatrix.size(); i++)
        if(nearLineMatrix[i].size() != similarityMatrix[i].size())
            nearLineMatrix[i].resize(similarityMatrix[i].size());
    
    
    /*
     * highlight the match region in green on the matrix plot
     */
    for (int y=0; y < similarityMatrix.size(); y++) {
        for (int x=0; x<similarityMatrix[0].size(); x++) {
            if (y < matchRegionStartInUV || y > matchRegionEndInUV
                || x < targetPhonemeStartInDB || x > targetPhonemeEndInDB) {
                nearLineMatrix[y][x] = 0;
            } else {
                nearLineMatrix[y][x] = similarityMatrix[y][x];
            }
        }
    }
    
    float score;
    if(splitRegionScoring)
        score = matchScoreSplitRegion(similarityMatrix,
                                      targetPhonemeStartInDB, targetPhonemeEndInDB,
                                      matchRegionStartInUV, matchRegionEndInUV);
    else
        score = matchScoreSingleRegion(similarityMatrix,
                                       targetPhonemeStartInDB, targetPhonemeEndInDB,
                                       matchRegionStartInUV, matchRegionEndInUV, true);
    
    return score;
}

- (float)_draw:(FeatureTypeDTW::Features)userVoiceFeatures databaseVoice:(NSString*)databaseVoicePath {
    /*
     * Read audio files from file paths
     */
    
    NSURL *databaseVoiceURL = [NSURL URLWithString:[databaseVoicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    FeatureTypeDTW::Features databaseVoiceFeatures = [self _getPreProcessInfo:databaseVoiceURL
                                                               beginThreshold:kDefaultTrimBeginThreshold
                                                                 endThreshold:kDefaultTrimEndThreshold
                                                                         info:&_databaseVoiceFileInfo];
    
    
    
    // where does the target phoneme start and end in the database word?
    size_t targetPhonemeStartInDB = 0;
    size_t targetPhonemeEndInDB = databaseVoiceFeatures.size();
    
    
    
    // Clamp the target phoneme location within the valid range of indices.
    // Note that the size_t type is not signed so we don't need to clamp at
    // zero.
    if(targetPhonemeStartInDB >= databaseVoiceFeatures.size())
        targetPhonemeStartInDB = databaseVoiceFeatures.size()-1;
    if(targetPhonemeEndInDB >= databaseVoiceFeatures.size())
        targetPhonemeEndInDB = databaseVoiceFeatures.size()-1;
    
    
    
    // if the user voice recording is shorter than the target phoneme, we  pad it with copies of its last element to get a square match region.
    size_t targetPhonemeLength = 1 + targetPhonemeEndInDB - targetPhonemeStartInDB;
    if(userVoiceFeatures.size() < targetPhonemeLength)
        userVoiceFeatures.resize(targetPhonemeLength,userVoiceFeatures.back());
    
    
    /*
     * ensure that the similarity matrix arrays have enough space to store
     * the matrix
     */
    if(similarityMatrix.size() != userVoiceFeatures.size())
        similarityMatrix.resize(userVoiceFeatures.size());
    for(size_t i=0; i<userVoiceFeatures.size(); i++)
        if(similarityMatrix[i].size() != databaseVoiceFeatures.size())
            similarityMatrix[i].resize(databaseVoiceFeatures.size());
    
    
    // calculate the matrix of similarity
    genSimilarityMatrix(userVoiceFeatures, databaseVoiceFeatures, similarityMatrix);
    
    
    // normalize the output
    normaliseMatrix(similarityMatrix);
    
    // TODO: change this value
    /*
     * Phonemes that depend on the vowel sounds before and after do
     * better with split-region scoring
     */
    bool splitRegionScoring = NO;// for S this is false, for K it is true.
    
    
    // find the vertical location of a square match region, centred on the
    // target phoneme and the rows in the user voice that best match it.
    size_t matchRegionStartInUV, matchRegionEndInUV;
    bestMatchLocation(similarityMatrix, targetPhonemeStartInDB, targetPhonemeEndInDB, matchRegionStartInUV, matchRegionEndInUV, splitRegionScoring);
    
    
    
    // make sure nearLineMatrix has the right size
    if(nearLineMatrix.size() != similarityMatrix.size())
        nearLineMatrix.resize(similarityMatrix.size());
    for(size_t i=0; i<nearLineMatrix.size(); i++)
        if(nearLineMatrix[i].size() != similarityMatrix[i].size())
            nearLineMatrix[i].resize(similarityMatrix[i].size());
    
    
    /*
     * highlight the match region in green on the matrix plot
     */
    for (int y=0; y < similarityMatrix.size(); y++) {
        for (int x=0; x<similarityMatrix[0].size(); x++) {
            if (y < matchRegionStartInUV || y > matchRegionEndInUV
                || x < targetPhonemeStartInDB || x > targetPhonemeEndInDB) {
                nearLineMatrix[y][x] = 0;
            } else {
                nearLineMatrix[y][x] = similarityMatrix[y][x];
            }
        }
    }
    
    float score;
    if(splitRegionScoring)
        score = matchScoreSplitRegion(similarityMatrix,
                                      targetPhonemeStartInDB, targetPhonemeEndInDB,
                                      matchRegionStartInUV, matchRegionEndInUV);
    else
        score = matchScoreSingleRegion(similarityMatrix,
                                       targetPhonemeStartInDB, targetPhonemeEndInDB,
                                       matchRegionStartInUV, matchRegionEndInUV, true);
    
    // Page 3
    _matrixVC.upperView.graphColor = [UIColor greenColor];
    _matrixVC.upperView.legend = CGRectMake(targetPhonemeStartInDB, targetPhonemeEndInDB, matchRegionStartInUV, matchRegionEndInUV);
    [_matrixVC.upperView inputNormalizedDataW:(int)nearLineMatrix[0].size()
                                          matrixH:(int)nearLineMatrix.size()
                                             data:nearLineMatrix
                                             rect:self.view.bounds
                                           maxVal:0.5];
    
    [_matrixVC.lowerView inputNormalizedDataW:(int)similarityMatrix[0].size()
                                      matrixH:(int)similarityMatrix.size()
                                         data:similarityMatrix
                                         rect:self.view.bounds
                                       maxVal:0.5];
    [_matrixVC generateImage];
    
    return score;
}

- (FeatureTypeDTW::Features)_getPreProcessInfo:(NSURL*)url beginThreshold:(float)bt endThreshold:(float)et info:(WMAudioFilePreProcessInfo*) fileInfo{
    
    CFURLRef cfurl = (CFURLRef)CFBridgingRetain(url);
    
    AudioFileReaderRef reader(new WM::AudioFileReader(cfurl));
    
    WMAudioFilePreProcessInfo fileInf = reader->preprocess(kDefaultTrimBeginThreshold,
                                                           kDefaultTrimEndThreshold,
                                                           1.0f);
    NSLog(@"For file %@", url.lastPathComponent);
    //    NSLog(@"Peak: %f", fileInf.max_peak);
    //    NSLog(@"Begin: %f", fileInf.threshold_start_time);
    //    NSLog(@"End: %f", fileInf.threshold_end_time);
    //    NSLog(@"Norm Factor: %f", fileInf.normalization_factor);
    
    *fileInfo = fileInf;
    
    AudioFileReaderRef reader_a(new WM::AudioFileReader(cfurl));
    return get_mfcc_features(reader_a, fileInfo);
    
}

@end
