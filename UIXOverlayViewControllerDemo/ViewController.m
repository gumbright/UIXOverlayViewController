//
//  ViewController.m
//  oc2
//
//  Created by Guy Umbright on 10/18/15.
//  Copyright © 2015 Guy Umbright. All rights reserved.
//

#import "ViewController.h"
#import "UIXOverlayViewController.h"
#import "OverlayViewController.h"

@interface ViewController ()
@property (nonatomic, strong) OverlayViewController* overlay;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPressed:(id)sender
{
    OverlayViewController* vc = [[OverlayViewController alloc] init];
    
    vc.dismissUponTouchMask = YES;
    vc.minimumDisplayTime = 5.0;
    self.overlay = vc;
    
    UIXOverlayViewControllerBlock block = ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Displayed"
                                                                       message:@"overlay displayed"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    };
    [vc presentOverlayOn:self animated:YES completionBlock:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [vc dismissOverlay:YES completionBlock:^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Displayed"
                                                                           message:@"overlay display completed"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];

        }];
    });

}

@end
