import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi/business_logic/cubit/map_cubit/maps_cubit.dart';
import 'package:taxi/constants/strings.dart';
import 'package:taxi/presentation/widgets/custom_button.dart';

import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../widgets/custom_divider.dart';
import '../widgets/custom_drawer.dart';

class MapScreen extends StatefulWidget {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;

  void animateCameraPosition(LatLng latLng) {
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 14);
    mapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Widget buildTripLoading(MapsCubit cubit) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 300,
        decoration: boxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Requesting a Ride...',
                    curve: Curves.easeIn,
                    textStyle: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    width: 1,
                    color: colorLightGrayFair,
                  ),
                ),
                child: InkWell(
                    onTap: () {
                      cubit.resetMap(cubit.originPosition!);
                      animateCameraPosition(cubit.originPosition!);
                      cubit.cancelRide();
                    },
                    child: const Icon(Icons.close)),
              ),
              const Text(
                'Cancel ride',
                style: TextStyle(
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTripDetails(DirectionsLoaded state, MapsCubit cubit) {
    final rideDistance =
        (state.directionsDetails.distanceValue! / 1000).toStringAsFixed(2);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 300,
        decoration: boxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                color: colorAccent1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Image.asset(
                        'images/taxi.png',
                        height: 72,
                        width: 72,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Taxi',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Bolt-SemiBold',
                            ),
                          ),
                          Text(
                            '$rideDistance km',
                            style: const TextStyle(
                              fontSize: 16,
                              color: colorTextLight,
                            ),
                          )
                        ],
                      ),
                      const Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        'EGP ${cubit.totalFare}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Bolt-SemiBold',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(
                      FontAwesomeIcons.moneyBill1,
                      size: 20,
                    ),
                    SizedBox(width: 16),
                    Text('Cash'),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        color: colorTextLight, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  title: 'REQUEST CAB',
                  color: colorGreen,
                  onPressed: () => cubit.requestCab(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSheet(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 300,
        decoration: boxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Nice to see you!',
                style: TextStyle(fontSize: 12),
              ),
              const Text(
                'Where are you going?',
                style: TextStyle(fontSize: 20, fontFamily: 'Bolt-SemiBold'),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => Navigator.pushNamed(context, searchScreen),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        spreadRadius: 0.4,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.search,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: 12),
                        Text('Search Destination'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    color: colorDimText,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Add Home',
                          style: TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your residential address',
                          style: TextStyle(fontSize: 12, color: colorDimText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const CustomDivider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.work_outline,
                    color: colorDimText,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Add Work',
                          style: TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your office address',
                          style: TextStyle(fontSize: 12, color: colorDimText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<LatLng> getCurrentUserLocation() async {
    await Geolocator.requestPermission();
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    final originPosition =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    return originPosition;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapsCubit>();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawer: BlocBuilder<MapsCubit, MapsState>(
          builder: (context, state) {
            if (state is MapsLoaded) {
              return Container(
                width: 252,
                color: Colors.white,
                child: const CustomDrawer(),
              );
            }
            return Container();
          },
        ),
        body: Stack(
          children: [
            BlocBuilder<MapsCubit, MapsState>(
              builder: (context, state) {
                if (state is DirectionsLoaded) {
                  animateCameraPosition(cubit.destinationPosition!);
                }
                if (state is TaxiRequested) {
                  animateCameraPosition(cubit.originPosition!);
                }
                return GoogleMap(
                  markers: cubit.markers,
                  polylines: cubit.polylines,
                  padding: const EdgeInsets.only(bottom: 300),
                  initialCameraPosition: MapScreen._kGooglePlex,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) async {
                    _controller.complete(controller);
                    mapController = controller;
                    LatLng originPosition = await getCurrentUserLocation();
                    cubit.resetMap(originPosition);
                    animateCameraPosition(originPosition);
                  },
                );
              },
            ),
            Positioned(
              top: 12,
              left: 12,
              child: InkWell(
                onTap: () => scaffoldKey.currentState!.openDrawer(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 0.8,
                          offset: Offset(0.7, 0.7))
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(
                      Icons.menu,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        spreadRadius: 0.8,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: InkWell(
                    onTap: () => animateCameraPosition(cubit.originPosition!),
                    child: const Icon(
                      Icons.gps_fixed_outlined,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<MapsCubit, MapsState>(
              builder: (context, state) {
                if (state is MapsLoaded) {
                  return buildSheet(context);
                }
                if (state is DirectionsLoaded) {
                  return buildTripDetails(state, cubit);
                }
                if (state is TaxiRequested) {
                  return buildTripLoading(cubit);
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
