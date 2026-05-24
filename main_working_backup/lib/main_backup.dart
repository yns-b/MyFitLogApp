import 'package:flutter/material.dart';
import 'profile.dart';
import 'hesapla.dart';
import 'statistics.dart';

// Kullanıcı seviyesi için veri yapısı
class UserLevel {
  final String name;
  final String level; // 'Yeni Başlayan', 'Orta Seviye', 'İleri Seviye'
  final int minSets;
  final int maxSets;

  UserLevel({
    required this.name,
    required this.level,
    required this.minSets,
    required this.maxSets,
  });
}

// Global kullanıcı bilgileri
UserLevel? globalUserLevel;

// Global dil değişkeni
String globalLanguage = 'Türkçe';

void main() {
  runApp(const WeightTrackerApp());
}

class WeightTrackerApp extends StatelessWidget {
  const WeightTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Takip',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: globalUserLevel == null ? OnboardingScreen() : MainScreen(),
    );
  }
}

// --- Egzersiz ve Kas Grubu Modeli ---
class Exercise {
  final String name;
  final List<String> muscleGroups;
  final String mainMuscleGroup;
  final Map<String, double> muscleGroupRatios;
  
  const Exercise({
    required this.name, 
    required this.muscleGroups, 
    required this.mainMuscleGroup,
    this.muscleGroupRatios = const {},
  });
}

