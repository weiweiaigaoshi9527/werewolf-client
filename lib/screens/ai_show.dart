import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api.dart';
import '../store.dart';
import '../theme.dart';

/// 全 AI 队局（观战房）创建弹窗：先拉可选板子，选完立刻开局，自己作为观战者进入。
/// 对应网页版大厅的「全 AI 队局」按钮。
Future<void> openAiShowCreate(BuildContext context) async {
  final store = context.read<AppStore>();
  List<Map<String, dynamic>> boards;
  try {
    boards = await store.aiShowBoards();
  } on AppError catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
    return;
  }
  if (boards.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('服务端没有可用的剧本')));
    }
    return;
  }
  var boardId = '${boards.first['id']}';
  if (!context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setDialogState) => AlertDialog(
        backgroundColor: kPanel,
        title: const Text('🎬 全 AI 队局'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('整局由 AI 自动对战，你可以随时进场旁观；一局结束后会自动续开。',
                style: TextStyle(color: kDim, height: 1.6, fontSize: 13)),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: boardId,
              decoration: const InputDecoration(labelText: '剧本'),
              items: [
                for (final b in boards)
                  DropdownMenuItem(value: '${b['id']}', child: Text('${b['name'] ?? b['id']}')),
              ],
              onChanged: (v) => setDialogState(() => boardId = v ?? boardId),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('提示：开局后会直接进入对局页，可在「对局记录」栏看 AI 的完整行动。',
                  style: TextStyle(color: kDim, fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('开局')),
        ],
      ),
    ),
  );
  if (ok != true) return;
  try {
    await store.createAiShow(boardId);
  } on AppError catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// 大厅里的「全 AI 观战厅」卡片：列出进行中的全 AI 局，点一条即可进场旁观。
class AiShowSection extends StatefulWidget {
  const AiShowSection({super.key});
  @override
  State<AiShowSection> createState() => _AiShowSectionState();
}

class _AiShowSectionState extends State<AiShowSection> {
  List<Map<String, dynamic>> _shows = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await context.read<AppStore>().aiShowList();
      if (mounted) {
        setState(() {
          _shows = s;
          _loading = false;
        });
      }
    } on AppError {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppStore>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('🎬 全 AI 观战厅',
                      style: TextStyle(color: kMoon, fontWeight: FontWeight.bold)),
                ),
                if (store.feat('aiShow'))
                  TextButton(onPressed: () => openAiShowCreate(context), child: const Text('开一场')),
                IconButton(
                  tooltip: '刷新',
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () {
                    setState(() => _loading = true);
                    _load();
                  },
                ),
              ],
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: LinearProgressIndicator(minHeight: 2),
              )
            else if (_shows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('暂无进行中的全 AI 对局。', style: TextStyle(color: kDim, fontSize: 13)),
              )
            else
              for (final s in _shows) _showRow(store, s),
          ],
        ),
      ),
    );
  }

  Widget _showRow(AppStore store, Map<String, dynamic> s) {
    final roomNo = '${s['roomNo'] ?? ''}';
    final total = (s['total'] as num?)?.toInt() ?? 0;
    final alive = (s['alive'] as num?)?.toInt() ?? 0;
    final watchers = (s['watchers'] as num?)?.toInt() ?? 0;
    final day = (s['day'] as num?)?.toInt() ?? 0;
    final playing = s['playing'] == true;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Text('🎬', style: TextStyle(fontSize: 22)),
      title: Text('房间 $roomNo · ${s['boardName'] ?? '全 AI 队局'}', style: const TextStyle(color: kText)),
      subtitle: Text(
        playing ? '第 $day 天 · 存活 $alive/$total · $watchers 人旁观' : '等待续开 · $watchers 人旁观',
        style: const TextStyle(color: kDim, fontSize: 12),
      ),
      trailing: const Text('观战 ›', style: TextStyle(color: kAccent, fontSize: 12)),
      onTap: () async {
        try {
          await store.spectate(roomNo);
        } on AppError catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
          }
        }
      },
    );
  }
}
