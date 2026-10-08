import 'package:flutter/material.dart';

import '../core/draft.dart';
import 'palette.dart';
import 'scope.dart';

/// カード（85.6×54mm）を画面に当てて、1mm の大きさを合わせる。
class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  double? _value;

  @override
  Widget build(BuildContext context) {
    final d = AppScope.of(context).draft;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final standard = Draft.standardPtPerMm(dpr);
    final v = _value ?? d.ptPerMm(dpr);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('実寸の調整'), backgroundColor: Washi.paper),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'キャッシュカードやポイントカード（85.6×54mm）を枠に重ね、ぴったり合うように −／＋ で調整してください。',
                style: TextStyle(height: 1.55),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: 53.98 * v,
                  height: 85.6 * v,
                  decoration: BoxDecoration(
                    border: Border.all(color: Washi.shu, width: 1.5),
                    borderRadius: BorderRadius.circular(3.2 * v),
                  ),
                  alignment: Alignment.center,
                  child: const Text('カードの大きさ', style: TextStyle(color: Washi.shu)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  IconButton.outlined(
                    onPressed: () => setState(() => _value = (v - 0.02).clamp(standard * 0.8, standard * 1.2)),
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: Slider(
                      value: v.clamp(standard * 0.8, standard * 1.2),
                      min: standard * 0.8,
                      max: standard * 1.2,
                      onChanged: (x) => setState(() => _value = x),
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: () => setState(() => _value = (v + 0.02).clamp(standard * 0.8, standard * 1.2)),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await d.setCalibration(null);
                        setState(() => _value = null);
                      },
                      child: const Text('標準に戻す'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await d.setCalibration(v);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text('この大きさで保存'),
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
