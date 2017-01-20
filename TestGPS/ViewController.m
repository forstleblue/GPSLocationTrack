//
//  ViewController.m
//  TestGPS
//
//  Created by Lucky Ji on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Pin.h"

#define LongtitudeSeg  0.00171661368347031384474
#define DISPLAYGRID     @"DisplayGrid"
#define FIRSTRUNTHISAPP         @"firstRunApp"
#define BOTTOMLOCATION          @"bottomLocation"
#define DATAPATH                @"/dataPathFile.DB"
@interface ViewController ()

@end

@implementation ViewController
//@synthesize lat;
//@synthesize llong;

@synthesize allPins;
@synthesize lineView;
@synthesize polyline;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    m_sqlite = [[CSqlite alloc]init];
    [m_sqlite openSqlite];
    
    if ([CLLocationManager locationServicesEnabled]) { // 检查定位服务是否可用
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter=0.5;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation]; // 开始定位
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.mapView.showsUserLocation = YES;//显示ios自带的我的位置显示
    self.allPins = [[NSMutableArray alloc] init];
    self.mapView.delegate = self;
    
    arrayRectLineTrack = [[NSMutableArray alloc] init];
    arrayImageRectTrack = [[NSMutableArray alloc] init];
    
    defaults = [NSUserDefaults standardUserDefaults];
    bDisplayGrid = NO;
    bTracLocation = NO;
    nRectId = 0;
    fTimeBetween = 0;
    
    self.btnStop.enabled = NO;
    for (int i = 0; i < 50; i++) {
        aRectCount[i] = 0;
    }
}

- (void) drawUserRect
{
    CLLocationCoordinate2D mapPoint = mylocation;
    int iCount = 0;
    
    float xRectOne, xRectTwo;
    float yRectOne, yRectTwo;
    
    if (mapPoint.longitude > bottomLeftPos.longitude) {
        while (mapPoint.longitude > bottomLeftPos.longitude + LongtitudeSeg * iCount) {
            iCount ++;
        }
        xRectOne = bottomLeftPos.longitude + LongtitudeSeg * (iCount - 1);
        xRectTwo = bottomLeftPos.longitude + LongtitudeSeg * iCount;
    }
    else if(mapPoint.longitude < bottomLeftPos.longitude)
    {
        while (mapPoint.longitude < bottomLeftPos.longitude + LongtitudeSeg * iCount) {
            iCount --;
        }
        
        xRectOne = bottomLeftPos.longitude + LongtitudeSeg * iCount;
        xRectTwo = bottomLeftPos.longitude + LongtitudeSeg * (iCount + 1);
    }
    
    iCount = 0;
    if (mapPoint.latitude > bottomLeftPos.latitude) {
        while (mapPoint.latitude > bottomLeftPos.latitude + LongtitudeSeg * iCount) {
            iCount ++;
        }
        yRectOne = bottomLeftPos.latitude + LongtitudeSeg * (iCount - 1);
        yRectTwo = bottomLeftPos.latitude + LongtitudeSeg * iCount;
    }
    else {
        while (mapPoint.latitude < bottomLeftPos.latitude + LongtitudeSeg * iCount) {
            iCount --;
        }
        yRectOne = bottomLeftPos.latitude + LongtitudeSeg * iCount;
        yRectTwo = bottomLeftPos.latitude + LongtitudeSeg * (iCount + 1);
    }
    
//    arrayRectCenter[nRectId].longitude = (xRectOne + xRectTwo) / 2;
//    arrayRectCenter[nRectId].latitude = (yRectOne + yRectTwo) / 2;
    
    CLLocationCoordinate2D coordinates[5];
    
    coordinates[0].latitude = yRectTwo;
    coordinates[0].longitude = xRectOne;
    
    coordinates[1].latitude = yRectTwo;
    coordinates[1].longitude = xRectTwo;
    
    coordinates[2].latitude = yRectOne;
    coordinates[2].longitude = xRectTwo;
    
    coordinates[3].latitude = yRectOne;
    coordinates[3].longitude = xRectOne;
    
    coordinates[4].latitude = yRectTwo;
    coordinates[4].longitude = xRectOne;
    
    MKPolyline* polyLine = [MKPolyline polylineWithCoordinates:coordinates count:5];
    [arrayRectLineTrack addObject:polyLine];
    [self.mapView addOverlay:polyLine];
    
    self.polyline = polyLine;
    self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor blueColor];
    self.lineView.lineWidth = 2;

}

