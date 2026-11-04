import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controller/categorias_controller.dart';
import '../controller/lugares_controller.dart';
import '../models/lugares_model.dart';
import '../services/localizacao_service.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  final _formulario = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _endereco = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  int? _categoriaId;
  bool _buscando = false;
  String? _enderecoEncontrado;
  Uint8List? _foto;
  String? _nomeFoto;

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _endereco.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  Future<void> _buscarEndereco() async {
    String busca;
    try {
      busca = LocalizacaoService.prepararBusca(_endereco.text);
    } catch (erro) {
      _aviso(erro.toString().replaceFirst('Exception: ', ''));
      return;
    }

    _endereco.value = TextEditingValue(
      text: busca,
      selection: TextSelection.collapsed(offset: busca.length),
    );

    setState(() => _buscando = true);
    try {
      final local = await LocalizacaoService().buscar(busca);
      if (!mounted) return;
      if (local == null) {
        _aviso('Endereço não encontrado');
        return;
      }
      setState(() {
        _latitude.text = local.latitude.toStringAsFixed(6);
        _longitude.text = local.longitude.toStringAsFixed(6);
        _enderecoEncontrado = local.endereco;
      });
    } catch (erro) {
      if (!mounted) return;
      _aviso('Erro na busca: ${erro.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _selecionarFoto(ImageSource origem) async {
    try {
      final imagem = await ImagePicker().pickImage(
        source: origem,
        imageQuality: 75,
        maxWidth: 1200,
      );
      if (imagem == null) return;
      final bytes = await imagem.readAsBytes();
      if (!mounted) return;
      setState(() {
        _foto = bytes;
        _nomeFoto = imagem.name;
      });
    } catch (_) {
      if (mounted) _aviso('Não foi possível selecionar a foto.');
    }
  }

  String? _validarCoordenada(String? texto, bool latitude) {
    final numero = double.tryParse((texto ?? '').replaceAll(',', '.'));
    if (numero == null) return 'Informe um número';
    if (latitude && (numero < -90 || numero > 90)) return 'Entre -90 e 90';
    if (!latitude && (numero < -180 || numero > 180)) return 'Entre -180 e 180';
    return null;
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;
    if (_categoriaId == null) {
      _aviso('Escolha uma categoria');
      return;
    }
    final controle = context.read<LugaresController>();

    final lugar = LugaresModel(
      id: 0,
      nome: _nome.text.trim(),
      descricao: _descricao.text.trim(),
      categoriaId: _categoriaId!,
      latitude: double.parse(_latitude.text.replaceAll(',', '.')),
      longitude: double.parse(_longitude.text.replaceAll(',', '.')),
    );

    final salvou = await controle.cadastrarLugar(
      lugar,
      foto: _foto,
      nomeFoto: _nomeFoto,
    );
    if (!mounted) return;
    _aviso(controle.mensagem);
    if (salvou) {
      await controle.listaLugares();
      if (mounted) Navigator.pop(context);
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<CategoriasController>();
    final lugares = context.watch<LugaresController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar lugar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dados do lugar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome do lugar'),
                validator: (texto) => (texto ?? '').trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
                validator: (texto) => (texto ?? '').trim().isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 12),
              if (categorias.carregando)
                const Center(child: CircularProgressIndicator())
              else if (categorias.erro.isNotEmpty || categorias.categorias.isEmpty)
                TextButton.icon(
                  onPressed: categorias.listaCategorias,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar carregar categorias novamente'),
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _categoriaId,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: categorias.categorias.map((categoria) => DropdownMenuItem(
                    value: categoria.id,
                    child: Text(categoria.nome),
                  )).toList(),
                  onChanged: (id) => setState(() => _categoriaId = id),
                  validator: (id) => id == null ? 'Escolha uma categoria' : null,
                ),
              const SizedBox(height: 24),
              const Text('Localização', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Digite um endereço ou CEP'),
              const SizedBox(height: 12),
              TextField(
                controller: _endereco,
                onChanged: (texto) {
                  final formatado = LocalizacaoService.formatarCepParcial(texto);
                  if (formatado != texto) {
                    _endereco.value = TextEditingValue(
                      text: formatado,
                      selection: TextSelection.collapsed(offset: formatado.length),
                    );
                  }
                  _latitude.clear();
                  _longitude.clear();
                  setState(() => _enderecoEncontrado = null);
                },
                decoration: const InputDecoration(
                  labelText: 'Endereço ou CEP',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _buscando ? null : _buscarEndereco,
                icon: _buscando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.search),
                label: const Text('Buscar coordenadas'),
              ),
              if (_enderecoEncontrado != null) ...[
                const SizedBox(height: 8),
                Text('Encontrado: $_enderecoEncontrado', style: const TextStyle(color: Colors.green)),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitude,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (texto) => _validarCoordenada(texto, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitude,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (texto) => _validarCoordenada(texto, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Foto (opcional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_foto != null) ...[
                Image.memory(_foto!, height: 150, width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 8),
              ],
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _selecionarFoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text('Galeria'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _selecionarFoto(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                  child: ElevatedButton(
                  onPressed: lugares.carregando || _buscando ? null : _salvar,
                  child: lugares.carregando
                      ? const CircularProgressIndicator()
                      : const Text('Salvar lugar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
