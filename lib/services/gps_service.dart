import 'package:geolocator/geolocator.dart';

class GpsService {
  Future<void> permitir() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Ative o GPS do aparelho.');
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada.');
    }
  }

  Future<Position> posicaoAtual() async {
    await permitir();
    return Geolocator.getCurrentPosition();
  }

  Stream<Position> acompanhar() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  static double distanciaEmMetros(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static String formatarDistancia(double metros) {
    if (metros < 1000) return '${metros.round()} m';
    return '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  }
}
