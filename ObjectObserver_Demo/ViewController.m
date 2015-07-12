//
//  ViewController.m
//  ObjectObserver_Demo
//
//  Created by Lei on 15/7/12.
//  Copyright (c) 2015年 Leii. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+OO.h"

@interface OOTest : NSObject

@property(nonatomic)NSString *name;
@property(nonatomic)NSNumber *number;

@end

@implementation OOTest

@end

@interface ViewController ()

@property(nonatomic)OOTest *test;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.test = [[OOTest alloc] init];
    self.test.name = @"Le";
    self.test.number = [NSNumber numberWithInt:1];
    
    [self.test O_addObserver:self withBlock:^(id observedObject, NSString *observedKey, id oldValue, id newValue) {
    NSLog(@"The property '%@' is changed from %@ to %@",observedKey,oldValue,newValue);
    }];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(self.view.frame.size.width/2-60, self.view.frame.size.height/2, 120, 50)];
    [button setTitle:@"ChangeValues" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeValues) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void)changeValues{
    self.test.name = [self.test.name stringByAppendingString:@"i"];
    int num = arc4random()%12+1;
    self.test.number = [NSNumber numberWithInt:num];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
