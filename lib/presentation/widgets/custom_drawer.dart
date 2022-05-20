import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/constants/strings.dart';

import '../../business_logic/cubit/map_cubit/maps_cubit.dart';
import '../../constants/styles.dart';
import 'custom_divider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapsCubit>();
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            height: 160,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('images/user_icon.png'),
                    radius: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cubit.userDetails!.name!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Bolt-SemiBold',
                            ),
                          ),
                          Text(
                            cubit.userDetails!.phoneNumber!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bolt-Regualr',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('View Profile'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const CustomDivider(),
          const SizedBox(height: 12),
          const ListTile(
            leading: Icon(
              Icons.card_giftcard_outlined,
            ),
            title: Text(
              'Free Rides',
              style: drawerItemStyle,
            ),
          ),
          const ListTile(
            leading: Icon(
              Icons.credit_card,
            ),
            title: Text(
              'Payments',
              style: drawerItemStyle,
            ),
          ),
          const ListTile(
            leading: Icon(
              Icons.history,
            ),
            title: Text(
              'Ride History',
              style: drawerItemStyle,
            ),
          ),
          const ListTile(
            leading: Icon(
              Icons.contact_support_outlined,
            ),
            title: Text(
              'Support',
              style: drawerItemStyle,
            ),
          ),
          const Expanded(child: SizedBox()),
          const CustomDivider(),
          InkWell(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, loginScreen, (route) => false);
            },
            child: const ListTile(
              leading: Icon(
                Icons.logout_outlined,
              ),
              title: Text(
                'Logout',
                style: drawerItemStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
