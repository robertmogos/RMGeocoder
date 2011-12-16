//
//  RMGeocoder.m
//
//  Created by Robert Mogos
//

#import "RMGeocoder.h"
#import <MapKit/MKPlacemark.h>

@interface RMGeocoder (PrivateMethods)
- (void)startFetching;
@end

@implementation RMGeocoder
@synthesize delegate = delegate_;

- (void)locate{
  translatePosition_ = NO;
  [self startFetching];
}

- (void)locateAndRetriever{
	translatePosition_ = YES;
  [self startFetching];	
}

- (void)startFetching{
  
  hasBeenGeolocalized_ = NO;
  if (!locationManager_) {
		locationManager_ = [[CLLocationManager alloc] init];		
		locationManager_.distanceFilter = kCLDistanceFilterNone;
		locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
		[locationManager_ setDelegate:self];
	}
  
	[locationManager_ startUpdatingLocation];
  [self performSelector:@selector(stopUpdatingLocation:) 
             withObject:@"Timed Out" 
             afterDelay:20.0];
}

- (void)retrieveAddressWithCoordinates:(CLLocationCoordinate2D)coords{
  MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coords];
  [geocoder setDelegate:self];
  if (geocoder.placemark) {
    
    if ([delegate_ respondsToSelector:@selector(rmGeocoder:didFinishWithPlacemark:andLocation:)]) {
      [delegate_ rmGeocoder:self didFinishWithPlacemark:geocoder.placemark andLocation:locationManager_.location];
    }
    
    [geocoder autorelease];
    return;
  }
  [geocoder start];
}

#pragma mark CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation{
  
  #if !(TARGET_IPHONE_SIMULATOR)
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
  #endif
  
  if (newLocation.horizontalAccuracy < 0) return;
  
	if (!hasBeenGeolocalized_){
		hasBeenGeolocalized_ = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self 
                                             selector:@selector(stopUpdatingLocation:) 
                                               object:@"Timed Out"];
    
    if ([delegate_ respondsToSelector:@selector(rmGeocoder:didFinishWithLocation:)]) {
      [delegate_ rmGeocoder:self didFinishWithLocation:newLocation];
    }
    
    if (translatePosition_) {
      [self retrieveAddressWithCoordinates:newLocation.coordinate];
    }
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	[locationManager_ stopUpdatingLocation];
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:@"Timed Out"];
  
  if ([delegate_ respondsToSelector:@selector(rmGeocoder:didFinishWithError:)]) {
    [delegate_ rmGeocoder:self didFinishWithError:error];
  }
}

- (void)stopUpdatingLocation:(NSString *)state{
  [locationManager_ stopUpdatingLocation];
  
  if ([delegate_ respondsToSelector:@selector(rmGeocoder:didFinishWithError:)]) {
    [delegate_ rmGeocoder:self didFinishWithError:nil];
  }
}

#pragma mark MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
  if (placemark) {

    if ([delegate_ respondsToSelector:@selector(rmGeocoder:didFinishWithPlacemark:andLocation:)]) {
      [delegate_ rmGeocoder:self didFinishWithPlacemark:placemark andLocation:locationManager_.location];  
    }

    [geocoder setDelegate:nil];
    [geocoder autorelease];
 		[locationManager_ stopUpdatingLocation];
  }else{
    [geocoder cancel];
    [geocoder start];
  }
  
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
	[locationManager_ stopUpdatingLocation];
  
  if ([delegate_ respondsToSelector:@selector(rmGeocoder:didFinishWithError:)]) {
    [delegate_ rmGeocoder:self didFinishWithError:error];
  }
  
  [geocoder setDelegate:nil];
  [geocoder autorelease];
}


-(void)dealloc{
  [locationManager_ setDelegate:nil];
  [locationManager_ stopUpdatingLocation];
	[locationManager_ release];
	[super dealloc];
}
@end
