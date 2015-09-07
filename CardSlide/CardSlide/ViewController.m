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
#define CONST_SHOW             0
#define BORDER_PADDING         50

@interface ViewController ()

@property (nonatomic) CardView              *viewTop;
@property (nonatomic) CardView              *viewFront;
@property (nonatomic) CardView              *viewBack;
@property (nonatomic) NSMutableDictionary   *dictCardView;
@property (nonatomic) CGFloat               startValue;
@property (nonatomic) CGFloat               startDiff;
@property (nonatomic) NSArray               *pageData;
@property (nonatomic) int                   pageIndex;

@end

@implementation ViewController

- (void)loadView
{
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    _dictCardView = [NSMutableDictionary dictionaryWithCapacity:3];
    _viewTop = [self addCardViewForPosition:POSITION_TOP color:[UIColor blueColor]];
    _viewBack = [self addCardViewForPosition:POSITION_BACK color:[UIColor yellowColor]];
    _viewFront = [self addCardViewForPosition:POSITION_FRONT color:[UIColor greenColor]];
}

- (CardView *)addCardViewForPosition:(CardPosition)position color:(UIColor *)color
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"CardView"
                                                      owner:self
                                                    options:nil];
    
    CardView *cardView = [nibViews firstObject];
    [cardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    cardView.backgroundColor = color;
    [cardView setTag:position];
    [self.view addSubview:cardView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cardView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:-BORDER_PADDING]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cardView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:-BORDER_PADDING]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cardView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:cardView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:CONST_SHOW];
    [self.view addConstraint:verticalConstraint];
    [_dictCardView setObject:verticalConstraint forKey:[NSNumber numberWithInt:position]];
    return cardView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    _pageData = [[dateFormatter monthSymbols] copy];
    _pageIndex = 0;
    
    UILabel *lab = [[_viewFront subviews] firstObject];
    [lab setText:_pageData[_pageIndex]];
    lab = [[_viewBack subviews] firstObject];
    [lab setText:_pageData[_pageIndex + 1]];
}

- (NSLayoutConstraint *)constraintForView:(CardPosition)position
{
    return [_dictCardView objectForKey:[NSNumber numberWithInt:position]];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint loc = [recognizer locationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    
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
        
        if (_startDiff < 0 && _pageIndex > 0)
        {
            [self constraintForView:[_viewTop tag]].constant -= diff;
        }
        else if (_startDiff > 0 && _pageIndex < _pageData.count-1)
        {
            [self constraintForView:[_viewFront tag]].constant -= diff;
        }
        
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (velocity.y > VELOCITY_LIMIT && _pageIndex > 0)
        {
            [self animateViewsForSlide:NO];
        }
        else if (velocity.y <= VELOCITY_LIMIT && velocity.y >= -VELOCITY_LIMIT)
        {
            [self moveViewsForReset:YES];
        }
        else if (velocity.y <-VELOCITY_LIMIT && _pageIndex < _pageData.count-1)
        {
            [self animateViewsForSlide:YES];
        }
    }
}

- (void)animateViewsForSlide:(BOOL)slideUp
{
    if (slideUp)
    {
        [self.view sendSubviewToBack:_viewTop];
        [_viewTop setHidden:YES];
        [self.view bringSubviewToFront:_viewFront];
        [self constraintForView:[_viewBack tag]].constant = CONST_SHOW;
        [self constraintForView:[_viewFront tag]].constant = -(_viewFront.frame.size.height + BORDER_PADDING);
        [self constraintForView:[_viewTop tag]].constant = CONST_SHOW;
    }
    else
    {
        [self.view bringSubviewToFront:_viewTop];
        [_viewBack setHidden:YES];
        [self.view sendSubviewToBack:_viewBack];
        [self constraintForView:[_viewBack tag]].constant = -(_viewBack.frame.size.height + BORDER_PADDING);
        [self constraintForView:[_viewFront tag]].constant = CONST_SHOW;
        [self constraintForView:[_viewTop tag]].constant = CONST_SHOW;
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
                             [_viewTop setHidden:NO];
                             _pageIndex++;
                             _viewTop = viewFront;
                             _viewFront = viewBack;
                             _viewBack = viewTop;
                         }
                         else
                         {
                             [_viewBack setHidden:NO];
                             _pageIndex--;
                             _viewTop = viewBack;
                             _viewFront = viewTop;
                             _viewBack = viewFront;
                         }
                         
                         [self.view bringSubviewToFront:_viewTop];
                         [self.view sendSubviewToBack:_viewBack];
                         [self setDataForCurrentIndex:slideUp];
                     }];
}

- (void)moveViewsForReset:(BOOL)animate
{
    [self constraintForView:[_viewBack tag]].constant = CONST_SHOW;
    [self constraintForView:[_viewFront tag]].constant = CONST_SHOW;
    [self constraintForView:[_viewTop tag]].constant = -(_viewFront.frame.size.height + BORDER_PADDING);
    
    [UIView animateWithDuration:animate ? ANIMATION_DURATION : 0
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)setDataForCurrentIndex:(BOOL)slideUp
{
    if ( _pageIndex <= 0 || _pageIndex >= _pageData.count-1)
    {
        return;
    }
    
    if (slideUp)
    {
        UILabel *lab = [[_viewBack subviews] firstObject];
        [lab setText:_pageData[_pageIndex+1]];
    }
    else
    {
        UILabel *lab = [[_viewTop subviews] firstObject];
        [lab setText:_pageData[_pageIndex-1]];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [_viewTop setHidden:YES];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self moveViewsForReset:NO];
         [_viewTop setHidden:NO];
     }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
