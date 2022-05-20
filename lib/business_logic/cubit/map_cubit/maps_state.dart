part of 'maps_cubit.dart';

@immutable
abstract class MapsState {}

class MapsInitial extends MapsState {}

class MapsLoaded extends MapsState {
  final Set<Marker> markers;

  MapsLoaded(this.markers);
}

class PlaceSearched extends MapsState {
  final List<Prediction> predictions;

  PlaceSearched(this.predictions);
}

class PlaceSelected extends MapsState {
  final PlaceDetails placeDetails;

  PlaceSelected(this.placeDetails);
}

class DetailsLoading extends MapsState {}

class DirectionsLoaded extends MapsState {
  final DirectionDetails directionsDetails;

  DirectionsLoaded(this.directionsDetails);
}

class TaxiRequested extends MapsState {}

class TaxiCanceled extends MapsState {}
