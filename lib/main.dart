import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');
const String appName = 'BESNARD CHRISTIAN';
const String supportEmail = 'support@besnardchristian.app';

const Color _navy = Color(0xFF06152E);
const Color _blue = Color(0xFF0A7BC2);
const Color _cyan = Color(0xFF14C9E8);
const Color _green = Color(0xFF168A63);
const Color _amber = Color(0xFFE69F2E);
const Color _red = Color(0xFFC75343);
const Color _paper = Color(0xFFF4F8FB);
const Color _ink = Color(0xFF172033);

void main() {
  runApp(const BesnardChristianApp(screenshotMode: _screenshotMode));
}

class BesnardChristianApp extends StatelessWidget {
  const BesnardChristianApp({super.key, required this.screenshotMode});

  final bool screenshotMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _blue,
      brightness: Brightness.light,
      primary: _blue,
      secondary: _cyan,
      tertiary: _amber,
      surface: Colors.white,
    );

    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFDCE7EF)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: _cyan.withValues(alpha: 0.18),
          checkmarkColor: _navy,
          side: const BorderSide(color: Color(0xFFC9D8E4)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _blue, width: 2),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: _cyan.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
      home: OperationsShell(screenshotMode: screenshotMode),
    );
  }
}

enum RecordType { quality, equipment, shipment, compliance }

extension RecordTypeText on RecordType {
  String get label {
    switch (this) {
      case RecordType.quality:
        return 'Quality control';
      case RecordType.equipment:
        return 'Equipment checkout';
      case RecordType.shipment:
        return 'Shipment log';
      case RecordType.compliance:
        return 'Compliance report';
    }
  }

  String get shortLabel {
    switch (this) {
      case RecordType.quality:
        return 'Quality';
      case RecordType.equipment:
        return 'Equipment';
      case RecordType.shipment:
        return 'Shipment';
      case RecordType.compliance:
        return 'Compliance';
    }
  }

  IconData get icon {
    switch (this) {
      case RecordType.quality:
        return Icons.fact_check_outlined;
      case RecordType.equipment:
        return Icons.precision_manufacturing_outlined;
      case RecordType.shipment:
        return Icons.local_shipping_outlined;
      case RecordType.compliance:
        return Icons.verified_user_outlined;
    }
  }
}

enum RecordStatus { open, inProgress, blocked, complete }

extension RecordStatusText on RecordStatus {
  String get label {
    switch (this) {
      case RecordStatus.open:
        return 'Open';
      case RecordStatus.inProgress:
        return 'In progress';
      case RecordStatus.blocked:
        return 'Needs review';
      case RecordStatus.complete:
        return 'Complete';
    }
  }

  Color get color {
    switch (this) {
      case RecordStatus.open:
        return _blue;
      case RecordStatus.inProgress:
        return _amber;
      case RecordStatus.blocked:
        return _red;
      case RecordStatus.complete:
        return _green;
    }
  }
}

