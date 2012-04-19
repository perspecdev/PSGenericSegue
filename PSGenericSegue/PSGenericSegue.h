//
//  GenericSegue.h
//  Faster
//
//  Created by Daniel Isenhower on 2/11/12.
//  Copyright (c) 2012 PerspecDev Solutions LLC. All rights reserved.
//
//  Want to use this code in your app?  Just send me a quick email about your project
//  and I'll grant you an MIT-style license.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PSGenericSegue : UIStoryboardSegue

- (void)performSimpleFadeWithCompletion:(void (^)(void))completion;
- (UIImageView *)imageViewFromLayerInView:(UIView *)view;
- (void)moveRight:(UIView *)view;
- (void)moveLeft:(UIView *)view;

@end