- (void)reDrawUserRect
{
    for (int i = 0; i < nRectId; i++) {
        float xRectOne, xRectTwo;
        float yRectOne, yRectTwo;
        xRectOne = arrayRectCenter[i].longitude - LongtitudeSeg / 2;
        xRectTwo = arrayRectCenter[i].longitude + LongtitudeSeg / 2;
        
        yRectOne  = arrayRectCenter[i].latitude - LongtitudeSeg / 2;
        yRectTwo = arrayRectCenter[i].latitude + LongtitudeSeg / 2;
        
        CLLocationCoordinate2D coordinates[5];
        
        coordinates[0].latitude = yRectTwo;
        coordinates[0].longitude = xRectOne;
        
        coordinates[1].latitude = yRectTwo;
        coordinates[1].longitude = xRectTwo;
        
        coordinates[2].latitude = yRectOne;
        coordinates[2].longitude = xRectTwo;
        
        coordinates[3].latitude = yRectOne;
        coordinates[3].longitude = xRectOne;
        
        coordinates[4].latitude = yRectTwo;
        coordinates[4].longitude = xRectOne;
        
        MKPolyline* polyLine = [MKPolyline polylineWithCoordinates:coordinates count:5];
        [self.mapView addOverlay:polyLine];
        
        [arrayRectLineTrack addObject:polyLine];
        
        self.polyline = polyLine;
        self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
        self.lineView.strokeColor = [UIColor blueColor];
        self.lineView.lineWidth = 3;
    }
}

- (void) calculateTime
{
    fTimeBetween = fTimeBetween + 0.01;
    NSString* strTimeBetween = [NSString stringWithFormat:@"%.2f", fTimeBetween];
    if ([strTimeBetween isEqualToString:@"5.00"] == YES) {
        aRectCount[nRectId] = aRectCount[nRectId] + 1;
        arrayRectCenter[nRectId] = oldRectCenter;
        fTimeBetween = fTimeBetween + 0.01;
        
        [self drawUserRect];
        [self drawUserRect];

        nRectId ++;
    }
}

