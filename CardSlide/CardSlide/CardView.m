//
//  CardView.m
//  CardSlide
//
//  Created by Rahul Pant on 03/09/15.
//  Copyright (c) 2015 Rahul Pant. All rights reserved.
//

#import "CardView.h"

@implementation CardView

- (void)awakeFromNib
{
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
}

@end
