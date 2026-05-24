import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import 'profile.dart';
import 'hesapla.dart';
import 'statistics.dart';

// Veri yönetimi için sınıflar
class DataManager {
  static const String _userNameKey = 'user_name';
  static const String _currentWeightKey = 'current_weight';
  static const String _targetWeightKey = 'target_weight';
  static const String _weightHistoryKey = 'weight_history';
  static const String _weeklyRoutineKey = 'weekly_routine';
  static const String _completedWorkoutsKey = 'completed_workouts';
  static const String _lastCompletedKey = 'last_completed';
  static const String _exerciseHistoryKey = 'exercise_history';
  static const String _languageKey = 'language';
  static const String _userLevelKey = 'user_level';
  static const String _weightReminderEnabledKey = 'weight_reminder_enabled';
  static const String _waterReminderEnabledKey = 'water_reminder_enabled';
  static const String _weightReminderTimeKey = 'weight_reminder_time';
  static const String _waterReminderTimeKey = 'water_reminder_time';
  static const String _weightReminderFrequencyKey = 'weight_reminder_frequency';
  static const String _waterReminderIntervalKey = 'water_reminder_interval';

  // Kullanıcı adını kaydet
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // Kullanıcı adını al
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? '';
  }

  // Mevcut kiloyu kaydet
  static Future<void> saveCurrentWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_currentWeightKey, weight);
  }

  // Mevcut kiloyu al
  static Future<double?> getCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_currentWeightKey);
  }

  // Hedef kiloyu kaydet
  static Future<void> saveTargetWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_targetWeightKey, weight);
  }

  // Hedef kiloyu al
  static Future<double?> getTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_targetWeightKey);
  }

  // Tartılma geçmişini kaydet
  static Future<void> saveWeightHistory(List<WeightEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = history.map((entry) => {
      'weight': entry.weight,
      'date': entry.date.toIso8601String(),
      'note': entry.note,
    }).toList();
    await prefs.setString(_weightHistoryKey, jsonEncode(historyJson));
  }

  // Tartılma geçmişini al
  static Future<List<WeightEntry>> getWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_weightHistoryKey);
    if (historyString == null) return [];
    
    final historyJson = jsonDecode(historyString) as List;
    return historyJson.map((json) => WeightEntry(
      weight: json['weight'].toDouble(),
      date: DateTime.parse(json['date']),
      note: json['note'],
    )).toList();
  }

  // Haftalık rutini kaydet
  static Future<void> saveWeeklyRoutine(Map<String, List<RoutineEntry>> routine) async {
    final prefs = await SharedPreferences.getInstance();
    final routineJson = routine.map((day, entries) => MapEntry(day, entries.map((entry) => {
      'exerciseName': entry.exercise.name,
      'mainMuscleGroup': entry.exercise.mainMuscleGroup,
      'muscleGroups': entry.exercise.muscleGroups,
      'setCount': entry.setCount,
      'sets': entry.sets.map((set) => {
        'targetReps': set.targetReps,
        'targetWeight': set.targetWeight,
        'actualReps': set.actualReps,
        'actualWeight': set.actualWeight,
        'isCompleted': set.isCompleted,
      }).toList(),
    }).toList()));
    await prefs.setString(_weeklyRoutineKey, jsonEncode(routineJson));
  }

  // Haftalık rutini al
  static Future<Map<String, List<RoutineEntry>>> getWeeklyRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final routineString = prefs.getString(_weeklyRoutineKey);
    if (routineString == null) return {};
    try {
      final routineJson = jsonDecode(routineString) as Map;
      return routineJson.map((day, entries) => MapEntry(day.toString(), (entries as List).map((entry) {
        final exerciseName = entry['exerciseName']?.toString() ?? '';
        final mainMuscleGroup = entry['mainMuscleGroup']?.toString();
        final muscleGroups = (entry['muscleGroups'] as List?)?.map((e) => e.toString()).toList();
        Exercise? exercise;
        try {
          exercise = allExercises.firstWhere((e) => e.name == exerciseName);
        } catch (e) {
          // Ad tam eşleşmezse, kas grubu ve ana kas grubu ile eşleşme dene
          exercise = allExercises.firstWhere(
            (e) => (mainMuscleGroup != null && e.mainMuscleGroup == mainMuscleGroup) &&
                   (muscleGroups != null && e.muscleGroups.toSet().containsAll(muscleGroups)),
            orElse: () => Exercise(
              name: exerciseName,
              mainMuscleGroup: mainMuscleGroup ?? 'Bilinmeyen',
              muscleGroups: muscleGroups ?? ['Bilinmeyen'],
              muscleGroupRatios: {for (var m in (muscleGroups ?? ['Bilinmeyen'])) m: 1.0},
            ),
          );
        }
        return RoutineEntry(
          exercise: exercise!,
          setCount: entry['setCount'] ?? 0,
          sets: (entry['sets'] as List? ?? []).map((set) => SetEntry(
            targetReps: set['targetReps'] ?? 0,
            targetWeight: set['targetWeight'] ?? 0.0,
            actualReps: set['actualReps'] ?? 0,
            actualWeight: set['actualWeight'] ?? 0.0,
            isCompleted: set['isCompleted'] ?? false,
          )).toList(),
        );
      }).toList()));
    } catch (e) {
      print('Error loading weekly routine: $e');
      return {};
    }
  }

  // Tamamlanan antrenmanları kaydet
  static Future<void> saveCompletedWorkouts(Map<String, List<RoutineEntry>> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsJson = workouts.map((day, entries) => MapEntry(day, entries.map((entry) => {
      'exerciseName': entry.exercise.name,
      'mainMuscleGroup': entry.exercise.mainMuscleGroup,
      'muscleGroups': entry.exercise.muscleGroups,
      'setCount': entry.setCount,
      'sets': entry.sets.map((set) => {
        'targetReps': set.targetReps,
        'targetWeight': set.targetWeight,
        'actualReps': set.actualReps,
        'actualWeight': set.actualWeight,
        'isCompleted': set.isCompleted,
      }).toList(),
    }).toList()));
    await prefs.setString(_completedWorkoutsKey, jsonEncode(workoutsJson));
  }

  // Tamamlanan antrenmanları al
  static Future<Map<String, List<RoutineEntry>>> getCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsString = prefs.getString(_completedWorkoutsKey);
    if (workoutsString == null) return {};
    try {
      final workoutsJson = jsonDecode(workoutsString) as Map;
      return workoutsJson.map((day, entries) => MapEntry(day.toString(), (entries as List).map((entry) {
        final exerciseName = entry['exerciseName']?.toString() ?? '';
        final mainMuscleGroup = entry['mainMuscleGroup']?.toString();
        final muscleGroups = (entry['muscleGroups'] as List?)?.map((e) => e.toString()).toList();
        Exercise? exercise;
        try {
          exercise = allExercises.firstWhere((e) => e.name == exerciseName);
        } catch (e) {
          exercise = allExercises.firstWhere(
            (e) => (mainMuscleGroup != null && e.mainMuscleGroup == mainMuscleGroup) &&
                   (muscleGroups != null && e.muscleGroups.toSet().containsAll(muscleGroups)),
            orElse: () => Exercise(
              name: exerciseName,
              mainMuscleGroup: mainMuscleGroup ?? 'Bilinmeyen',
              muscleGroups: muscleGroups ?? ['Bilinmeyen'],
              muscleGroupRatios: {for (var m in (muscleGroups ?? ['Bilinmeyen'])) m: 1.0},
            ),
          );
        }
        return RoutineEntry(
          exercise: exercise!,
          setCount: entry['setCount'] ?? 0,
          sets: (entry['sets'] as List? ?? []).map((set) => SetEntry(
            targetReps: set['targetReps'] ?? 0,
            targetWeight: set['targetWeight'] ?? 0.0,
            actualReps: set['actualReps'] ?? 0,
            actualWeight: set['actualWeight'] ?? 0.0,
            isCompleted: set['isCompleted'] ?? false,
          )).toList(),
        );
      }).toList()));
    } catch (e) {
      print('Error loading completed workouts: $e');
      return {};
    }
  }

  // Dil ayarını kaydet
  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // Dil ayarını al
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'Türkçe';
  }

  // Egzersiz geçmişini kaydet
  static Future<void> saveExerciseHistory(Map<String, List<ExerciseHistory>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = history.map((exerciseName, entries) => MapEntry(exerciseName, entries.map((entry) => {
      'exerciseName': entry.exerciseName,
      'date': entry.date.toIso8601String(),
      'weight': entry.weight,
      'reps': entry.reps,
      'sets': entry.sets,
    }).toList()));
    await prefs.setString(_exerciseHistoryKey, jsonEncode(historyJson));
  }

  // Egzersiz geçmişini al
  static Future<Map<String, List<ExerciseHistory>>> getExerciseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_exerciseHistoryKey);
    if (historyString == null) return {};
    
    try {
      final historyJson = jsonDecode(historyString) as Map;
      return historyJson.map((exerciseName, entries) => MapEntry(exerciseName.toString(), (entries as List).map((entry) => ExerciseHistory(
        exerciseName: entry['exerciseName']?.toString() ?? '',
        date: DateTime.tryParse(entry['date']?.toString() ?? '') ?? DateTime.now(),
        weight: (entry['weight'] ?? 0.0).toDouble(),
        reps: entry['reps'] ?? 0,
        sets: entry['sets'] ?? 0,
      )).toList()));
    } catch (e) {
      print('Error loading exercise history: $e');
      return {};
    }
  }

  // Hatırlatıcı ayarlarını kaydet
  static Future<void> saveWeightReminderSettings({
    required bool enabled,
    required TimeOfDay time,
    required String frequency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weightReminderEnabledKey, enabled);
    await prefs.setString(_weightReminderTimeKey, '${time.hour}:${time.minute}');
    await prefs.setString(_weightReminderFrequencyKey, frequency);
  }

  static Future<void> saveWaterReminderSettings({
    required bool enabled,
    required TimeOfDay time,
    required String interval,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_waterReminderEnabledKey, enabled);
    await prefs.setString(_waterReminderTimeKey, '${time.hour}:${time.minute}');
    await prefs.setString(_waterReminderIntervalKey, interval);
  }

  // Hatırlatıcı ayarlarını al
  static Future<Map<String, dynamic>> getWeightReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_weightReminderEnabledKey) ?? false;
    final timeString = prefs.getString(_weightReminderTimeKey) ?? '8:0';
    final frequency = prefs.getString(_weightReminderFrequencyKey) ?? 'Haftalık';
    
    final timeParts = timeString.split(':');
    final time = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 8,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );
    
    return {
      'enabled': enabled,
      'time': time,
      'frequency': frequency,
    };
  }

  static Future<Map<String, dynamic>> getWaterReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_waterReminderEnabledKey) ?? false;
    final timeString = prefs.getString(_waterReminderTimeKey) ?? '9:0';
    final interval = prefs.getString(_waterReminderIntervalKey) ?? '2 saat';
    
    final timeParts = timeString.split(':');
    final time = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 9,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );
    
    return {
      'enabled': enabled,
      'time': time,
      'interval': interval,
    };
  }
}

