import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi/business_logic/cubit/map_cubit/maps_cubit.dart';
import 'package:taxi/data/models/predictions.dart';

import '../../constants/colors.dart';

class PredictionList extends StatelessWidget {
  final Prediction prediction;

  const PredictionList({
    Key? key,
    required this.prediction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<MapsCubit>().getPlaceDetails(prediction.id!),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: colorDimText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.mainText!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prediction.secondaryText!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: colorDimText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
