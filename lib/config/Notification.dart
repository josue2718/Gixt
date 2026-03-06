import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gixt/components/alertExpress.dart';
import 'package:gixt/config/Notifiers/express_notifiers.dart';

void handleNotification(
  BuildContext context,
  Map<String, dynamic> data,
  RemoteNotification? notification,
) {
  print("🔔 Notificación recibida:");
  print("Title: ${notification?.title}");
  print("Body: ${notification?.body}");
  print("Data: $data");

  /// 🔥 EXPRESS
  if (data['serviceType'] == 'express') {
    mostrarDialogExpress(
       id: data['expressid'],
    title: "Nueva Propuesta",
    worker_id: data['workerid'],
    message: "${data['username']} A propuesto por ${data['price']}",
    );
  }

  if (data['type'] == 'Express') {
    expressStatusNotifier.refresh();
  }
}

