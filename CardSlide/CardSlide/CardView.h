//
//  CardView.h
//  CardSlide
//
//  Created by Rahul Pant on 03/09/15.
//  Copyright (c) 2015 Rahul Pant. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    POSITION_TOP,
    POSITION_FRONT,
    POSITION_BACK
} CardPosition;

@interface CardView : UIView

@property CardPosition position;

@end
