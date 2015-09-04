//
//  ViewController.m
//  CardSlide
//
//  Created by Rahul Pant on 03/09/15.
//  Copyright (c) 2015 Rahul Pant. All rights reserved.
//

#import "ViewController.h"
#import "CardView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewFront;
@property (weak, nonatomic) IBOutlet CardView           *viewTop;
@property (weak, nonatomic) IBOutlet CardView           *viewFront;
@property (weak, nonatomic) IBOutlet CardView           *viewBack;
@property (nonatomic) CGFloat startValue;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _constTopViewTop.constant -= _viewTop.frame.size.height + 10;

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self.view addGestureRecognizer:panGesture];

}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    
    CGPoint loc = [recognizer locationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _startValue = loc.y;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat diff = _startValue - loc.y;
        _startValue = loc.y;
        _constTopViewBack.constant -= diff;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
    }

}

@end
