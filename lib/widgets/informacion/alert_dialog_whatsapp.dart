import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/utils/enviar%20whatsapp.dart';

import 'package:mygym/utils/mensaje_personalizado.dart';
import 'package:shared_preferences/shared_preferences.dart';


void alertDialogWhatsApp(BuildContext context, DateTime proximoPago, String telefono) {
  showDialog(
    context: context,
    builder: (context) {
      return _AlertDialogWhatsAppContent(proximoPago: proximoPago, telefono: telefono);
    },
  );
}

class _AlertDialogWhatsAppContent extends StatefulWidget {
  final DateTime proximoPago;
  final String telefono;
  const _AlertDialogWhatsAppContent({required this.proximoPago, required this.telefono});

  @override
  State<_AlertDialogWhatsAppContent> createState() => _AlertDialogWhatsAppContentState();
}

class _AlertDialogWhatsAppContentState extends State<_AlertDialogWhatsAppContent> {
  List<MensajePersonalizado> mensajes = [];
  int? seleccionado;
  TextEditingController mensajeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
  }

  Future<void> _cargarMensajes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.get('mensajes_personalizados');
    String? data;
    if (raw is String) {
      data = raw;
    } else {
      // Si es una lista antigua, ignórala y borra la clave
      if (raw is List) {
        await prefs.remove('mensajes_personalizados');
      }
      data = null;
    }
    setState(() {
      mensajes = data != null && data.isNotEmpty
          ? MensajePersonalizado.decodeList(data)
          : [
              MensajePersonalizado(titulo: 'Recordar pago', mensaje: 'Hola, recuerda que tu próximo pago es el ${_formatearFecha(widget.proximoPago)}.'),
              MensajePersonalizado(titulo: 'Promoción', mensaje: '¡Aprovecha nuestra promoción especial!'),
            ];
    });
  }

  Future<void> _guardarMensajes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mensajes_personalizados', MensajePersonalizado.encodeList(mensajes));
  }

  String _formatearFecha(DateTime fecha) {
    if (fecha.isBefore(DateTime(1901, 1, 1))) return 'próximamente';
    return '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';
  }

  void _onChipSelected(int? idx) {
    setState(() {
      seleccionado = idx;
      if (idx != null) {
        final raw = mensajes[idx].mensaje;
        final texto = raw.contains('{proximo_pago}')
            ? raw.replaceAll('{proximo_pago}', _formatearFecha(widget.proximoPago))
            : raw;
        mensajeController.text = texto;
      }
    });
  }

  void _agregarOModificarMensaje({int? idx}) async {
    final tituloController = TextEditingController(text: idx != null ? mensajes[idx].titulo : '');
    final mensajeEditController = TextEditingController(text: idx != null ? mensajes[idx].mensaje : '');
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(idx == null ? 'Agregar mensaje' : 'Editar mensaje'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: mensajeEditController,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(labelText: 'Mensaje'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: Icon(Icons.date_range, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 90, 99, 224),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  const variable = '{proximo_pago}';
                  final text = mensajeEditController.text;
                  final selection = mensajeEditController.selection;
                  final newText = text.replaceRange(
                    selection.start >= 0 ? selection.start : text.length,
                    selection.end >= 0 ? selection.end : text.length,
                    variable,
                  );
                  mensajeEditController.text = newText;
                  mensajeEditController.selection = TextSelection.collapsed(offset: (selection.start >= 0 ? selection.start : text.length) + variable.length);
                },
                label: Text('Agregar variable proximo pago'),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (idx != null)
                ElevatedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Eliminar mensaje'),
                        content: Text('¿Seguro que deseas eliminar este mensaje?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      Navigator.pop(context, {'eliminar': 'true'});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              if (idx == null)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
              ElevatedButton(
                onPressed: () {
                  if (tituloController.text.trim().isEmpty || mensajeEditController.text.trim().isEmpty) return;
                  Navigator.pop(context, {
                    'titulo': tituloController.text.trim(),
                    'mensaje': mensajeEditController.text.trim(),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
    if (result != null) {
      if (result['eliminar'] == 'true' && idx != null) {
        setState(() {
          mensajes.removeAt(idx);
          if (seleccionado == idx) {
            seleccionado = null;
            mensajeController.clear();
          } else if (seleccionado != null && seleccionado! > idx) {
            seleccionado = seleccionado! - 1;
          }
        });
        await _guardarMensajes();
        return;
      }
      setState(() {
        if (idx != null) {
          mensajes[idx] = MensajePersonalizado(titulo: result['titulo']!, mensaje: result['mensaje']!);
          if (seleccionado == idx) mensajeController.text = result['mensaje']!;
        } else {
          mensajes.add(MensajePersonalizado(titulo: result['titulo']!, mensaje: result['mensaje']!));
        }
      });
      await _guardarMensajes();
    }
  }

  bool get _isCursorActive {
    final selection = mensajeController.selection;
    return selection.start >= 0 && selection.end >= 0;
  }

  void _updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Elige un mensaje:"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ...List.generate(mensajes.length, (i) => ChoiceChip(
                  label: Text(mensajes[i].titulo, style: TextStyle(color: Colors.green[800])),
                  selected: seleccionado == i,
                  checkmarkColor: Colors.green[800],
                  selectedColor: Colors.green[100],
                  onSelected: (selected) {
                    _onChipSelected(selected ? i : null);
                  },
                )),
                ActionChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.add, size: 18), Text(' Nuevo')],
                  ),
                  onPressed: () => _agregarOModificarMensaje(),
                ),
              ],
            ),
            if (seleccionado != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.green[800]),
                  tooltip: 'Editar mensaje',
                  onPressed: () => _agregarOModificarMensaje(idx: seleccionado),
                ),
              ),
            Focus(
              onFocusChange: (_) => _updateState(),
              child: TextField(
                controller: mensajeController,
                minLines: 6,
                maxLines: 10,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                onTap: _updateState,
                onChanged: (_) => _updateState(),
                onEditingComplete: _updateState,
                onSubmitted: (_) => _updateState(),
              ),
            ),
            SizedBox(height: 8),
            // Botón de agregar variable fecha eliminado de aquí
            Container(
              padding: EdgeInsets.only(top: 10.0),
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(FontAwesomeIcons.paperPlane, color: Colors.green[900]),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[200]),
                onPressed: () {
                  final texto = mensajeController.text.replaceAll(
                    '{proximo_pago}',
                    _formatearFecha(widget.proximoPago),
                  );
                  enviarWhatsapp(widget.telefono, texto);
                },
                label: Text("Enviar", style: TextStyle(color: Colors.green[900])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}