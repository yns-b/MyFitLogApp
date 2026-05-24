import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'main.dart';

class StatisticsScreen extends StatefulWidget {
  final Map<String, List<RoutineEntry>> completedWorkouts;
  
  const StatisticsScreen({super.key, required this.completedWorkouts});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, int> get _weeklyMuscleSets {
    Map<String, int> muscleSets = {
      'Göğüs': 0,
      'Omuz': 0,
      'Bacak': 0,
      'Sırt': 0,
      'Biceps': 0,
      'Triceps': 0,
      'Core': 0,
      'Kalça': 0,
    };

    // Eğer hiç tamamlanmış antrenman yoksa tüm değerler 0 kalır
    if (widget.completedWorkouts.isEmpty) {
      return muscleSets;
    }

    for (var dayWorkouts in widget.completedWorkouts.values) {
      for (var entry in dayWorkouts) {
        // Ana kas grubu için tam set sayısı
        muscleSets[entry.exercise.mainMuscleGroup] = 
            (muscleSets[entry.exercise.mainMuscleGroup] ?? 0) + entry.setCount;
        
        // Yardımcı kas grupları için oranlı hesaplama
        for (String muscle in entry.exercise.muscleGroups) {
          if (muscle != entry.exercise.mainMuscleGroup) {
            double ratio = entry.exercise.muscleGroupRatios[muscle] ?? 1.0;
            muscleSets[muscle] = (muscleSets[muscle] ?? 0) + (entry.setCount * ratio).round();
          }
        }
      }
    }

    return muscleSets;
  }

