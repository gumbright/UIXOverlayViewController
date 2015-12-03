//
//  UIXOverlayViewController.m
//  oc2
//
//  Created by Guy Umbright on 10/18/15.
//  Copyright © 2015 Guy Umbright. All rights reserved.
//

#import "UIXOverlayView.h"
#define DISMISS_MASK_NOTIFICATION		@"OverlayViewDismissMask"


@interface UIXOverlayView()
@property (nonatomic, strong) UIXOverlayMaskView* maskView;
@end

@interface UIXOverlayView()
@property (nonatomic, strong) NSDate* whenPresented;
@property (nonatomic, copy) UIXOverlayViewBlock displayCompletionBlock;
@property (nonatomic, copy) UIXOverlayViewBlock dismissCompletionBlock;
@property (nonatomic, assign) BOOL animated;
@end

@implementation UIXOverlayView
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (instancetype) init
{
    if (self = [super init])
    {
        self.minimumDisplayTime = 0.0;
    }
    return self;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) presentOverlayOn:(UIView*) parent
                 animated:(BOOL) animated
{
    [self presentOverlayOn:parent animated:animated completionBlock:nil];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) presentOverlayOn:(UIView*) parent
                 animated:(BOOL) animated
          completionBlock:(UIXOverlayViewBlock)completionBlock
{
    self.animated = animated;
    
    self.whenPresented = [NSDate date];
    __weak __typeof__ (self) weakself = self;
    
    NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(maskTapped) name:DISMISS_MASK_NOTIFICATION object:nil];
        
        //[parent addChildViewController:self];
        
        //create mask
        CGRect frame = parent.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        
        self.maskView = [[UIXOverlayMaskView alloc] initWithFrame:frame];
        
        self.maskView.backgroundColor = (self.maskColor != nil) ? self.maskColor : [UIColor colorWithWhite:.0 alpha:.75];
        
        if (animated)
        {
            self.displayCompletionBlock = completionBlock;
            self.maskView.alpha = 0.0;
            [parent addSubview:self.maskView];
            [parent addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[mask]|"options:nil metrics:nil views:@{@"mask":self.maskView}]];
            [parent addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mask]|"options:nil metrics:nil views:@{@"mask":self.maskView}]];
            [parent setNeedsLayout];
            
            [UIView beginAnimations:@"maskfadein" context:nil];
            [UIView setAnimationDidStopSelector:@selector(maskFadeInComplete:finished:context:)];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:0.25];
            self.maskView.alpha = 0.5;
            [UIView commitAnimations];
        }
        else
        {
            [parent addSubview:self.maskView];
            
            [parent addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[mask]|"options:nil metrics:nil views:@{@"mask":self.maskView}]];
            [parent addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mask]|"options:nil metrics:nil views:@{@"mask":self.maskView}]];
            [parent setNeedsLayout];
            frame = self.frame;
            
            CGRect placement = frame;
            placement.origin.x = (parent.frame.size.width - placement.size.width)/2;
            placement.origin.y = (parent.frame.size.height - placement.size.height)/2;
            
            self.frame = placement;
            
            [self.maskView addSubview:self];
            [self.maskView addConstraint:
             [NSLayoutConstraint constraintWithItem:self
                                          attribute:NSLayoutAttributeCenterX
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self.maskView
                                          attribute:NSLayoutAttributeCenterX
                                         multiplier:1
                                           constant:0]];
            [self.maskView addConstraint:
             [NSLayoutConstraint constraintWithItem:self
                                          attribute:NSLayoutAttributeCenterY
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self.maskView
                                          attribute:NSLayoutAttributeCenterY
                                         multiplier:1
                                           constant:0]];
            
            
//            if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0)
//            {
//                [self viewDidAppear:NO];
//            }
            
            if (completionBlock != nil)
            {
                completionBlock();
            }
        }
    }];
    [[NSOperationQueue mainQueue] addOperation:blockOp];
}