- (CLLocationCoordinate2D)calculateCurrentRectCenter:(CLLocationCoordinate2D) currentLocation
{
    CLLocationCoordinate2D mapPoint = currentLocation;
    
    int iCount = 0;
    
    float xRectOne, xRectTwo;
    float yRectOne, yRectTwo;
    
    if (mapPoint.longitude > bottomLeftPos.longitude) {
        while (mapPoint.longitude > bottomLeftPos.longitude + LongtitudeSeg * iCount) {
            iCount ++;
        }
        xRectOne = bottomLeftPos.longitude + LongtitudeSeg * (iCount - 1);
        xRectTwo = bottomLeftPos.longitude + LongtitudeSeg * iCount;
    }
    else if(mapPoint.longitude < bottomLeftPos.longitude)
    {
        while (mapPoint.longitude < bottomLeftPos.longitude + LongtitudeSeg * iCount) {
            iCount --;
        }
        
        xRectOne = bottomLeftPos.longitude + LongtitudeSeg * iCount;
        xRectTwo = bottomLeftPos.longitude + LongtitudeSeg * (iCount + 1);
    }
    
    iCount = 0;
    if (mapPoint.latitude > bottomLeftPos.latitude) {
        while (mapPoint.latitude > bottomLeftPos.latitude + LongtitudeSeg * iCount) {
            iCount ++;
        }
        yRectOne = bottomLeftPos.latitude + LongtitudeSeg * (iCount - 1);
        yRectTwo = bottomLeftPos.latitude + LongtitudeSeg * iCount;
    }
    else {
        while (mapPoint.latitude < bottomLeftPos.latitude + LongtitudeSeg * iCount) {
            iCount --;
        }
        yRectOne = bottomLeftPos.latitude + LongtitudeSeg * iCount;
        yRectTwo = bottomLeftPos.latitude + LongtitudeSeg * (iCount + 1);
    }
    
    CLLocationCoordinate2D coordinates[5];
    
    coordinates[0].latitude = yRectTwo;
    coordinates[0].longitude = xRectOne;
    
    coordinates[1].latitude = yRectTwo;
    coordinates[1].longitude = xRectTwo;
    
    coordinates[2].latitude = yRectOne;
    coordinates[2].longitude = xRectTwo;
    
    coordinates[3].latitude = yRectOne;
    coordinates[3].longitude = xRectOne;
    
    coordinates[4].latitude = yRectTwo;
    coordinates[4].longitude = xRectOne;
    CLLocation* ptRectCenter = [[CLLocation alloc] initWithLatitude:(yRectOne + yRectTwo) / 2  longitude:(xRectOne + xRectTwo) / 2];
    return ptRectCenter.coordinate;
}

- (void)viewDidUnload
{
    
    [self setOffLat:nil];
    [self setOffLog:nil];
    [self setMapView:nil];
    [self setM_locationName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)drawLineSubroutine {
    
    // remove polyline if one exists
    [self.mapView removeOverlay:self.polyline];
    
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[self.allPins.count];
    int i = 0;
    for (Pin *currentPin in self.allPins) {
        coordinates[i] = currentPin.coordinate;
        i++;
    }
    
    NSLog(@"%d", self.allPins.count);
    
    // create a polyline with all cooridnates
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:self.allPins.count];
    [self.mapView addOverlay:polyLine];
    self.polyline = polyLine;
    
    // create an MKPolylineView and add it to the map view
    self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor redColor];
    self.lineView.lineWidth = 5;
    
    // for a laugh: how many polylines are we drawing here?
    self.title = [[NSString alloc]initWithFormat:@"%lu", (unsigned long)self.mapView.overlays.count];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


// 定位成功时调用
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation 
{
    
    [self.mapView removeOverlays:arrayLine];
    [self.mapView removeOverlays:arrayRectLineTrack];
    
    mylocation = newLocation.coordinate;//手机GPS
    
    mylocation = [self zzTransGPS:mylocation];///火星GPS
    
    [self SetMapPoint:mylocation];
    self.offLat.text = [[NSString alloc]initWithFormat:@"%lf",mylocation.latitude];
    self.offLog.text = [[NSString alloc]initWithFormat:@"%lf",mylocation.longitude];
    
    //显示火星坐标
    
    /////////获取位置信息
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray* placemarks,NSError *error)
    {
        if (placemarks.count >0)
        {
            CLPlacemark * plmark = [placemarks objectAtIndex:0];
            
            NSString * country = plmark.country;
            NSString * city    = plmark.locality;
            
            NSLog(@"%@-%@-%@",country,city,plmark.name);
            self.m_locationName.text =plmark.name;
        }
        
        NSLog(@"%@",placemarks);
        
    }];
    
    CLLocationCoordinate2D locationRectCenter  = [self calculateCurrentRectCenter:mylocation];
    
    //If the current Position Rect center is same with old center rect
    if ((locationRectCenter.longitude != oldRectCenter.longitude || locationRectCenter.latitude != oldRectCenter.latitude) && bTracLocation == YES) {
        oldRectCenter = locationRectCenter;
        fTimeBetween = 0;
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self.mapView removeOverlays:arrayLine];
    [self.mapView removeOverlays:arrayRectLineTrack];
    
    [self.mapView removeOverlays:arrayLine];
    [self.mapView removeOverlays:arrayRectLineTrack];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self drawGridLine];
}

