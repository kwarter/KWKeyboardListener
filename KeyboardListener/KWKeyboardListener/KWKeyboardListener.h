//
//  KWKeyboardListener.h
//  KeyboardListener
//
//  Created by Florent Crivello on 10/17/14.
//	Under GPL-3 Licence
//  Copyright (c) 2014 Kwarter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^KWKeyboardActionHandler)(CGRect keyboardFrame, BOOL opening, BOOL closing);

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
- (void)addKeyboardEventsListener:(id)listener withHandler:(KWKeyboardActionHandler)actionHandler;

@property (nonatomic, assign, readonly) BOOL keyboardVisible;
@property (nonatomic, assign, readonly) CGRect lastKeyboardFrame;

@end
