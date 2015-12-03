//
//  UIXOverlayViewController.h
//  oc2
//
//  Created by Guy Umbright on 10/18/15.
//  Copyright © 2015 Guy Umbright. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIXOverlayViewController;

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
@interface UIXOverlayControllerMaskView : UIView
{    
}
@end


@protocol UIXOverlayViewControllerDelegate

@optional
- (void) overlayWillDisplayContent:(UIXOverlayViewController*) overlayController;
- (void) overlayContentDisplayed:(UIXOverlayViewController*) overlayController;
- (void) overlayMaskTouched:(UIXOverlayViewController*) overlayController;
- (void) overlayRemoved:(UIXOverlayViewController*) overlayController;

@end


///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
typedef void (^UIXOverlayViewControllerBlock)();

@interface UIXOverlayViewController : UIViewController
{
}
@property (assign) BOOL dismissUponTouchMask;
@property (nonatomic, strong) UIColor* maskColor;
@property (nonatomic, weak) NSObject<UIXOverlayViewControllerDelegate>* overlayDelegate;
@property (nonatomic, assign) NSTimeInterval minimumDisplayTime;

- (void) presentOverlayOn:(UIViewController*) parent
                 animated:(BOOL) animated;
- (void) presentOverlayOn:(UIViewController*) parent
                 animated:(BOOL) animated
          completionBlock:(UIXOverlayViewControllerBlock) completionBlock;


- (void) dismissOverlay:(BOOL) animated;
- (void) dismissOverlay:(BOOL) animated
        completionBlock:(UIXOverlayViewControllerBlock) completionBlock;


@end
