//
//  RGMMapViewController.m
//  PhotoMap
//
//  Created by Ramon Pastor on 5/14/14.
//  Copyright (c) 2014 Rogomi Inc. All rights reserved.
//

#import "RGMMapViewController.h"
#import "RGMMapViewAnnotation.h"

@interface RGMMapViewController ()

@end

@implementation RGMMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark View Controller Methods
- (IBAction)refreshUserLocation:(id)sender {
    [_photoMapView setRegion:MKCoordinateRegionMake(_photoMapView.userLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05)) animated:YES];
}

- (IBAction)takePicture:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.delegate = self;
        [self presentViewController:ipc
                           animated:YES
                         completion:^{
                             NSLog(@"Camera presented");
                         }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Not Available"
                                                        message:@"This device does not have a camera, or the camera is currently unavailable."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark Map View Delegate Methods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"%s", __FUNCTION__);
    [self refreshUserLocation:userLocation];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSString *messsage = [[NSString alloc] initWithFormat:@"Error %i : %@", [error code], [error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Locating User"
                                                    message:messsage
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    if([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *identifier = @"PhotoAnnotationView";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    RGMMapViewAnnotation *mva = (RGMMapViewAnnotation *)annotation;
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout = YES;
    }
    UIImage *resizedImage = [[UIImage alloc] initWithCGImage:mva.annotationImage.CGImage scale:64.0 orientation:UIImageOrientationUp];
    annotationView.image = resizedImage;
//    NSLog(@"annotationView.image.size = %@", NSStringFromCGSize(annotationView.image.size));
    
    return annotationView;
}

#pragma Navigation Bar Delegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark Image Picker Controller Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    NSLog(@"image.size = %@", NSStringFromCGSize(image.size));
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSLog(@"Camera view dismissed");
                                 RGMMapViewAnnotation *annotation = [[RGMMapViewAnnotation alloc] init];
                                 annotation.annotationImage = image;
                                 annotation.coordinate = _photoMapView.userLocation.coordinate;
                                 NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                 df.locale = [NSLocale currentLocale];
                                 df.dateStyle = NSDateFormatterShortStyle;
                                 df.timeStyle = NSDateFormatterShortStyle;
                                 annotation.title = [df stringFromDate:[NSDate date]];
                                 [_photoMapView addAnnotation:annotation];
                             }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSLog(@"Camera view cancelled");
                             }];
}

#pragma mark Tab Bar Controller Delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"%s", __FUNCTION__);
    if (![viewController isEqual:self]) {
        [viewController setValue:_photoMapView.annotations forKeyPath:@"annotations"];
    }
}
@end
