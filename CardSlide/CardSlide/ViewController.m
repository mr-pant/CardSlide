//
//  ViewController.m
//  CardSlide
//
//  Created by Rahul Pant on 03/09/15.
//  Copyright (c) 2015 Rahul Pant. All rights reserved.
//

#import "ViewController.h"
#import "CardView.h"

#define SPEED_LIMIT         170
#define ANIMATION_DURATION  0.4

@interface ViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTopViewFront;
@property (nonatomic) CardView                          *viewTop;
@property (nonatomic) CardView                          *viewFront;
@property (nonatomic) CardView                          *viewBack;
@property (nonatomic) NSMutableDictionary               *dictCardView;
@property (nonatomic) CGFloat startValue;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _viewTop = (CardView *)[self.view viewWithTag:POSITION_TOP];
    _viewFront = (CardView *)[self.view viewWithTag:POSITION_FRONT];
    _viewBack = (CardView *)[self.view viewWithTag:POSITION_BACK];
    
    [_viewTop setPosition:POSITION_TOP];
    [_viewFront setPosition:POSITION_FRONT];
    [_viewBack setPosition:POSITION_BACK];
    
    _dictCardView = [NSMutableDictionary dictionaryWithCapacity:3];
    [_dictCardView setObject:_constTopViewTop forKey:[NSNumber numberWithInt:POSITION_TOP]];
    [_dictCardView setObject:_constTopViewFront forKey:[NSNumber numberWithInt:POSITION_FRONT]];
    [_dictCardView setObject:_constTopViewBack forKey:[NSNumber numberWithInt:POSITION_BACK]];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];
    
    [self animateViewsForReset];
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
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat diff = _startValue - loc.y;
        _startValue = loc.y;
        //        NSLog(@"diff %f" , diff);
        [self constraintForView:(diff < 1) ? [_viewTop position] : [_viewFront position]].constant -= diff;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (velocity.y > SPEED_LIMIT )
        {
            //down slide
            NSLog(@"down slide");
            [self animateViewsForSlide:NO];
        }
        else if (velocity.y <= SPEED_LIMIT & velocity.y >= -SPEED_LIMIT)
        {
            [self animateViewsForReset];
        }
        else if (velocity.y < -SPEED_LIMIT)
        {
            //up
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
        [self constraintForView:[_viewBack position]].constant = 10;
        [self constraintForView:[_viewFront position]].constant = -(_viewFront.frame.size.height + 20);
        [self constraintForView:[_viewTop position]].constant = 10;
    }
    else
    {
        [self.view bringSubviewToFront:_viewTop];
        [self.view sendSubviewToBack:_viewBack];
        [self constraintForView:[_viewBack position]].constant = -(_viewBack.frame.size.height + 20);
        [self constraintForView:[_viewFront position]].constant = 10;
        [self constraintForView:[_viewTop position]].constant = 10;
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
                             _viewTop.tag = viewFront.tag;
                             _viewFront = viewBack;
                             _viewFront.tag = viewBack.tag;
                             _viewBack = viewTop;
                             _viewBack.tag = viewTop.tag;
                         }
                         else
                         {
                             _viewTop = viewBack;
                             _viewTop.tag = viewBack.tag;
                             _viewFront = viewTop;
                             _viewFront.tag = viewTop.tag;
                             _viewBack = viewFront;
                             _viewBack.tag = viewFront.tag;
                         }
                         
                         [self.view bringSubviewToFront:_viewTop];
                         [self.view sendSubviewToBack:_viewBack];
                         
                         NSLog(@"2top     = %d -> %d", viewTop.tag, _viewTop.tag);
                         NSLog(@"2front   = %d -> %d", viewFront.tag, _viewFront.tag);
                         NSLog(@"2back    = %d -> %d", viewBack.tag, _viewBack.tag);

                     }];
}

- (void)animateViewsForReset
{
    [self constraintForView:[_viewBack position]].constant = 10;
    [self constraintForView:[_viewFront position]].constant = 10;
    [self constraintForView:[_viewTop position]].constant = -(_viewFront.frame.size.height + 20);
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {}];
}

@end
