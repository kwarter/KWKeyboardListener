//
//  KWKeyboardListener.h
//  KeyboardListener
//
//  Created by Florent Crivello on 10/17/14.
//	Under GPL-3 Licence
//  Copyright (c) 2014 Kwarter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KWKeyboardEventsListener <NSObject>

- (void)keyboardWillShowWithInfos:(NSDictionary *)infos;
- (void)keyboardWillHideWithInfos:(NSDictionary *)infos;
- (void)keyboardDidShowWithInfos:(NSDictionary *)infos;
- (void)keyboardDidHideWithInfos:(NSDictionary *)infos;
- (void)keyboardWillChangeFrameWithInfos:(NSDictionary *)infos;
- (void)keyboardDidChangeFrameWithInfos:(NSDictionary *)infos;

@end

@interface KWKeyboardListener : NSObject

+ (KWKeyboardListener *)sharedInstance;

- (void)addKeyboardEventsListener:(id<KWKeyboardEventsListener>)listener;
- (void)removeKeyboardEventsListener:(id<KWKeyboardEventsListener>)listener;

@property (nonatomic, assign, readonly) BOOL keyboardVisible;

@end
