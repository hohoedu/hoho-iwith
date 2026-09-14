import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:get/get.dart';

/// 보유 이용권 카드 (남은 횟수 / 사용기한)
class ReservationPassCard extends StatelessWidget {
  const ReservationPassCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookstoreMainDataController>(
      init: BookstoreMainDataController(),
      builder: (c) {
        final passTotal = c.data?.passTotal;
        final passRemain = c.data?.passRemain;
        final passValidUntilLabel = c.data?.passValidUntilLabel;
        final hasPass = passTotal != null && passRemain != null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon/ticket.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '보유한 호호책방 이용권',
                        style: TextStyle(
                          fontFamily: 'Pretendard-Bold',
                          fontSize: 16,
                          color: Color(0xFF363636),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!hasPass)
                        const Text(
                          '보유한 이용권이 없어요',
                          style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                        )
                      else
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '남은 이용권   ',
                                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                              ),
                              TextSpan(
                                text: '$passRemain',
                                style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 16, color: Color(0xFF00A08C)),
                              ),
                              TextSpan(
                                text: ' / $passTotal회',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF373737)),
                              ),
                            ],
                          ),
                        ),
                      if (hasPass && passValidUntilLabel != null) ...[
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '사용기한   ',
                                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                              ),
                              TextSpan(
                                text: passValidUntilLabel,
                                style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 14, color: Color(0xFF363636)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (hasPass) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFECECEC)),
                        const SizedBox(height: 12),
                        const Text(
                          '※ 여러 이용권을 보유한 경우, 사용기한이 짧은 이용권부터 우선 사용돼요.',
                          style: TextStyle(fontSize: 8, color: Color(0xFF9E9E9E)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