  List<String> get _undertrainedMuscles {
    return _weeklyMuscleSets.entries
        .where((e) => e.value < 12 && e.value > 0) // Sadece 0'dan büyük ama 12'den küçük değerler
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final muscleSets = _weeklyMuscleSets;
    final undertrainedMuscles = _undertrainedMuscles;
    
    // Debug: Eğer hiç antrenman yapılmamışsa tüm değerler 0 olmalı
    final hasAnyWorkouts = widget.completedWorkouts.isNotEmpty;
    final totalSets = muscleSets.values.fold(0, (sum, count) => sum + count);
    


    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık İstatistikler'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uyarı bölümü
            if (undertrainedMuscles.isNotEmpty && widget.completedWorkouts.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Dikkat!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu kas grupları haftalık 12 setten az çalışılmış:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(undertrainedMuscles.join(', ')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Çubuk grafik
            const Text(
              'Haftalık Kas Grubu Set Toplamları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Çubuk grafik
            Container(
              height: MediaQuery.of(context).size.height * 0.4, // Responsive yükseklik
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.round()} set',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                         bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         getTitlesWidget: (value, meta) {
                           final isSmallScreen = MediaQuery.of(context).size.width < 400;
                           final style = TextStyle(
                             color: Colors.grey,
                             fontWeight: FontWeight.bold,
                             fontSize: isSmallScreen ? 10 : 12,
                           );
                           switch (value.toInt()) {
                             case 0:
                               return Text(isSmallScreen ? 'Göğüs' : 'Göğüs', style: style);
                             case 1:
                               return Text(isSmallScreen ? 'Omuz' : 'Omuz', style: style);
                             case 2:
                               return Text(isSmallScreen ? 'Bacak' : 'Bacak', style: style);
                             case 3:
                               return Text(isSmallScreen ? 'Sırt' : 'Sırt', style: style);
                             case 4:
                               return Text(isSmallScreen ? 'Biceps' : 'Biceps', style: style);
                             case 5:
                               return Text(isSmallScreen ? 'Triceps' : 'Triceps', style: style);
                             case 6:
                               return Text(isSmallScreen ? 'Core' : 'Core', style: style);
                             case 7:
                               return Text(isSmallScreen ? 'Kalça' : 'Kalça', style: style);
                             case 8:
                               return Text(isSmallScreen ? 'Core' : 'Core', style: style);
                             default:
                               return const Text('');
                           }
                         },
                       ),
                     ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  barGroups: muscleSets.entries.map((entry) {
                    final index = muscleSets.keys.toList().indexOf(entry.key);
                    final setCount = entry.value;
                    final isUndertrained = setCount < 12 && setCount > 0; // 0 değerler kırmızı olmasın
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: setCount.toDouble(),
                          color: isUndertrained ? Colors.red : (setCount > 0 ? Colors.green : Colors.grey),
                          width: MediaQuery.of(context).size.width < 400 ? 16 : 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: const FlGridData(
                    show: true,
                    horizontalInterval: 4,
                    drawVerticalLine: false,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Hedef çizgisi açıklaması
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('12+ set (Hedef)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('<12 set (Yetersiz)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('0 set (Henüz çalışılmamış)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Genel istatistikler
            const Text(
              'Genel İstatistikler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  _buildStatRow('Toplam Çalışılan Gün', '${widget.completedWorkouts.length} gün'),
                  const SizedBox(height: 8),
                  _buildStatRow('Toplam Egzersiz', '${_getTotalExercises()} egzersiz'),
                  const SizedBox(height: 8),
                  _buildStatRow('Toplam Set', '${_getTotalSets()} set'),
                  const SizedBox(height: 8),
                  _buildStatRow('Ortalama Set/Gün', '${_getAverageSetsPerDay().toStringAsFixed(1)} set'),
                ],
              ),
            ),

            // Egzersiz geçmişi başlığı
            const SizedBox(height: 24),
            const Text(
              'Egzersiz Geçmişi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Geçmiş kartları
            ...widget.completedWorkouts.entries.expand((dayEntry) {
              final day = dayEntry.key;
              final entries = dayEntry.value;
              return entries.map((entry) {
                // Son setin tekrar ve kg bilgisi
                final lastSet = entry.sets.isNotEmpty ? entry.sets.last : null;
                // Tarih: bugünden kaç gün önce?
                DateTime? workoutDate;
                if (entry.sets.isNotEmpty && entry.sets.last is SetEntry && entry.sets.last is dynamic) {
                  // Eğer SetEntry'de tarih varsa kullan, yoksa günün tarihini bulmak için ek veri gerekebilir
                  // Şimdilik gün adı üzerinden relative gün hesaplanacak
                  // (Daha iyi veri için RoutineEntry'ye tarih eklenmeli)
                }
                // Gün farkı için: Haftanın gününü bugünkü gün ile karşılaştır
                int dayDiff = 0;
                try {
                  final now = DateTime.now();
                  final weekDays = ['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'];
                  final todayIndex = now.weekday - 1;
                  final entryIndex = weekDays.indexOf(day);
                  if (entryIndex >= 0) {
                    dayDiff = todayIndex - entryIndex;
                    if (dayDiff < 0) dayDiff += 7; // Geçen haftaya sarkarsa pozitif yap
                  }
                } catch (_) {}
                String dayText = dayDiff == 0 ? 'Bugün' : '-${dayDiff}g';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
                    title: Text(entry.exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Set: ${entry.sets.where((s) => s.isCompleted).length}/${entry.setCount}'),
                        if (lastSet != null)
                          Text('Son: ${lastSet.actualReps} tekrar, ${lastSet.actualWeight.toStringAsFixed(1)} kg'),
                        Text('Tarih: $dayText'),
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  int _getTotalExercises() {
    int total = 0;
    for (var dayWorkouts in widget.completedWorkouts.values) {
      total += dayWorkouts.length;
    }
    return total;
  }

  int _getTotalSets() {
    int total = 0;
    for (var dayWorkouts in widget.completedWorkouts.values) {
      for (var entry in dayWorkouts) {
        if (entry is RoutineEntry) {
          total += entry.setCount;
        }
      }
    }
    return total;
  }

  double _getAverageSetsPerDay() {
    if (widget.completedWorkouts.isEmpty) return 0;
    return _getTotalSets() / widget.completedWorkouts.length;
  }
}

// Ana dosyadan sınıfları import et 