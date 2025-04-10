import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/book_data/ym_book_count_data.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';
import '../../style.dart';

//////////////////////
// 독서클리닉3 차트  //
//////////////////////

class BookChart extends StatefulWidget {
  const BookChart({super.key});

  @override
  State<BookChart> createState() => _BookChartState();
}

class _BookChartState extends State<BookChart> {
  // 컨트롤러
  final ymBookCountDataController = Get.put(YMBookCountDataController());
  final themeController = Get.put(ThemeController());

  // 색상값
  List<Color> lightMainGradientColors = [
    Colors.white,
    const Color(0xff8cda3e)
  ];
  List<Color> lightAvgGradientColors = [
    Colors.white,
    const Color(0xfffa963c)
  ];

  List<Color> darkMainGradientColors = [
    const Color(0xff5a5a5a),
    const Color(0xff8cda3e)
  ];
  List<Color> darkAvgGradientColors = [
    const Color(0xff5a5a5a),
    const Color(0xfffa963c)
  ];

  // 평균값
  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: themeController.isLightTheme.value ? const Color(0xfffefefa) : const Color(0xff5a5a5a), 
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: themeController.isLightTheme.value ? const Color(0xffE7E7DD) : const Color(0xff343333),
                offset: const Offset(6.91, 6.91),
                blurRadius: 29,
              ),
              BoxShadow(
                color: themeController.isLightTheme.value ? const Color(0xffffffff) : const Color(0xff383838),
                offset: const Offset(-6.91, -6.91),
                blurRadius: 29,
              ),
            ],
          ),
          height: 250,
          width: double.infinity,
        ),
        // 차트 비율
        AspectRatio(
          aspectRatio: 1.50,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, top: 40,),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width - 130,
          top: 8,
          child: Column(
            children: [
              SizedBox(
                width: 50,
                height: 34,
                // 평균값 버튼
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      showAvg = !showAvg;
                    });
                  },
                  child: Text(
                    '평균',
                    style: TextStyle(
                      fontSize: 13,
                      color: showAvg ? CommonColors.grey3 : Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                height: 2,
                width: 40,
                color: showAvg ? CommonColors.grey3 : Colors.black,
              )
            ],
          ),
        ),
      ],
    );
  }

  // x좌표 제목
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final bottomtitleStyle = TextStyle(
      color: themeController.isLightTheme.value ? CommonColors.grey4 : CommonColors.grey2,
      fontSize: 15,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('1', style: bottomtitleStyle);
        break;
      case 1:
        text = Text('2', style: bottomtitleStyle);
        break;
      case 2:
        text = Text('3', style: bottomtitleStyle);
        break;
      case 3:
        text = Text('4', style: bottomtitleStyle);
        break;
      case 4:
        text = Text('5', style: bottomtitleStyle);
        break;
      case 5:
        text = Text('6', style: bottomtitleStyle);
        break;
      case 6:
        text = Text('7', style: bottomtitleStyle);
        break;
      case 7:
        text = Text('8', style: bottomtitleStyle);
        break;
      case 8:
        text = Text('9', style: bottomtitleStyle);
        break;
      case 9:
        text = Text('10', style: bottomtitleStyle);
        break;
      case 10:
        text = Text('11', style: bottomtitleStyle);
        break;
      default:
        text = Text('12', style: bottomtitleStyle);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  // y좌표 제목
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final leftTitleStyle = TextStyle(
      color: themeController.isLightTheme.value ? CommonColors.grey4 : CommonColors.grey2,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 5:
        text = '5권';
        break;
      case 10:
        text = '10권';
        break;
      default:
        return Container();
    }

    return Text(text, style: leftTitleStyle, textAlign: TextAlign.left);
  }

  // 메인그래프
  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: themeController.isLightTheme.value ? CommonColors.grey4 :CommonColors.grey2,
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      // x, y 좌표 개수 
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 11,
      // 각 데이터의 x,y 좌표값
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            12, 
            (index) => FlSpot(index.toDouble(), ymBookCountDataController.bookCountList[index].toDouble())
          ),
          isCurved: true,
          color: const Color.fromARGB(255, 173, 253, 93),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: themeController.isLightTheme.value 
              ? lightMainGradientColors.map((color) => color.withOpacity(0.5)).toList()
              : darkMainGradientColors.map((color) => color.withOpacity(0.5)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 평균값 그래프
  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: themeController.isLightTheme.value ? CommonColors.grey4 : CommonColors.grey2,
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      // x, y 좌표 개수
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 11,
      // 각 데이터의 x,y 좌표 값
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            12, 
            (index) => FlSpot(index.toDouble(), ymBookCountDataController.meanCountList[index])),
          isCurved: true,
          color: const Color.fromARGB(255, 255, 193, 100),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: themeController.isLightTheme.value 
              ? lightAvgGradientColors.map((color) => color.withOpacity(0.5)).toList()
              : darkAvgGradientColors.map((color) => color.withOpacity(0.5)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}