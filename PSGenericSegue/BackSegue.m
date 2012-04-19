//
//  BackSegue.m
//  PSGenericSegue
//
//  Created by Daniel Isenhower on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BackSegue.h"
#import "ViewController.h"
#import "RevealViewController.h"

@implementation BackSegue

- (void)perform {
    RevealViewController *revealViewController = (RevealViewController *)self.sourceViewController;
    ViewController *viewController = (ViewController *)self.destinationViewController;
    
    /*
     * Note that we're using the destinationViewController's view.bounds.  This is so we can make sure
     * its view gets loaded before we go any further.
     */
    UIView *flipCanvas = [[UIView alloc] initWithFrame:viewController.view.bounds];
    [revealViewController.view addSubview:flipCanvas];
    
    UIView *slideCanvas = [[UIView alloc] initWithFrame:viewController.view.bounds];
    [revealViewController.view addSubview:slideCanvas];
    
    UIImageView *hiddenImage1 = [self imageViewFromLayerInView:viewController.image1];
    UIImageView *hiddenImage2 = [self imageViewFromLayerInView:viewController.image2];
    UIImageView *revealedImage1 = [self imageViewFromLayerInView:revealViewController.image1];
    UIImageView *revealedImage2 = [self imageViewFromLayerInView:revealViewController.image2];
    UIImageView *buttonGo = [self imageViewFromLayerInView:viewController.buttonGo];
    
    __block BOOL animatingFlips = YES;
    __block BOOL animatingSlides = YES;
    
    void (^finalize)();
    finalize = ^{
        if (!animatingFlips && !animatingSlides) {
            [flipCanvas removeFromSuperview];
            [slideCanvas removeFromSuperview];
            
            revealViewController.image1.hidden = NO;
            revealViewController.image2.hidden = NO;
            
            [self moveRight:revealViewController.logo];
            [self moveRight:revealViewController.buttonBack];
            
            /*
             * If you want to be able to jump around all willy-nilly between view controllers
             * you could dismiss the current view controller before presenting the new one.
             * That way you don't leak view controllers as you hop around.  Just make sure not
             * to dismiss your root view controller.  An example of this might be if you wanted
             * to go from your root view controller to a 2nd level controller, to a 3rd level
             * controller, back directly to the root view controller.
             */
            [revealViewController presentModalViewController:viewController animated:NO];
        }
    };
    
    [UIView transitionWithView:revealViewController.view
                      duration:0.01
                       options:UIViewAnimationOptionTransitionNone // this "animation" is only here to give the initial changes a chance to appear on screen
                    animations:^{
                        // setup
                        
                        revealViewController.image1.hidden = YES;
                        revealViewController.image2.hidden = YES;
                        [flipCanvas addSubview:revealedImage1];
                        [flipCanvas addSubview:revealedImage2];
                        
                        buttonGo.hidden = YES;
                        [slideCanvas addSubview:buttonGo];
                        [self moveRight:buttonGo];
                    }
                    completion:^(BOOL finished){
                        [UIView transitionWithView:flipCanvas
                                          duration:0.5
                                           options:UIViewAnimationOptionTransitionFlipFromRight
                                        animations:^{
                                            
                                            [revealedImage1 removeFromSuperview];
                                            [revealedImage2 removeFromSuperview];
                                            [flipCanvas addSubview:hiddenImage1];
                                            [flipCanvas addSubview:hiddenImage2];
                                        }
                                        completion:^(BOOL finished) {
                                            animatingFlips = NO;
                                            finalize();
                                        }];
                        
                        [UIView animateWithDuration:0.5
                                         animations:^{
                                             buttonGo.hidden = NO;
                                             [self moveLeft:buttonGo];
                                             
                                             [self moveLeft:revealViewController.logo];
                                             [self moveLeft:revealViewController.buttonBack];
                                         }
                                         completion:^(BOOL finished) {
                                             animatingSlides = NO;
                                             finalize();
                                         }];
                        
                    }];
}

@end
