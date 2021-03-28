import 'dart:io';

import 'package:yaml/yaml.dart';

YamlMap config;
String hostname;

void loadConfig() {
  config = loadYaml(File('config.yaml').readAsStringSync())['gemini'];
  hostname = 'gemini://${config['hostname']}' +
      (config['port'] != 1965 ? ':${config['port']}' : '');
}

void createServer() async {
  loadConfig();
  final server = await SecureServerSocket.bind(
      config['hostname'],
      config['port'],
      SecurityContext()
        ..useCertificateChain('static/cert.pem')
        ..usePrivateKey('static/key.pem', password: config['password']));
  server.listen(serve);
}

void serve(SecureSocket socket) {
  socket.listen((data) {
    final address = String.fromCharCodes(data);
    final pageContent = handleRequest(address);
    socket.write('${pageContent[0]}\r\n${pageContent[1]}');
    socket.close();
  });
}

List<String> handleRequest(String url) {
  try {
    var path = Uri.parse(url).path.replaceAll('%0D', '').replaceAll('%0A', '');
    if (path.endsWith('pem')) return ['40 Temporary Failure', ''];
    path += path.endsWith('/') ? 'index.gmi' : '';
    print(path);
    var f = File('static$path');
    if (!f.existsSync() && Directory('static$path').existsSync()) {
      if (!path.endsWith('/')) return ['31 $hostname$path/', ''];
      if (!f.existsSync()) return ['51 Not found!', ''];
    } else if (!f.existsSync()) return ['51 Not found!', ''];
    var fileContent = f.readAsStringSync();
    fileContent =
        fileContent.codeUnits.last != 0x0a ? fileContent + '\n' : fileContent;
    return ['20 text/gemini', fileContent];
  } on Exception {
    return ['50 Permanent failure!', ''];
  }
}
