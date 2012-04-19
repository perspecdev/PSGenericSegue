//
//  GenericSegue.m
//  Faster
//
//  Created by Daniel Isenhower on 2/11/12.
//  Copyright (c) 2012 PerspecDev Solutions LLC. All rights reserved.
//
//  Want to use this code in your app?  Just send me a quick email about your project
//  and I'll grant you an MIT-style license.

#import "PSGenericSegue.h"

@implementation PSGenericSegue

- (void)perform {
    [self.sourceViewController presentModalViewController:self.destinationViewController animated:YES];
}

- (void)performSimpleFadeWithCompletion:(void (^)(void))completion {
    UIViewController *source = (UIViewController *)self.sourceViewController;
    UIViewController *destination = (UIViewController *)self.destinationViewController;
    
    UIView *canvas = [[UIView alloc] initWithFrame:destination.view.bounds]; // using destination so that we call its view so that the view will be loaded
    [source.view addSubview:canvas];
    
    UIImageView *everythingWrapper = [self imageViewFromLayerInView:destination.view];
    everythingWrapper.frame = everythingWrapper.bounds;
    
    __block BOOL animatingFades = YES;
    
    void (^finalize)();
    finalize = ^{
        if (!animatingFades) {
            [canvas removeFromSuperview];
            
            completion();
        }
    };
    
    [UIView transitionWithView:canvas
                      duration:0.01
                       options:UIViewAnimationOptionTransitionNone // this "animation" is only here to give the initial changes a chance to appear on screen
                    animations:^{
                        // setup
                        
                        everythingWrapper.alpha = 0.0f;
                        [canvas addSubview:everythingWrapper];
                    }
                    completion:^(BOOL finished){
                        
                        [UIView animateWithDuration:0.3
                                         animations:^{
                                             everythingWrapper.alpha = 1.0f;
                                         }
                                         completion:^(BOOL finished) {
                                             animatingFades = NO;
                                             finalize();
                                         }];
                        
                    }];
}

- (UIImageView *)imageViewFromLayerInView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = view.frame;
    
    return imageView;
}

- (void)moveRight:(UIView *)view {
    CGRect viewFrame = view.frame;
    viewFrame.origin.x += ((UIViewController *)self.sourceViewController).view.frame.size.width;
    view.frame = viewFrame;
}

- (void)moveLeft:(UIView *)view {
    CGRect viewFrame = view.frame;
    viewFrame.origin.x -= ((UIViewController *)self.sourceViewController).view.frame.size.width;
    view.frame = viewFrame;
}

@end