- (void) drawGridLine
{
    arrayLine = [[NSMutableArray alloc] init];
    
    region = self.mapView.region;
    MKCoordinateSpan span = region.span;
    CLLocationCoordinate2D center = region.center;
    
    if (span.longitudeDelta < LongtitudeSeg * 20) {
        
        
        [arrayImageRectTrack removeAllObjects];
        [arrayRectLineTrack removeAllObjects];
        
        CLLocationCoordinate2D posLeftBottom;
        
        posLeftBottom.longitude = center.longitude - span.longitudeDelta / 2;
        posLeftBottom.latitude = center.latitude - span.latitudeDelta / 2;
        
        int nWidthCount = span.longitudeDelta / LongtitudeSeg;
        
        if (bDisplayGrid == NO) {
            bDisplayGrid = YES;
            bottomLeftPos = posLeftBottom;
//            BOOL bFirstRun = [defaults boolForKey:FIRSTRUNTHISAPP];
//            NSMutableArray* points = [[NSMutableArray alloc] init];
//            [points addObject:[NSValue valueWithMKCoordinate:bottomLeftPos]];
//            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString* documentsDirectory = [paths objectAtIndex:0];
//            NSString* strFilePath = [documentsDirectory stringByAppendingString:DATAPATH];
//
//            if (bFirstRun == NO) {
//                
//                [defaults setBool:YES forKey:FIRSTRUNTHISAPP];
//                [defaults synchronize];
//                
////                bottomLeftPos = posLeftBottom;
//                
//                BOOL writeResults = NO;
//                NSData *data = [NSData dataWithBytes:&bottomLeftPos length:sizeof(CLLocationCoordinate2D)];
//                writeResults = [data writeToFile:strFilePath atomically:NO];
//                NSLog(@"%d", writeResults);
//            }
//            else
//            {
//                NSData* savedData;
//                savedData = [[NSData alloc] initWithContentsOfFile:strFilePath];
//                [savedData getBytes:&bottomLeftPos  length:sizeof(bottomLeftPos)];
//            }
        }
        else
        {
            int cnWidth = (posLeftBottom.longitude - bottomLeftPos.longitude) / LongtitudeSeg;
            int cnHeight = (posLeftBottom.latitude - bottomLeftPos.latitude) / LongtitudeSeg;
            
            posLeftBottom.longitude = bottomLeftPos.longitude + cnWidth * LongtitudeSeg;
            posLeftBottom.latitude = bottomLeftPos.latitude + cnHeight * LongtitudeSeg;
        }
        
        float fTopLatitude = region.center.latitude + span.latitudeDelta / 2;
        float fBottomLatitude = region.center.latitude - span.latitudeDelta / 2;
        
        int nHeightCount = span.latitudeDelta / LongtitudeSeg;
        
        float fLeftLongtitude = region.center.longitude - span.longitudeDelta / 2;
        float fRightLongtitude = region.center.longitude + span.longitudeDelta / 2;
        
        // Draw the Rectangle Line  Width
        for (int i = 0; i < nWidthCount + 3; i++) {
            float itemLongtitude = posLeftBottom.longitude + LongtitudeSeg * i;
            
            CLLocationCoordinate2D coordinates[2];
            
            coordinates[0].latitude = fTopLatitude;
            coordinates[0].longitude = itemLongtitude;
            
            coordinates[1].latitude = fBottomLatitude;
            coordinates[1].longitude = itemLongtitude;
            
            MKPolyline* polyLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
            [arrayLine addObject:polyLine];
            [self.mapView addOverlay:polyLine];
            self.polyline = polyLine;
            self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
            self.lineView.strokeColor = [UIColor redColor];
            self.lineView.lineWidth = 1;
        }
        
        //Draw the Rectangle Line Height;
        for (int i = 0; i < nHeightCount + 3; i++) {
            float itemLatitude = posLeftBottom.latitude + LongtitudeSeg * i;
            
            CLLocationCoordinate2D coordinates[2];
            coordinates[0].latitude = itemLatitude;
            coordinates[0].longitude = fLeftLongtitude;
            
            coordinates[1].latitude = itemLatitude;
            coordinates[1].longitude = fRightLongtitude;
            
            MKPolyline* polyLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
            [arrayLine addObject:polyLine];
            [self.mapView addOverlay:polyLine];
            self.polyline = polyLine;
            self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
            self.lineView.strokeColor = [UIColor redColor];
            self.lineView.lineWidth = 1;
        }
        [self reDrawUserRect];
        [self reDrawUserRect];
    }
    else
    {
        [self.mapView removeOverlays:arrayLine];
        [self.mapView removeOverlays:arrayRectLineTrack];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    return self.lineView;
}


// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
}

