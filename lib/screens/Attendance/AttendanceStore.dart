import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/sos_model.dart';

part 'AttendanceStore.g.dart';

class AttendanceStore = AttendanceStoreBase with _$AttendanceStore;

abstract class AttendanceStoreBase with Store {
  final Location locationService = Location();

  late StreamSubscription<LocationData> locationSubscription;

  List<SosAlertModel> sosAlerts = [];


  List<LatLng> polylineCoordinates = [];
  Future<void> getPolyPoints(sourceLocation, destination) async {
    PolylinePoints polylinePoints = PolylinePoints();
    debugPrint('poly points loading...');
    try{
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyB8FqsngMx4_4R7X9uUjECoTKuUXIARiE8",
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
      );
      debugPrint('poly points ${result.points}');
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
    }catch (e){
      debugPrint("error---> $e");
    }

  }

  /*LocationData? currentLocation;
void getCurrentLocation() async {
    Location location = Location();
location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
GoogleMapController googleMapController = await _controller.future;
location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
setState(() {});
      },
    );
  }*/

  /*BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
void setCustomMarkerIcon() {
  BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "assets/Pin_source.png")
      .then(
    (icon) {
      sourceIcon = icon;
    },
  );
  BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "assets/Pin_destination.png")
      .then(
    (icon) {
      destinationIcon = icon;
    },
  );
  BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "assets/Badge.png")
      .then(
    (icon) {
      currentLocationIcon = icon;
    },
  );
}*/

  /*double calculateBearing(LatLng startPoint, LatLng endPoint) {
    final double startLat = toRadians(startPoint.latitude);
    final double startLng = toRadians(startPoint.longitude);
    final double endLat = toRadians(endPoint.latitude);
    final double endLng = toRadians(endPoint.longitude);

    final double deltaLng = endLng - startLng;

    final double y = Math.sin(deltaLng) * Math.cos(endLat);
    final double x = Math.cos(startLat) * Math.sin(endLat) -
        Math.sin(startLat) * Math.cos(endLat) * Math.cos(deltaLng);

    final double bearing = Math.atan2(y, x);

    return (toDegrees(bearing) + 360) % 360;
  }

  double toRadians(double degrees) {
    return degrees * (Math.pi / 180.0);
  }

  double toDegrees(double radians) {
    return radians * (180.0 / Math.pi);
  }
Then, you can use this to rotate the Marker like this:

Marker(
   markerId: MarkerId(currentPosition.toString()),
   position: currentPosition,
   icon: movementArrow,  // Custom arrow Marker
   // Rotate the arrow in direction of movement. Func is defined below
   rotation: calculateBearing(previousPosition, currentPosition) - 90,
   anchor: const Offset(0.5, 0.5),
);
*/

  @observable
  bool isLoading = true;

  Future<List<SosAlertModel>> loadAlerts() async {
    return await apiRepo.getAlerts();
  }

  void getData() async {
    isLoading = true;
    var statusResult = await apiRepo.checkAttendanceStatus();
    if (statusResult != null) {
      appStore.setCurrentStatus(statusResult);
    }
    isLoading = false;
  }

  Future checkInOut(String status) async {
    isLoading = true;
    var location = await locationService.getLocation();
    var battery = Battery();
    var connectivityResult = await (Connectivity().checkConnectivity());
    Map req = {
      "status": status,
      "latitude": location.latitude,
      "longitude": location.longitude,
      "altitude": location.altitude ?? 0,
      "bearing": 0,
      "locationAccuracy": location.accuracy ?? 0,
      "speed": location.speed ?? 0,
      "time": location.time ?? 0,
      "isMock": location.isMock ?? false,
      "batteryPercentage": await battery.batteryLevel,
      "isLocationOn": true,
      "isWifiOn": connectivityResult == ConnectivityResult.wifi,
      "signalStrength": connectivityResult == ConnectivityResult.mobile ? 5 : 0
    };

    var result = await apiRepo.checkInOut(req);
    if (!result.isSuccess) {
      toast(result.message);
      return false;
    }
    var statusResult = await apiRepo.checkAttendanceStatus();
    if (statusResult != null) {
      appStore.setCurrentStatus(statusResult);
    }
    if (status == 'checkin') {
      trackingService.startTrackingService();
    } else {
      trackingService.stopTrackingService();
    }
    toast('Successfully $status');
    isLoading = false;
    return true;
  }
}