const List<Exercise> allExercises = [
  Exercise(name: 'Squat', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
  Exercise(name: 'Bench Press', muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], mainMuscleGroup: 'Göğüs'),
  Exercise(name: 'Deadlift', muscleGroups: ['Sırt', 'Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Sırt'),
  Exercise(name: 'Overhead Press', muscleGroups: ['Omuz', 'Triceps', 'Core'], mainMuscleGroup: 'Omuz'),
  Exercise(name: 'Barbell Row', muscleGroups: ['Sırt', 'Biceps', 'Core'], mainMuscleGroup: 'Sırt'),
  Exercise(name: 'Pull Up', muscleGroups: ['Sırt', 'Biceps'], mainMuscleGroup: 'Sırt'),
  Exercise(name: 'Lunge', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
  Exercise(name: 'Biceps Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
  Exercise(name: 'Triceps Extension', muscleGroups: ['Triceps'], mainMuscleGroup: 'Triceps'),
  Exercise(name: 'Leg Press', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
];

const List<String> weekDays = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

const Map<String, String> weekDayShort = {
  'Pazartesi': 'Pzt',
  'Salı': 'Sal',
  'Çarşamba': 'Çrş',
  'Perşembe': 'Prş',
  'Cuma': 'Cum',
  'Cumartesi': 'Cmt',
  'Pazar': 'Paz',
};

const Map<String, Color> weekDayColors = {
  'Pazartesi': Colors.purple,
  'Salı': Colors.blue,
  'Çarşamba': Colors.green,
  'Perşembe': Colors.amber,
  'Cuma': Colors.orange,
  'Cumartesi': Colors.brown,
  'Pazar': Colors.grey,
};

class SetEntry {
  final int targetReps;
  final double targetWeight;
  int actualReps;
  double actualWeight;
  bool isCompleted;
  
  SetEntry({
    required this.targetReps,
    required this.targetWeight,
    int? actualReps,
    double? actualWeight,
    this.isCompleted = false,
  })  : actualReps = actualReps ?? targetReps,
        actualWeight = actualWeight ?? targetWeight;

  SetEntry copyWith({int? actualReps, double? actualWeight, bool? isCompleted}) {
    return SetEntry(
      targetReps: targetReps,
      targetWeight: targetWeight,
      actualReps: actualReps ?? this.actualReps,
      actualWeight: actualWeight ?? this.actualWeight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class RoutineEntry {
  final Exercise exercise;
  final int setCount;
  final List<SetEntry> sets;
  RoutineEntry({required this.exercise, required this.setCount, required this.sets});
}



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WeekScreen(),
    const HesaplaScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Rutin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Hesapla',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'İstatistikler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

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

    // WeekScreen'den static cache'i kullan
    final completedWorkouts = _WeekScreenState._cachedCompletedWorkouts;
    
    // Eğer hiç tamamlanmış antrenman yoksa tüm değerler 0 kalır
    if (completedWorkouts.isEmpty) {
      return muscleSets;
    }

    for (var dayWorkouts in completedWorkouts.values) {
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
        .where((e) => e.value < 12) // 12'den küçük tüm değerler (0 dahil)
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final muscleSets = _weeklyMuscleSets;
    final undertrainedMuscles = _undertrainedMuscles;
    final completedWorkouts = _WeekScreenState._cachedCompletedWorkouts;
    

    
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uyarı bölümü
            if (undertrainedMuscles.isNotEmpty && completedWorkouts.isNotEmpty) ...[
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
                      'Şu kas gruplarını haftada ${globalUserLevel?.minSets ?? 12} setten az çalıştırdın:\n${undertrainedMuscles.join(', ')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Haftalık kas grubu set istatistikleri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Haftalık Kas Grubu Set İstatistikleri',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Basit bar chart (fl_chart olmadan)
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        itemCount: muscleSets.length,
                        itemBuilder: (context, index) {
                          final entry = muscleSets.entries.elementAt(index);
                          Color barColor;
                          if (entry.value == 0) {
                            barColor = Colors.grey;
                          } else if (entry.value >= 12) {
                            barColor = Colors.green;
                          } else {
                            barColor = Colors.red;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 16,
                                    width: (entry.value / 20 * 150).clamp(0, 150),
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${entry.value}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Renk açıklaması
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        const Text('12+ set (Yeterli)'),
                        const SizedBox(width: 16),
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text('1-11 set (Eksik)'),
                        const SizedBox(width: 16),
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('0 set'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Genel istatistikler
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Genel İstatistikler',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Toplam Gün',
                            completedWorkouts.length.toString(),
                            Icons.calendar_today,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Toplam Egzersiz',
                            completedWorkouts.values.fold(0, (sum, entries) => sum + entries.length).toString(),
                            Icons.fitness_center,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Toplam Set',
                            muscleSets.values.fold(0, (sum, count) => sum + count).toString(),
                            Icons.repeat,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Ortalama Set/Gün',
                            completedWorkouts.isNotEmpty 
                              ? (muscleSets.values.fold(0, (sum, count) => sum + count) / completedWorkouts.length).round().toString()
                              : '0',
                            Icons.analytics,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  // Sadece kullanıcı tarafından eklenen günler
  Map<String, List<RoutineEntry>> _weeklyRoutine = {};
  // Her gün için son tamamlanma tarihi
  Map<String, DateTime> _lastCompleted = {};
  // Sadece tamamlanan antrenmanlar (istatistik için)
  Map<String, List<RoutineEntry>> _completedWorkouts = {
    // Test verisi ekleyelim
    'Pazartesi': [
      RoutineEntry(
        exercise: allExercises[1], // Bench Press
        setCount: 3,
        sets: [],
      ),
      RoutineEntry(
        exercise: allExercises[3], // Overhead Press
        setCount: 3,
        sets: [],
      ),
    ],
    'Salı': [
      RoutineEntry(
        exercise: allExercises[2], // Deadlift
        setCount: 3,
        sets: [],
      ),
    ],
    'Çarşamba': [
      RoutineEntry(
        exercise: allExercises[4], // Machine Curl
        setCount: 3,
        sets: [],
      ),
    ],
  };
  
  bool _warningShown = false;
  // Günlerin sırası (görüntüleme sırası)
  List<String> _dayOrder = [];
  // Gün adı değiştirildiğinde orijinal ismi korumak için
  Map<String, String> _originalDayNames = {};
  
  // Dinamik sporcu seçimi için
  late AthleteQuote _currentAthlete;

  // Static cache - widget yeniden oluşturulduğunda korunur
  static Map<String, List<RoutineEntry>> _cachedWeeklyRoutine = {};
  static List<String> _cachedDayOrder = [];
  static Map<String, String> _cachedOriginalDayNames = {};
  static Map<String, DateTime> _cachedLastCompleted = {};
  static Map<String, List<RoutineEntry>> _cachedCompletedWorkouts = {};
  static Map<String, List<ExerciseHistory>> _cachedExerciseHistory = {};
  
  // Dil değiştirme metodu
  static void setLanguage(String language) {
    globalLanguage = language;
  }
  
  @override
  void initState() {
    super.initState();
    // Cache'den verileri yükle
    _weeklyRoutine = Map.from(_cachedWeeklyRoutine);
    _dayOrder = List.from(_cachedDayOrder);
    _originalDayNames = Map.from(_cachedOriginalDayNames);
    _lastCompleted = Map.from(_cachedLastCompleted);
    _completedWorkouts = Map.from(_cachedCompletedWorkouts);
    
    // Rastgele sporcu seç
    _currentAthlete = athleteQuotes[DateTime.now().millisecondsSinceEpoch % athleteQuotes.length];
  }

  @override
  void dispose() {
    // Verileri cache'e kaydet
    _cachedWeeklyRoutine = Map.from(_weeklyRoutine);
    _cachedDayOrder = List.from(_dayOrder);
    _cachedOriginalDayNames = Map.from(_originalDayNames);
    _cachedLastCompleted = Map.from(_lastCompleted);
    _cachedCompletedWorkouts = Map.from(_completedWorkouts);
    super.dispose();
  }

  // Egzersiz geçmişini kaydet
  static void saveExerciseHistory(String exerciseName, double weight, int reps, int sets) {
    final history = ExerciseHistory(
      exerciseName: exerciseName,
      date: DateTime.now(),
      weight: weight,
      reps: reps,
      sets: sets,
    );
    
    if (!_cachedExerciseHistory.containsKey(exerciseName)) {
      _cachedExerciseHistory[exerciseName] = [];
    }
    _cachedExerciseHistory[exerciseName]!.add(history);
    
    // Son 10 kaydı tut (eski kayıtları sil)
    if (_cachedExerciseHistory[exerciseName]!.length > 10) {
      _cachedExerciseHistory[exerciseName] = _cachedExerciseHistory[exerciseName]!.skip(
        _cachedExerciseHistory[exerciseName]!.length - 10
      ).toList();
    }
  }

  // Egzersiz geçmişini al
  static List<ExerciseHistory> getExerciseHistory(String exerciseName) {
    return _cachedExerciseHistory[exerciseName] ?? [];
  }

  // Haftalık kas grubu toplam setleri
  Map<String, int> get _weeklyMuscleSets {
    final Map<String, int> muscleSets = {
      'Bacak': 0,
      'Kalça': 0,
      'Core': 0,
      'Göğüs': 0,
      'Triceps': 0,
      'Omuz': 0,
      'Sırt': 0,
      'Biceps': 0,
    };
    for (var entries in _completedWorkouts.values) {
      for (var entry in entries) {
        for (var muscle in entry.exercise.muscleGroups) {
          if (muscle == entry.exercise.mainMuscleGroup) {
            muscleSets[muscle] = (muscleSets[muscle] ?? 0) + entry.setCount;
          } else {
            muscleSets[muscle] = (muscleSets[muscle] ?? 0) + 1;
          }
        }
      }
    }
    return muscleSets;
  }

  List<String> get _undertrainedMuscles {
    // Kullanıcı seviyesine göre minimum set sayısını belirle
    int minSets = 12; // Varsayılan değer
    if (globalUserLevel != null) {
      minSets = globalUserLevel!.minSets;
    }
    
    return _weeklyMuscleSets.entries
        .where((e) => e.value < minSets) // Kullanıcı seviyesine göre minimum set
        .map((e) => e.key)
        .toList();
  }

  void _openDayDetail(String day) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => DayDetailScreen(
          day: day,
          entries: List<RoutineEntry>.from(_weeklyRoutine[day]!),
          lastCompleted: _lastCompleted[day],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _weeklyRoutine[day] = result['entries'] as List<RoutineEntry>;
        if (result['completed'] == true) {
          _lastCompleted[day] = DateTime.now();
          _completedWorkouts[day] = List<RoutineEntry>.from(result['entries'] as List<RoutineEntry>);
          // Cache'i hemen güncelle
          _cachedCompletedWorkouts[day] = List<RoutineEntry>.from(result['entries'] as List<RoutineEntry>);
          _cachedLastCompleted[day] = DateTime.now();
          // Sadece haftanın son günü antrenmanı bitirildiğinde uyarı göster
          if (_isLastDayOfWeek(day)) {
            _showWarningIfNeeded();
          }
        }
      });
    }
  }
  bool _isLastDayOfWeek(String currentDay) {
    // Eklenen günlerin son günü mü kontrol et
    final addedDays = _weeklyRoutine.keys.toList();
    if (addedDays.isEmpty) return false;
    
    // Haftanın günlerini sırala ve son günü bul
    final sortedDays = addedDays.where((day) => weekDays.contains(day)).toList();
    sortedDays.sort((a, b) => weekDays.indexOf(a).compareTo(weekDays.indexOf(b)));
    
    return sortedDays.isNotEmpty && sortedDays.last == currentDay;
  }
  
  void _showWarningIfNeeded() {
    final undertrained = _undertrainedMuscles;
    if (undertrained.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWarningDialog(undertrained);
      });
    }
  }

  // Cache'i temizle (test için)
  void _clearCache() {
    setState(() {
      _cachedWeeklyRoutine.clear();
      _cachedDayOrder.clear();
      _cachedOriginalDayNames.clear();
      _cachedLastCompleted.clear();
      _cachedCompletedWorkouts.clear();
      _weeklyRoutine.clear();
      _dayOrder.clear();
      _originalDayNames.clear();
      _lastCompleted.clear();
      _completedWorkouts.clear();
    });
  }

  void _addDay() async {
    // Kullanıcıya eklenmemiş günleri seçtir
    final availableDays = weekDays.where((d) => !_weeklyRoutine.containsKey(d)).toList();
    if (availableDays.isEmpty) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Gün Seç'),
        children: availableDays
            .map((d) => SimpleDialogOption(
                  child: Text(d),
                  onPressed: () => Navigator.pop(context, d),
                ))
            .toList(),
      ),
    );
    if (selected != null && !_weeklyRoutine.containsKey(selected)) {
      setState(() {
        _weeklyRoutine[selected] = [];
        _dayOrder.add(selected);
        _originalDayNames[selected] = selected;
      });
    }
  }

  void _removeDay(String day) {
    setState(() {
      _weeklyRoutine.remove(day);
      _dayOrder.remove(day);
      _originalDayNames.remove(day);
    });
  }
  void _moveDayUp(int index) {
    if (index > 0) {
      setState(() {
        final day = _dayOrder[index];
        _dayOrder.removeAt(index);
        _dayOrder.insert(index - 1, day);
      });
    }
  }

  void _moveDayDown(int index) {
    if (index < _dayOrder.length - 1) {
      setState(() {
        final day = _dayOrder[index];
        _dayOrder.removeAt(index);
        _dayOrder.insert(index + 1, day);
      });
    }
  }

  void _editDayName(String day) async {
    final TextEditingController controller = TextEditingController(text: day);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gün Adını Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Gün Adı',
            hintText: 'Örn: Pazartesi Göğüs',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        // Gün adını değiştir
        final entries = _weeklyRoutine[day];
        final lastCompleted = _lastCompleted[day];
        final completedWorkouts = _completedWorkouts[day];
        final originalName = _originalDayNames[day];
        final currentIndex = _dayOrder.indexOf(day);
        
        _weeklyRoutine.remove(day);
        _lastCompleted.remove(day);
        _completedWorkouts.remove(day);
        _originalDayNames.remove(day);
        
        _weeklyRoutine[result] = entries ?? [];
        if (lastCompleted != null) _lastCompleted[result] = lastCompleted;
        if (completedWorkouts != null) _completedWorkouts[result] = completedWorkouts;
        // Aynı pozisyonda kalması için
        _dayOrder[currentIndex] = result;
        _originalDayNames[result] = originalName ?? day;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final muscleSets = _weeklyMuscleSets;
    final undertrainedMuscles = _undertrainedMuscles;
    final completedWorkouts = _WeekScreenState._cachedCompletedWorkouts;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.fitness_center, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Haftalık Rutinini Seç'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red),
            onPressed: _clearCache,
            tooltip: 'Cache Temizle',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dinamik sporcu banner'ı
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.withOpacity(0.8),
                    Colors.purple.withOpacity(0.6),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black,
                            Colors.grey[800]!,
                            Colors.grey[600]!,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sports, color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              _currentAthlete.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _currentAthlete.sport,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '"${globalLanguage == 'Türkçe' ? _currentAthlete.quoteTurkish : _currentAthlete.quote}"',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Başlık ve gün ekle butonu
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.deepPurple, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Haftalık Rutin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _addDay,
                      icon: Icon(Icons.add_circle, color: Colors.white),
                      label: Text('Yeni Gün Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Günler listesi
            if (_weeklyRoutine.isEmpty)
              Container(
                height: 300,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(32),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Henüz gün eklemedin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Yukarıdaki butona tıklayarak ilk gününü ekle',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dayOrder.length,
                itemBuilder: (context, i) {
                  final day = _dayOrder[i];
                  final count = _weeklyRoutine[day]!.length;
                  final originalDay = _originalDayNames[day] ?? day;
                  final short = weekDayShort[originalDay] ?? '';
                  final color = weekDayColors[originalDay] ?? Colors.black;
                  String? completedText;
                  if (_lastCompleted[day] != null) {
                    final diff = DateTime.now().difference(_lastCompleted[day]!).inDays;
                    completedText = '-${diff}g';
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openDayDetail(day),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    short,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      day,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.fitness_center,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          count > 0 ? '$count egzersiz' : 'Egzersiz yok',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  if (completedText != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: Text(
                                        completedText,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                                        onPressed: () => _editDayName(day),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.keyboard_arrow_up, size: 20),
                                        onPressed: i > 0 ? () => _moveDayUp(i) : null,
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.keyboard_arrow_down, size: 20),
                                        onPressed: i < _dayOrder.length - 1 ? () => _moveDayDown(i) : null,
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _removeDay(day),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 24),
            
            // İstatistik butonu

            
            const SizedBox(height: 32), // Alt boşluk
          ],
        ),
      ),


    );
  }
  void _showWarningDialog(List<String> undertrained) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Uyarı'),
        content: Text(
          'Şu kas gruplarını haftada 12 setten az çalıştırdın:\n\n${undertrained.join(', ')}\n\nGenel fitness prensiplerine göre her ana kas grubunu haftada en az 12 set çalıştırmalısın!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

// Kas grubu ikonları (emoji)
const Map<String, String> muscleGroupIcons = {
  'Göğüs': '🏋️‍♂️',
  'Omuz': '💪',
  'Bacak': '🦵',
  'Sırt': '🏋️',
  'Biceps': '💪',
  'Triceps': '🤜',
  'Core': '💪',
  'Kalça': '🍑',
};

// Kas grubu ve egzersiz eşlemesi
const Map<String, List<Exercise>> muscleGroupExercises = {
  'Göğüs': [
    Exercise(
      name: 'Barbell Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Triceps': 0.5, 'Omuz': 0.3},
    ),
    Exercise(
      name: 'Incline Barbell Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Triceps': 0.5, 'Omuz': 0.3},
    ),
    Exercise(
      name: 'Dumbbell Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Triceps': 0.4, 'Omuz': 0.3},
    ),
    Exercise(
      name: 'Incline Dumbbell Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Triceps': 0.4, 'Omuz': 0.3},
    ),
    Exercise(
      name: 'Close-Grip Bench Press', 
      muscleGroups: ['Triceps', 'Göğüs'], 
      mainMuscleGroup: 'Triceps',
      muscleGroupRatios: {'Göğüs': 0.3},
    ),
    Exercise(
      name: 'Dips (Chest Version)', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Triceps': 0.6, 'Omuz': 0.2},
    ),
    Exercise(
      name: 'Push-Up', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz', 'Core'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Triceps': 0.4, 'Omuz': 0.2, 'Core': 0.3},
    ),
    Exercise(
      name: 'Smith Machine Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Triceps': 0.5, 'Omuz': 0.3},
    ),
    Exercise(
      name: 'Dumbbell Bench Fly', 
      muscleGroups: ['Göğüs'], 
      mainMuscleGroup: 'Göğüs',
    ),
  ],
  'Omuz': [
    Exercise(
      name: 'Overhead Barbell Press (Military Press)', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Dumbbell Shoulder Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Push Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Arnold Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Behind-the-Neck Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Barbell Upright Row', 
      muscleGroups: ['Omuz', 'Sırt'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Sırt': 0.3},
    ),
    Exercise(
      name: 'Dumbbell Lateral Raise', 
      muscleGroups: ['Omuz'], 
      mainMuscleGroup: 'Omuz',
    ),
    Exercise(
      name: 'Facepull', 
      muscleGroups: ['Omuz', 'Sırt'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Sırt': 0.3},
    ),
    Exercise(
      name: 'Machine Shoulder Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Smith Machine Shoulder Press', 
      muscleGroups: ['Omuz', 'Triceps'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Triceps': 0.4},
    ),
    Exercise(
      name: 'Reverse Machine Flys', 
      muscleGroups: ['Omuz', 'Sırt'], 
      mainMuscleGroup: 'Omuz',
      muscleGroupRatios: {'Sırt': 0.3},
    ),
    Exercise(
      name: 'Single Arm Pulley Machine Raise', 
      muscleGroups: ['Omuz'], 
      mainMuscleGroup: 'Omuz',
    ),
  ],
  'Sırt': [
    Exercise(
      name: 'Pull-Up', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.6},
    ),
    Exercise(
      name: 'Chin-Up', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.6},
    ),
    Exercise(
      name: 'Lat Pulldown', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.4},
    ),
    Exercise(
      name: 'Barbell Row', 
      muscleGroups: ['Sırt', 'Biceps', 'Omuz'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.6, 'Omuz': 0.2},
    ),
    Exercise(
      name: 'Dumbbell Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.5},
    ),
    Exercise(
      name: 'T-Bar Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.5},
    ),
    Exercise(
      name: 'Pendlay Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.5},
    ),
    Exercise(
      name: 'Smith Machine Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.4},
    ),
    Exercise(
      name: 'Machine Row', 
      muscleGroups: ['Sırt', 'Biceps'], 
      mainMuscleGroup: 'Sırt',
      muscleGroupRatios: {'Biceps': 0.4},
    ),
  ],
  'Biceps': [
    Exercise(name: 'Barbell Biceps Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Dumbbell Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Concentration Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Dumbbell Hammer Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Machine Biceps Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Scott Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
    Exercise(name: 'Machine Curl', muscleGroups: ['Biceps'], mainMuscleGroup: 'Biceps'),
  ],
  'Triceps': [
    Exercise(
      name: 'Dips', 
      muscleGroups: ['Triceps', 'Göğüs', 'Omuz'], 
      mainMuscleGroup: 'Triceps',
      muscleGroupRatios: {'Göğüs': 0.3, 'Omuz': 0.2},
    ),
    Exercise(
      name: 'Close Grip Bench', 
      muscleGroups: ['Triceps', 'Göğüs'], 
      mainMuscleGroup: 'Triceps',
      muscleGroupRatios: {'Göğüs': 0.3},
    ),
    Exercise(
      name: 'Ez-Bar French Press', 
      muscleGroups: ['Triceps'], 
      mainMuscleGroup: 'Triceps',
    ),
    Exercise(
      name: 'Overhead Pulley Triceps', 
      muscleGroups: ['Triceps'], 
      mainMuscleGroup: 'Triceps',
    ),
    Exercise(
      name: 'Pulley Machine Triceps', 
      muscleGroups: ['Triceps'], 
      mainMuscleGroup: 'Triceps',
    ),
  ],
  'Bacak': [
    Exercise(name: 'Barbell Back Squat', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Front Squat', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Bulgarian Split Squat', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Lunges (Walking)', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Lunges (Static)', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Step-Up', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Romanian Deadlift', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Sumo Deadlift', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Leg Press', muscleGroups: ['Bacak', 'Kalça'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Deadlift', muscleGroups: ['Bacak', 'Sırt', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Trap Bar Deadlift', muscleGroups: ['Bacak', 'Sırt', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
    Exercise(name: 'Squat', muscleGroups: ['Bacak', 'Kalça', 'Core'], mainMuscleGroup: 'Bacak'),
  ],
  'Karın': [
    Exercise(name: 'Turkish Get-Up', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Farmer\'s Walk', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Bear Crawl', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Plank', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
  ],
  'Kalça': [
    Exercise(name: 'Hip Thrust', muscleGroups: ['Kalça', 'Bacak'], mainMuscleGroup: 'Kalça'),
    Exercise(name: 'Glute Bridge', muscleGroups: ['Kalça', 'Bacak'], mainMuscleGroup: 'Kalça'),
    Exercise(name: 'Good Morning', muscleGroups: ['Kalça', 'Sırt', 'Core'], mainMuscleGroup: 'Kalça'),
    Exercise(name: 'Kettlebell Swing', muscleGroups: ['Kalça', 'Core', 'Omuz'], mainMuscleGroup: 'Kalça'),
  ],
};
const List<String> mainMuscleGroups = [
  'Göğüs',
  'Omuz',
  'Bacak',
  'Sırt',
  'Biceps',
  'Triceps',
  'Core',
  'Kalça',
];

class DayDetailScreen extends StatefulWidget {
  final String day;
  final List<RoutineEntry> entries;
  final DateTime? lastCompleted;
  const DayDetailScreen({super.key, required this.day, required this.entries, this.lastCompleted});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late List<RoutineEntry> _entries;
  String? _selectedMuscleGroup;
  Exercise? _selectedExercise;
  late TextEditingController _weightController;
  late TextEditingController _setCountController;
  late TextEditingController _repsController;
  bool _workoutStarted = false;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _showExerciseForm = false; // Egzersiz ekleme formunu göster/gizle (varsayılan gizli)
  bool _showSaveButton = false; // Kaydet butonunu göster/gizle
  // Antrenman sırasında yapılanlar (günlük)
  Map<String, List<SetEntry>> _workoutSets = {};

  // Son yapılan egzersiz bilgisini bul
  RoutineEntry? _findLastEntryForExercise(Exercise exercise) {
    for (var i = _entries.length - 1; i >= 0; i--) {
      if (_entries[i].exercise.name == exercise.name) {
        return _entries[i];
      }
    }
    return null;
  }

  bool _routineExists(Exercise exercise, int setCount) {
    return _entries.any((e) => e.exercise.name == exercise.name && e.setCount == setCount);
  }

  @override
  void initState() {
    super.initState();
    _entries = List<RoutineEntry>.from(widget.entries);
    _weightController = TextEditingController(text: '');
    _setCountController = TextEditingController(text: '');
    _repsController = TextEditingController(text: '8');
    
    // Eğer hiç egzersiz yoksa formu aç
    if (_entries.isEmpty) {
      _showExerciseForm = true;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _setCountController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _addEntry() {
    final weight = double.tryParse(_weightController.text);
    final setCount = int.tryParse(_setCountController.text);
    final reps = int.tryParse(_repsController.text);
    if (_selectedExercise != null && weight != null && setCount != null && reps != null) {
      if (_routineExists(_selectedExercise!, setCount)) {
        // Aynı egzersiz ve set sayısı ile tekrar eklenmesin
        return;
      }
      setState(() {
        _entries.add(RoutineEntry(
          exercise: _selectedExercise!,
          setCount: setCount,
          sets: List.generate(setCount, (i) => SetEntry(targetReps: reps, targetWeight: weight)),
        ));
        
        // Geçmiş verilerini kaydet
        _WeekScreenState.saveExerciseHistory(_selectedExercise!.name, weight, reps, setCount);
        
        // Egzersiz eklendikten sonra formu gizleme satırını kaldır
        _selectedExercise = null;
        _selectedMuscleGroup = null;
        _setCountController.clear();
        _weightController.clear();
        _repsController.text = '8'; // Default tekrar değeri
        _showSaveButton = true; // Kaydet butonunu göster
      });
    }
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  void _updateEntryWeight(int entryIndex, int setIndex, double delta) {
    setState(() {
      final entry = _entries[entryIndex];
      final sets = List<SetEntry>.from(entry.sets);
      final set = sets[setIndex];
      sets[setIndex] = set.copyWith(actualWeight: (set.actualWeight + delta).clamp(0, 9999));
      _entries[entryIndex] = RoutineEntry(
        exercise: entry.exercise,
        setCount: entry.setCount,
        sets: sets,
      );
    });
  }

  void _updateEntryReps(int entryIndex, int setIndex, int delta) {
    setState(() {
      final entry = _entries[entryIndex];
      final sets = List<SetEntry>.from(entry.sets);
      final set = sets[setIndex];
      sets[setIndex] = set.copyWith(actualReps: (set.actualReps + delta).clamp(0, 99));
      _entries[entryIndex] = RoutineEntry(
        exercise: entry.exercise,
        setCount: entry.setCount,
        sets: sets,
      );
    });
  }

  void _openSetDetail(int entryIndex) async {
    final entry = _entries[entryIndex];
    final updatedSets = await Navigator.push<List<SetEntry>>(
      context,
      MaterialPageRoute(
        builder: (context) => SetDetailScreen(
          exercise: entry.exercise,
          sets: List<SetEntry>.from(entry.sets),
        ),
      ),
    );
    if (updatedSets != null) {
      setState(() {
        _entries[entryIndex] = RoutineEntry(
          exercise: entry.exercise,
          setCount: entry.setCount,
          sets: updatedSets,
        );
      });
    }
  }

  void _onExerciseChanged(Exercise? newExercise) {
    setState(() {
      _selectedExercise = newExercise;
      if (newExercise != null) {
        final last = _findLastEntryForExercise(newExercise);
        if (last != null) {
          _weightController.text = last.sets.first.targetWeight.toStringAsFixed(0);
          _setCountController.text = last.setCount.toString();
          _repsController.text = last.sets.first.targetReps.toString();
        } else {
          // Varsayılan değerler
          _weightController.text = '20';
          _setCountController.text = '3';
          _repsController.text = '8';
        }
      }
    });
  }





  void _changeWeightField(double delta) {
    final current = double.tryParse(_weightController.text) ?? 0;
    final newValue = (current + delta).clamp(0, 9999);
    setState(() {
      _weightController.text = newValue.toStringAsFixed(0);
    });
  }

  void _updateCurrentSetReps(int delta) {
    if (_currentExerciseIndex < _entries.length && _currentSetIndex < _entries[_currentExerciseIndex].sets.length) {
      setState(() {
        final entry = _entries[_currentExerciseIndex];
        final sets = List<SetEntry>.from(entry.sets);
        final set = sets[_currentSetIndex];
        sets[_currentSetIndex] = set.copyWith(actualReps: (set.actualReps + delta).clamp(0, 99));
        _entries[_currentExerciseIndex] = RoutineEntry(
          exercise: entry.exercise,
          setCount: entry.setCount,
          sets: sets,
        );
      });
    }
  }

  void _updateCurrentSetWeight(double delta) {
    if (_currentExerciseIndex < _entries.length && _currentSetIndex < _entries[_currentExerciseIndex].sets.length) {
      setState(() {
        final entry = _entries[_currentExerciseIndex];
        final sets = List<SetEntry>.from(entry.sets);
        final set = sets[_currentSetIndex];
        sets[_currentSetIndex] = set.copyWith(actualWeight: (set.actualWeight + delta).clamp(0, 9999));
        _entries[_currentExerciseIndex] = RoutineEntry(
          exercise: entry.exercise,
          setCount: entry.setCount,
          sets: sets,
        );
      });
    }
  }

  void _completeCurrentSet() {
    if (_currentExerciseIndex < _entries.length && _currentSetIndex < _entries[_currentExerciseIndex].sets.length) {
      setState(() {
        final entry = _entries[_currentExerciseIndex];
        final sets = List<SetEntry>.from(entry.sets);
        sets[_currentSetIndex] = sets[_currentSetIndex].copyWith(isCompleted: true);
        _entries[_currentExerciseIndex] = RoutineEntry(
          exercise: entry.exercise,
          setCount: entry.setCount,
          sets: sets,
        );

        // Sonraki sete geç
        _currentSetIndex++;
        
        // Eğer bu egzersizin tüm setleri tamamlandıysa, sonraki egzersize geç
        if (_currentSetIndex >= entry.setCount) {
          _currentSetIndex = 0;
          _currentExerciseIndex++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    RoutineEntry? lastEntry;
    if (_selectedExercise != null) {
      lastEntry = _findLastEntryForExercise(_selectedExercise!);
    }
    // Seçili kas grubuna göre egzersizler
    final exercises = _selectedMuscleGroup != null ? muscleGroupExercises[_selectedMuscleGroup!] ?? [] : <Exercise>[];
    String? lastCompletedText;
    if (widget.lastCompleted != null) {
      final diff = DateTime.now().difference(widget.lastCompleted!).inDays;
      lastCompletedText = 'Son tamamlanma: -${diff}g';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.day} Rutini'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, {'entries': _entries, 'completed': false}),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastCompletedText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(lastCompletedText, style: const TextStyle(color: Colors.green)),
              ),
            const Text('Kas Grubu ve Egzersiz Ekle:', style: TextStyle(fontWeight: FontWeight.bold)),
            // Profesyonel egzersiz seçme bölümü
            // Egzersiz ekleme alanı - koşullu gösterim
            if (_showExerciseForm) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        const Text(
                          'Yeni Egzersiz Ekle',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                          onPressed: () {
                            setState(() {
                              _showExerciseForm = false;
                            });
                          },
                          tooltip: 'Formu Kapat',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Kas grubu seçimi
                    const Text('1. Kas Grubu Seçin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Kas Grubu',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        hint: const Text('Kas grubunu seçin'),
                        value: _selectedMuscleGroup,
                        items: mainMuscleGroups.map((g) => DropdownMenuItem(
                          value: g,
                          child: Row(
                            children: [
                              Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                              const SizedBox(width: 8),
                              Text(g),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedMuscleGroup = v;
                            _selectedExercise = null;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Egzersiz seçimi
                    if (_selectedMuscleGroup != null) ...[
                      const Text('2. Egzersiz Seçin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<Exercise>(
                          decoration: const InputDecoration(
                            labelText: 'Egzersiz',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          hint: const Text('Egzersizi seçin'),
                          value: _selectedExercise,
                          items: exercises.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          )).toList(),
                          onChanged: _onExerciseChanged,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Set ve kg girişi
                    if (_selectedExercise != null) ...[
                      const Text('3. Set ve Ağırlık Belirleyin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Set sayısı
                          Expanded(
                            child: Container(
                              height: 50,
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Set',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                controller: _setCountController,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tekrar sayısı
                          Expanded(
                            child: Container(
                              height: 50,
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Tekrar',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                controller: _repsController,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Ağırlık girişi
                          Expanded(
                            child: Container(
                              height: 50,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                    onPressed: () => _changeWeightField(-5),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'KG',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      keyboardType: TextInputType.number,
                                      controller: _weightController,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                    onPressed: () => _changeWeightField(5),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Ekle butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addEntry,
                          icon: const Icon(Icons.add),
                          label: const Text('Egzersizi Rutine Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (lastEntry != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  'Son: ${lastEntry.setCount} set, ${lastEntry.sets.first.targetWeight} kg',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Günün Rutinleri:', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                if (!_showExerciseForm)
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.deepPurple, size: 28),
                    onPressed: () {
                      setState(() {
                        _showExerciseForm = true;
                      });
                    },
                    tooltip: 'Yeni Egzersiz Ekle',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entries.length,
              itemBuilder: (context, i) {
                final entry = _entries[i];
                final icon = muscleGroupIcons[entry.exercise.mainMuscleGroup] ?? '🏋️‍♂️';
                // Egzersizin tamamlanıp tamamlanmadığını kontrol et
                bool isCompleted = entry.sets.every((set) => set.isCompleted);
                
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 28)),
                      if (isCompleted) ...[
                        SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                  title: Text(
                    '${entry.exercise.name} - ${entry.setCount} set',
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.black,
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'Kas grupları: ${entry.exercise.muscleGroups.join(', ')}',
                    style: TextStyle(
                      color: isCompleted ? Colors.green[700] : Colors.grey[600],
                    ),
                  ),
                  tileColor: isCompleted ? Colors.green.withOpacity(0.1) : null,
                  onTap: () => _openSetDetail(i),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEntry(i),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            if (!_workoutStarted)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Antrenmanı Başlat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    if (_entries.isNotEmpty) {
                      setState(() {
                        _workoutStarted = true;
                        _currentExerciseIndex = 0;
                        _currentSetIndex = 0;
                      });
                    }
                  },
                ),
              ),
            if (_workoutStarted) ...[
              // İlerleme göstergesi
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Antrenman İlerlemesi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          '${_currentExerciseIndex < _entries.length ? _currentExerciseIndex + 1 : _entries.length}/${_entries.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _entries.isNotEmpty 
                        ? (_currentExerciseIndex < _entries.length ? _currentExerciseIndex + 1 : _entries.length) / _entries.length 
                        : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  ],
                ),
              ),
              // Mevcut egzersiz
              if (_currentExerciseIndex < _entries.length) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fitness_center, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            _entries[_currentExerciseIndex].exercise.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Set ilerleme kutucuğu
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Set İlerlemesi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  '${_currentSetIndex + 1}/${_entries[_currentExerciseIndex].setCount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _entries[_currentExerciseIndex].setCount > 0 
                                ? (_currentSetIndex + 1) / _entries[_currentExerciseIndex].setCount 
                                : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Hedef: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetReps} tekrar, ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetWeight.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Tekrar: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualReps}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'KG: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualWeight.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.remove),
                            label: Text('Tekrar -'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetReps(-1),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Tekrar +'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetReps(1),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.remove),
                            label: Text('KG -'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetWeight(-2.5),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('KG +'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetWeight(2.5),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.check),
                        label: Text('Seti Tamamla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: _completeCurrentSet,
                      ),
                    ],
                  ),
                ),
              ],
              // Antrenmanı bitir butonu
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Antrenmanı Bitir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {'entries': _entries, 'completed': true});
                  },
                ),
              ),
              // Tüm egzersizler tamamlandığında tebrik mesajı
              if (_currentExerciseIndex >= _entries.length && _entries.isNotEmpty) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.celebration, color: Colors.green, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Tebrikler! Tüm egzersizler tamamlandı! 🎉',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),

          ],
        ),
      ),
      floatingActionButton: _showSaveButton ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _showSaveButton = false; // Kaydet butonunu gizle
          });
          Navigator.pop(context, {'entries': _entries, 'completed': false});
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.save),
      ) : null,

    );
  }
}

// Yeni: Set detay ekranı
class SetDetailScreen extends StatefulWidget {
  final Exercise exercise;
  final List<SetEntry> sets;
  const SetDetailScreen({super.key, required this.exercise, required this.sets});

  @override
  State<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends State<SetDetailScreen> {
  late List<SetEntry> _sets;

  @override
  void initState() {
    super.initState();
    _sets = List<SetEntry>.from(widget.sets);
  }

  void _updateWeight(int i, double delta) {
    setState(() {
      final set = _sets[i];
      _sets[i] = set.copyWith(actualWeight: (set.actualWeight + delta).clamp(0, 9999));
    });
  }

  void _updateReps(int i, int delta) {
    setState(() {
      final set = _sets[i];
      _sets[i] = set.copyWith(actualReps: (set.actualReps + delta).clamp(0, 99));
    });
  }

  void _completeSet(int i) {
    setState(() {
      _sets[i] = _sets[i].copyWith(isCompleted: true);
    });
  }

  Widget _buildSetDetailHistorySection() {
    final history = _WeekScreenState.getExerciseHistory(widget.exercise.name);
    
    if (history.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
            SizedBox(width: 8),
            Text(
              'Bu egzersiz için henüz geçmiş kaydı yok',
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ],
        ),
      );
    }

    final latest = history.last;
    final previous = history.length > 1 ? history[history.length - 2] : null;
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Colors.green[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Son Antrenman Geçmişi',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Son antrenman
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'En Son:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text('${latest.weight} kg × ${latest.reps} tekrar'),
                      Text('${latest.sets} set'),
                    ],
                  ),
                ),
                Text(
                  '${latest.date.day}/${latest.date.month}',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Önceki antrenman (varsa)
          if (previous != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Önceki:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text('${previous.weight} kg × ${previous.reps} tekrar'),
                        Text('${previous.sets} set'),
                      ],
                    ),
                  ),
                  Text(
                    '${previous.date.day}/${previous.date.month}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 8),
          Text(
            'Toplam ${history.length} antrenman kaydı',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _sets.where((s) => s.isCompleted).length;
    final totalCount = _sets.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple),
            ),
            child: Text(
              '$completedCount/$totalCount',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Geçmiş bilgileri
          _buildSetDetailHistorySection(),
          
          // İlerleme çubuğu
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İlerleme: $completedCount/$totalCount set',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${((completedCount / totalCount) * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalCount > 0 ? completedCount / totalCount : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sets.length,
              itemBuilder: (context, i) {
                final set = _sets[i];
                return Card(
                  color: set.isCompleted ? Colors.green[50] : null,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: set.isCompleted ? Colors.green : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Set ${i + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: set.isCompleted ? Colors.white : Colors.grey[700],
                                ),
                              ),
                            ),
                            Spacer(),
                            if (set.isCompleted)
                              Icon(Icons.check_circle, color: Colors.green, size: 24),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Hedef: ${set.targetReps} tekrar, ${set.targetWeight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Tekrar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                      onPressed: set.isCompleted ? null : () => _updateReps(i, -1),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                    Text(
                                      '${set.actualReps}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                      onPressed: set.isCompleted ? null : () => _updateReps(i, 1),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Ağırlık',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                      onPressed: set.isCompleted ? null : () => _updateWeight(i, -2.5),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                    Text(
                                      '${set.actualWeight.toStringAsFixed(1)} kg',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                      onPressed: set.isCompleted ? null : () => _updateWeight(i, 2.5),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (!set.isCompleted)
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.check),
                              label: Text('Seti Onayla'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () => _completeSet(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, _sets),
        child: const Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

// Egzersiz geçmişi için veri yapısı
class ExerciseHistory {
  final String exerciseName;
  final DateTime date;
  final double weight;
  final int reps;
  final int sets;

  ExerciseHistory({
    required this.exerciseName,
    required this.date,
    required this.weight,
    required this.reps,
    required this.sets,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'date': date.toIso8601String(),
      'weight': weight,
      'reps': reps,
      'sets': sets,
    };
  }

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) {
    return ExerciseHistory(
      exerciseName: json['exerciseName'],
      date: DateTime.parse(json['date']),
      weight: json['weight'].toDouble(),
      reps: json['reps'],
      sets: json['sets'],
    );
  }
}

// Sporcu verileri
class AthleteQuote {
  final String name;
  final String imageUrl;
  final String quote;
  final String quoteTurkish;
  final String sport;
  final List<Color> gradientColors;

  AthleteQuote({
    required this.name,
    required this.imageUrl,
    required this.quote,
    required this.quoteTurkish,
    required this.sport,
    required this.gradientColors,
  });
}

final List<AthleteQuote> athleteQuotes = [
  AthleteQuote(
    name: 'Muhammad Ali',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'Impossible is just a big word thrown around by small men who find it easier to live in the world they\'ve been given than to explore the power they have to change it.',
    quoteTurkish: 'İmkansız, sadece küçük adamların attığı büyük bir kelimedir. Onlar verilen dünyada yaşamayı, sahip oldukları gücü keşfetmekten daha kolay bulurlar.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Arnold Schwarzenegger',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'The difference between the impossible and the possible lies in determination.',
    quoteTurkish: 'İmkansız ile mümkün arasındaki fark kararlılıkta yatar.',
    sport: 'Bodybuilding',
    gradientColors: [Colors.purple, Colors.deepPurple, Colors.indigo],
  ),
  AthleteQuote(
    name: 'Michael Jordan',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'ve failed over and over and over again in my life and that is why I succeed.',
    quoteTurkish: 'Hayatımda tekrar tekrar başarısız oldum ve işte bu yüzden başarılıyım.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Usain Bolt',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ff2084a31?auto=format&fit=crop&w=800&q=80',
    quote: 'Don\'t think about the start of the race, think about the ending.',
    quoteTurkish: 'Yarışın başlangıcını düşünme, sonunu düşün.',
    sport: 'Athletics',
    gradientColors: [Colors.green, Colors.teal, Colors.cyan],
  ),
  AthleteQuote(
    name: 'Serena Williams',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I really think a champion is defined not by their wins but by how they can recover when they fall.',
    quoteTurkish: 'Bir şampiyonun tanımı kazanımları değil, düştüğünde nasıl toparlandığıdır.',
    sport: 'Tennis',
    gradientColors: [Colors.pink, Colors.red, Colors.orange],
  ),
  AthleteQuote(
    name: 'Cristiano Ronaldo',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'Your love makes me strong, your hate makes me unstoppable.',
    quoteTurkish: 'Sevgin beni güçlü yapar, nefretin beni durdurulamaz yapar.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Conor McGregor',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'There\'s no talent here, this is hard work. This is an obsession.',
    quoteTurkish: 'Burada yetenek yok, bu sıkı çalışma. Bu bir takıntı.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Kobe Bryant',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Great things come from hard work and perseverance. No excuses.',
    quoteTurkish: 'Büyük şeyler sıkı çalışma ve azimden gelir. Bahane yok.',
    sport: 'Basketball',
    gradientColors: [Colors.purple, Colors.deepPurple, Colors.black],
  ),
  AthleteQuote(
    name: 'Bruce Lee',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'The successful warrior is the average man, with laser-like focus.',
    quoteTurkish: 'Başarılı savaşçı, lazer gibi odaklanmış ortalama bir adamdır.',
    sport: 'Martial Arts',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Muhammad Ali',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'I am the greatest, I said that even before I knew I was.',
    quoteTurkish: 'Ben en büyüğüm, bunu bilmeden önce bile söylerdim.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Michael Phelps',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ff2084a31?auto=format&fit=crop&w=800&q=80',
    quote: 'You can\'t put a limit on anything. The more you dream, the farther you get.',
    quoteTurkish: 'Hiçbir şeye sınır koyamazsın. Ne kadar hayal edersen, o kadar ileri gidersin.',
    sport: 'Swimming',
    gradientColors: [Colors.blue, Colors.cyan, Colors.teal],
  ),
  AthleteQuote(
    name: 'Simone Biles',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'m not the next Usain Bolt or Michael Phelps. I\'m the first Simone Biles.',
    quoteTurkish: 'Ben bir sonraki Usain Bolt veya Michael Phelps değilim. Ben ilk Simone Biles\'ım.',
    sport: 'Gymnastics',
    gradientColors: [Colors.pink, Colors.purple, Colors.indigo],
  ),
];

// İlk giriş ekranı
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedLevel = 'Yeni Başlayan';
  
  final List<String> levels = [
    'Yeni Başlayan',
    'Orta Seviye', 
    'İleri Seviye'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.purple,
              Colors.indigo,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Logo ve başlık
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Fitness Takip',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hedeflerine ulaşmak için başlayalım!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                
                // İsim girişi
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adınız',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Adınızı girin',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Seviye seçimi
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spor Seviyeniz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...levels.map((level) => RadioListTile<String>(
                        title: Text(
                          level,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _getLevelDescription(level),
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        value: level,
                        groupValue: _selectedLevel,
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value!;
                          });
                        },
                        activeColor: Colors.white,
                        selectedTileColor: Colors.white.withOpacity(0.1),
                      )).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                
                // Başla butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _startApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Başla',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'Yeni Başlayan':
        return '6-10 set yeterli';
      case 'Orta Seviye':
        return '10-15 set önerilen';
      case 'İleri Seviye':
        return '15-20 set hedefli';
      default:
        return '';
    }
  }

  void _startApp() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen adınızı girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kullanıcı seviyesini belirle
    int minSets, maxSets;
    switch (_selectedLevel) {
      case 'Yeni Başlayan':
        minSets = 6;
        maxSets = 10;
        break;
      case 'Orta Seviye':
        minSets = 10;
        maxSets = 15;
        break;
      case 'İleri Seviye':
        minSets = 15;
        maxSets = 20;
        break;
      default:
        minSets = 10;
        maxSets = 15;
    }

    globalUserLevel = UserLevel(
      name: _nameController.text.trim(),
      level: _selectedLevel,
      minSets: minSets,
      maxSets: maxSets,
    );

    // Ana ekrana git
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }
}