-(CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps
{
    int TenLat=0;
    int TenLog=0;
    TenLat = (int)(yGps.latitude*10);
    TenLog = (int)(yGps.longitude*10);
    NSString *sql = [[NSString alloc]initWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d",TenLat,TenLog];
    sqlite3_stmt* stmtL = [m_sqlite NSRunSql:sql];
    int offLat=0;
    int offLog=0;
    while (sqlite3_step(stmtL)==SQLITE_ROW)
    {
        offLat = sqlite3_column_int(stmtL, 0);
        offLog = sqlite3_column_int(stmtL, 1);
    }
    
    yGps.latitude = yGps.latitude+offLat*0.0001;
    yGps.longitude = yGps.longitude + offLog*0.0001;
    return yGps;
}

- (void)addPin:(UIGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    // convert touched position to map coordinate
    CGPoint userTouch = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D mapPoint = [self.mapView convertPoint:userTouch toCoordinateFromView:self.mapView];
    
    // and add it to our view and our array
    Pin *newPin = [[Pin alloc]initWithCoordinate:mapPoint];
    [self.mapView addAnnotation:newPin];
    [self.allPins addObject:newPin];
    
    [self drawLineSubroutine];
    [self drawLineSubroutine];
    
}

-(void)SetMapPoint:(CLLocationCoordinate2D)myLocation
{

    POI* m_poi = [[POI alloc]initWithCoords:myLocation];
    
    [self.mapView addAnnotation:m_poi];
    
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center=myLocation;
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [self.mapView setRegion:theRegion animated:YES];
}

- (IBAction)onStop:(id)sender {
    self.btnStart.enabled = YES;
    self.btnStop.enabled = NO;
    if (nRectId > 0) {
        NSMutableArray* arrayUserTrack;
        arrayUserTrack = [[NSMutableArray alloc] init];
        for (int i = 0; i < nRectId; i++) {
            NSData* dataRect = [NSData dataWithBytes:&arrayRectCenter[i] length:sizeof(CLLocationCoordinate2D)];
            [arrayUserTrack addObject:dataRect];
        }
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* strFilePath = [documentsDirectory stringByAppendingString:DATAPATH];
        
        BOOL writeResults = NO;
        writeResults = [arrayUserTrack writeToFile:strFilePath atomically:YES];
        NSLog(@"%d", writeResults);
    }
}

- (IBAction)onStart:(id)sender {
    oldRectCenter = [self calculateCurrentRectCenter:mylocation];
    bTracLocation = YES;
    timer = [[NSTimer alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(calculateTime) userInfo:nil repeats:YES];
    UIButton* btn = (UIButton*)sender;
    btn.enabled = NO;
    self.btnStop.enabled = YES;
}

@end


@implementation POI

@synthesize coordinate,subtitle,title;

- (id) initWithCoords:(CLLocationCoordinate2D) coords{
    
    self = [super init];
    
    if (self != nil) {
        
        coordinate = coords;
        
    }
    
    return self;
    
}


@end
