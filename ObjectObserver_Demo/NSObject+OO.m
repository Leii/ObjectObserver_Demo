//
//  NSObject+OO.m
//  ObjectObserver_Demo
//
//  Created by Lei on 15/7/12.
//  Copyright (c) 2015年 Leii. All rights reserved.
//

#import "NSObject+OO.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const kOOClassPrefix = @"OOClassPrefix_";
NSString *const kOOAssociatedObservers = @"OOAssociatedObservers";

#pragma mark - OOInfo
@interface OOInfo : NSObject

@property(nonatomic,weak) NSObject *observer;
@property(nonatomic,copy) NSString *key;
@property(nonatomic,copy) OOBlock block;

@end

@implementation OOInfo

-(instancetype)initWithObserver:(NSObject *)observer Key:(NSString *)key block:(OOBlock)block{
    self = [super init];
    if (self) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}

@end


#pragma mark - Category
@implementation NSObject (OO)
-(void)O_addObserver:(NSObject *)observer withBlock:(OOBlock)block{
    Class clazz = object_getClass(self);

    unsigned int propertyNum = 0;
    objc_property_t *propertyList = class_copyPropertyList(clazz ,&propertyNum);
    NSAssert(propertyNum>0, @"Object hasn't property");
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kOOAssociatedObservers));
    //creat a OOClass for replace to original class
    NSString *clazzName = NSStringFromClass(clazz);
    if (![clazzName hasPrefix:kOOClassPrefix]) {
        clazz = [self makeOOClassWithOriginalClassName:clazzName];
        object_setClass(self, clazz);
    }
    //collection for observers as a associated to observed object
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void*)(kOOAssociatedObservers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    for (int i =0; i<propertyNum; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        SEL setterSelector = NSSelectorFromString([self setterForGetter:key]);
        Method setterMethod = class_getInstanceMethod(clazz, setterSelector);
        NSAssert1(setterMethod, @"Object hasn't a setter for key%@", key);
        //add oo setter if this class doesn't implement the setter
        if (![self hasSelector:setterSelector]) {
            const char *types = method_getTypeEncoding(setterMethod);
            class_addMethod(clazz, setterSelector, (IMP)oo_setter , types);
        }
        OOInfo *info = [[OOInfo alloc] initWithObserver:observer Key:key block:block];
        
        [observers addObject:info];
    }
}

-(void)O_removeObserber:(NSObject *)observer{


}


#pragma mark - Helper
-(Class)makeOOClassWithOriginalClassName:(NSString *)className{
    NSString *OOClazzName = [kOOClassPrefix stringByAppendingString:className];
    Class clazz = NSClassFromString(OOClazzName);
    if (clazz) {
        return clazz;
    }
    Class originalClazz = object_getClass(self);
    Class OOClazz = objc_allocateClassPair(originalClazz, OOClazzName.UTF8String, 0);
    
    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(OOClazz, @selector(class), (IMP)oo_class,types);
    objc_registerClassPair(OOClazz);
    
    return OOClazz;
}

-(BOOL)hasSelector:(SEL)setterSelector{
    Class clazz = object_getClass(self);
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(clazz, &methodCount);
    for (int i=0; i<methodCount; i++) {
        SEL thisSelector = method_getName(methodList[i]);
        if (thisSelector==setterSelector) {
            free(methodList);
            return YES;
        }
    }
    free(methodList);
    return NO;
}

-(NSString *)getterForSetter:(NSString *)setter
{
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *getter = [setter substringWithRange:range];
    
    NSString *firstLetter = [[getter substringToIndex:1] lowercaseString];
    getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                             withString:firstLetter];
    
    return getter;
}


-(NSString *)setterForGetter:(NSString *)getter
{
    if (getter.length <= 0) {
        return nil;
    }
    NSString *firstLetter = [[getter substringToIndex:1] uppercaseString];
    NSString *remainingString = [getter substringFromIndex:1];
    
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingString];
    
    return setter;
}

#pragma mark - Overridden Methods
static void oo_setter(id self,SEL _cmd,id newValue){
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = [self getterForSetter:setterName];
    NSAssert(getterName, @"Object hasn't setter!");
    
    id oldValue = [self valueForKey:getterName];
    struct objc_super superclazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    void (*objc_msgSendSuperCasted)(void *,SEL,id) = (void *)objc_msgSendSuper;
    objc_msgSendSuperCasted(&superclazz,_cmd,newValue);
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kOOAssociatedObservers));
    for (OOInfo *info in observers) {
        if ([info.key isEqualToString:getterName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                info.block(self,getterName,oldValue,newValue);
                
            });
        }
    }
    
}
static Class oo_class(id self ,SEL _cmd){
    return class_getSuperclass(object_getClass(self));
}



@end
