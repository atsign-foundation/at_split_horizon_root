import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_commons/at_commons.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:hive/hive.dart';

void main() async {
  var box = await Hive.openBox('rootBox', path: './');

  await loadBox(box);

  // re-load hiveDB if we see a SIGHUP
  ProcessSignal.sighup.watch().listen((signal) async {
    await loadBox(box);
    print('reloadingbox');
  });

  var secCon = SecurityContext();
  secCon.useCertificateChain('fullchain.pem');
  secCon.usePrivateKey('privkey.pem');
  secCon.setTrustedCertificates('cacert.pem');

  await SecureServerSocket.bind(InternetAddress.anyIPv4, 64, secCon,
          requestClientCertificate: false)
      .then((SecureServerSocket secSocket) {
    secSocket.listen((connection) {
      var send = utf8.encode("@");
      connection.add(send);
      connection.listen((Uint8List data) async {
        final message = utf8.decode(data);
        if (message.trim() == '' || message.length > 257) {
          connection.destroy();
        }
        var stuff = box.get(message.trim());
        if (stuff == null) {
          connection.writeln(await rootLookup(message.trim()));
        } else {
          connection.writeln(stuff);
        }
        var send = utf8.encode("@");
        connection.add(send);
      }, onError: (error) {
        print(error.toString());
      });
    });
  });
}

Future<String> rootLookup(String atsign) async {
  var atLookupImpl = AtLookupImpl('', 'root.atsign.org', 64);
  SecondaryAddress secondaryAddress;
  SecondaryAddressFinder secondaryAddressFinder;
  print(">$atsign<");
  try {
    secondaryAddressFinder = atLookupImpl.secondaryAddressFinder;

    secondaryAddress = await secondaryAddressFinder.findSecondary(atsign);
  } catch (e) {
    return ('null');
  }

  return ('${secondaryAddress.host}:${secondaryAddress.port}');
}

/// TODO  Catch SIGHUP and reload DB for updates to file
/// Find out why we need dummy data else the first put does not work ??
///
Future<void> loadBox(Box box) async {
  await box.clear();
  File file = File('./atServers');

  List<String> lines = file.readAsLinesSync();
  try {
    for (var line in lines) {
      var atsign = line.split(RegExp(r'\s+'));
      await box.put(atsign[0], atsign[1]);
    }
  } catch (e) {
    print(e.toString());
    print('Format error in atsigns file');
    await box.close();
    exit(-1);
  }
}
