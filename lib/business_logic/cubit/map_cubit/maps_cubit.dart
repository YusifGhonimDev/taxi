import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi/data/models/address.dart';
import 'package:taxi/data/models/direction_details.dart';
import 'package:taxi/data/models/driver.dart';
import 'package:taxi/data/models/place_details.dart';
import 'package:taxi/data/models/predictions.dart';
import 'package:taxi/data/models/user_details.dart';
import 'package:taxi/data/repositories/maps_repository.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final _mapsRepository = MapsRepository();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  LatLng? originPosition, destinationPosition;
  String? totalFare, originAddressName, _destinationAddressName;
  final int _baseFare = 8, _distanceFare = 3;
  final double _timeFare = 0.5;
  final List<LatLng> _polylineCoordinates = [];
  Set<Polyline> polylines = {};
  final _polylinePoints = PolylinePoints();
  Set<Marker> markers = {};
  UserDetails? userDetails;
  List<Driver> nearbyDrivers = [];

  MapsCubit() : super(MapsInitial());

  void resetMap(LatLng originPosition) async {
    _resetDrivers();
    _removePolylines();
    _removeMarkers();
    await _getCurrentUserInfo()
        .then((user) => userDetails = UserDetails.fromSnapshot(user));
    _mapsRepository
        .getAddressName(originPosition.latitude, originPosition.longitude)
        .then((address) {
      _updateOriginAddressName(address);
      _updateOriginPosition(originPosition.latitude, originPosition.longitude);
      _searchDrivers();
      Future.delayed(const Duration(seconds: 1), () {
        emit(MapsLoaded(markers));
      });
    });
  }

  void _resetDrivers() => nearbyDrivers.clear();

  void _searchDrivers() {
    final geo = Geoflutterfire();
    final drivers = FirebaseFirestore.instance.collection('drivers');
    GeoFirePoint center = geo.point(
        latitude: originPosition!.latitude,
        longitude: originPosition!.longitude);
    double radius = 50;
    String field = 'position';
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: drivers)
        .within(center: center, radius: radius, field: field);
    stream.listen(
      (event) {
        _addNearbyDrivers(event);
        _updateDriversOnMap();
      },
    );
  }

  void _updateDriversOnMap() async {
    for (var driver in nearbyDrivers) {
      LatLng driverPosition = LatLng(driver.latitude!, driver.longitude!);
      Marker driverMarker = Marker(
        markerId: MarkerId(driver.geoHash!),
        position: driverPosition,
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(4, 4)), 'images/car1.png'),
      );
      markers.add(driverMarker);
    }
  }

  void _addNearbyDrivers(List<DocumentSnapshot<Object?>> event) {
    for (var driverInfo in event) {
      final driver = Driver.fromSnapshot(driverInfo.data());
      Driver nearbyDriver = Driver(
          latitude: driver.latitude,
          longitude: driver.longitude,
          geoHash: driver.geoHash!);
      nearbyDrivers.add(nearbyDriver);
    }
  }

  void _removeMarkers() => markers.clear();

  void _removePolylines() {
    _polylineCoordinates.clear();
    polylines.clear();
  }

  void _updateOriginPosition(double latitude, double longitude) =>
      originPosition = LatLng(latitude, longitude);

  void _updateOriginAddressName(Address address) =>
      originAddressName = address.addressName;

  void searchPlace(String placeName) => _mapsRepository
      .searchPlace(placeName)
      .then((address) => emit(PlaceSearched(address)));

  void getPlaceDetails(String placeID) {
    emit(DetailsLoading());
    _mapsRepository.getPlaceDetails(placeID).then((placeDetails) {
      emit(PlaceSelected(placeDetails));
      _updateDestinationAddressName(placeDetails);
      _updateDestinationPosition(placeDetails);
      _addMarkers();
    });
  }

  void _updateDestinationAddressName(PlaceDetails placeDetails) =>
      _destinationAddressName = placeDetails.name;

  void _addMarkers() {
    markers.add(_getOriginMarker());
    markers.add(_getDestinationMarker());
  }

  Marker _getDestinationMarker() {
    Marker destinationMarker = Marker(
      markerId: const MarkerId('2'),
      position: destinationPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: _destinationAddressName, snippet: 'Destination'),
    );
    return destinationMarker;
  }

  Marker _getOriginMarker() {
    Marker originMarker = Marker(
      markerId: const MarkerId('1'),
      position: originPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: originAddressName, snippet: 'My Location'),
    );
    return originMarker;
  }

  void _updateDestinationPosition(PlaceDetails placeDetails) =>
      destinationPosition =
          LatLng(placeDetails.latitude!, placeDetails.longitude!);

  void getDirectionDetails(LatLng originPoint, LatLng destinationPoint) {
    _mapsRepository
        .getDirectionDetails(originPoint, destinationPoint)
        .then((directionDetails) {
      emit(DirectionsLoaded(directionDetails));
      _calculateTotalFare(directionDetails);
      List<PointLatLng> decodedPolyline = _getDecodedPolyline(directionDetails);
      if (decodedPolyline.isNotEmpty) {
        for (PointLatLng point in decodedPolyline) {
          _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
      Polyline polyline = _buildSinglePolyline();
      polylines.add(polyline);
    });
  }

  void _calculateTotalFare(DirectionDetails directionDetails) =>
      totalFare = (_baseFare +
              _getRideDistanceFare(directionDetails) +
              _getRideDurationFare(directionDetails))
          .toStringAsFixed(2);

  double _getRideDurationFare(DirectionDetails directionDetails) =>
      (directionDetails.durationValue!.toDouble() / 60) * _timeFare;

  double _getRideDistanceFare(DirectionDetails directionDetails) =>
      (directionDetails.distanceValue!.toDouble() / 1000) * _distanceFare;

  Polyline _buildSinglePolyline() {
    Polyline polyline = Polyline(
      polylineId: const PolylineId('1'),
      color: const Color.fromARGB(255, 95, 109, 237),
      points: _polylineCoordinates,
      jointType: JointType.round,
      width: 4,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
    return polyline;
  }

  List<PointLatLng> _getDecodedPolyline(DirectionDetails directionDetails) {
    List<PointLatLng> results =
        _polylinePoints.decodePolyline(directionDetails.polylinePoints!);
    return results;
  }

  void cancelRide() {
    _firestore.collection('rideDetails').doc(_auth.currentUser!.uid).delete();
    emit(TaxiCanceled());
  }

  void requestCab() {
    _removePolylines();
    _removeMarkers();
    _searchDrivers();
    _updateTripDetails();
    Future.delayed(const Duration(seconds: 1), () {
      _firestore
          .collection('rideDetails')
          .doc(_auth.currentUser!.uid)
          .update({'tripFare': totalFare});
      emit(TaxiRequested());
    });
  }

  void _updateTripDetails() async {
    final userID = _auth.currentUser!.uid;
    final userInfo = _firestore.collection('users').doc(userID).get();
    final fullName = userInfo.then((value) => value.data()!['fullName']);
    final phoneNumber = userInfo.then((value) => value.data()!['phoneNumber']);
    _firestore.collection('rideDetails').doc(_auth.currentUser!.uid).set({
      'pickUp': originAddressName,
      'pickUpLatitude': originPosition!.latitude,
      'pickUpLongitude': originPosition!.longitude,
      'destination': _destinationAddressName,
      'destinationLatitude': destinationPosition!.latitude,
      'destinationLongitude': destinationPosition!.longitude,
      'paymentMethod': 'CASH',
      'riderName': await fullName,
      'riderPhone': await phoneNumber,
      'tripState': 'WAITING',
      'rideID': userID,
      'tripFare': 0
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getCurrentUserInfo() async {
    final currentUser = _auth.currentUser;
    final userID = currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get();
  }
}