///////////////////////////////////////////////
//
///////////////////////////////////////////////
- (void)maskTapped
{
    if ([self.overlayDelegate respondsToSelector:@selector(overlayMaskTouched:)])
    {
        [self.overlayDelegate overlayMaskTouched:self];
    }
    
    if (self.dismissUponTouchMask)
    {
        [self dismissOverlay:self.animated];
    }
}

///////////////////////////////////////////////
//
///////////////////////////////////////////////
- (void)maskFadeInComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    //!!!this is pretty repetive with non animated, should be factored
    if ([self.overlayDelegate respondsToSelector:@selector(overlayWillDisplayContent:)])
    {
        [self.overlayDelegate overlayWillDisplayContent:self];
    }
    
    CGRect frame = self.frame;
    
    CGRect placement = frame;
    placement.origin.x = (self.maskView.frame.size.width - placement.size.width)/2;
    placement.origin.y = (self.maskView.frame.size.height - placement.size.height)/2;
    
    self.frame = placement;
    self.alpha = 0.0;
    
    [self.maskView addSubview:self];
    [self.maskView addConstraint:
     [NSLayoutConstraint constraintWithItem:self
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.maskView
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1
                                   constant:0]];
    [self.maskView addConstraint:
     [NSLayoutConstraint constraintWithItem:self
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.maskView
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    
    [UIView animateWithDuration:0.25
                     animations:^(void) {
                         self.alpha = 1.0;
                         self.maskView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         if ([self.overlayDelegate respondsToSelector:@selector(overlayContentDisplayed:)])
                         {
                             [self.overlayDelegate overlayContentDisplayed:self];
                         }
                         
                         if (self.displayCompletionBlock != nil)
                         {
                             self.displayCompletionBlock();
                         }
                     }];
}

///////////////////////////////////////////////
//
///////////////////////////////////////////////
- (void) detachOverlay
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.maskView removeFromSuperview];
    self.maskView = nil;
    //_contentController = nil;
    
    if ([self.overlayDelegate respondsToSelector:@selector(overlayRemoved:)])
    {
        [self.overlayDelegate overlayRemoved:self];
    }
}

///////////////////////////////////////////////
//
///////////////////////////////////////////////
- (void)maskFadeOutComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
//    if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0)
//    {
//        [self viewDidDisappear:YES];
//    }

    [self detachOverlay];

    if (self.dismissCompletionBlock != nil)
    {
        self.dismissCompletionBlock();
    }
    }];
    [[NSOperationQueue mainQueue] addOperation:blockOp];
}

#if 0
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.maskView.frame = CGRectMake(0, 0, size.width, size.height);
        self.center = self.maskView.center;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {}];
}
#endif

///////////////////////////////////////////////
//
///////////////////////////////////////////////
- (void) dismissOverlay:(BOOL) animated
{
    [self dismissOverlay:animated completionBlock:nil];
}

///////////////////////////////////////////////
//
///////////////////////////////////////////////
- (void) dismissOverlay:(BOOL) animated
        completionBlock:(UIXOverlayViewBlock) completionBlock;
{
    NSDate* now = [NSDate date];
    
    NSTimeInterval timeDisplayed = [now timeIntervalSinceDate:self.whenPresented];
    
    NSTimeInterval delayTime = self.minimumDisplayTime - timeDisplayed;
    if (delayTime < 0)
    {
        delayTime = 0.0;
    }
    
    NSLog(@"UIXOverlayViewController dismiss delay = %f",delayTime);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
            [self removeFromSuperview];
            
            if (animated)
            {
                self.dismissCompletionBlock = completionBlock;
                [UIView beginAnimations:@"maskfadeout" context:nil];
                [UIView setAnimationDidStopSelector:@selector(maskFadeOutComplete:finished:context:)];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDuration:0.3];
                self.maskView.alpha = 0.0;
                [UIView commitAnimations];
            }
            else
            {
//                if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0)
//                {
//                    [self viewDidDisappear:NO];
//                }
                [self detachOverlay];
                
                if (completionBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock();
                    });
                }
            }
        }];
        [[NSOperationQueue mainQueue] addOperation:blockOp];
    });
}

@end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

@implementation UIXOverlayMaskView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:DISMISS_MASK_NOTIFICATION object:nil];
}

@end
