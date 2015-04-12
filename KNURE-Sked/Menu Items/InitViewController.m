//
//  InitViewController.m
//  SlideMenu
//
//  Created by Vlad Chapaev on 07.09.14.
//  Copyright (c) 2014 Shogunate. All rights reserved.
//

#import "InitViewController.h"

@interface InitViewController ()

@end

@implementation InitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath {
    NSString *identifier;
    switch (indexPath.row) {
        case 0:
            identifier = @"SkedSegue";
            break;
        case 1:
            identifier = @"GroupSegue";
            break;
        case 2:
            identifier = @"TeacherSegue";
            break;
        case 3:
            identifier = @"AuditorySegue";
            break;
    }
    return identifier;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)configureLeftMenuButton:(UIButton *)button {
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0, 0};
    frame.size = (CGSize){40,40};
    button.frame = frame;
    [button setImage:[UIImage imageNamed:@"MenuButton"] forState:UIControlStateNormal];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (shoudOffPanGesture)?NO:YES;
}

-(CGFloat)leftMenuWidth {
    return (isTablet)?300:200;
}

@end
