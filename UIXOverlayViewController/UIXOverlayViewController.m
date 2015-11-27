//
//  UIXOverlayViewController.m
//  oc2
//
//  Created by Guy Umbright on 10/18/15.
//  Copyright © 2015 Guy Umbright. All rights reserved.
//

#import "UIXOverlayViewController.h"
#define DISMISS_MASK_NOTIFICATION		@"OverlayControllerDismissMask"


@interface UIXOverlayViewController()
@property (nonatomic, strong) UIXOverlayMaskView* maskView;
@end

@interface UIXOverlayViewController()
@property (nonatomic, strong) NSDate* whenPresented;
@property (nonatomic, copy) UIXOverlayViewControllerBlock displayCompletionBlock;
@property (nonatomic, copy) UIXOverlayViewControllerBlock dismissCompletionBlock;
@end

@implementation UIXOverlayViewController
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
- (void) presentOverlayOn:(UIViewController*) parent
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
- (void) presentOverlayOn:(UIViewController*) parent
                 animated:(BOOL) animated
          completionBlock:(UIXOverlayViewControllerBlock)completionBlock
{
    self.whenPresented = [NSDate date];
    __weak __typeof__ (self) weakself = self;
    
    NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(maskTapped) name:DISMISS_MASK_NOTIFICATION object:nil];
        
        [parent addChildViewController:self];
        
        //create mask
        CGRect frame = parent.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        
        self.maskView = [[UIXOverlayMaskView alloc] initWithFrame:frame];
        
        self.maskView.backgroundColor = (self.maskColor != nil) ? self.maskColor : [UIColor colorWithWhite:.0 alpha:.75];
        
        if (animated)
        {
            self.displayCompletionBlock = completionBlock;
            self.maskView.alpha = 0.0;
            [parent.view addSubview:self.maskView];
            
            [UIView beginAnimations:@"maskfadein" context:nil];
            [UIView setAnimationDidStopSelector:@selector(maskFadeInComplete:finished:context:)];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:0.25];
            self.maskView.alpha = 0.5;
            [UIView commitAnimations];
        }
        else
        {
            [parent.view addSubview:self.maskView];
            
            frame = self.view.frame;
            
            CGRect placement = frame;
            placement.origin.x = (parent.view.frame.size.width - placement.size.width)/2;
            placement.origin.y = (parent.view.frame.size.height - placement.size.height)/2;
            
            self.view.frame = placement;
            
            [self.maskView addSubview:self.view];
            
            if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0)
            {
                [self viewDidAppear:NO];
            }
            
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
        [self dismissOverlay:YES];
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
    
    CGRect frame = self.view.frame;
    
    CGRect placement = frame;
    placement.origin.x = (self.parentViewController.view.frame.size.width - placement.size.width)/2;
    placement.origin.y = (self.parentViewController.view.frame.size.height - placement.size.height)/2;
    
    self.view.frame = placement;
    self.view.alpha = 0.0;
    
    [self.maskView addSubview:self.view];
    
    [UIView animateWithDuration:0.25
                     animations:^(void) {
                         self.view.alpha = 1.0;
                         self.maskView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         if ([self.overlayDelegate respondsToSelector:@selector(overlayContentDisplayed:)])
                         {
                             [self.overlayDelegate overlayContentDisplayed:self];
                         }
                         
                         if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0)
                         {
                             [self viewDidAppear:YES];
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
    if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0)
    {
        [self viewDidDisappear:YES];
    }

    [self detachOverlay];

    if (self.dismissCompletionBlock != nil)
    {
        self.dismissCompletionBlock();
    }
    }];
    [[NSOperationQueue mainQueue] addOperation:blockOp];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.maskView.frame = CGRectMake(0, 0, size.width, size.height);
        self.view.center = self.maskView.center;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {}];
}

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
        completionBlock:(UIXOverlayViewControllerBlock) completionBlock;
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
            [self.view removeFromSuperview];
            
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
                if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0)
                {
                    [self viewDidDisappear:NO];
                }
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
