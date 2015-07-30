//
//  ViewController.m
//  ObjectObserver_Demo
//
//  Created by Lei on 15/7/12.
//  Copyright (c) 2015年 Leii. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+OO.h"

@interface TestClass : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *number;

@end

@implementation TestClass

@end

@interface ViewController ()

@property (nonatomic) TestClass *testObject;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testObject = [[TestClass alloc] init];
    self.testObject.name = @"Le";
    self.testObject.number = [NSNumber numberWithInt:1];
    
    [self.testObject O_addObserver:self withBlock:^(id observedObject, NSString *observedKey, id oldValue, id newValue) {
    NSLog(@"The property '%@' is changed from %@ to %@",observedKey,oldValue,newValue);
    }];
    
    UIButton * nameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nameButton setFrame:CGRectMake(self.view.frame.size.width/2-60, self.view.frame.size.height/2-80, 120, 50)];
    [nameButton setTitle:@"ChangeName" forState:UIControlStateNormal];
    [nameButton setTag:0];
    [nameButton addTarget:self action:@selector(changeValues:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * numberButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [numberButton setFrame:CGRectMake(self.view.frame.size.width/2-60, self.view.frame.size.height/2-15, 120, 50)];
    [numberButton setTitle:@"ChangeNumber" forState:UIControlStateNormal];
    [numberButton setTag:1];
    [numberButton addTarget:self action:@selector(changeValues:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:nameButton];
    [self.view addSubview:numberButton];
    
}

-(void)changeValues:(id)sender{
    if ([sender tag] == 0) {
        self.testObject.name = [self.testObject.name stringByAppendingString:@"i"];
    }else if([sender tag] == 1){
        int num = arc4random()%12+1;
        self.testObject.number = [NSNumber numberWithInt:num];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
