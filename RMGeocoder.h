//
//  RMGeocoder.h
//
//  Created by Robert Mogos
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <MapKit/MKPlacemark.h>

@protocol RMGeocoderDelegate;

@interface RMGeocoder : NSObject<CLLocationManagerDelegate,MKReverseGeocoderDelegate> {
  CLLocationManager *locationManager_;
	id<RMGeocoderDelegate>delegate_;
	BOOL hasBeenGeolocalized_;
  BOOL translatePosition_;
}

@property(nonatomic,assign) id<RMGeocoderDelegate> delegate;

//inverse geocode the coordinates
- (void)retrieveAddressWithCoordinates:(CLLocationCoordinate2D)coords;

//geolocalize and inverse geocode the position
- (void)locateAndRetriever;

//geolocalize
- (void)locate;
@end

@protocol RMGeocoderDelegate <NSObject>

@optional
-(void)rmGeocoder:(RMGeocoder*)geocoder didFinishWithPlacemark:(MKPlacemark *)place 
      andLocation:(CLLocation *)location;

-(void)rmGeocoder:(RMGeocoder*)geocoder didFinishWithLocation:(CLLocation *)location;

-(void)rmGeocoder:(RMGeocoder*)geocoder didFinishWithError:(NSError*)error;
@end
