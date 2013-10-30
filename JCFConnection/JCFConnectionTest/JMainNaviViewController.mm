//
//  JMainNaviViewController.m
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "JMainNaviViewController.h"
#import "JMainViewController.h"

@interface JMainNaviViewController ()

@property (nonatomic,strong)JMainViewController* mainVC;

@end

@implementation JMainNaviViewController

+ (instancetype)shareController
{
    static JMainNaviViewController* mnvc = [[JMainNaviViewController alloc] init];
    return mnvc;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.mainVC = [[JMainViewController alloc] init];
    
    [self pushViewController:self.mainVC animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
