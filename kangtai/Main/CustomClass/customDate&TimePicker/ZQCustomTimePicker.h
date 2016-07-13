//
//
/**
 * Copyright (c) www.bugull.com
 */
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface ZQCustomTimePicker : UIView

@property (nonatomic, strong) iCarousel *hourPicker;
@property (nonatomic, strong) iCarousel *minutePicker;

- (id)initWithFrame:(CGRect)frame withIsZero:(BOOL)isZero andSetTimeString:(NSString *)timeStr;

@end
