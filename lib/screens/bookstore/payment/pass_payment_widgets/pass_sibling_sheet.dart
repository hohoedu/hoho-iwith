import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';

/// 형제 묶음결제 선택 시트.
///
/// `/payment/siblings`는 본인을 포함해서 내려주므로, 2건 이상일 때만 이 시트를 띄운다.
/// 본인은 기본 선택 상태로 시작하고, 선택된 학생 수만큼 금액이 곱해진다
/// (개별 학생 상품은 항상 같다는 서버 전제와 동일).
///
/// 돌려주는 값: 선택된 studentId 목록. 취소하면 null.
Future<List<String>?> showPassSiblingSheet({
  required BuildContext context,
  required List<PassSibling> siblings,
  required String myStudentId,
  required int unitPrice,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PassSiblingSheet(
      siblings: siblings,
      myStudentId: myStudentId,
      unitPrice: unitPrice,
    ),
  );
}

class _PassSiblingSheet extends StatefulWidget {
  final List<PassSibling> siblings;
  final String myStudentId;
  final int unitPrice;

  const _PassSiblingSheet({
    required this.siblings,
    required this.myStudentId,
    required this.unitPrice,
  });

  @override
  State<_PassSiblingSheet> createState() => _PassSiblingSheetState();
}

class _PassSiblingSheetState extends State<_PassSiblingSheet> {
  late final Set<String> _selected = {widget.myStudentId};

  void _toggle(PassSibling sibling) {
    setState(() {
      if (!_selected.remove(sibling.studentId)) {
        _selected.add(sibling.studentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.unitPrice * _selected.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '결제할 학생을 선택해주세요',
              style: TextStyle(
                fontFamily: 'Pretendard-Bold',
                fontSize: 18,
                color: Color(0xFF363636),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.siblings.map(_siblingTile).toList(),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('합계', style: TextStyle(fontSize: 15, color: Color(0xFF6C7176))),
                Text(
                  formatWon(total),
                  style: const TextStyle(
                    fontFamily: 'Pretendard-Bold',
                    fontSize: 18,
                    color: Color(0xFF363636),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: _button('취소', const Color(0xFFF3F4F5), const Color(0xFF6C7176)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selected.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(_selected.toList()),
                    child: _button(
                      '결제 계속하기',
                      _selected.isEmpty ? const Color(0xFFE0E0E0) : const Color(0xFFF8EBB4),
                      _selected.isEmpty ? const Color(0xFF9E9E9E) : const Color(0xFF6C7176),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _siblingTile(PassSibling sibling) {
    final checked = _selected.contains(sibling.studentId);
    final subtitle = [
      if (sibling.school.isNotEmpty) sibling.school,
      if (sibling.gradeKey.isNotEmpty) sibling.gradeKey,
    ].join(' · ');

    return CheckboxListTile(
      value: checked,
      onChanged: (_) => _toggle(sibling),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFFF8EBB4),
      checkColor: const Color(0xFF6C7176),
      title: Text(
        sibling.studentName,
        style: const TextStyle(fontSize: 16, color: Color(0xFF363636)),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
    );
  }

  Widget _button(String label, Color bg, Color fg) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: bg),
      child: Text(
        label,
        style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 16, color: fg),
      ),
    );
  }
}
