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

    [self setFrontViewInFront];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self.view addGestureRecognizer:panGesture];

}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    
    CGPoint loc = [recognizer locationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
//    NSLog(@"velocity = %f %f", velocity.x, velocity.y);
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
     
        if (velocity.y > 100 )
        {
            //down
            if (_currentFrontView == _viewFront)
            {
                [self setTopViewInFront];
                
            }
            else if (_currentFrontView == _viewBack)
                {
                    [self setFrontViewInFront];
                }
            else if (_currentFrontView == _viewTop)
                {
                    [self setBackViewInFront];
                }
            
            
        }
        else if (velocity.y < 100)
            {

                if (_currentFrontView == _viewFront)
                {
                    [self setBackViewInFront];
                }
                else if (_currentFrontView == _viewBack)
                {
                    [self setTopViewInFront];
                }
                else if (_currentFrontView == _viewTop)
                {
                    [self setFrontViewInFront];
                }

            }
        
    }

}


- (void)setFrontViewInFront
{
    NSLog(@"setFrontViewInFront");
//    [_viewBack setHidden:YES];
//    [_viewFront setHidden:NO];
//    [_viewTop setHidden:NO];
    
    _constTopViewBack.constant = 10;
    _constTopViewFront.constant = 10;
    _constTopViewTop.constant -= _viewTop.frame.size.height;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    _currentFrontView = _viewFront;
}

- (void)setTopViewInFront
{
        NSLog(@"setTopViewInFront");
    [_viewBack setHidden:NO];
    [_viewFront setHidden:YES];
    [_viewTop setHidden:NO];

    _constTopViewBack.constant -= _viewBack.frame.size.height;
    _constTopViewFront.constant = 10;
    _constTopViewTop.constant = 10;

    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    _currentFrontView = _viewTop;
}

- (void)setBackViewInFront
{
        NSLog(@"setBackViewInFront");
    [_viewBack setHidden:NO];
    [_viewFront setHidden:NO];
    [_viewTop setHidden:YES];

    _constTopViewBack.constant = 10;
    _constTopViewFront.constant -= _viewFront.frame.size.height;
    _constTopViewTop.constant = 10;

    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    _currentFrontView = _viewBack;
}

@end
