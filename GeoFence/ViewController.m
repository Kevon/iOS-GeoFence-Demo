//
//  ViewController.m
//  GeoFence
//
//  Created by Kevin on 8/8/16.
//  Copyright © 2016 Kevin Skompinski. All rights reserved.
//

#import "ViewController.h"
#import "MapKit/MapKit.h"

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL mapIsMoving;
@property (strong, nonatomic) MKPointAnnotation *currentAnno;
@property (strong,nonatomic) CLCircularRegion *geoRegion;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapIsMoving = NO;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 3;
    
    CLLocationCoordinate2D noLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapview regionThatFits:viewRegion];
    [self.mapview setRegion:adjustedRegion animated:YES];
    
    [self addCurrentAnnotation];
    [self setUpGeoRegion];
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] == YES){
        CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
        if((currentStatus != kCLAuthorizationStatusAuthorizedWhenInUse) && (currentStatus != kCLAuthorizationStatusAuthorizedAlways)){
            [self.locationManager requestAlwaysAuthorization];
        }
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:CLLocationCoordinate2DMake(43.023791, -78.877086)];
    [annotation setTitle:@"The Riviera Theatre"];
    [self.mapview addAnnotation:annotation];
    
    [self startTracking];
}

/*
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
}
*/

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    self.mapIsMoving = YES;
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    self.mapIsMoving = NO;
}

- (void) setUpGeoRegion{
    self.geoRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(43.023791, -78.877086) radius:7 identifier:@"The Riviera Theatre"];
}

- (void) addCurrentAnnotation{
    self.currentAnno = [[MKPointAnnotation alloc] init];
    self.currentAnno.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentAnno.title = @"My Location";
}

- (void) centerMap:(MKPointAnnotation *)centerPoint{
    [self.mapview setCenterCoordinate:centerPoint.coordinate animated:YES];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    self.currentAnno.coordinate = locations.lastObject.coordinate;
    if(self.mapIsMoving == NO){
        [self centerMap:self.currentAnno];
    }
}

- (void) startTracking{
    self.mapview.showsUserLocation = YES;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringForRegion:self.geoRegion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"The Riviera Theatre coupon offer!";
    note.alertBody = [NSString stringWithFormat:@"Come inside in the next 30 minutes to recieve 10%% off!"];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"The Riviera Theatre coupon offer!"
                                          message:@"Come inside in the next 30 minutes to recieve 10% off with coupon code 1738!"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"GeoFence Alert!";
    note.alertBody = [NSString stringWithFormat:@"You exited the geofence."];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    
}
 */

@end
