//
//  KWKeyboardListener.m
//  KeyboardListener
//
//  Created by Florent Crivello on 10/17/14.
//	Under GPL-3 Licence
//  Copyright (c) 2014 Kwarter Inc. All rights reserved.
//

#import "KWKeyboardListener.h"

//NSString *const

@interface KWKeyboardListener ()

@property (nonatomic, strong) NSHashTable *registeredListeners;
@property (nonatomic, strong) NSMapTable *registeredListenersWithBlockHandlers;
@property (nonatomic, assign) BOOL keyboardVisible;
@property (nonatomic, assign) CGRect lastKeyboardFrame;

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
    [defaultCenter addObserver:self selector:@selector(didChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(willChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.registeredListeners = [NSHashTable weakObjectsHashTable];
    self.registeredListenersWithBlockHandlers = [NSMapTable weakToStrongObjectsMapTable];
    
    // At the app start, the keyboard is considered at the very bottom at the screen, with no size
    self.lastKeyboardFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 0, 0);
    
    return self;
}

- (void)addKeyboardEventsListener:(id<KWKeyboardEventsListener>)listener {
    [self.registeredListeners addObject:listener];
}

- (void)removeKeyboardEventsListener:(id<KWKeyboardEventsListener>)listener {
    if ([self.registeredListeners containsObject:listener]) {
        [self.registeredListeners removeObject:listener];
    }
    if ([self.registeredListenersWithBlockHandlers objectForKey:listener]) {
        [self.registeredListenersWithBlockHandlers removeObjectForKey:listener];
    }
}

- (void)addKeyboardEventsListener:(id)listener withHandler:(KWKeyboardActionHandler)actionHandler {
    if (![self.registeredListenersWithBlockHandlers objectForKey:listener]) {
        [self.registeredListenersWithBlockHandlers setObject:[actionHandler copy] forKey:listener];
    }
    [self addKeyboardEventsListener:listener];
}

- (void)notifyListenersWithSelector:(SEL)selector withObject:(id)anObject {
    for (NSObject<KWKeyboardEventsListener>*listener in self.registeredListeners) {
        if (listener && [listener respondsToSelector:selector]) {
            // The following is to avoid memory leaks and zombie calling crashes
            IMP imp = [listener methodForSelector:selector];
            void (*func)(id, SEL, id) = (void *)imp;
            func(listener, selector, anObject);
        } else if (!listener) {
            [self.registeredListeners removeObject:anObject];
        }
    }
}

- (void)notifyBlockListenersWithKeyboardFrame:(CGRect)keyboardFrame
                                      opening:(BOOL)opening
                                      closing:(BOOL)closing {
    for (id listener in self.registeredListenersWithBlockHandlers) {
        if (listener) {
            void (^handler)(CGRect, BOOL, BOOL);
            handler = [self.registeredListenersWithBlockHandlers objectForKey:listener];
            handler(keyboardFrame,opening,closing);
        } else {
            [self.registeredListenersWithBlockHandlers removeObjectForKey:listener];
        }
    }
}

- (void)didShow:(NSNotification *)notification {
    if (!self.keyboardVisible) {
        self.keyboardVisible = YES;
        self.lastKeyboardFrame = ((NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        [self notifyListenersWithSelector:@selector(keyboardDidShowWithInfos:) withObject:notification.userInfo];
    }
}

- (void)willShow:(NSNotification *)notification {
    if (!self.keyboardVisible) {
        [self notifyListenersWithSelector:@selector(keyboardWillShowWithInfos:) withObject:notification.userInfo];
        CGRect keyboardFrame = ((NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        self.lastKeyboardFrame = keyboardFrame;
        [self notifyBlockListenersWithKeyboardFrame:keyboardFrame opening:YES closing:NO];
    }
}

- (void)didHide:(NSNotification *)notification {
    if (self.keyboardVisible) {
        self.keyboardVisible = NO;
        self.lastKeyboardFrame = ((NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        [self notifyListenersWithSelector:@selector(keyboardDidHideWithInfos:) withObject:notification.userInfo];
    }
}

- (void)willHide:(NSNotification *)notification {
    if (self.keyboardVisible) {
        [self notifyListenersWithSelector:@selector(keyboardWillHideWithInfos:) withObject:notification.userInfo];
        CGRect keyboardFrame = ((NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        self.lastKeyboardFrame = keyboardFrame;
        [self notifyBlockListenersWithKeyboardFrame:keyboardFrame opening:NO closing:YES];
    }
}

- (void)didChangeFrame:(NSNotification *)notification {
    [self notifyListenersWithSelector:@selector(keyboardDidChangeFrameWithInfos:) withObject:notification.userInfo];
    CGRect keyboardFrame = ((NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    self.lastKeyboardFrame = keyboardFrame;
    [self notifyBlockListenersWithKeyboardFrame:keyboardFrame opening:NO closing:NO];
}

- (void)willChangeFrame:(NSNotification *)notification {
    [self notifyListenersWithSelector:@selector(keyboardWillChangeFrameWithInfos:) withObject:notification.userInfo];
    CGRect keyboardFrame = ((NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    self.lastKeyboardFrame = keyboardFrame;
    [self notifyBlockListenersWithKeyboardFrame:keyboardFrame opening:NO closing:NO];
}

@end
