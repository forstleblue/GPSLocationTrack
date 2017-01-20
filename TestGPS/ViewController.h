//
//  ViewController.h
//  TestGPS
//
//  Created by Lucky Ji on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CSqlite.h"
#import <MapKit/MapKit.h>

@interface POI : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D coordinate;
    NSString *subtitle;
    NSString *title;
}

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *subtitle;
@property (nonatomic,retain) NSString *title;

-(id) initWithCoords:(CLLocationCoordinate2D) coords;

@end

@interface ViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
{
    
    CSqlite *m_sqlite;
    
    int nTime;
    
    CLLocationManager *locationManager;
    MKCoordinateRegion region;
    NSMutableArray* arrayLine;          //Screen grid Line
    NSMutableArray* arrayRectLineTrack;   //to save the center point of the user went(more than 5 minutes)
    NSMutableArray* arrayImageRectTrack;
    NSTimer* timer;
    
    int nTapCount;
    CLLocationCoordinate2D bottomLeftPos;
    CLLocationCoordinate2D arrayRectCenter[50];  // The center point that user go
    CLLocationCoordinate2D mylocation;           // current user location
    CLLocationCoordinate2D oldRectCenter;
    NSUserDefaults* defaults;
    BOOL bDisplayGrid;
    
    BOOL bTracLocation;
    int nRectId;    //The rectangle count that user go
    int aRectCount[50]; // count how many times user go
    
    float fTimeBetween;  // calculate the time the user is on same location
}
@property (strong, nonatomic) IBOutlet UIButton *btnStart;
@property (strong, nonatomic) IBOutlet UIButton *btnStop;

- (IBAction)onStop:(id)sender;
- (IBAction)onStart:(id)sender;
//@property (weak, nonatomic) IBOutlet UILabel *lat;
//@property (weak, nonatomic) IBOutlet UILabel *llong;
@property (weak, nonatomic) IBOutlet UILabel *offLat;
@property (weak, nonatomic) IBOutlet UILabel *offLog;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *m_locationName;
@property (nonatomic, strong) NSMutableArray* allPins;
@property (nonatomic, strong) MKPolylineView* lineView;
@property (nonatomic, strong) MKPolyline * polyline;

@end


