import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../core/app_theme.dart';
import '../core/retro_panel.dart';
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
  String? dueFilter;
  String order = 'CREATED_DESC';

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
      final dueRange = currentDueRange;
      final nextTags = await api.tags();
      final nextItems = await api.items(
        type: type,
        status: status,
        search: search.text,
        tagId: tagId,
        dueFrom: dueRange?.from,
        dueTo: dueRange?.to,
        order: order,
      );
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
    final confirmed = await confirmDelete(
      title: 'BORRAR REGISTRO',
      message: item.title?.isNotEmpty == true ? item.title! : item.content,
    );
    if (!confirmed) return;

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

  Future<bool> confirmDelete({required String title, required String message}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: retroRed)),
        content: Text(
          'Esta acción no se puede deshacer.\n\n$message',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar'),
          ),
        ],
      ),
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;
    return Scaffold(
      appBar: AppBar(
        title: const Text('IDEAPOCKET'),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: RetroPanel(
              color: const Color(0xFF7D8CC4),
              padding: const EdgeInsets.all(12),
              shadow: false,
              child: Column(
                children: [
                  Container(
                    width: 78,
                    height: 8,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: retroInk,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  RetroScreen(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 10, color: retroRed),
                        const SizedBox(width: 8),
                        Text(
                          '${items.length.toString().padLeft(2, '0')} REGISTROS',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          loading ? 'SYNC...' : 'READY',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        labelText: 'Buscar',
                        suffixIcon: IconButton(onPressed: load, icon: const Icon(Icons.arrow_forward)),
                      ),
                      onSubmitted: (_) => load(),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'CREATED_DESC', label: Text('Recientes'), icon: Icon(Icons.history)),
                        ButtonSegment(value: 'DUE_ASC', label: Text('Vence'), icon: Icon(Icons.event)),
                        ButtonSegment(value: 'PRIORITY_DESC', label: Text('Prioridad'), icon: Icon(Icons.priority_high)),
                      ],
                      selected: {order},
                      onSelectionChanged: (value) => _setOrder(value.first),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(label: const Text('Ideas'), selected: type == 'IDEA', onSelected: (_) => _setType('IDEA')),
                        FilterChip(label: const Text('Notas'), selected: type == 'NOTE', onSelected: (_) => _setType('NOTE')),
                        FilterChip(label: const Text('Tareas'), selected: type == 'TASK', onSelected: (_) => _setType('TASK')),
                        FilterChip(
                          label: const Text('Pendientes'),
                          selected: status == 'ACTIVE',
                          onSelected: (_) => _setStatus('ACTIVE'),
                        ),
                        FilterChip(
                          label: const Text('Completadas'),
                          selected: status == 'COMPLETED',
                          onSelected: (_) => _setStatus('COMPLETED'),
                        ),
                        FilterChip(
                          label: const Text('Hoy'),
                          selected: dueFilter == 'TODAY',
                          onSelected: (_) => _setDueFilter('TODAY'),
                        ),
                        FilterChip(
                          label: const Text('Vencidas'),
                          selected: dueFilter == 'OVERDUE',
                          onSelected: (_) => _setDueFilter('OVERDUE'),
                        ),
                        for (final tag in tags)
                          FilterChip(
                            label: Text(tag.name),
                            selected: tagId == tag.id,
                            onSelected: (_) => _setTag(tag.id),
                          ),
                        if (hasActiveFilters)
                          ActionChip(
                            avatar: const Icon(Icons.close, size: 16),
                            label: const Text('Limpiar'),
                            onPressed: clearFilters,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: loading
                          ? const Center(child: CircularProgressIndicator())
                          : error != null
                              ? Center(
                                  child: RetroScreen(
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
                                  ? Center(
                                      child: RetroScreen(
                                        shadow: false,
                                        child: Text(
                                          emptyMessage,
                                          style: const TextStyle(fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 96),
                                      itemCount: items.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                                      itemBuilder: (context, index) => ItemTile(
                                        item: items[index],
                                        onEdit: () => edit(items[index]),
                                        onComplete: () => completeItem(items[index]),
                                        onDelete: () => deleteItem(items[index]),
                                      ),
                                    ),
                    ),
                  ),
                ],
              ),
            ),
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

  void _setDueFilter(String value) {
    setState(() {
      dueFilter = dueFilter == value ? null : value;
      if (value == 'OVERDUE' && dueFilter == 'OVERDUE') {
        status = 'ACTIVE';
      }
    });
    load();
  }

  void _setOrder(String value) {
    setState(() => order = value);
    load();
  }

  bool get hasActiveFilters =>
      type != null || status != null || tagId != null || dueFilter != null || search.text.trim().isNotEmpty;

  String get emptyMessage => hasActiveFilters ? 'Sin resultados para estos filtros' : 'Sin registros todavía';

  void clearFilters() {
    setState(() {
      type = null;
      status = null;
      tagId = null;
      dueFilter = null;
      search.clear();
    });
    load();
  }

  DueRange? get currentDueRange {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    return switch (dueFilter) {
      'TODAY' => DueRange(todayStart, tomorrowStart),
      'OVERDUE' => DueRange(null, now),
      _ => null,
    };
  }
}

class DueRange {
  DueRange(this.from, this.to);

  final DateTime? from;
  final DateTime? to;
}
