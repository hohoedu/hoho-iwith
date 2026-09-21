import 'package:flutter/material.dart';

/// 남은 이용권 카드. 책방 예약 화면의 보유 이용권 카드와 같은 톤으로 맞춘다.
class PaymentRemainCard extends StatelessWidget {
  final int remain;

  const PaymentRemainCard({super.key, required this.remain});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.asset('assets/images/icon/ticket.png', width: 64, height: 64),
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
                  if (remain <= 0)
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
                            text: '$remain회',
                            style: const TextStyle(
                              fontFamily: 'Pretendard-Bold',
                              fontSize: 16,
                              color: Color(0xFF363636),
                            ),
                          ),
                        ],
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