// Responsive tasarım için extension
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Font boyutları için responsive değerler
  double get responsiveFontSize {
    if (screenWidth < 400) return 12.0; // Küçük ekranlar
    if (screenWidth < 600) return 14.0; // Orta ekranlar
    if (screenWidth < 900) return 16.0; // Büyük ekranlar
    return 18.0; // Çok büyük ekranlar
  }
  
  double get responsiveTitleFontSize {
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 600) return 18.0;
    if (screenWidth < 900) return 20.0;
    return 22.0;
  }
  
  double get responsivePadding {
    if (screenWidth < 400) return 8.0;
    if (screenWidth < 600) return 12.0;
    if (screenWidth < 900) return 16.0;
    return 20.0;
  }
  
  double get responsiveIconSize {
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 600) return 20.0;
    if (screenWidth < 900) return 24.0;
    return 28.0;
  }
}

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

// Global completed workouts
Map<String, List<RoutineEntry>> globalCompletedWorkouts = {};

// Global state için callback listesi
final List<Function> _languageChangeCallbacks = <Function>[];

void addLanguageChangeCallback(Function callback) {
  _languageChangeCallbacks.add(callback);
}

void removeLanguageChangeCallback(Function callback) {
  _languageChangeCallbacks.remove(callback);
}

void updateGlobalLanguage(String newLanguage) async {
  globalLanguage = newLanguage;
  // Dil ayarını kaydet
  await DataManager.saveLanguage(newLanguage);
  // Tüm callback'leri çağır
  for (var callback in _languageChangeCallbacks) {
    callback();
  }
}

// Kas grubu isimlerini lokalize etmek için fonksiyon
String getLocalizedMuscleGroup(String muscleGroup) {
  if (globalLanguage == 'Türkçe') {
    return muscleGroup;
  } else {
    switch (muscleGroup) {
      case 'Göğüs':
        return 'Chest';
      case 'Omuz':
        return 'Shoulder';
      case 'Bacak':
        return 'Leg';
      case 'Sırt':
        return 'Back';
      case 'Biceps':
        return 'Biceps';
      case 'Triceps':
        return 'Triceps';
      case 'Core':
        return 'Core';
      case 'Kalça':
        return 'Hip';
      default:
        return muscleGroup;
    }
  }
}

