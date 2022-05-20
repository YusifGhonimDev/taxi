import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taxi/business_logic/cubit/map_cubit/maps_cubit.dart';
import 'package:taxi/constants/colors.dart';
import 'package:taxi/data/models/place_details.dart';
import 'package:taxi/data/models/predictions.dart';
import 'package:taxi/presentation/widgets/custom_dialog.dart';
import 'package:taxi/presentation/widgets/custom_divider.dart';

import '../widgets/prediction_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Prediction>? prediction;
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapsCubit>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: 212,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, top: 48, right: 24, bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      InkWell(
                        child: const Icon(Icons.arrow_back),
                        onTap: () => Navigator.pop(context),
                      ),
                      const Center(
                        child: Text(
                          'Set Destination',
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'Bolt-SemiBold'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'images/pickicon.png',
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorLightGrayFair,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: BlocBuilder<MapsCubit, MapsState>(
                                builder: (context, state) {
                                  if (state is MapsLoaded) {
                                    pickupController.text =
                                        cubit.originAddressName ?? '';
                                  }
                                  return TextField(
                                    controller: pickupController,
                                    decoration: const InputDecoration(
                                      hintText: 'Pickup location',
                                      fillColor: colorLightGrayFair,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                        left: 12,
                                        top: 2,
                                        bottom: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'images/desticon.png',
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorLightGrayFair,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: TextField(
                                onChanged: (value) => cubit.searchPlace(value),
                                autofocus: true,
                                controller: destinationController,
                                decoration: const InputDecoration(
                                  hintText: 'Where to?',
                                  fillColor: colorLightGrayFair,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                    left: 12,
                                    top: 2,
                                    bottom: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocConsumer<MapsCubit, MapsState>(
            listener: (context, state) {
              if (state is PlaceSelected) {
                Navigator.pop(context);
                LatLng originPosition = cubit.originPosition!;
                PlaceDetails placeDetails = state.placeDetails;
                LatLng destinationPosition =
                    LatLng(placeDetails.latitude!, placeDetails.longitude!);
                cubit.getDirectionDetails(originPosition, destinationPosition);
              }
              if (state is DirectionsLoaded) {
                Navigator.pop(context);
              }
              if (state is DetailsLoading) {
                showDialog(
                    context: context,
                    builder: (context) =>
                        const CustomDialog(status: 'Please wait...'),
                    barrierDismissible: false);
              }
            },
            builder: (context, state) {
              if (state is PlaceSearched) {
                prediction = state.predictions;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListView.separated(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) =>
                          PredictionList(prediction: prediction![index]),
                      separatorBuilder: (context, index) =>
                          const CustomDivider(),
                      itemCount: prediction!.length),
                );
              }
              return Container();
            },
          )
        ],
      ),
    );
  }
}
