//
//  GoSegue.m
//  PSGenericSegue
//
//  Created by Daniel Isenhower on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GoSegue.h"
#import "ViewController.h"
#import "RevealViewController.h"

@implementation GoSegue

- (void)perform {
    ViewController *viewController = (ViewController *)self.sourceViewController;
    RevealViewController *revealViewController = (RevealViewController *)self.destinationViewController;
    
    /*
     * Note that we're using the destinationViewController's view.bounds.  This is so we can make sure
     * its view gets loaded before we go any further.
     */
    UIView *flipCanvas = [[UIView alloc] initWithFrame:revealViewController.view.bounds];
    [viewController.view addSubview:flipCanvas];
    
    UIView *slideCanvas = [[UIView alloc] initWithFrame:revealViewController.view.bounds];
    [viewController.view addSubview:slideCanvas];
    
    UIImageView *hiddenImage1 = [self imageViewFromLayerInView:viewController.image1];
    UIImageView *hiddenImage2 = [self imageViewFromLayerInView:viewController.image2];
    UIImageView *revealedImage1 = [self imageViewFromLayerInView:revealViewController.image1];
    UIImageView *revealedImage2 = [self imageViewFromLayerInView:revealViewController.image2];
    UIImageView *logo = [self imageViewFromLayerInView:revealViewController.logo];
    UIImageView *buttonBack = [self imageViewFromLayerInView:revealViewController.buttonBack];
    
    __block BOOL animatingFlips = YES;
    __block BOOL animatingSlides = YES;
    
    void (^finalize)();
    finalize = ^{
        if (!animatingFlips && !animatingSlides) {
            [flipCanvas removeFromSuperview];
            [slideCanvas removeFromSuperview];
            
            viewController.image1.hidden = NO;
            viewController.image2.hidden = NO;
            
            [self moveRight:viewController.buttonGo];
            
            /*
             * If you want to be able to jump around all willy-nilly between view controllers
             * you could dismiss the current view controller before presenting the new one.
             * That way you don't leak view controllers as you hop around.  Just make sure not
             * to dismiss your root view controller.  An example of this might be if you wanted
             * to go from your root view controller to a 2nd level controller, to a 3rd level
             * controller, back directly to the root view controller.
             */
            [viewController presentModalViewController:revealViewController animated:NO];
        }
    };
    
    [UIView transitionWithView:viewController.view
                      duration:0.01
                       options:UIViewAnimationOptionTransitionNone // this "animation" is only here to give the initial changes a chance to appear on screen
                    animations:^{
                        // setup
                        
                        viewController.image1.hidden = YES;
                        viewController.image2.hidden = YES;
                        [flipCanvas addSubview:hiddenImage1];
                        [flipCanvas addSubview:hiddenImage2];
                        
                        logo.hidden = YES;
                        [slideCanvas addSubview:logo];
                        [self moveRight:logo];
                        
                        buttonBack.hidden = YES;
                        [slideCanvas addSubview:buttonBack];
                        [self moveRight:buttonBack];
                    }
                    completion:^(BOOL finished){
                        [UIView transitionWithView:flipCanvas
                                          duration:0.5
                                           options:UIViewAnimationOptionTransitionFlipFromRight
                                        animations:^{
                                            
                                            [hiddenImage1 removeFromSuperview];
                                            [hiddenImage2 removeFromSuperview];
                                            [flipCanvas addSubview:revealedImage1];
                                            [flipCanvas addSubview:revealedImage2];
                                        }
                                        completion:^(BOOL finished) {
                                            animatingFlips = NO;
                                            finalize();
                                        }];
                        
                        [UIView animateWithDuration:0.5
                                         animations:^{
                                             logo.hidden = NO;
                                             [self moveLeft:logo];
                                             
                                             buttonBack.hidden = NO;
                                             [self moveLeft:buttonBack];
                                             
                                             [self moveLeft:viewController.buttonGo];
                                         }
                                         completion:^(BOOL finished) {
                                             animatingSlides = NO;
                                             finalize();
                                         }];
                        
                    }];
}

@end
