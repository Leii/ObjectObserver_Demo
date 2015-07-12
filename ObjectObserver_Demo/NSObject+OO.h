//
//  NSObject+OO.h
//  ObjectObserver_Demo
//
//  Created by Lei on 15/7/12.
//  Copyright (c) 2015年 Leii. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^OOBlock)(id observedObject, NSString *observedKey, id oldValue, id newValue);

@interface  NSObject (OO)

-(void)O_addObserver:(NSObject *)observer
           withBlock:(OOBlock)block;

-(void)O_removeObserber:(NSObject *)observer ;

@end
