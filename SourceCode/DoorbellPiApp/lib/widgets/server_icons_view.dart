import 'package:doorbell_pi_app/controllers/server_icons_controller.dart';
import 'package:doorbell_pi_app/enumerations/server_connection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/app_colors.dart';

class ServerIconsView extends StatelessWidget {

  const ServerIconsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ServerIconsController controller = Get.put(ServerIconsController());

    return Row(
      children: [
        Obx( () { // The Wifi icon
          if (controller.connectionState.value == ServerConnectionState.NotConnected) {
            return GestureDetector(
              onTap: () => _openServerDialog (
                'Server Connection Status',
                'No server has been selected as the active server',
                context
              ),
              child: const Icon(
                Icons.wifi_off,
                color: Colors.grey,
                size: 42,
              ),
            );
          } else if (controller.connectionState.value == ServerConnectionState.NotReachable) {
            return GestureDetector(
              onTap: () => _openServerDialog (
                  'Server Connection Status',
                  'The server is currently unreachable',
                  context
              ),
              child: const Icon(
                Icons.wifi,
                color: Colors.grey,
                size: 42,
              ),
            );
          } else {
            return GestureDetector(
              onTap: () => _openServerDialog (
                  'Server Connection Status',
                  'The server is currently reachable',
                  context
              ),
              child: const Icon(
                Icons.wifi,
                color: AppColors.textForegroundOrange,
                size: 42,
              ),
            );
          }
        }),
        const SizedBox(width: 20,),
        Obx( () { // The status icon
          if (controller.connectionState.value == ServerConnectionState.NotConnected) {
            return const Icon(
                Icons.info_outline_rounded,
                color: Colors.grey,
                size: 42,
            );
          } else {
            return GestureDetector(
              onTap: () => _openServerDialog (
                  'Server Connection Status',
                  // Known not null because the connection state is derived from the active server or lack thereof.
                  'Server IP Address/Port\n${controller.activeServer.value!.ipAddress}:${controller.activeServer.value!.portNumber}\n\n'
                      'Display Name: ${controller.activeServer.value!.displayName}',
                  context
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.textForegroundOrange,
                size: 42,
              ),
            );
          }
        }),
        const SizedBox(width: 20,)
      ]
    );
  }

  // Code found on https://dev-yakuza.posstree.com/en/flutter/getx/dialog/
  void _openServerDialog(String title, String body, BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.navigationBackgroundPink,
        title: Text(title, style: Theme.of(context).textTheme.labelMedium),
        content: Text(body, style: Theme.of(context).textTheme.labelSmall),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

}