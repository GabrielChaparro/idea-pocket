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
  final quickCapture = TextEditingController();
  List<Item> items = [];
  List<Tag> tags = [];
  bool loading = true;
  bool quickSaving = false;
  String? error;
  String? type;
  String? status;
  String? tagId;
  String? dueFilter;
  String order = 'CREATED_DESC';
  bool todayMode = false;

  @override
  void initState() {
    super.initState();
    api = ApiClient(widget.token);
    load();
  }

  @override
  void dispose() {
    search.dispose();
    quickCapture.dispose();
    super.dispose();
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
        type: todayMode ? null : type,
        status: todayMode ? 'ACTIVE' : status,
        search: search.text,
        tagId: todayMode ? null : tagId,
        dueFrom: todayMode ? null : dueRange?.from,
        dueTo: todayMode ? null : dueRange?.to,
        order: todayMode ? 'DUE_ASC' : order,
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

  Future<void> submitQuickCapture() async {
    final raw = quickCapture.text.trim();
    if (raw.isEmpty || quickSaving) return;

    setState(() => quickSaving = true);
    try {
      final draft = QuickCaptureDraft.parse(raw, tags);
      await api.createItem(
        type: draft.type,
        title: null,
        content: draft.content,
        priority: draft.priority,
        dueDate: draft.dueDate,
        tagIds: draft.tagIds,
      );
      quickCapture.clear();
      await load();
    } catch (e) {
      showError(e);
    } finally {
      if (mounted) setState(() => quickSaving = false);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage(error))));
  }

  Future<bool> confirmDelete({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, color: retroRed),
        ),
        content: Text(
          'Esta acción no se puede deshacer.\n\n$message',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
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
        title: const Text('FARODECK'),
        actions: [
          IconButton(
            onPressed: load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
          IconButton(
            onPressed: manageTags,
            icon: const Icon(Icons.label_outline),
            tooltip: 'Etiquetas',
          ),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Salir',
          ),
        ],
      ),
      floatingActionButton: _ArcadeCaptureButton(onPressed: create),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [arcadeNight, Color(0xFF27377E), Color(0xFF132A3A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 1100 : 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: RetroPanel(
                color: arcadeCabinet,
                padding: const EdgeInsets.all(12),
                shadow: false,
                child: Column(
                  children: [
                    const _ArcadeMarquee(),
                    RetroScreen(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 10,
                                color: retroRed,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${items.length.toString().padLeft(2, '0')} REGISTROS',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                loading ? 'SYNC...' : 'READY',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _QuickCaptureBar(
                            controller: quickCapture,
                            saving: quickSaving,
                            onSubmit: submitQuickCapture,
                          ),
                          const SizedBox(height: 10),
                          _ModeSwitch(
                            todayMode: todayMode,
                            onAll: _showAll,
                            onToday: _showToday,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: search,
                            style: retroInputTextStyle,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              labelText: 'Buscar',
                              suffixIcon: IconButton(
                                onPressed: load,
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ),
                            onSubmitted: (_) => load(),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _OrderChip(
                                  icon: Icons.history,
                                  label: 'Recientes',
                                  selected: order == 'CREATED_DESC',
                                  onPressed: () => _setOrder('CREATED_DESC'),
                                ),
                                _OrderChip(
                                  icon: Icons.event,
                                  label: 'Vence',
                                  selected: order == 'DUE_ASC',
                                  onPressed: () => _setOrder('DUE_ASC'),
                                ),
                                _OrderChip(
                                  icon: Icons.priority_high,
                                  label: 'Prioridad',
                                  selected: order == 'PRIORITY_DESC',
                                  onPressed: () => _setOrder('PRIORITY_DESC'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('Ideas'),
                                selected: type == 'IDEA',
                                onSelected: (_) => _setType('IDEA'),
                              ),
                              FilterChip(
                                label: const Text('Notas'),
                                selected: type == 'NOTE',
                                onSelected: (_) => _setType('NOTE'),
                              ),
                              FilterChip(
                                label: const Text('Tareas'),
                                selected: type == 'TASK',
                                onSelected: (_) => _setType('TASK'),
                              ),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              )
                            : todayMode
                            ? _TodayMissionList(
                                items: items,
                                onEdit: edit,
                                onComplete: completeItem,
                                onDelete: deleteItem,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(4, 4, 4, 96),
                                itemCount: items.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
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
      ),
    );
  }

  void _setType(String value) {
    setState(() {
      todayMode = false;
      type = type == value ? null : value;
    });
    load();
  }

  void _setStatus(String value) {
    setState(() {
      todayMode = false;
      status = status == value ? null : value;
    });
    load();
  }

  void _setTag(String value) {
    setState(() {
      todayMode = false;
      tagId = tagId == value ? null : value;
    });
    load();
  }

  void _setDueFilter(String value) {
    setState(() {
      todayMode = false;
      dueFilter = dueFilter == value ? null : value;
      if (value == 'OVERDUE' && dueFilter == 'OVERDUE') {
        status = 'ACTIVE';
      }
    });
    load();
  }

  void _setOrder(String value) {
    setState(() {
      todayMode = false;
      order = value;
    });
    load();
  }

  void _showToday() {
    setState(() {
      todayMode = true;
      type = null;
      status = null;
      tagId = null;
      dueFilter = null;
      order = 'DUE_ASC';
    });
    load();
  }

  void _showAll() {
    setState(() => todayMode = false);
    load();
  }

  bool get hasActiveFilters =>
      type != null ||
      status != null ||
      tagId != null ||
      dueFilter != null ||
      search.text.trim().isNotEmpty;

  String get emptyMessage => hasActiveFilters
      ? 'Sin resultados para estos filtros'
      : 'Sin registros todavía';

  void clearFilters() {
    setState(() {
      todayMode = false;
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

class QuickCaptureDraft {
  QuickCaptureDraft({
    required this.type,
    required this.content,
    required this.priority,
    required this.tagIds,
    this.dueDate,
  });

  final String type;
  final String content;
  final String priority;
  final DateTime? dueDate;
  final List<String> tagIds;

  factory QuickCaptureDraft.parse(String raw, List<Tag> tags) {
    var text = raw.trim();
    var type = 'IDEA';
    var priority = 'NORMAL';
    DateTime? dueDate;

    final lower = text.toLowerCase();
    if (lower.startsWith('tarea:') || lower.startsWith('task:')) {
      type = 'TASK';
      text = text.substring(text.indexOf(':') + 1).trim();
    } else if (lower.startsWith('nota:') || lower.startsWith('note:')) {
      type = 'NOTE';
      text = text.substring(text.indexOf(':') + 1).trim();
    } else if (lower.startsWith('idea:')) {
      type = 'IDEA';
      text = text.substring(text.indexOf(':') + 1).trim();
    }

    final priorityTokens = {
      '!alta': 'HIGH',
      '!high': 'HIGH',
      '!media': 'NORMAL',
      '!normal': 'NORMAL',
      '!baja': 'LOW',
      '!low': 'LOW',
    };

    for (final entry in priorityTokens.entries) {
      if (text.toLowerCase().contains(entry.key)) {
        priority = entry.value;
        text = text
            .replaceAll(
              RegExp(RegExp.escape(entry.key), caseSensitive: false),
              '',
            )
            .trim();
      }
    }

    final tagIds = <String>[];
    final tagMatches = RegExp(
      r'(^|\s)#([\wáéíóúÁÉÍÓÚñÑ-]+)',
    ).allMatches(text).toList();
    for (final match in tagMatches) {
      final name = match.group(2)?.toLowerCase();
      if (name == null) continue;
      for (final tag in tags) {
        if (tag.name.toLowerCase() == name) {
          tagIds.add(tag.id);
        }
      }
    }
    text = text.replaceAll(RegExp(r'(^|\s)#([\wáéíóúÁÉÍÓÚñÑ-]+)'), ' ').trim();

    final now = DateTime.now();
    if (text.toLowerCase().contains(' mañana')) {
      type = 'TASK';
      final tomorrow = now.add(const Duration(days: 1));
      dueDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
      text = text
          .replaceAll(RegExp(r'\s+mañana', caseSensitive: false), '')
          .trim();
    } else if (text.toLowerCase().contains(' hoy')) {
      type = 'TASK';
      dueDate = DateTime(now.year, now.month, now.day, 18);
      text = text
          .replaceAll(RegExp(r'\s+hoy', caseSensitive: false), '')
          .trim();
    }

    return QuickCaptureDraft(
      type: type,
      content: text.isEmpty ? raw.trim() : text,
      priority: priority,
      dueDate: dueDate,
      tagIds: tagIds.toSet().toList(),
    );
  }
}

class _ArcadeMarquee extends StatelessWidget {
  const _ArcadeMarquee();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: retroInk,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: retroAmber, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAAFF5CC8),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt, color: retroAmber, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'FARODECK // ARCADE CAPTURE DECK',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.circle, color: arcadeCyan, size: 10),
          SizedBox(width: 5),
          Icon(Icons.circle, color: arcadePink, size: 10),
          SizedBox(width: 5),
          Icon(Icons.circle, color: retroMint, size: 10),
        ],
      ),
    );
  }
}

class _ArcadeCaptureButton extends StatelessWidget {
  const _ArcadeCaptureButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(color: retroInk, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Material(
        color: arcadePink,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: retroInk, width: 2),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: retroInk, size: 20),
                SizedBox(width: 8),
                Text(
                  'CAPTURAR',
                  style: TextStyle(
                    color: retroInk,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickCaptureBar extends StatelessWidget {
  const _QuickCaptureBar({
    required this.controller,
    required this.saving,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD84F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: retroInk, width: 2),
        boxShadow: const [
          BoxShadow(color: retroInk, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.gamepad_outlined, size: 18, color: retroInk),
              SizedBox(width: 8),
              Text(
                'INSERT COIN // CAPTURA RAPIDA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: retroInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: retroInputTextStyle,
            decoration: InputDecoration(
              prefixText: '> ',
              hintText: 'tarea: llamar mañana #personal !alta',
              fillColor: Colors.white,
              suffixIcon: IconButton(
                onPressed: saving ? null : onSubmit,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                tooltip: 'Guardar',
              ),
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 7),
          const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _HintPill(text: 'tarea:'),
              _HintPill(text: 'nota:'),
              _HintPill(text: '#tag'),
              _HintPill(text: '!alta'),
              _HintPill(text: 'hoy'),
              _HintPill(text: 'mañana'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: retroInk,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: retroScreen,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.todayMode,
    required this.onAll,
    required this.onToday,
  });

  final bool todayMode;
  final VoidCallback onAll;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _OrderChip(
          icon: Icons.view_list,
          label: 'Todo',
          selected: !todayMode,
          onPressed: onAll,
        ),
        _OrderChip(
          icon: Icons.today,
          label: 'Hoy',
          selected: todayMode,
          onPressed: onToday,
        ),
      ],
    );
  }
}

class _TodayMissionList extends StatelessWidget {
  const _TodayMissionList({
    required this.items,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  final List<Item> items;
  final ValueChanged<Item> onEdit;
  final ValueChanged<Item> onComplete;
  final ValueChanged<Item> onDelete;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final overdue = <Item>[];
    final today = <Item>[];
    final unscheduled = <Item>[];

    for (final item in items.where((item) => item.status == 'ACTIVE')) {
      final dueDate = item.dueDate;
      if (dueDate == null) {
        unscheduled.add(item);
      } else if (dueDate.isBefore(todayStart)) {
        overdue.add(item);
      } else if (dueDate.isBefore(tomorrowStart)) {
        today.add(item);
      }
    }

    final sections = [
      _TodaySectionData(
        title: 'VENCIDAS',
        color: retroRed,
        icon: Icons.warning_amber,
        items: overdue,
      ),
      _TodaySectionData(
        title: 'PARA HOY',
        color: retroAmber,
        icon: Icons.today,
        items: today,
      ),
      _TodaySectionData(
        title: 'SIN FECHA',
        color: arcadeCyan,
        icon: Icons.inbox,
        items: unscheduled,
      ),
    ];

    if (sections.every((section) => section.items.isEmpty)) {
      return const Center(
        child: RetroScreen(
          shadow: false,
          child: Text(
            'Sin misiones activas para hoy',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 96),
      children: [
        for (final section in sections)
          if (section.items.isNotEmpty)
            _TodaySection(
              section: section,
              onEdit: onEdit,
              onComplete: onComplete,
              onDelete: onDelete,
            ),
      ],
    );
  }
}

class _TodaySectionData {
  const _TodaySectionData({
    required this.title,
    required this.color,
    required this.icon,
    required this.items,
  });

  final String title;
  final Color color;
  final IconData icon;
  final List<Item> items;
}

class _TodaySection extends StatelessWidget {
  const _TodaySection({
    required this.section,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  final _TodaySectionData section;
  final ValueChanged<Item> onEdit;
  final ValueChanged<Item> onComplete;
  final ValueChanged<Item> onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: section.color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: retroInk, width: 2),
              boxShadow: const [
                BoxShadow(color: retroInk, offset: Offset(2, 2), blurRadius: 0),
              ],
            ),
            child: Row(
              children: [
                Icon(section.icon, size: 17, color: retroInk),
                const SizedBox(width: 8),
                Text(
                  '${section.title} // ${section.items.length}',
                  style: const TextStyle(
                    color: retroInk,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final item in section.items) ...[
            ItemTile(
              item: item,
              onEdit: () => onEdit(item),
              onComplete: () => onComplete(item),
              onDelete: () => onDelete(item),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _OrderChip extends StatelessWidget {
  const _OrderChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: selected ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? retroMint : retroPanel,
        foregroundColor: retroInk,
        disabledBackgroundColor: retroMint,
        disabledForegroundColor: retroInk,
        side: const BorderSide(color: retroInk, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
