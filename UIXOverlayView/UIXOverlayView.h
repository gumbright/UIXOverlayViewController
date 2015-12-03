//
//  UIXOverlayView.h
//  oc2
//
//  Created by Guy Umbright on 10/18/15.
//  Copyright © 2015 Guy Umbright. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIXOverlayView;

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
@interface UIXOverlayMaskView : UIView
{    
}
@end


@protocol UIXOverlayViewDelegate

@optional
- (void) overlayWillDisplayContent:(UIXOverlayView*) overlayController;
- (void) overlayContentDisplayed:(UIXOverlayView*) overlayController;
- (void) overlayMaskTouched:(UIXOverlayView*) overlayController;
- (void) overlayRemoved:(UIXOverlayView*) overlayController;

@end


///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
typedef void (^UIXOverlayViewBlock)();

@interface UIXOverlayView : UIView
{
}
@property (assign) BOOL dismissUponTouchMask;
@property (nonatomic, strong) UIColor* maskColor;
@property (nonatomic, weak) NSObject<UIXOverlayViewDelegate>* overlayDelegate;
@property (nonatomic, assign) NSTimeInterval minimumDisplayTime;

- (void) presentOverlayOn:(UIView*) parent
                 animated:(BOOL) animated;
- (void) presentOverlayOn:(UIView*) parent
                 animated:(BOOL) animated
          completionBlock:(UIXOverlayViewBlock) completionBlock;


- (void) dismissOverlay:(BOOL) animated;
- (void) dismissOverlay:(BOOL) animated
        completionBlock:(UIXOverlayViewBlock) completionBlock;


@end
