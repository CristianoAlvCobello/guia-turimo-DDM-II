import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/favoritos_controller.dart';
import '../models/lugares_model.dart';
import '../services/gps_service.dart';
import '../services/lugares_services.dart';

class MapaScreen extends StatefulWidget {
  final List<LugaresModel> lugares;
  final LugaresModel? lugarSelecionado;

  const MapaScreen({
    super.key,
    required this.lugares,
    this.lugarSelecionado,
  });

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _mapa = MapController();
  StreamSubscription<Position>? _assinatura;
  Position? _posicao;

  @override
  void initState() {
    super.initState();
    _iniciarGps();
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }

  Future<void> _iniciarGps() async {
    try {
      final gps = GpsService();
      await gps.permitir();
      final atual = await gps.posicaoAtual();
      if (!mounted) return;
      setState(() => _posicao = atual);
      _assinatura = gps.acompanhar().listen((posicao) {
        if (mounted) setState(() => _posicao = posicao);
      });
    } catch (erro) {
      if (!mounted) return;
      _aviso(erro.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _irParaMinhaLocalizacao() {
    final posicao = _posicao;
    if (posicao == null) {
      _aviso('Localização ainda não encontrada.');
      return;
    }
    _mapa.move(LatLng(posicao.latitude, posicao.longitude), 15);
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final lugares = widget.lugares;
    final lugarSelecionado = widget.lugarSelecionado;
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
          mapController: _mapa,
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
            if (_posicao != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_posicao!.latitude, _posicao!.longitude),
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton.small(
            tooltip: 'Minha localização',
            onPressed: _irParaMinhaLocalizacao,
            child: const Icon(Icons.my_location),
          ),
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
    final posicao = _posicao;
    final distancia = posicao == null
        ? null
        : GpsService.formatarDistancia(GpsService.distanciaEmMetros(
            posicao.latitude, posicao.longitude, lugar.latitude, lugar.longitude));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(lugar.nome, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Consumer<FavoritosController>(
                    builder: (context, favoritos, _) => IconButton(
                      tooltip: 'Favoritar',
                      onPressed: () => favoritos.alternar(lugar.id),
                      icon: Icon(
                        favoritos.ehFavorito(lugar.id) ? Icons.favorite : Icons.favorite_border,
                        color: favoritos.ehFavorito(lugar.id) ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(lugar.categoria ?? 'Sem categoria'),
              if ((lugar.descricao ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(lugar.descricao!),
              ],
              const SizedBox(height: 12),
              _FotosLugar(lugar: lugar),
              const SizedBox(height: 8),
              Text('Latitude: ${lugar.latitude}  |  Longitude: ${lugar.longitude}'),
              if (distancia != null) ...[
                const SizedBox(height: 4),
                Text('Distância: $distancia'),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _comoChegar(lugar),
                  icon: const Icon(Icons.directions),
                  label: const Text('Como chegar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _comoChegar(LugaresModel lugar) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${lugar.latitude},${lugar.longitude}',
    );
    final abriu = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!abriu && mounted) _aviso('Não foi possível abrir o aplicativo de mapas.');
  }
}

class _FotosLugar extends StatefulWidget {
  final LugaresModel lugar;

  const _FotosLugar({required this.lugar});

  @override
  State<_FotosLugar> createState() => _FotosLugarState();
}

class _FotosLugarState extends State<_FotosLugar> {
  late final Future<List<String>> _fotos = widget.lugar.fotos.isNotEmpty
      ? Future.value(widget.lugar.fotos)
      : LugaresServices().buscarFotos(widget.lugar.id);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fotos,
      builder: (context, resultado) {
        if (resultado.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final fotos = resultado.data ?? [];
        if (fotos.isEmpty) return const Text('Sem fotos cadastradas');
        return SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fotos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, indice) => Image.network(
              fotos[indice],
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                width: 150,
                child: Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
        );
      },
    );
  }
}
