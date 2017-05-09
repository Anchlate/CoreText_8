//
//  ViewController.m
//  CoreText
//
//  Created by Qianrun on 16/12/15.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import "ViewController.h"
#import "CTView.h"
#import "Masonry.h"
#import "ANMarkupParser.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet CTView *myView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zombies" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    ANMarkupParser* mp = [[ANMarkupParser alloc]init];
    [self.myView setAttString:[mp attrStringFromMark:string] withImages:mp.images];
    
    [self.myView buildFrames];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