String getLocalizedDayName(String dayName) {
  if (globalLanguage == 'Türkçe') {
    return dayName;
  } else {
    switch (dayName) {
      case 'Pazartesi': return 'Monday';
      case 'Salı': return 'Tuesday';
      case 'Çarşamba': return 'Wednesday';
      case 'Perşembe': return 'Thursday';
      case 'Cuma': return 'Friday';
      case 'Cumartesi': return 'Saturday';
      case 'Pazar': return 'Sunday';
      default: return dayName;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Dil ayarını yükle
  globalLanguage = await DataManager.getLanguage();
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
      home: const MainScreen(),
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
  Exercise(
    name: 'Squat', 
    muscleGroups: ['Bacak', 'Kalça'], 
    mainMuscleGroup: 'Bacak',
    muscleGroupRatios: {'Bacak': 1.0, 'Kalça': 0.3},
  ),
  Exercise(
    name: 'Bench Press', 
    muscleGroups: ['Göğüs', 'Triceps'], 
    mainMuscleGroup: 'Göğüs',
    muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.3},
  ),
  Exercise(
    name: 'Barbell Bench Press', 
    muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
    mainMuscleGroup: 'Göğüs',
    muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.5, 'Omuz': 0.4},
  ),
  Exercise(
    name: 'Deadlift', 
    muscleGroups: ['Sırt', 'Bacak', 'Kalça'], 
    mainMuscleGroup: 'Sırt',
    muscleGroupRatios: {'Sırt': 1.0, 'Bacak': 0.3, 'Kalça': 0.2},
  ),
  Exercise(
    name: 'Overhead Press', 
    muscleGroups: ['Omuz', 'Triceps'], 
    mainMuscleGroup: 'Omuz',
    muscleGroupRatios: {'Omuz': 1.0, 'Triceps': 0.3},
  ),
  Exercise(
    name: 'Barbell Row', 
    muscleGroups: ['Sırt', 'Biceps', 'Core'], 
    mainMuscleGroup: 'Sırt',
    muscleGroupRatios: {'Sırt': 0.6, 'Biceps': 0.3, 'Core': 0.1},
  ),
  Exercise(
    name: 'Pull Up', 
    muscleGroups: ['Sırt', 'Biceps'], 
    mainMuscleGroup: 'Sırt',
    muscleGroupRatios: {'Sırt': 0.7, 'Biceps': 0.3},
  ),
  Exercise(
    name: 'Lunge', 
    muscleGroups: ['Bacak', 'Kalça'], 
    mainMuscleGroup: 'Bacak',
    muscleGroupRatios: {'Bacak': 0.7, 'Kalça': 0.3},
  ),
  Exercise(
    name: 'Biceps Curl', 
    muscleGroups: ['Biceps'], 
    mainMuscleGroup: 'Biceps',
    muscleGroupRatios: {'Biceps': 1.0},
  ),
  Exercise(
    name: 'Triceps Extension', 
    muscleGroups: ['Triceps'], 
    mainMuscleGroup: 'Triceps',
    muscleGroupRatios: {'Triceps': 1.0},
  ),
  Exercise(
    name: 'Leg Press', 
    muscleGroups: ['Bacak', 'Kalça'], 
    mainMuscleGroup: 'Bacak',
    muscleGroupRatios: {'Bacak': 0.7, 'Kalça': 0.3},
  ),
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
  void initState() {
    super.initState();
    _initializeReminders();
    // globalLanguage değiştiğinde UI'ı güncelle
    addLanguageChangeCallback(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _initializeReminders() async {
    try {
      // Notification servisini başlat
      await NotificationService.initialize();
      
      // Hatırlatıcı ayarlarını yükle ve aktif olanları planla
      final weightSettings = await DataManager.getWeightReminderSettings();
      final waterSettings = await DataManager.getWaterReminderSettings();
      
      if (weightSettings['enabled'] == true) {
        await NotificationService.scheduleWeightReminder(
          time: weightSettings['time'],
          frequency: weightSettings['frequency'],
        );
      }
      
      if (waterSettings['enabled'] == true) {
        await NotificationService.scheduleWaterReminder(
          time: waterSettings['time'],
          interval: waterSettings['interval'],
        );
      }
    } catch (e) {
      print('Error initializing reminders: $e');
    }
  }

  @override
  void dispose() {
    removeLanguageChangeCallback(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: globalLanguage == 'Türkçe' ? 'Rutin' : 'Routine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: globalLanguage == 'Türkçe' ? 'Hesapla' : 'Calculate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: globalLanguage == 'Türkçe' ? 'İstatistikler' : 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: globalLanguage == 'Türkçe' ? 'Profil' : 'Profile',
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
  Map<String, List<RoutineEntry>> _completedWorkouts = {};
  Map<String, List<ExerciseHistory>> _exerciseHistory = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('Loading statistics data...');
      final completedWorkouts = await DataManager.getCompletedWorkouts();
      final exerciseHistory = await DataManager.getExerciseHistory();
      
      print('Loaded completed workouts: $completedWorkouts');
      print('Loaded exercise history: $exerciseHistory');
      
      setState(() {
        _completedWorkouts = completedWorkouts;
        _exerciseHistory = exerciseHistory;
      });
    } catch (e) {
      print('Error loading statistics data: $e');
      setState(() {
        _completedWorkouts = {};
        _exerciseHistory = {};
      });
    }
  }

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

    // Global completed workouts'u kullan
    final completedWorkouts = globalCompletedWorkouts;

    // Eğer hiç tamamlanmış antrenman yoksa tüm değerler 0 kalır
    if (completedWorkouts.isEmpty) {
      print('No completed workouts found');
      return muscleSets;
    }

    print('Processing ${completedWorkouts.length} days of completed workouts');
    
    for (var dayWorkouts in completedWorkouts.values) {
      print('Processing ${dayWorkouts.length} exercises for a day');
      for (var entry in dayWorkouts) {
        print('Processing exercise: ${entry.exercise.name}, main muscle: ${entry.exercise.mainMuscleGroup}, sets: ${entry.sets.length}');
        
        final ratios = entry.exercise.muscleGroupRatios;
        final actualSetCount = entry.sets.length;
        
        if (ratios.isNotEmpty) {
          // Oranları kullanarak set sayılarını hesapla
          print('DEBUG: Egzersiz oranları: $ratios');
          for (var muscle in entry.exercise.muscleGroups) {
            final ratio = ratios[muscle] ?? 1.0;
            final setCount = (actualSetCount * ratio).round();
            print('DEBUG: $muscle için $setCount set eklendi (oran: $ratio)');
            muscleSets[muscle] = (muscleSets[muscle] ?? 0) + setCount;
          }
        } else {
          // Eski yöntem (geriye uyumluluk için)
          for (var muscle in entry.exercise.muscleGroups) {
            if (muscle == entry.exercise.mainMuscleGroup) {
              muscleSets[muscle] = (muscleSets[muscle] ?? 0) + actualSetCount;
            } else {
              muscleSets[muscle] = (muscleSets[muscle] ?? 0) + 1;
            }
          }
        }
      }
    }

    print('Final muscle sets: $muscleSets');
    return muscleSets;
  }

  List<String> get _undertrainedMuscles {
    // Eğer hiç veri yoksa boş liste döndür
    if (_completedWorkouts.isEmpty) {
      return [];
    }
    return _weeklyMuscleSets.entries
        .where((e) => e.value < 12) // 12'den küçük tüm değerler (0 dahil)
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final muscleSets = _weeklyMuscleSets;
    final undertrainedMuscles = _undertrainedMuscles;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(globalLanguage == 'Türkçe' ? 'İstatistikler' : 'Statistics'),
        centerTitle: true,
        actions: [

          Container(
            margin: EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              icon: Icon(Icons.delete_forever, color: Colors.white, size: 18),
              label: Text(
                globalLanguage == 'Türkçe' ? 'Sıfırla' : 'Reset',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text(globalLanguage == 'Türkçe' ? 'İstatistikleri Sıfırla' : 'Reset Statistics'),
                    content: Text(globalLanguage == 'Türkçe' 
                      ? 'Tüm istatistik verileri silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?'
                      : 'All statistics data will be deleted. This action cannot be undone. Do you want to continue?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                        child: Text(globalLanguage == 'Türkçe' ? 'İptal' : 'Cancel'),
                    ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      onPressed: () async {
                        // Tüm verileri temizle
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        
                        setState(() {
                          _completedWorkouts = {};
                          _exerciseHistory = {};
                          globalCompletedWorkouts = {};
                        });
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(globalLanguage == 'Türkçe' ? 'İstatistikler sıfırlandı' : 'Statistics reset'),
                              backgroundColor: Colors.red,
                            ),
                        );
                      },
                        child: Text(globalLanguage == 'Türkçe' ? 'Sıfırla' : 'Reset'),
                    ),
                  ],
                ),
              );
            },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uyarı bölümü
            if (undertrainedMuscles.isNotEmpty && _completedWorkouts.isNotEmpty) ...[
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
                        Text(
                          globalLanguage == 'Türkçe' ? 'Dikkat!' : 'Warning!',
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
                      globalLanguage == 'Türkçe' 
                        ? 'Şu kas gruplarını haftada ${globalUserLevel?.minSets ?? 12} setten az çalıştırdın:\n${undertrainedMuscles.map((m) => getLocalizedMuscleGroup(m)).join(', ')}'
                        : 'You worked these muscle groups less than ${globalUserLevel?.minSets ?? 12} sets per week:\n${undertrainedMuscles.map((m) => getLocalizedMuscleGroup(m)).join(', ')}',
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
                    Text(
                      globalLanguage == 'Türkçe' ? 'Haftalık Kas Grubu Set İstatistikleri' : 'Weekly Muscle Group Set Statistics',
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
                                    getLocalizedMuscleGroup(entry.key),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              globalLanguage == 'Türkçe' ? '12+ set' : '12+ set',
                              style: TextStyle(fontSize: context.responsiveFontSize - 2),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              globalLanguage == 'Türkçe' ? '1-11 set' : '1-11 set',
                              style: TextStyle(fontSize: context.responsiveFontSize - 2),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '0 set',
                              style: TextStyle(fontSize: context.responsiveFontSize - 2),
                            ),
                          ],
                        ),
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
                    Text(
                      globalLanguage == 'Türkçe' ? 'Genel İstatistikler' : 'General Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            globalLanguage == 'Türkçe' ? 'Toplam Gün' : 'Total Days',
                            _completedWorkouts.length.toString(),
                            Icons.calendar_today,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            globalLanguage == 'Türkçe' ? 'Toplam Egzersiz' : 'Total Exercises',
                            _completedWorkouts.values.fold(0, (sum, entries) => sum + entries.length).toString(),
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
                            globalLanguage == 'Türkçe' ? 'Toplam Set' : 'Total Sets',
                            muscleSets.values.fold(0, (sum, count) => sum + count).toString(),
                            Icons.repeat,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            globalLanguage == 'Türkçe' ? 'Ortalama Set/Gün' : 'Average Sets/Day',
                            _completedWorkouts.isNotEmpty 
                              ? (muscleSets.values.fold(0, (sum, count) => sum + count) / _completedWorkouts.length).round().toString()
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
  Map<String, List<RoutineEntry>> _completedWorkouts = {};
  
  bool _warningShown = false;
  // Günlerin sırası (görüntüleme sırası)
  List<String> _dayOrder = [];
  // Gün adı değiştirildiğinde orijinal ismi korumak için
  Map<String, String> _originalDayNames = {};
  
  // Dinamik sporcu seçimi için
  late AthleteQuote _currentAthlete;

  // Cache - widget yeniden oluşturulduğunda korunur
  // Map<String, List<RoutineEntry>> _cachedWeeklyRoutine = {};
  // List<String> _cachedDayOrder = [];
  // Map<String, String> _cachedOriginalDayNames = {};
  // Map<String, DateTime> _cachedLastCompleted = {};
  // Map<String, List<RoutineEntry>> _cachedCompletedWorkouts = {};
  Map<String, List<ExerciseHistory>> _cachedExerciseHistory = {};
  
  @override
  void initState() {
    super.initState();
    // Rastgele sporcu seç
    _currentAthlete = athleteQuotes[DateTime.now().millisecondsSinceEpoch % athleteQuotes.length];
    
    // Verileri yükle
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // SharedPreferences'dan verileri yükle
      final savedRoutine = await DataManager.getWeeklyRoutine();
      final savedCompleted = await DataManager.getCompletedWorkouts();
      final savedHistory = await DataManager.getExerciseHistory();
      
      setState(() {
        _weeklyRoutine = savedRoutine;
        _completedWorkouts = savedCompleted;
        _cachedExerciseHistory = savedHistory;
        
        // Global değişkeni güncelle
        globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
        
        // Gün sırasını oluştur
        _dayOrder = _weeklyRoutine.keys.toList();
        _originalDayNames = Map.fromEntries(_dayOrder.map((day) => MapEntry(day, day)));
        
        // Eğer hiç gün yoksa boş bırak (kullanıcı manuel olarak ekleyecek)
        if (_dayOrder.isEmpty) {
          _dayOrder = [];
          _originalDayNames = {};
        }
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _weeklyRoutine = {};
        _completedWorkouts = {};
        _cachedExerciseHistory = {};
        _dayOrder = [];
        _originalDayNames = {};
      });
    }
  }

  // Tüm verileri temizle (test için)
  Future<void> _clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Tüm SharedPreferences verilerini temizle
      
      setState(() {
        _weeklyRoutine = {};
        _completedWorkouts = {};
        _cachedExerciseHistory = {};
        _dayOrder = [];
        _originalDayNames = {};
        globalCompletedWorkouts = {};
      });
      
      print('Tüm veriler temizlendi');
    } catch (e) {
      print('Veri temizleme hatası: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveData() async {
    try {
      await DataManager.saveWeeklyRoutine(_weeklyRoutine);
      await DataManager.saveCompletedWorkouts(_completedWorkouts);
      await DataManager.saveExerciseHistory(_cachedExerciseHistory);
      
      // Global değişkeni güncelle
      globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
      
      print('Veriler başarıyla kaydedildi');
    } catch (e) {
      print('Veri kaydetme hatası: $e');
    }
  }

  // Egzersiz geçmişini kaydet
  void saveExerciseHistory(String exerciseName, double weight, int reps, int sets) {
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
  List<ExerciseHistory> getExerciseHistory(String exerciseName) {
    return _cachedExerciseHistory[exerciseName] ?? [];
  }

  // Haftalık kas grubu toplam setleri (cache'lenmiş)
  Map<String, int>? _cachedMuscleSets;
  Map<String, int> get _weeklyMuscleSets {
    // Cache kontrolü
    if (_cachedMuscleSets != null) {
      return _cachedMuscleSets!;
    }
    final Map<String, int> muscleSets = {
      'Bacak': 0,
      'Kalça': 0,
      'Core': 0,
      'Göğüs': 0,
      'Triceps': 0,
      'Omuz': 0,
      'Sırt': 0,
      'Biceps': 0,
      'Bilinmeyen': 0,
    };
    
    // Debug için print ekleyelim
    print('DEBUG: StatisticsScreen - Hesaplama başlıyor');
    
    for (var entries in _completedWorkouts.values) {
      for (var entry in entries) {
        final ratios = entry.exercise.muscleGroupRatios;
        final actualSetCount = entry.sets.length;
        print('DEBUG: ${entry.exercise.name} - $actualSetCount set');
        
        if (ratios.isNotEmpty) {
          for (var muscle in entry.exercise.muscleGroups) {
            final ratio = ratios[muscle] ?? 1.0;
            final setCount = (actualSetCount * ratio).round();
            print('DEBUG: $muscle için $setCount set eklendi (oran: $ratio)');
            muscleSets[muscle] = (muscleSets[muscle] ?? 0) + setCount;
          }
        } else {
          for (var muscle in entry.exercise.muscleGroups) {
            if (muscle == entry.exercise.mainMuscleGroup) {
              muscleSets[muscle] = (muscleSets[muscle] ?? 0) + actualSetCount;
            } else {
              muscleSets[muscle] = (muscleSets[muscle] ?? 0) + 1;
            }
          }
        }
      }
    }
    
    print('DEBUG: Final muscle sets: $muscleSets');
    _cachedMuscleSets = muscleSets;
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
          // Global değişkeni güncelle
          globalCompletedWorkouts = Map<String, List<RoutineEntry>>.from(_completedWorkouts);
          // Sadece haftanın son günü antrenmanı bitirildiğinde uyarı göster
          if (_isLastDayOfWeek(day)) {
            _showWarningIfNeeded();
          }
        }
      });
      // Her durumda verileri kaydet
      _cachedMuscleSets = null; // Cache'i temizle
      await _saveData();
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
      // _cachedWeeklyRoutine.clear();
      // _cachedDayOrder.clear();
      // _cachedOriginalDayNames.clear();
      // _cachedLastCompleted.clear();
      // _cachedCompletedWorkouts.clear();
      _cachedMuscleSets = null; // Muscle sets cache'ini temizle
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
        title: Text(globalLanguage == 'Türkçe' ? 'Gün Seç' : 'Select Day'),
        children: availableDays
            .map((d) => SimpleDialogOption(
                  child: Text(getLocalizedDayName(d)),
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
      // Verileri kaydet
      await _saveData();
    }
  }

  void _removeDay(String day) async {
    setState(() {
      _weeklyRoutine.remove(day);
      _dayOrder.remove(day);
      _originalDayNames.remove(day);
    });
    // Verileri kaydet
    await _saveData();
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
        title: Text(globalLanguage == 'Türkçe' ? 'Gün Adını Düzenle' : 'Edit Day Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: globalLanguage == 'Türkçe' ? 'Gün Adı' : 'Day Name',
            hintText: globalLanguage == 'Türkçe' ? 'Örn: Pazartesi Göğüs' : 'Ex: Monday Chest',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(globalLanguage == 'Türkçe' ? 'İptal' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
                                child: Text(globalLanguage == 'Türkçe' ? 'Kaydet' : 'Save'),
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
        // Gün adını _dayOrder listesinde de güncelle
        if (currentIndex >= 0 && currentIndex < _dayOrder.length) {
          _dayOrder[currentIndex] = result;
        }
        _originalDayNames[result] = originalName ?? day;
      });
      // Verileri kaydet
      await _saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final muscleSets = _weeklyMuscleSets;
    final undertrainedMuscles = _undertrainedMuscles;
    final completedWorkouts = _completedWorkouts;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: Colors.deepPurple, size: context.responsiveIconSize),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                globalLanguage == 'Türkçe' ? 'Kaslarını değil, planını inşa et!' : 'Build your plan, not just muscles!',
                style: GoogleFonts.montserrat(
                  fontSize: context.responsiveTitleFontSize - 4,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Verileri Temizle'),
                  content: Text('Tüm veriler silinecek. Devam etmek istiyor musunuz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearAllData();
                        Navigator.pop(context);
                      },
                      child: Text('Temizle'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Tüm Verileri Temizle',
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
                    bottom: 32,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports, color: Colors.white, size: context.responsiveIconSize),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _currentAthlete.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.responsiveTitleFontSize,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
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
                                  fontSize: context.responsiveFontSize - 2,
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
                            fontSize: context.responsiveFontSize - 1,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
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
                        globalLanguage == 'Türkçe' ? 'Haftalık Rutin' : 'Weekly Routine',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.responsiveTitleFontSize,
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
                      label: Text(globalLanguage == 'Türkçe' ? 'Yeni Gün Ekle' : 'Add New Day'),
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
                          globalLanguage == 'Türkçe' ? 'Henüz gün eklemedin' : 'No days added yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          globalLanguage == 'Türkçe' ? 'Yukarıdaki butona tıklayarak ilk gününü ekle' : 'Click the button above to add your first day',
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
                itemCount: _dayOrder?.length ?? 0,
                itemBuilder: (context, i) {
                  final day = _dayOrder[i];
                  if (day == null) return Container(); // Null gün için boş container
                  final count = _weeklyRoutine[day]?.length ?? 0;
                  final originalDay = _originalDayNames[day] ?? day;
                  final short = weekDayShort[originalDay] ?? '';
                  final color = weekDayColors[originalDay] ?? Colors.black;
                  String? completedText;
                  final lastCompleted = _lastCompleted[day];
                  if (lastCompleted != null) {
                    final diff = DateTime.now().difference(lastCompleted).inDays;
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
                          padding: EdgeInsets.all(context.responsivePadding),
                          child: Row(
                            children: [
                              Container(
                                width: context.responsiveIconSize * 2.5,
                                height: context.responsiveIconSize * 2.5,
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
                                      fontSize: context.responsiveFontSize,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.responsivePadding),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getLocalizedDayName(day),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.responsiveTitleFontSize,
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
                                          count > 0 
                                            ? (globalLanguage == 'Türkçe' ? '$count egzersiz' : '$count exercises')
                                            : (globalLanguage == 'Türkçe' ? 'Egzersiz yok' : 'No exercises'),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: context.responsiveFontSize,
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
                                        icon: Icon(Icons.edit, color: Colors.blue, size: context.responsiveIconSize - 4),
                                        onPressed: () => _editDayName(day),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.keyboard_arrow_up, size: context.responsiveIconSize - 4),
                                        onPressed: i > 0 ? () => _moveDayUp(i) : null,
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.keyboard_arrow_down, size: context.responsiveIconSize - 4),
                                        onPressed: i < _dayOrder.length - 1 ? () => _moveDayDown(i) : null,
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red, size: context.responsiveIconSize - 4),
                                        onPressed: () => _removeDay(day),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 28, minHeight: 28),
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
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.5, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Incline Barbell Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.5, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Dumbbell Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.4, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Incline Dumbbell Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.4, 'Omuz': 0.4},
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
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.6, 'Omuz': 0.4},
    ),
    Exercise(
      name: 'Push-Up', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz', 'Core'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.4, 'Omuz': 0.4, 'Core': 0.3},
    ),
    Exercise(
      name: 'Smith Machine Bench Press', 
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'], 
      mainMuscleGroup: 'Göğüs',
      muscleGroupRatios: {'Göğüs': 1.0, 'Triceps': 0.5, 'Omuz': 0.4},
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
  'Core': [
    Exercise(name: 'Plank', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Turkish Get-Up', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Farmer\'s Walk', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Bear Crawl', muscleGroups: ['Core', 'Omuz', 'Kalça'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Side Plank', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Russian Twist', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Crunches', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
    Exercise(name: 'Leg Raises', muscleGroups: ['Core'], mainMuscleGroup: 'Core'),
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
    
    // Verileri SharedPreferences'dan yükle
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final savedRoutine = await DataManager.getWeeklyRoutine();
      final dayEntries = savedRoutine[widget.day];
      if (dayEntries != null) {
        setState(() {
          _entries = List<RoutineEntry>.from(dayEntries);
          if (_entries.isEmpty) {
            _showExerciseForm = true;
          }
        });
      }
    } catch (e) {
      print('Veri yükleme hatası: $e');
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
        DataManager.saveExerciseHistory({_selectedExercise!.name: [ExerciseHistory(
          exerciseName: _selectedExercise!.name,
          date: DateTime.now(),
          weight: weight,
          reps: reps,
          sets: setCount,
        )]});
        
        // Egzersiz eklendikten sonra formu gizleme satırını kaldır
        _selectedExercise = null;
        _selectedMuscleGroup = null;
        _setCountController.clear();
        _weightController.clear();
        _repsController.text = '8'; // Default tekrar değeri
        _showSaveButton = true; // Kaydet butonunu göster
      });
      
      // Rutini kaydet
      _saveRoutine();
    }
  }

  Future<void> _saveRoutine() async {
    try {
      // WeekScreen'e rutini kaydet
      final weekScreen = context.findAncestorStateOfType<_WeekScreenState>();
      if (weekScreen != null) {
        weekScreen._weeklyRoutine[widget.day] = List<RoutineEntry>.from(_entries);
        await weekScreen._saveData();
        print('Rutin kaydedildi: ${widget.day}');
      }
    } catch (e) {
      print('Rutin kaydetme hatası: $e');
    }
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
    // Rutini kaydet
    _saveRoutine();
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
        title: Text(globalLanguage == 'Türkçe' ? '${widget.day} Rutini' : '${getLocalizedDayName(widget.day)} Routine'),
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
            Text(globalLanguage == 'Türkçe' ? 'Kas Grubu ve Egzersiz Ekle:' : 'Add Muscle Group and Exercise:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Text(
                          globalLanguage == 'Türkçe' ? 'Yeni Egzersiz Ekle' : 'Add New Exercise',
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
                    Text(globalLanguage == 'Türkçe' ? '1. Kas Grubu Seçin' : '1. Select Muscle Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: globalLanguage == 'Türkçe' ? 'Kas Grubu' : 'Muscle Group',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        hint: Text(
                          globalLanguage == 'Türkçe' ? 'Kas grubunu seçin' : 'Select muscle group',
                          style: TextStyle(fontSize: context.responsiveFontSize),
                          overflow: TextOverflow.ellipsis,
                        ),
                        value: _selectedMuscleGroup,
                        items: mainMuscleGroups.map((g) => DropdownMenuItem(
                          value: g,
                          child: Row(
                            children: [
                              Text(muscleGroupIcons[g] ?? '🏋️‍♂️'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  getLocalizedMuscleGroup(g),
                                  style: TextStyle(fontSize: context.responsiveFontSize),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedMuscleGroup = v;
                            _selectedExercise = null;
                          });
                        },
                        isExpanded: true, // Tam genişlik kullan
                        menuMaxHeight: 200, // Menü yüksekliğini sınırla
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Egzersiz seçimi
                    if (_selectedMuscleGroup != null) ...[
                      Text(globalLanguage == 'Türkçe' ? '2. Egzersiz Seçin' : '2. Select Exercise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<Exercise>(
                          decoration: InputDecoration(
                            labelText: globalLanguage == 'Türkçe' ? 'Egzersiz' : 'Exercise',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          hint: Text(
                            globalLanguage == 'Türkçe' ? 'Egzersizi seçin' : 'Select exercise',
                            style: TextStyle(fontSize: context.responsiveFontSize),
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: _selectedExercise,
                          items: exercises.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.name, 
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: context.responsiveFontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                          onChanged: _onExerciseChanged,
                          isExpanded: true, // Tam genişlik kullan
                          menuMaxHeight: 200, // Menü yüksekliğini sınırla
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Set ve kg girişi
                    if (_selectedExercise != null) ...[
                      Text(globalLanguage == 'Türkçe' ? '3. Set ve Ağırlık Belirleyin' : '3. Set Weight and Reps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      // Responsive düzen - küçük ekranlarda dikey, büyük ekranlarda yatay
                      context.screenWidth < 600 
                        ? Column(
                            children: [
                              // Set sayısı
                              Container(
                                height: 50,
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: globalLanguage == 'Türkçe' ? 'Set' : 'Sets',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: _setCountController,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Tekrar sayısı
                              Container(
                                height: 50,
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: globalLanguage == 'Türkçe' ? 'Tekrar' : 'Reps',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: _repsController,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Ağırlık girişi
                              Container(
                                height: 25,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: context.responsiveIconSize + 4),
                                      onPressed: () => _changeWeightField(-5),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: globalLanguage == 'Türkçe' ? 'KG' : 'KG',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                          isDense: true,
                                          constraints: BoxConstraints(maxHeight: 25),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: _weightController,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline, color: Colors.green, size: context.responsiveIconSize + 4),
                                      onPressed: () => _changeWeightField(5),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              // Set sayısı
                              Expanded(
                                child: Container(
                                  height: 25,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: globalLanguage == 'Türkçe' ? 'Set' : 'Sets',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                      isDense: true,
                                      constraints: BoxConstraints(maxHeight: 25),
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _setCountController,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Tekrar sayısı
                              Expanded(
                                child: Container(
                                  height: 25,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: globalLanguage == 'Türkçe' ? 'Tekrar' : 'Reps',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                      isDense: true,
                                      constraints: BoxConstraints(maxHeight: 25),
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _repsController,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Ağırlık girişi
                              Expanded(
                                child: Container(
                                  height: 25,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: context.responsiveIconSize + 4),
                                        onPressed: () => _changeWeightField(-5),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: globalLanguage == 'Türkçe' ? 'KG' : 'KG',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                            isDense: true,
                                            constraints: BoxConstraints(maxHeight: 25),
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: _weightController,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline, color: Colors.green, size: context.responsiveIconSize + 4),
                                        onPressed: () => _changeWeightField(5),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
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
                          label: Text(globalLanguage == 'Türkçe' ? 'Egzersizi Rutine Ekle' : 'Add Exercise to Routine'),
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
                Text(globalLanguage == 'Türkçe' ? 'Günün Rutinleri:' : 'Day\'s Routines:', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                if (!_showExerciseForm)
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.deepPurple, size: 28),
                    onPressed: () {
                      setState(() {
                        _showExerciseForm = true;
                      });
                    },
                    tooltip: globalLanguage == 'Türkçe' ? 'Yeni Egzersiz Ekle' : 'Add New Exercise',
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
                    globalLanguage == 'Türkçe' ? 'Kas grupları: ${entry.exercise.muscleGroups.join(', ')}' : 'Muscle groups: ${entry.exercise.muscleGroups.map((m) => getLocalizedMuscleGroup(m)).join(', ')}',
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
                                      label: Text(globalLanguage == 'Türkçe' ? 'Antrenmanı Başlat' : 'Start Workout'),
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
                          globalLanguage == 'Türkçe' ? 'Antrenman İlerlemesi' : 'Workout Progress',
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
                                  globalLanguage == 'Türkçe' ? 'Set İlerlemesi' : 'Set Progress',
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
                              globalLanguage == 'Türkçe' 
                                ? 'Hedef: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetReps} tekrar, ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetWeight.toStringAsFixed(1)} kg'
                                : 'Target: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetReps} reps, ${_entries[_currentExerciseIndex].sets[_currentSetIndex].targetWeight.toStringAsFixed(1)} kg',
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
                                  globalLanguage == 'Türkçe' ? 'Tekrar: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualReps}' : 'Reps: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualReps}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  globalLanguage == 'Türkçe' ? 'KG: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualWeight.toStringAsFixed(1)}' : 'KG: ${_entries[_currentExerciseIndex].sets[_currentSetIndex].actualWeight.toStringAsFixed(1)}',
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
                            label: Text(globalLanguage == 'Türkçe' ? 'Tekrar -' : 'Rep -'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetReps(-1),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text(globalLanguage == 'Türkçe' ? 'Tekrar +' : 'Rep +'),
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
                            label: Text(globalLanguage == 'Türkçe' ? 'KG -' : 'KG -'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _updateCurrentSetWeight(-2.5),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text(globalLanguage == 'Türkçe' ? 'KG +' : 'KG +'),
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
                                                    label: Text(globalLanguage == 'Türkçe' ? 'Seti Tamamla' : 'Complete Set'),
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
                                      label: Text(globalLanguage == 'Türkçe' ? 'Antrenmanı Bitir' : 'Finish Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    // Rutini kaydet
                    await _saveRoutine();
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
                      Icon(Icons.celebration, color: Colors.green, size: context.responsiveIconSize),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          globalLanguage == 'Türkçe' ? 'Tebrikler! Tüm egzersizler tamamlandı! 🎉' : 'Congratulations! All exercises completed! 🎉',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: context.responsiveFontSize,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
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
        onPressed: () async {
          setState(() {
            _showSaveButton = false; // Kaydet butonunu gizle
          });
          // Rutini kaydet
          await _saveRoutine();
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
  List<ExerciseHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _sets = List<SetEntry>.from(widget.sets);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final allHistory = await DataManager.getExerciseHistory();
    setState(() {
      _history = allHistory[widget.exercise.name] ?? [];
    });
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
    final history = _history;
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
  AthleteQuote(
    name: 'Muhammed Ali',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'The man who has no imagination has no wings.',
    quoteTurkish: 'Hayal gücü olmayan insanın kanatları da yoktur.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Michael Jordan',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'ve failed over and over and over again in my life. And that is why I succeed.',
    quoteTurkish: 'Başarısız oldum, tekrar tekrar. Bu yüzden başardım.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Cristiano Ronaldo',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'Talent without working hard is nothing.',
    quoteTurkish: 'Yetenek sadece bir başlangıçtır, çalışmak seni zirveye taşır.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Serena Williams',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I really think a champion is defined not by their wins but by how they can recover when they fall.',
    quoteTurkish: 'Zorluklar beni durdurmadı, tam tersine motive etti.',
    sport: 'Tennis',
    gradientColors: [Colors.pink, Colors.red, Colors.orange],
  ),
  AthleteQuote(
    name: 'Usain Bolt',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ff2084a31?auto=format&fit=crop&w=800&q=80',
    quote: 'Winners never quit and quitters never win.',
    quoteTurkish: 'Kazananlar asla vazgeçmez, vazgeçenler asla kazanamaz.',
    sport: 'Athletics',
    gradientColors: [Colors.green, Colors.teal, Colors.cyan],
  ),
  AthleteQuote(
    name: 'Kobe Bryant',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Mamba Mentality is about being the best version of yourself every single day.',
    quoteTurkish: 'Mamba Mentalitesi: Her gün daha iyi olmaya çalışmaktır.',
    sport: 'Basketball',
    gradientColors: [Colors.purple, Colors.deepPurple, Colors.black],
  ),
  AthleteQuote(
    name: 'Roger Federer',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'You have to believe in the long term plan you have but you need the short term goals to motivate and inspire you.',
    quoteTurkish: 'Başarı; tutku, sabır ve kararlılıkla gelir.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Lionel Messi',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'You have to fight to reach your dream. You have to sacrifice and work hard for it.',
    quoteTurkish: 'Hayal kurmak zorundasın, sonra o hayali gerçeğe çevirmek için çalışmalısın.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Ronda Rousey',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'You have two choices: You can sit and dwell on what was wrong, or you can get up and do something about it.',
    quoteTurkish: 'Hayatta ya bir şeyleri beklersin ya da gidip alırsın.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Michael Phelps',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ff2084a31?auto=format&fit=crop&w=800&q=80',
    quote: 'You can\'t put a limit on anything. The more you dream, the farther you get.',
    quoteTurkish: 'Hayal kurun. Büyük düşünün. Sınırlarınızı zorlayın.',
    sport: 'Swimming',
    gradientColors: [Colors.blue, Colors.cyan, Colors.teal],
  ),
  AthleteQuote(
    name: 'LeBron James',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Hard work beats talent when talent fails to work hard.',
    quoteTurkish: 'Çalışmadan başarı gelmez.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Tom Brady',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'You wanna know which ring is my favorite? The next one.',
    quoteTurkish: 'Başarı; fedakarlık, disiplin ve inançla gelir.',
    sport: 'American Football',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Manny Pacquiao',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'All those who are around me are the bridge to my success, so they are all important.',
    quoteTurkish: 'Tanrı bana bir yetenek verdi, ben de onun hakkını vermek zorundayım.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Novak Djokovic',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'Mental strength is just as important as physical strength.',
    quoteTurkish: 'Zihinsel güç, fiziksel gücün önündedir.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Conor McGregor',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'Doubt is only removed by action. If you\'re not working then that\'s where doubt comes in.',
    quoteTurkish: 'Başarı benim için bir seçenek değil, zorunluluktur.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Stephen Curry',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Be the best version of yourself in anything you do. You don\'t have to live anybody else\'s story.',
    quoteTurkish: 'Kendine inan. Hiç kimse senin yerine o işi yapamaz.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Shaquille O\'Neal',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Excellence is not a singular act, but a habit. You are what you repeatedly do.',
    quoteTurkish: 'Mazeretler başarısızlığın yapıtaşlarıdır.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Zlatan Ibrahimović',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'I can\'t help but laugh at how perfect I am.',
    quoteTurkish: 'Asla sıradan olma. Kendi yolunu çiz.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Khabib Nurmagomedov',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'If you give up once, it becomes a habit. Never give up.',
    quoteTurkish: 'Sadece kazanmak yetmez, nasıl kazandığın da önemlidir.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Andy Murray',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I don\'t play for the applause, I play for the progress.',
    quoteTurkish: 'Başarı; yalnızca kazanmak değil, zorlukların üstesinden gelmektir.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Tyson Fury',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'You don\'t lose if you get knocked down; you lose if you stay down.',
    quoteTurkish: 'En büyük savaşlarımız kendi içimizdekiyle olur.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Neymar Jr.',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    quote: 'The secret is to believe in your dreams; in your potential that you can be like your star.',
    quoteTurkish: 'Hayal ediyorsan başarabilirsin.',
    sport: 'Football',
    gradientColors: [Colors.orange, Colors.red, Colors.pink],
  ),
  AthleteQuote(
    name: 'Simone Biles',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'d rather regret the risks that didn\'t work out than the chances I didn\'t take at all.',
    quoteTurkish: 'Kendi gücünün farkına vardığında hiçbir şey imkansız değildir.',
    sport: 'Gymnastics',
    gradientColors: [Colors.pink, Colors.purple, Colors.indigo],
  ),
  AthleteQuote(
    name: 'Andy Roddick',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'At one point in your life, you either have the thing you want or the reasons why you don\'t.',
    quoteTurkish: 'Çalışma etiğiniz karakterinizin yansımasıdır.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Dirk Nowitzki',
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
    quote: 'Whatever I try, I always try to give my best.',
    quoteTurkish: 'Tutku, başarıdan daha değerlidir.',
    sport: 'Basketball',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
  AthleteQuote(
    name: 'Valentino Rossi',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'To be a great motorbike racer, the most important thing is passion for the bike.',
    quoteTurkish: 'En büyük hız cesaretten gelir.',
    sport: 'MotoGP',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Anderson Silva',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'The best fighter is not necessarily the greatest winner, but the one who overcomes the most.',
    quoteTurkish: 'Rakibin en büyük silahı korkudur.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'George St-Pierre',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'I\'m not trying to be better than anyone else. I\'m trying to be better than I was yesterday.',
    quoteTurkish: 'Zayıf olduğun yerleri geliştirmek, gerçek başarıdır.',
    sport: 'MMA',
    gradientColors: [Colors.grey, Colors.black, Colors.red],
  ),
  AthleteQuote(
    name: 'Floyd Mayweather',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
    quote: 'Hard work and dedication. You have to be willing to sacrifice.',
    quoteTurkish: 'Sıkı çalışma ve adanmışlık. Fedakarlık yapmaya hazır olmalısın.',
    sport: 'Boxing',
    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
  ),
  AthleteQuote(
    name: 'Rafael Nadal',
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
    quote: 'The most important thing is to enjoy your life - to be happy - it\'s all that matters.',
    quoteTurkish: 'En önemli şey hayatından zevk almak - mutlu olmak - tek önemli olan bu.',
    sport: 'Tennis',
    gradientColors: [Colors.blue, Colors.indigo, Colors.purple],
  ),
];

// Notification servisi
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Timezone'u başlat
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
    _initialized = true;
  }

  static Future<void> scheduleWeightReminder({
    required TimeOfDay time,
    required String frequency,
  }) async {
    await initialize();

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Eğer bugünün saati geçtiyse, yarını ayarla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1, // Weight reminder ID
      'Tartılma Hatırlatıcısı',
      'Bugün tartılma zamanınız geldi! Kilo takibinizi yapmayı unutmayın.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'weight_reminder',
          'Tartılma Hatırlatıcısı',
          channelDescription: 'Kilo takibi için hatırlatıcılar',
                importance: Importance.max,
      priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: frequency == 'Haftalık' 
          ? DateTimeComponents.dayOfWeekAndTime 
          : DateTimeComponents.dayOfMonthAndTime,
    );
  }

  static Future<void> scheduleWaterReminder({
    required TimeOfDay time,
    required String interval,
  }) async {
    await initialize();

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Eğer bugünün saati geçtiyse, yarını ayarla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Aralık hesaplama
    int hours = 2; // Varsayılan 2 saat
    switch (interval) {
      case '1 saat':
        hours = 1;
        break;
      case '2 saat':
        hours = 2;
        break;
      case '3 saat':
        hours = 3;
        break;
    }

    await _notifications.zonedSchedule(
      2, // Water reminder ID
      'Su İçme Hatırlatıcısı',
      'Su içme zamanınız geldi! Sağlıklı kalmak için su içmeyi unutmayın.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder',
          'Su İçme Hatırlatıcısı',
          channelDescription: 'Su içme hatırlatıcıları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Tekrarlayan notification için
    await _notifications.zonedSchedule(
      3, // Repeating water reminder ID
      'Su İçme Hatırlatıcısı',
      'Su içme zamanınız geldi! Sağlıklı kalmak için su içmeyi unutmayın.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder_repeat',
          'Su İçme Hatırlatıcısı (Tekrarlı)',
          channelDescription: 'Tekrarlayan su içme hatırlatıcıları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelWeightReminder() async {
    await _notifications.cancel(1);
  }

  static Future<void> cancelWaterReminder() async {
    await _notifications.cancel(2);
    await _notifications.cancel(3);
  }

  static Future<void> requestPermissions() async {
    await initialize();
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }
}


