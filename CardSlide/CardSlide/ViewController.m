//
//  ViewController.m
//  CardSlide
//
//  Created by Rahul Pant on 03/09/15.
//  Copyright (c) 2015 Rahul Pant. All rights reserved.
//

#import "ViewController.h"
#import "CardView.h"

typedef enum{
    POSITION_TOP = 100,
    POSITION_FRONT,
    POSITION_BACK
} CardPosition;

#define VELOCITY_LIMIT         170
#define ANIMATION_DURATION     0.4

@interface ViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewFront;
@property (nonatomic) CardView                          *viewTop;
@property (nonatomic) CardView                          *viewFront;
@property (nonatomic) CardView                          *viewBack;
@property (nonatomic) NSMutableDictionary               *dictCardView;
@property (nonatomic) CGFloat                           startValue;
@property (nonatomic) CGFloat                           startDiff;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _viewTop = (CardView *)[self.view viewWithTag:POSITION_TOP];
    _viewFront = (CardView *)[self.view viewWithTag:POSITION_FRONT];
    _viewBack = (CardView *)[self.view viewWithTag:POSITION_BACK];
    
    _dictCardView = [NSMutableDictionary dictionaryWithCapacity:3];
    [_dictCardView setObject:_constTopViewTop forKey:[NSNumber numberWithInt:POSITION_TOP]];
    [_dictCardView setObject:_constTopViewFront forKey:[NSNumber numberWithInt:POSITION_FRONT]];
    [_dictCardView setObject:_constTopViewBack forKey:[NSNumber numberWithInt:POSITION_BACK]];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];
    
    [self animateViewsForSlide:YES];
}

- (NSLayoutConstraint *)constraintForView:(CardPosition)position
{
    return [_dictCardView objectForKey:[NSNumber numberWithInt:position]];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint loc = [recognizer locationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    NSLog(@"velocity = %f", velocity.y);

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _startValue = loc.y;
        _startDiff = -999;
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat diff = _startValue - loc.y;
        if (_startDiff == -999) _startDiff = diff;
            
        _startValue = loc.y;
                NSLog(@"diff %f" , diff);
        [self constraintForView:(_startDiff < 1) ? [_viewTop tag] : [_viewFront tag]].constant -= diff;
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (velocity.y > VELOCITY_LIMIT )
        {
            NSLog(@"down slide");
            [self animateViewsForSlide:NO];
        }
        else if (velocity.y <= VELOCITY_LIMIT && velocity.y >= -VELOCITY_LIMIT)
        {
            [self animateViewsForReset];
        }
        else if (velocity.y <-VELOCITY_LIMIT)
        {
            NSLog(@"up slide");
            [self animateViewsForSlide:YES];
        }
    }
}

- (void)animateViewsForSlide:(BOOL)slideUp
{
    if (slideUp)
    {
        [self.view sendSubviewToBack:_viewTop];
        [self.view bringSubviewToFront:_viewFront];
        [self constraintForView:[_viewBack tag]].constant = 10;
        [self constraintForView:[_viewFront tag]].constant = -(_viewFront.frame.size.height + 20);
        [self constraintForView:[_viewTop tag]].constant = 10;
    }
    else
    {
        [self.view bringSubviewToFront:_viewTop];
        [self.view sendSubviewToBack:_viewBack];
        [self constraintForView:[_viewBack tag]].constant = -(_viewBack.frame.size.height + 20);
        [self constraintForView:[_viewFront tag]].constant = 10;
        [self constraintForView:[_viewTop tag]].constant = 10;
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                         CardView *viewTop = _viewTop;
                         CardView *viewFront = _viewFront;
                         CardView *viewBack = _viewBack;

                         if (slideUp)
                         {
                             _viewTop = viewFront;
                             _viewFront = viewBack;
                             _viewBack = viewTop;
                         }
                         else
                         {
                             _viewTop = viewBack;
                             _viewFront = viewTop;
                             _viewBack = viewFront;
                         }
                         
                         [self.view bringSubviewToFront:_viewTop];
                         [self.view sendSubviewToBack:_viewBack];
                     }];
}

- (void)animateViewsForReset
{
    [self constraintForView:[_viewBack tag]].constant = 10;
    [self constraintForView:[_viewFront tag]].constant = 10;
    [self constraintForView:[_viewTop tag]].constant = -(_viewFront.frame.size.height + 20);
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

@end
