//
//  KWKeyboardListener.m
//  KeyboardListener
//
//  Created by Florent Crivello on 10/17/14.
//	Under GPL-3 Licence
//  Copyright (c) 2014 Kwarter Inc. All rights reserved.
//

#import "KWKeyboardListener.h"
#import <UIKit/UIKit.h>

@interface KWKeyboardListener ()

@property (nonatomic, strong) NSMutableSet *registeredListeners;
@property (nonatomic, assign) BOOL keyboardVisible;

@end

static KWKeyboardListener *sharedInstance;

@implementation KWKeyboardListener

+ (KWKeyboardListener *)sharedInstance {
    return sharedInstance;
}

+ (void)load {
    sharedInstance = [[self alloc] init];
}

- (KWKeyboardListener *)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(didHide:) name:UIKeyboardDidHideNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(willHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.registeredListeners = [NSMutableSet new];
    
    return self;
}

- (void)addKeyboardEventsListener:(id<KWKeyboardEventsListener>)listener {
    [self.registeredListeners addObject:listener];
}

- (void)removeKeyboardEventsListener:(id<KWKeyboardEventsListener>)listener {
    if ([self.registeredListeners containsObject:listener]) {
        [self.registeredListeners removeObject:listener];
    }
}

- (void)notifyListenersWithSelector:(SEL)selector withObject:(id)anObject {
    for (NSObject<KWKeyboardEventsListener>*listener in self.registeredListeners) {
        if (listener && [listener respondsToSelector:selector]) {
            // The following is to avoid memory leaks and zombie calling crashes
            IMP imp = [listener methodForSelector:selector];
            void (*func)(id, SEL, id) = (void *)imp;
            func(listener, selector, anObject);
        }
    }
}

- (void)didShow:(NSNotification *)notification {
    self.keyboardVisible = YES;
    [self notifyListenersWithSelector:@selector(keyboardDidShowWithInfos:) withObject:notification.userInfo];
}

- (void)willShow:(NSNotification *)notification {
    [self notifyListenersWithSelector:@selector(keyboardWillShowWithInfos:) withObject:notification.userInfo];
}

- (void)didHide:(NSNotification *)notification {
    self.keyboardVisible = NO;
    [self notifyListenersWithSelector:@selector(keyboardDidHideWithInfos:) withObject:notification.userInfo];
}

- (void)willHide:(NSNotification *)notification {
    [self notifyListenersWithSelector:@selector(keyboardWillHideWithInfos:) withObject:notification.userInfo];
}

@end
