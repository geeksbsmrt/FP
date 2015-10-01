//
//  UIAppearanceSwift.m
//  testApp
//
//  Created by Adam Crawford on 8/17/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

#import "UIAppearanceSwift.h"

@implementation UIView (UIAppearance_Swift)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
	return [self appearanceWhenContainedIn:containerClass, nil];
}
@end