//
//  SMViewController.m
//  SMFloatingLabelTextField
//
//  Created by Michał Moskała on 06/30/2016.
//  Copyright (c) 2016 Michał Moskała. All rights reserved.
//

#import "SMViewController.h"
#import "SMFloatingLabelTextField.h"

@interface SMViewController ()
@property (nonatomic, weak) IBOutlet SMFloatingLabelTextField *addressTextField;
@end

@implementation SMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.addressTextField setText:@"NYC"];
}

@end
