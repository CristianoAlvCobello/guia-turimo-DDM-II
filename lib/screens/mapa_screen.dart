import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/lugares_model.dart';

class MapaScreen extends StatelessWidget {
  final List<LugaresModel> lugares;
  final LugaresModel? lugarSelecionado;

  const MapaScreen({
    super.key,
    required this.lugares,
    this.lugarSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    final validos = lugares.where((lugar) =>
        lugar.latitude >= -90 && lugar.latitude <= 90 &&
        lugar.longitude >= -180 && lugar.longitude <= 180 &&
        !(lugar.latitude == 0 && lugar.longitude == 0)).toList();

    final destaque = validos.any((l) => l.id == lugarSelecionado?.id)
        ? lugarSelecionado
        : null;
    final pontos = validos.map((l) => LatLng(l.latitude, l.longitude)).toList();
    final opcoes = destaque != null
        ? MapOptions(
            initialCenter: LatLng(destaque.latitude, destaque.longitude),
            initialZoom: 14,
          )
        : pontos.toSet().length > 1
            ? MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints(pontos),
                  padding: const EdgeInsets.all(55),
                ),
              )
            : MapOptions(
                initialCenter: validos.isNotEmpty
                    ? LatLng(validos.first.latitude, validos.first.longitude)
                    : const LatLng(-15.8, -47.9),
                initialZoom: validos.isNotEmpty ? 13 : 11,
              );

    return Stack(
      children: [
        FlutterMap(
          options: opcoes,
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.turistero',
            ),
            MarkerLayer(
              markers: validos.map((lugar) => Marker(
                point: LatLng(lugar.latitude, lugar.longitude),
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: lugar.nome,
                  icon: const Icon(Icons.location_pin, size: 38),
                  color: Colors.blue,
                  onPressed: () => _mostrarLugar(context, lugar),
                ),
              )).toList(),
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
        if (validos.isEmpty)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Nenhum lugar com coordenadas para mostrar. Cadastre um lugar primeiro.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _mostrarLugar(BuildContext context, LugaresModel lugar) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lugar.nome, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(lugar.categoria ?? 'Sem categoria'),
              if ((lugar.descricao ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(lugar.descricao!),
              ],
              const SizedBox(height: 8),
              Text('Latitude: ${lugar.latitude}  |  Longitude: ${lugar.longitude}'),
            ],
          ),
        ),
      ),
    );
  }
}
