import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
// external packages
import 'package:args/args.dart';
import 'package:logging/src/level.dart';

// @platform packages
import 'package:at_utils/at_logger.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:hive/hive.dart';



void main(List<String> args) async {
  int port = 64;
  String atServers = 'atServers';
  String fullChain = 'fullchain.pem';
  String privKey = 'privkey.pem';
  final AtSignLogger logger = AtSignLogger(' shr ');

  // Have an argumnent :-)
  var parser = ArgParser();
  // Basic arguments
  parser.addOption('port',
      abbr: 'p',
      mandatory: false,
      defaultsTo: '64',
      help: 'TCP port number to listen on');
  parser.addOption('config',
      abbr: 'c',
      mandatory: false,
      defaultsTo: 'atServers',
      help: 'configuration file for local atServers');
  parser.addOption('ssl-fullchain',
      abbr: 'f',
      mandatory: false,
      defaultsTo: 'fullchain.pem',
      help: 'SSL certificate file in pem format');
  parser.addOption('ssl-privkey',
      abbr: 'k',
      mandatory: false,
      defaultsTo: 'privkey.pem',
      help: 'SSL private key file in pem format');
  // Flags
  parser.addFlag('verbose', abbr: 'v', help: 'More logging');

  // Get args into variables
  try {
    var results = parser.parse(args);
    port = int.parse(results['port']);
    atServers = results['config'];
    fullChain = results['ssl-fullchain'];
    privKey = results['ssl-privkey'];

    // Get logging at the right level -v = INFO
    logger.logger.level = Level.SEVERE;
    if (results['verbose']) {
      logger.logger.level = Level.INFO;
    }
  } catch (e) {
    print(e.toString());
    print(parser.usage);
    exit(1);
  }

  // Get hiveDB up and running
  var box = await Hive.openBox('rootBox', path: './');
  await loadBox(box, atServers, logger);

  // re-load hiveDB if we see a SIGHUP
  ProcessSignal.sighup.watch().listen((signal) async {
    await loadBox(box, atServers, logger);
    logger.info(' caught SIGHUP reloading atServer Database');
  });

  var secCon = SecurityContext();
  try {
    secCon.useCertificateChain(fullChain);
    secCon.usePrivateKey(privKey);
  } catch (e) {
    logger.severe(' Error with SSL Certificates');
    exit(1);
  }

  await SecureServerSocket.bind(InternetAddress.anyIPv4, 64, secCon,
          requestClientCertificate: false)
      .then((SecureServerSocket secSocket) {
    secSocket.listen((connection) {
      var send = utf8.encode("@");
      connection.add(send);
      connection.listen((Uint8List data) async {
        final message = utf8.decode(data);
        bool atExit = false;
        String atsign = message.trim();
        if (atsign == '' || atsign == '@exit' || atsign.length > 255) {
          connection.destroy();
          atExit = true;
        }
        if(atExit){
          logger.info(' client sent @exit');
        }else{
        var stuff = box.get(atsign);
        if (stuff == null) {
          connection.writeln(await rootLookup(atsign, logger));
        } else {
          connection.writeln(stuff);
          logger.info(' Local lookup for: $atsign');
        }
        var send = utf8.encode("@");
        connection.add(send);
      }}, onError: (error) {
        logger.severe(' Error on port ${port.toString()}');
        logger.severe(error.toString());
      });
    });
  });
}

Future<String> rootLookup(String atsign, AtSignLogger logger) async {
  var atLookupImpl = AtLookupImpl('', 'root.atsign.org', 64);
  SecondaryAddress secondaryAddress;
  SecondaryAddressFinder secondaryAddressFinder;
  logger.info(' Upstream lookup for: $atsign');
  try {
    secondaryAddressFinder = atLookupImpl.secondaryAddressFinder;

    secondaryAddress = await secondaryAddressFinder.findSecondary(atsign);
  } catch (e) {
    return ('null');
  }

  return ('${secondaryAddress.host}:${secondaryAddress.port}');
}

Future<void> loadBox(Box box, String atServers, AtSignLogger logger) async {
  await box.clear();
  File file = File(atServers);
  bool fileError = false;

// test atServer file for errors
  List<String> lines = file.readAsLinesSync();
  try {
    for (var line in lines) {
      // Allow Comments with leading #
      if (!line.trimLeft().startsWith('#')) {
        line.split(RegExp(r'\s+'));
      }
    }
  } catch (e) {
    logger.info(e.toString());
    logger.info('Format error in atServers file');
    fileError = true;
  }

  if (!fileError) {
    try {
      for (var line in lines) {
        // Allow Comments with leading #
        if (!line.trimLeft().startsWith('#')) {
          var atsign = line.split(RegExp(r'\s+'));
          await box.put(atsign[0], atsign[1]);
        }
      }
    } catch (e) {
      logger.severe(e.toString());
      logger.severe('Format error in atServers file');
      await box.close();
      exit(-1);
    }
  }
}