class OperationRecord {
  const OperationRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.owner,
    required this.reference,
    required this.status,
    required this.dueDate,
    required this.notes,
    required this.completion,
    required this.createdAt,
  });

  final String id;
  final RecordType type;
  final String title;
  final String owner;
  final String reference;
  final RecordStatus status;
  final DateTime dueDate;
  final String notes;
  final int completion;
  final DateTime createdAt;

  bool get isDueSoon {
    final today = DateTime.now();
    final days = dueDate
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return status != RecordStatus.complete && days <= 2;
  }

  OperationRecord copyWith({
    RecordType? type,
    String? title,
    String? owner,
    String? reference,
    RecordStatus? status,
    DateTime? dueDate,
    String? notes,
    int? completion,
  }) {
    return OperationRecord(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      reference: reference ?? this.reference,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      completion: completion ?? this.completion,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'owner': owner,
      'reference': reference,
      'status': status.name,
      'dueDate': dueDate.toIso8601String(),
      'notes': notes,
      'completion': completion,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OperationRecord.fromJson(Map<String, Object?> json) {
    return OperationRecord(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: RecordType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => RecordType.quality,
      ),
      title: json['title'] as String? ?? 'Untitled record',
      owner: json['owner'] as String? ?? 'Unassigned',
      reference: json['reference'] as String? ?? 'No reference',
      status: RecordStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => RecordStatus.open,
      ),
      dueDate:
          DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String? ?? '',
      completion: ((json['completion'] as num?)?.round().clamp(0, 100) ?? 0)
          .toInt(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class RecordStore {
  static const String _storageKey = 'besnard_operations_records_v1';

  Future<List<OperationRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <OperationRecord>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => OperationRecord.fromJson(Map<String, Object?>.from(item)),
        )
        .toList()
      ..sort(_sortRecords);
  }

  Future<void> save(List<OperationRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

int _sortRecords(OperationRecord left, OperationRecord right) {
  final statusCompare = left.status.index.compareTo(right.status.index);
  if (statusCompare != 0) {
    return statusCompare;
  }
  return left.dueDate.compareTo(right.dueDate);
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key, required this.screenshotMode});

  final bool screenshotMode;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  final RecordStore _store = RecordStore();
  int _tab = 0;
  bool _loading = true;
  List<OperationRecord> _records = <OperationRecord>[];

  @override
  void initState() {
    super.initState();
    if (widget.screenshotMode) {
      _records = _sampleRecords();
      _loading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final records = await _store.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    if (!widget.screenshotMode) {
      await _store.save(_records);
    }
  }

  Future<void> _openCreateForm([RecordType? type]) async {
    final created = await Navigator.of(context).push<OperationRecord>(
      MaterialPageRoute(
        builder: (context) =>
            RecordFormScreen(initialType: type ?? RecordType.quality),
      ),
    );
    if (created == null) {
      return;
    }
    setState(() {
      _records = <OperationRecord>[created, ..._records]..sort(_sortRecords);
    });
    await _persist();
  }

  Future<void> _openDetail(OperationRecord record) async {
    final updated = await Navigator.of(context).push<OperationRecord>(
      MaterialPageRoute(
        builder: (context) => RecordDetailScreen(record: record),
      ),
    );
    if (updated == null) {
      return;
    }
    setState(() {
      _records =
          _records
              .map((item) => item.id == updated.id ? updated : item)
              .toList()
            ..sort(_sortRecords);
    });
    await _persist();
  }

  Future<void> _addComplianceSnapshot() async {
    final now = DateTime.now();
    final record = OperationRecord(
      id: 'record-${now.microsecondsSinceEpoch}',
      type: RecordType.compliance,
      title: 'Weekly compliance readiness',
      owner: 'Operations lead',
      reference: 'CMP-${now.month}${now.day}',
      status: RecordStatus.inProgress,
      dueDate: now.add(const Duration(days: 5)),
      notes:
          'Verify training files, shipment evidence, and equipment logs before sign-off.',
      completion: 64,
      createdAt: now,
    );
    setState(() {
      _records = <OperationRecord>[record, ..._records]..sort(_sortRecords);
    });
    await _persist();
  }

  Future<void> _clearRecords() async {
    setState(() {
      _records = <OperationRecord>[];
    });
    if (!widget.screenshotMode) {
      await _store.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardScreen(
        records: _records,
        loading: _loading,
        onCreate: _openCreateForm,
        onOpenRecord: _openDetail,
      ),
      WorkScreen(
        records: _records,
        onCreate: _openCreateForm,
        onOpenRecord: _openDetail,
      ),
      ReportsScreen(records: _records, onAddSnapshot: _addComplianceSnapshot),
      SettingsScreen(
        recordCount: _records.length,
        screenshotMode: widget.screenshotMode,
        onClear: _clearRecords,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('docs/icon.png', width: 34, height: 34),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(key: ValueKey<int>(_tab), child: screens[_tab]),
      ),
      floatingActionButton: _tab == 1
          ? FloatingActionButton.extended(
              key: const Key('add-record-button'),
              onPressed: () => _openCreateForm(),
              icon: const Icon(Icons.add),
              label: const Text('New'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Work',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.records,
    required this.loading,
    required this.onCreate,
    required this.onOpenRecord,
  });

  final List<OperationRecord> records;
  final bool loading;
  final ValueChanged<RecordType> onCreate;
  final ValueChanged<OperationRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final dueSoon = records.where((record) => record.isDueSoon).length;
    final complete = records
        .where((record) => record.status == RecordStatus.complete)
        .length;
    final completion = records.isEmpty
        ? 0
        : (complete / records.length * 100).round();
    final nextRecords = records.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _HeaderPanel(
          title: 'Operations control',
          subtitle:
              'Track daily checks, tools, shipments, and audit evidence in one local log.',
          action: FilledButton.icon(
            onPressed: () => onCreate(RecordType.quality),
            icon: const Icon(Icons.add_task),
            label: const Text('Create check'),
          ),
        ),
        const SizedBox(height: 16),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 560 ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.22,
            children: [
              MetricCard(
                label: 'Open records',
                value: '${records.length - complete}',
                icon: Icons.pending_actions_outlined,
                color: _blue,
              ),
              MetricCard(
                label: 'Due soon',
                value: '$dueSoon',
                icon: Icons.priority_high_rounded,
                color: dueSoon > 0 ? _red : _green,
              ),
              MetricCard(
                label: 'Completion',
                value: '$completion%',
                icon: Icons.verified_outlined,
                color: _green,
              ),
              MetricCard(
                label: 'Shipments',
                value:
                    '${records.where((r) => r.type == RecordType.shipment).length}',
                icon: Icons.local_shipping_outlined,
                color: _amber,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RecordType.values.map((type) {
              return ActionChip(
                avatar: Icon(type.icon, size: 18),
                label: Text(type.shortLabel),
                onPressed: () => onCreate(type),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          SectionTitle(
            title: 'Next actions',
            trailing: '${nextRecords.length} active',
          ),
          const SizedBox(height: 10),
          if (nextRecords.isEmpty)
            const EmptyState(
              icon: Icons.task_alt_outlined,
              title: 'No local records yet',
              message:
                  'Create your first checklist, checkout, shipment entry, or compliance note.',
            )
          else
            ...nextRecords.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecordTile(
                  record: record,
                  onTap: () => onOpenRecord(record),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class WorkScreen extends StatefulWidget {
  const WorkScreen({
    super.key,
    required this.records,
    required this.onCreate,
    required this.onOpenRecord,
  });

  final List<OperationRecord> records;
  final ValueChanged<RecordType> onCreate;
  final ValueChanged<OperationRecord> onOpenRecord;

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  RecordType? _filter;

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == null
        ? widget.records
        : widget.records.where((record) => record.type == _filter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        SectionTitle(
          title: 'Daily work log',
          trailing: '${filtered.length} shown',
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: _filter == null,
                  label: const Text('All'),
                  onSelected: (_) => setState(() => _filter = null),
                ),
              ),
              ...RecordType.values.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _filter == type,
                    label: Text(type.shortLabel),
                    avatar: Icon(type.icon, size: 18),
                    onSelected: (_) => setState(() => _filter = type),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.assignment_add,
            title: 'No records in this view',
            message: 'Add a local record to start tracking work for this area.',
            buttonLabel: 'Add record',
            onPressed: () => widget.onCreate(_filter ?? RecordType.quality),
          )
        else
          ...filtered.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RecordTile(
                record: record,
                onTap: () => widget.onOpenRecord(record),
              ),
            ),
          ),
      ],
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({
    super.key,
    required this.records,
    required this.onAddSnapshot,
  });

  final List<OperationRecord> records;
  final VoidCallback onAddSnapshot;

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final completed = records
        .where((record) => record.status == RecordStatus.complete)
        .length;
    final blocked = records
        .where((record) => record.status == RecordStatus.blocked)
        .length;
    final complianceScore = total == 0
        ? 0
        : ((completed / total) * 100).round();
    final byType = {
      for (final type in RecordType.values)
        type: records.where((record) => record.type == type).length,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _HeaderPanel(
          title: 'Compliance snapshot',
          subtitle:
              'Review local readiness signals before an internal audit or shipment closeout.',
          action: OutlinedButton.icon(
            onPressed: onAddSnapshot,
            icon: const Icon(Icons.add_chart_outlined),
            label: const Text('Add snapshot'),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$complianceScore%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: _navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Local completion score',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                  value: complianceScore / 100,
                  backgroundColor: const Color(0xFFE3EDF4),
                  valueColor: const AlwaysStoppedAnimation<Color>(_green),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatusPill(
                        label: 'Complete',
                        value: '$completed',
                        color: _green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatusPill(
                        label: 'Review',
                        value: '$blocked',
                        color: _red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionTitle(title: 'Workload by area', trailing: '$total records'),
        const SizedBox(height: 10),
        ...byType.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProgressRow(
              icon: entry.key.icon,
              title: entry.key.label,
              count: entry.value,
              total: total,
              color: _typeColor(entry.key),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.recordCount,
    required this.screenshotMode,
    required this.onClear,
  });

  final int recordCount;
  final bool screenshotMode;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        SectionTitle(title: 'Settings and privacy', trailing: 'Local only'),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.storage_outlined,
          title: 'Device storage',
          message:
              '$recordCount records are saved on this device. No account, sync, analytics, or external service is used.',
        ),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.shield_outlined,
          title: 'Privacy position',
          message:
              'Records stay in local app storage until you clear the app data or uninstall the app.',
        ),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.contact_support_outlined,
          title: 'Support',
          message: '$appName\n$supportEmail',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          key: const Key('clear-records-button'),
          onPressed: screenshotMode ? null : onClear,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear local records'),
        ),
      ],
    );
  }
}

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({super.key, required this.record});

  final OperationRecord record;

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  late OperationRecord _record = widget.record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_record.type.shortLabel)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _IconBadge(
                        icon: _record.type.icon,
                        color: _typeColor(_record.type),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _record.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _record.reference,
                              style: const TextStyle(color: Color(0xFF5E7081)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(status: _record.status),
                      Chip(
                        avatar: const Icon(Icons.event_outlined, size: 18),
                        label: Text('Due ${_formatDate(_record.dueDate)}'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.person_outline, size: 18),
                        label: Text(_record.owner),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Progress ${_record.completion}%',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                    value: _record.completion / 100,
                    backgroundColor: const Color(0xFFE3EDF4),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _record.status.color,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Notes',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(_record.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('complete-record-button'),
            onPressed: () {
              setState(() {
                _record = _record.copyWith(
                  status: RecordStatus.complete,
                  completion: 100,
                );
              });
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark complete'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(_record),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save status'),
          ),
        ],
      ),
    );
  }
}

class RecordFormScreen extends StatefulWidget {
  const RecordFormScreen({super.key, required this.initialType});

  final RecordType initialType;

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late RecordType _type = widget.initialType;
  RecordStatus _status = RecordStatus.open;
  int _dueInDays = 3;
  int _completion = 20;
  final _title = TextEditingController();
  final _owner = TextEditingController(text: 'Operations lead');
  final _reference = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _owner.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New operation record')),
      body: Form(
        key: _formKey,
        child: ListView(
          key: const Key('record-form-scroll'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            DropdownButtonFormField<RecordType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Workflow area'),
              items: RecordType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('record-title-field'),
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Record title'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Add a title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('record-reference-field'),
              controller: _reference,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Asset, shipment, or checklist ID',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Add a reference'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _owner,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Responsible person',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Add an owner' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RecordStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Current status'),
              items: RecordStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 14),
            const Text(
              'Due window',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 3, 7, 14].map((days) {
                return ChoiceChip(
                  selected: _dueInDays == days,
                  label: Text('$days d'),
                  onSelected: (_) => setState(() => _dueInDays = days),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Text(
              'Progress $_completion%',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: _completion.toDouble(),
              divisions: 10,
              min: 0,
              max: 100,
              label: '$_completion%',
              onChanged: (value) => setState(() => _completion = value.round()),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('record-notes-field'),
              controller: _notes,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes and evidence',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Add a short note'
                  : null,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('save-record-button'),
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save record'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    Navigator.of(context).pop(
      OperationRecord(
        id: 'record-${now.microsecondsSinceEpoch}',
        type: _type,
        title: _title.text.trim(),
        owner: _owner.text.trim(),
        reference: _reference.text.trim(),
        status: _status,
        dueDate: now.add(Duration(days: _dueInDays)),
        notes: _notes.text.trim(),
        completion: _completion,
        createdAt: now,
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _IconBadge(icon: icon, color: color),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF5E7081),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, required this.onTap});

  final OperationRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _IconBadge(
                icon: record.type.icon,
                color: _typeColor(record.type),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.type.label} • ${record.reference}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5E7081),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(8),
                      value: record.completion / 100,
                      backgroundColor: const Color(0xFFE3EDF4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        record.status.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: record.status),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(record.dueDate),
                    style: TextStyle(
                      color: record.isDueSoon ? _red : const Color(0xFF5E7081),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final RecordStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withValues(alpha: 0.36)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          status.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: status.color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class ProgressRow extends StatelessWidget {
  const ProgressRow({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.total,
    required this.color,
  });

  final IconData icon;
  final String title;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : count / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _IconBadge(icon: icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    value: progress,
                    backgroundColor: const Color(0xFFE3EDF4),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon: icon, color: _blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF5E7081),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _IconBadge(icon: icon, color: _blue),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF5E7081)),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 14),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: Color(0xFF5E7081),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFFC8D8E8), height: 1.35),
            ),
            const SizedBox(height: 16),
            action,
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

Color _typeColor(RecordType type) {
  switch (type) {
    case RecordType.quality:
      return _cyan;
    case RecordType.equipment:
      return _blue;
    case RecordType.shipment:
      return _amber;
    case RecordType.compliance:
      return _green;
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

List<OperationRecord> _sampleRecords() {
  final today = DateTime(2026, 5, 12);
  return [
    OperationRecord(
      id: 'sample-qc',
      type: RecordType.quality,
      title: 'Packaging line QC checklist',
      owner: 'Amelia Martin',
      reference: 'QC-1842',
      status: RecordStatus.inProgress,
      dueDate: today.add(const Duration(days: 1)),
      notes:
          'Inspect seal integrity, barcode legibility, and final carton count before dispatch.',
      completion: 68,
      createdAt: today.subtract(const Duration(days: 1)),
    ),
    OperationRecord(
      id: 'sample-eq',
      type: RecordType.equipment,
      title: 'Torque driver checkout',
      owner: 'Nicolas Bernard',
      reference: 'EQ-77',
      status: RecordStatus.open,
      dueDate: today.add(const Duration(days: 3)),
      notes:
          'Confirm calibration label, issue to station B, and record expected return window.',
      completion: 25,
      createdAt: today,
    ),
    OperationRecord(
      id: 'sample-ship',
      type: RecordType.shipment,
      title: 'Outbound shipment LX-290',
      owner: 'Claire Dubois',
      reference: 'LX-290',
      status: RecordStatus.blocked,
      dueDate: today.add(const Duration(days: 2)),
      notes:
          'Carrier pickup is pending final pallet photo and damage-free handoff confirmation.',
      completion: 52,
      createdAt: today.subtract(const Duration(days: 2)),
    ),
    OperationRecord(
      id: 'sample-comp',
      type: RecordType.compliance,
      title: 'Quarterly safety evidence pack',
      owner: 'Operations lead',
      reference: 'CMP-Q2',
      status: RecordStatus.complete,
      dueDate: today.add(const Duration(days: 6)),
      notes:
          'Training roster, incident log review, and sign-off notes are ready for archive.',
      completion: 100,
      createdAt: today.subtract(const Duration(days: 5)),
    ),
  ];
}
