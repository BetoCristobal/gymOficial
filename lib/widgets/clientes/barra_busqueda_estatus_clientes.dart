import 'package:flutter/material.dart';

class BarraBusquedaEstatusClientes extends StatefulWidget {
  final Function(String) onSearchChanged;
  const BarraBusquedaEstatusClientes({super.key, required this.onSearchChanged});
  

  @override
  State<BarraBusquedaEstatusClientes> createState() => _BarraBusquedaEstatusClientesState();
}

class _BarraBusquedaEstatusClientesState extends State<BarraBusquedaEstatusClientes> {

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Reconstruye el widget cuando cambia el texto
    });
  }

  void _clearSearchText() {
    _searchController.clear();
    widget.onSearchChanged('');
    _searchController.selection = TextSelection.collapsed(offset: 0);
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
                autofocus: true,
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: "Buscar...",
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearchText, icon: const Icon(Icons.clear, color: Colors.white,)
                      )
                    : null ,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white)
                  ),
                ),
                onChanged: widget.onSearchChanged
              ),
    );
  }
}