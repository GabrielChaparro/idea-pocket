import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../tags/tag.dart';
import '../tags/tag_manager_dialog.dart';
import 'item.dart';
import 'item_editor_sheet.dart';
import 'item_tile.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key, required this.token, required this.onLogout});

  final String token;
  final VoidCallback onLogout;

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late final ApiClient api;
  final search = TextEditingController();
  List<Item> items = [];
  List<Tag> tags = [];
  bool loading = true;
  String? error;
  String? type;
  String? status;
  String? tagId;

  @override
  void initState() {
    super.initState();
    api = ApiClient(widget.token);
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final nextTags = await api.tags();
      final nextItems = await api.items(type: type, status: status, search: search.text, tagId: tagId);
      setState(() {
        tags = nextTags;
        items = nextItems;
      });
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> create() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemEditorSheet(api: api, tags: tags),
    );
    if (created == true) load();
  }

  Future<void> edit(Item item) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemEditorSheet(api: api, tags: tags, item: item),
    );
    if (updated == true) load();
  }

  Future<void> manageTags() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => TagManagerDialog(api: api, initialTags: tags),
    );

    if (changed == true) {
      load();
    }
  }

  Future<void> completeItem(Item item) async {
    try {
      await api.complete(item.id, item.status == 'COMPLETED');
      load();
    } catch (e) {
      showError(e);
    }
  }

  Future<void> deleteItem(Item item) async {
    try {
      await api.delete(item.id);
      load();
    } catch (e) {
      showError(e);
    }
  }

  void showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(error))));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;
    return Scaffold(
      appBar: AppBar(
        title: const Text('IdeaPocket'),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh), tooltip: 'Actualizar'),
          IconButton(onPressed: manageTags, icon: const Icon(Icons.label_outline), tooltip: 'Etiquetas'),
          IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout), tooltip: 'Salir'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: create,
        icon: const Icon(Icons.add),
        label: const Text('Capturar'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 1100 : 640),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        labelText: 'Buscar',
                        suffixIcon: IconButton(onPressed: load, icon: const Icon(Icons.arrow_forward)),
                      ),
                      onSubmitted: (_) => load(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(label: const Text('Ideas'), selected: type == 'IDEA', onSelected: (_) => _setType('IDEA')),
                        FilterChip(label: const Text('Notas'), selected: type == 'NOTE', onSelected: (_) => _setType('NOTE')),
                        FilterChip(label: const Text('Tareas'), selected: type == 'TASK', onSelected: (_) => _setType('TASK')),
                        FilterChip(
                          label: const Text('Completadas'),
                          selected: status == 'COMPLETED',
                          onSelected: (_) => _setStatus('COMPLETED'),
                        ),
                        for (final tag in tags)
                          FilterChip(
                            label: Text(tag.name),
                            selected: tagId == tag.id,
                            onSelected: (_) => _setTag(tag.id),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(error!, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    onPressed: load,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reintentar'),
                                  ),
                                ],
                              ),
                            ),
                          )
                    : items.isEmpty
                        ? const Center(child: Text('Sin registros todavía'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) => ItemTile(
                              item: items[index],
                              onEdit: () => edit(items[index]),
                              onComplete: () => completeItem(items[index]),
                              onDelete: () => deleteItem(items[index]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setType(String value) {
    setState(() => type = type == value ? null : value);
    load();
  }

  void _setStatus(String value) {
    setState(() => status = status == value ? null : value);
    load();
  }

  void _setTag(String value) {
    setState(() => tagId = tagId == value ? null : value);
    load();
  }
}
