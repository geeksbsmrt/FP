//
//  UIAppearanceSwift.h
//  testApp
//
//  Created by Adam Crawford on 8/17/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

#ifndef testApp_UIAppearanceSwift_h
#define testApp_UIAppearanceSwift_h
#import <UIKit/UIKit.h>


#endif


@interface UIView (UIAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end