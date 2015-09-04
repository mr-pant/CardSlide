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
@property (weak, nonatomic) CardView                    *currentFrontView;

@property (nonatomic) CGFloat startValue;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setFrontViewInFront:YES];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self.view addGestureRecognizer:panGesture];

}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    
    CGPoint loc = [recognizer locationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    NSLog(@"velocity = %f", velocity.y);
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _startValue = loc.y;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat diff = _startValue - loc.y;
        _startValue = loc.y;

        
        if (_currentFrontView == _viewFront)
        {
        _constTopViewTop.constant -= diff;
        }
        else if (_currentFrontView == _viewBack)
        {
        _constTopViewFront.constant -= diff;
        }
        else if (_currentFrontView == _viewTop)
        {
        _constTopViewBack.constant -= diff;
        }

    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        
        if (velocity.y > 100 )
        {
            //down slide
            NSLog(@"down slide");
            if (_currentFrontView == _viewFront)
            {
                [self setTopViewInFront:NO];
            }
            else if (_currentFrontView == _viewBack)
            {
                [self setFrontViewInFront:NO];
            }
            else if (_currentFrontView == _viewTop)
            {
                [self setBackViewInFront:NO];
            }
        }
        else if (velocity.y <= 100 && velocity.y >= -100)
        {
            //down release
            NSLog(@"down release");

            if (_currentFrontView == _viewFront)
            {
                [self setFrontViewInFront:NO];
            }
            else if (_currentFrontView == _viewBack)
            {
                [self setBackViewInFront:NO];
            }
            else if (_currentFrontView == _viewTop)
            {
                [self setTopViewInFront:NO];
            }
        }
        else if (velocity.y < -100)
        {
            //up
            NSLog(@"up slide");

            if (_currentFrontView == _viewFront)
            {
                [self setBackViewInFront:YES];
            }
            else if (_currentFrontView == _viewBack)
            {
                [self setTopViewInFront:YES];
            }
            else if (_currentFrontView == _viewTop)
            {
                [self setFrontViewInFront:YES];
            }
            
        }
        
    }
    
}


- (void)setFrontViewInFront:(BOOL)slideUp
{
    NSLog(@"setFrontViewInFront");

    if (slideUp) [self.view sendSubviewToBack:_viewBack];

    _constTopViewBack.constant = 10;
    _constTopViewFront.constant = 10;
    _constTopViewTop.constant = -(_viewTop.frame.size.height + 20);
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [self.view bringSubviewToFront:_viewTop];
                     }];
    _currentFrontView = _viewFront;
}

- (void)setTopViewInFront:(BOOL)slideUp
{
        NSLog(@"setTopViewInFront");

    if (slideUp) [self.view sendSubviewToBack:_viewFront];

    _constTopViewBack.constant = -(_viewBack.frame.size.height + 20);
    _constTopViewFront.constant = 10;
    _constTopViewTop.constant = 10;

    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [self.view bringSubviewToFront:_viewBack];
                         
                     }];
    _currentFrontView = _viewTop;
}

- (void)setBackViewInFront:(BOOL)slideUp
{
        NSLog(@"setBackViewInFront");

    if (slideUp) [self.view sendSubviewToBack:_viewTop];
    
    _constTopViewBack.constant = 10;
    _constTopViewFront.constant = -(_viewFront.frame.size.height + 20);
    _constTopViewTop.constant = 10;

    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [self.view bringSubviewToFront:_viewFront];
                         
                     }];
    _currentFrontView = _viewBack;
}

@end
