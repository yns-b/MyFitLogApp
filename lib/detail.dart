import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'event_bus.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final List<SetEntry> sets;
  final List<ExerciseHistory> history;
  final bool workoutFlow;
  final int exerciseIndex;
  final List<RoutineEntry> allEntries;
  /// Antrenmanın yapıldığı gün (örn. Pazartesi); son tamamlanma tarihinin doğru güne yazılması için.
  final String? dayName;

  const ExerciseDetailScreen({
    Key? key,
    required this.exerciseName,
    required this.sets,
    required this.history,
    this.workoutFlow = false,
    this.exerciseIndex = 0,
    this.allEntries = const [],
    this.dayName,
  }) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  // Bu oturumda kaydedilen set sayısı (aynı egzersiz farklı rutine eklense de sıfırlanır)
  int _sessionSavedSets = 0;
  int currentSet = 0;
  double? currentWeight;
  int? currentReps;
  List<SetEntry> localSets = [];
  bool hasChanges = false;
  List<ExerciseHistory> _localHistory = [];

  @override
  void initState() {
    super.initState();
    localSets = List.from(widget.sets);
    if (localSets.isNotEmpty) {
      currentWeight = localSets[0].targetWeight?.toDouble();
      currentReps = localSets[0].targetReps;
    }
    _loadHistory();
    
    // DataClearedEvent listener ekle
    eventBus.on<DataClearedEvent>().listen((event) {
      print('DEBUG: Detail.dart - DataClearedEvent alındı - isGlobalClear: ${event.isGlobalClear}, exerciseName: ${event.exerciseName}');
      
      if (!mounted) return;
      if (event.isGlobalClear) {
        // Tüm veriler temizlendi
        setState(() {
          _localHistory = [];
        });
        print('DEBUG: Detail.dart - Tüm veriler temizlendi, _localHistory temizlendi');
      } else if (event.exerciseName != null && event.exerciseName == widget.exerciseName) {
        // Bu egzersizin verisi temizlendi
        setState(() {
          _localHistory = [];
        });
        print('DEBUG: Detail.dart - ${event.exerciseName} egzersiz verisi temizlendi');
      }
    });

    // Egzersiz detayı açıldığında hızlı ilerleme bildirimi göster
    if (localSets.isNotEmpty) {
      NotificationService.showCustomWorkoutNotification(
        exerciseName: widget.exerciseName,
        currentSet: currentSet + 1,
        totalSets: localSets.length,
        weight: currentWeight ?? 0,
        reps: currentReps ?? 0,
      );
    }
  }

  Future<void> _loadHistory() async {
    try {
      print('📋 DEBUG: _loadHistory - Fonksiyon başladı (${widget.exerciseName})');
      
      // Yerel state temizle
      setState(() {
        _localHistory = [];
      });
      print('📋 DEBUG: _loadHistory - Yerel state temizlendi');
      
      // DataManager'dan geçmiş verileri al
      final exerciseHistory = await DataManager.getExerciseHistory();
      print('📋 DEBUG: _loadHistory - DataManager\'dan alınan geçmiş: ${exerciseHistory.length} egzersiz');
      
      // Egzersiz anahtarlarını bul
      final keys = exerciseHistory.keys.toList();
      print('📋 DEBUG: _loadHistory - Bulunan egzersiz anahtarları: $keys');
      
      // Aranan egzersizi bul
      final searchKey = widget.exerciseName.trim().toLowerCase();
      print('📋 DEBUG: _loadHistory - Aranan anahtar: "$searchKey"');
      print('📋 DEBUG: _loadHistory - Mevcut anahtarlar: $keys');
      
      if (keys.contains(searchKey)) {
        final exerciseHistoryList = exerciseHistory[searchKey]!;
        print('📋 DEBUG: _loadHistory - "$searchKey" için bulunan kayıt sayısı: ${exerciseHistoryList.length}');
        
        // Sadece bugün ve en son tamamlanan gün için verileri yükle
        final today = DateTime.now();
        final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        // Son tamamlanan gün (WeekScreen'den gelir)
        final lastCompletedDay = (globalCompletedWorkouts.isNotEmpty)
            ? globalCompletedWorkouts.keys.toList().last
            : null;
        
        final filtered = exerciseHistoryList.where((h) {
          final d = h.date;
          final ds = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          if (ds == todayString) return true; // bugün yapılanlar
          if (lastCompletedDay != null && ds == lastCompletedDay) return true; // son tamamlanan gün
          return false;
        }).toList();
        // Yeni kayıtlar üstte görünsün
        filtered.sort((a, b) => b.date.compareTo(a.date));
        
        setState(() {
          _localHistory = filtered;
        });
        print('📋 DEBUG: _loadHistory - Bugün/son gün için ${filtered.length} kayıt yüklendi');
      } else {
        print('📋 DEBUG: _loadHistory - "$searchKey" için kayıt bulunamadı');
    setState(() {
          _localHistory = [];
    });
  }

      print('📋 DEBUG: _loadHistory - Fonksiyon tamamlandı');
    } catch (e) {
      print('📋 DEBUG: _loadHistory - Hata: $e');
    setState(() {
        _localHistory = [];
      });
    }
  }

  // Bugün kaydedilen set sayısı
  int get bugunKaydedilenSetSayisi {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    int count = 0;
    for (final h in _localHistory) {
      if (h.date != null) {
        final historyDate = h.date;
        final historyDateString = '${historyDate.year}-${historyDate.month.toString().padLeft(2, '0')}-${historyDate.day.toString().padLeft(2, '0')}';
        
        if (historyDateString == todayString) {
          count += h.setsCount;
        }
      }
    }
    
    print('DEBUG: bugunKaydedilenSetSayisi - _localHistory\'den: $count');
    return count;
  }

  // Toplam set sayısı
  int get toplamSetSayisi => widget.sets.length;

  Future<void> _saveExerciseHistory() async {
    try {
      print('💾 DEBUG: Detail.dart - Kaydet butonu tıklandı');
      print('💾 DEBUG: Detail.dart - Çağrı yığını: ${StackTrace.current}');
      
      // Oturum içi set limiti kontrolü (aynı gün yeni oturumlarda engel olmaması için)
      print('💾 DEBUG: Detail.dart - Oturumda kaydedilen set: $_sessionSavedSets / $toplamSetSayisi');
      if (_sessionSavedSets >= toplamSetSayisi) {
        print('💾 DEBUG: Detail.dart - Bu oturum için tüm setler kaydedildi, yeni kayıt eklenmiyor');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bu oturum için planlanan tüm setler tamamlandı.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Mevcut set bilgilerini güncelle ve tamamlandı işaretle
      localSets[currentSet] = localSets[currentSet].copyWith(
        actualWeight: currentWeight,
        actualReps: currentReps,
        isCompleted: true,
      );
      
      // Mevcut geçmişi al ve yeni veriyi ekle
      final currentHistory = await DataManager.getExerciseHistory();
      print('💾 DEBUG: Detail.dart - Mevcut geçmiş: ${currentHistory.length} egzersiz');
      
      final key = widget.exerciseName.trim().toLowerCase();
      final list = currentHistory[key] ?? [];
      print('Detail.dart - $key için mevcut kayıt sayısı: ${list.length}');
      
      // Bugün için eski kayıtlar korunuyor, yeni set ekleniyor
      print('Detail.dart - Bugün için eski kayıtlar korunuyor, yeni set ekleniyor');
      
      // Yeni history entry oluştur
      final newHistory = ExerciseHistory(
        exerciseName: widget.exerciseName,
        date: DateTime.now(),
        weight: currentWeight ?? 0.0,
        reps: currentReps ?? 0,
        setsCount: 1,
        sets: [localSets[currentSet]],
      );
      
      // Listeye ekle
      list.add(newHistory);
      currentHistory[key] = list;
      
      print('Detail.dart - Güncellenmiş geçmiş: ${currentHistory.length} egzersiz');
      
      // Kaydet
      await DataManager.saveExerciseHistory(currentHistory);
      
      // Oturum içi sayaç artır
      _sessionSavedSets += 1;
      
      // Sonraki set'e ilerle (varsa)
      if (currentSet < localSets.length - 1) {
        setState(() {
          currentSet += 1;
          currentWeight = localSets[currentSet].targetWeight?.toDouble();
          currentReps = localSets[currentSet].targetReps;
        });
      }
      
      // Yerel state'i güncelle
      await _loadHistory();
      
      print('Detail.dart - Egzersiz geçmişi başarıyla kaydedildi: ${widget.exerciseName} - ${currentWeight?.toStringAsFixed(1)} kg × ${currentReps} tekrar');
    } catch (e) {
      print('Detail.dart - Egzersiz geçmişi kaydetme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Antrenman tamamlandı olarak işaretle
  Future<void> _completeWorkout() async {
    try {
      print('DEBUG: Detail.dart - Antrenman tamamlanıyor...');
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Tamamlanan antrenman tarihlerini al
      final completedWorkoutDates = await DataManager.getCompletedWorkoutDates();
      
      // Bugün için antrenman tamamlandı olarak işaretle
      if (!completedWorkoutDates.contains(todayString)) {
        // Tüm egzersizleri içeren antrenman kaydı oluştur
        final allWorkouts = <RoutineEntry>[];
        
        // Günün tüm egzersizlerini ekle (tamamlanan set sayısını kullan)
        for (final entry in widget.allEntries) {
          final completedSets = entry.sets.where((s) => s.isCompleted).toList();
          final fallbackSets = completedSets.isNotEmpty ? completedSets : entry.sets;
          final workout = RoutineEntry(
            exercise: entry.exercise,
            setCount: fallbackSets.length,
            sets: fallbackSets,
          );
          allWorkouts.add(workout);
        }
        
        // Mevcut tamamlanan antrenmanları al
        final completedWorkouts = await DataManager.getCompletedWorkouts();
        completedWorkouts[todayString] = allWorkouts;
        await DataManager.saveCompletedWorkouts(completedWorkouts);
        
        print('DEBUG: Detail.dart - Bugün için ${allWorkouts.length} egzersiz ile antrenman tamamlandı olarak işaretlendi: $todayString');
      }
      
      // EventBus ile antrenman tamamlandığını bildir (dayName: hangi gün tamamlandı, tarih karışıklığını önler)
      eventBus.fire(WorkoutCompletedEvent(date: today, dayName: widget.dayName));
      print('DEBUG: Detail.dart - Antrenman başarıyla tamamlandı');
    } catch (e) {
      print('DEBUG: Detail.dart - Antrenman tamamlama hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Geçmişi Temizle butonu
          IconButton(
            icon: Icon(Icons.delete_sweep, color: Colors.orange),
            tooltip: globalLanguage == 'Türkçe' ? 'Egzersiz Geçmişini Temizle' : 'Clear Exercise History',
            onPressed: () => _showClearHistoryDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ÜST: Egzersiz Geçmişi Tablosu ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Text('Egzersiz Geçmişi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 8),
                            // Geçmiş veri sadece antrenman tamamlandıktan sonra gösterilsin
                    // Kayıt yok metni kaldırıldı
                    if (_localHistory.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: SingleChildScrollView(
                          child: Card(
                            margin: const EdgeInsets.all(12),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Tarih')),
                                DataColumn(label: Text('Kg')),
                                DataColumn(label: Text('Tekrar')),
                              ],
                              rows: [
                                for (final h in _localHistory)
                                          DataRow(
                                            cells: [
                                              DataCell(Text(h.date != null 
                                                ? '${h.date!.day}.${h.date!.month}.${h.date!.year}'
                                                : 'Bilinmiyor')),
                                              DataCell(Text(h.weight?.toString() ?? '0')),
                                              DataCell(Text(h.reps?.toString() ?? '0')),
                                            ],
                                          ),
                              ],
                            ),
                          ),
                        ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Henüz bugün için antrenman yapılmadı',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // --- ORTA: Set seçici ve egzersiz adı ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Set seçici
                    DropdownButton<int>(
                      value: currentSet + 1,
                      items: List.generate(widget.sets.length, (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('Set ${i + 1}'),
                      )),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            currentSet = val - 1;
                            currentWeight = widget.sets[currentSet].targetWeight?.toDouble();
                            currentReps = widget.sets[currentSet].targetReps;
                          });
                        }
                      },
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.exerciseName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Egzersiz görseli (egzersiz adına göre asset)
                    (() {
                      final name = widget.exerciseName.toLowerCase();
                      String? asset = assetForExercise(name);
                      if (asset != null) {
                        return Image.asset(
                          asset,
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.fitness_center, color: Colors.grey[400], size: 32),
                        );
                      }
                      return Icon(Icons.fitness_center, color: Colors.grey[400], size: 32);
                    })(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // --- ALT: Ağırlık ve Tekrar Ayarları ---
            Row(
              children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                              Text('Ağırlık (KG)', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                                        if (currentWeight != null) {
                                          currentWeight = (currentWeight! - 2.5).clamp(0.0, 999.0);
                                          localSets[currentSet] = localSets[currentSet].copyWith(
                                            actualWeight: currentWeight,
                                          );
                                          hasChanges = true;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.remove_circle_outline),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red[50],
                                      foregroundColor: Colors.red[700],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: currentWeight?.toStringAsFixed(1) ?? '',
                                      ),
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 14),
                                        labelText: 'KG',
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        final weight = double.tryParse(value);
                                        if (weight != null) {
                                          setState(() {
                                            currentWeight = weight;
                                            localSets[currentSet] = localSets[currentSet].copyWith(
                                              actualWeight: weight,
                                            );
                              hasChanges = true;
                            });
                                        }
                                      },
                                    ),
                                  ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                                        if (currentWeight != null) {
                                          currentWeight = (currentWeight! + 2.5).clamp(0.0, 999.0);
                                          localSets[currentSet] = localSets[currentSet].copyWith(
                                            actualWeight: currentWeight,
                                          );
                              hasChanges = true;
                                        }
                            });
                          },
                                    icon: Icon(Icons.add_circle_outline),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.green[50],
                                      foregroundColor: Colors.green[700],
                                    ),
                        ),
                      ],
                    ),
                  ],
                ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tekrar', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                                        if (currentReps != null) {
                                          currentReps = (currentReps! - 1).clamp(1, 999);
                                          localSets[currentSet] = localSets[currentSet].copyWith(
                                            actualReps: currentReps,
                                          );
                                          hasChanges = true;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.remove_circle_outline),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red[50],
                                      foregroundColor: Colors.red[700],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: currentReps?.toString() ?? '',
                                      ),
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 14),
                                        labelText: 'Tekrar',
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        final reps = int.tryParse(value);
                                        if (reps != null) {
                                          setState(() {
                                            currentReps = reps;
                                            localSets[currentSet] = localSets[currentSet].copyWith(
                                              actualReps: reps,
                                            );
                              hasChanges = true;
                            });
                                        }
                                      },
                                    ),
                                  ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                                        if (currentReps != null) {
                                          currentReps = (currentReps! + 1).clamp(1, 999);
                                          localSets[currentSet] = localSets[currentSet].copyWith(
                                            actualReps: currentReps,
                                          );
                              hasChanges = true;
                                        }
                            });
                          },
                                    icon: Icon(Icons.add_circle_outline),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.green[50],
                                      foregroundColor: Colors.green[700],
                                    ),
                        ),
                      ],
                    ),
                  ],
                          ),
                ),
              ],
            ),
                    SizedBox(height: 24),
                    // --- KAYDET BUTONU ---
                    ElevatedButton(
                      onPressed: () async {
                        print('💾 DEBUG: Detail.dart - Kaydet butonu tıklandı');
                        print('💾 DEBUG: Detail.dart - Çağrı yığını: ${StackTrace.current}');
                        
                        // Mevcut set bilgilerini güncelle
                        localSets[currentSet] = localSets[currentSet].copyWith(
                          actualWeight: currentWeight,
                          actualReps: currentReps,
                        );
                        
                        // Egzersiz geçmişine kaydet
                        await _saveExerciseHistory();
                        // İlerlemeyi kaydet
                        // Güncel setleri ana listedeki ilgili egzersize yaz
                        if (widget.allEntries.isNotEmpty && widget.exerciseIndex < widget.allEntries.length) {
                          final updatedEntries = List<RoutineEntry>.from(widget.allEntries);
                          final currentEntry = updatedEntries[widget.exerciseIndex];
                          updatedEntries[widget.exerciseIndex] = RoutineEntry(
                            exercise: currentEntry.exercise,
                            setCount: localSets.length,
                            sets: List<SetEntry>.from(localSets),
                          );
                          await DataManager.saveActiveWorkout(
                            entries: updatedEntries,
                            exerciseIndex: widget.exerciseIndex,
                            setIndex: currentSet,
                            exerciseName: widget.exerciseName,
                          );
                        } else {
                          await DataManager.saveActiveWorkout(
                            entries: [
                              RoutineEntry(
                                exercise: Exercise(
                                  name: widget.exerciseName,
                                  muscleGroups: const [],
                                  mainMuscleGroup: '',
                                ),
                                setCount: localSets.length,
                                sets: localSets,
                              )
                            ],
                            exerciseIndex: widget.exerciseIndex,
                            setIndex: currentSet,
                            exerciseName: widget.exerciseName,
                          );
                        }
                        
                        // Event: set ilerledi (ana ekran canlı günceller)
                        try {
                          eventBus.fire(SetProgressedEvent(widget.exerciseName, currentSet + 1));
                        } catch (_) {}

                        // Bildirimi güncelle/göster
                        await NotificationService.showQuickSetProgressNotification(
                          exerciseName: widget.exerciseName,
                          currentSet: currentSet + 1,
                          totalSets: localSets.length,
                          weight: currentWeight ?? 0,
                          reps: currentReps ?? 0,
                        );

                      },
                      child: Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Sonraki Egzersize Geç Butonu - Bu oturumda tüm setler tamamlanınca göster
                    if (widget.workoutFlow && _sessionSavedSets >= toplamSetSayisi)
              FutureBuilder<int?>(
                future: _findNextIncompleteExerciseIndex(widget.exerciseIndex, widget.allEntries),
                builder: (context, snapshot) {
                  final nextIndex = snapshot.data;
                  if (nextIndex == null) return SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await NotificationService.cancelQuickSetProgressNotification();
                        // Güncellenmiş entries'i al (aktif çalışmadan)
                        final active = await DataManager.getActiveWorkout();
                        final updatedEntries = (active != null && active['entries'] is List<RoutineEntry>)
                            ? List<RoutineEntry>.from(active['entries'])
                            : widget.allEntries;
                        final nextEntry = updatedEntries[nextIndex];
                        print('Sonraki egzersize geçiliyor: ${nextEntry.exercise.name}');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseDetailScreen(
                              exerciseName: nextEntry.exercise.name,
                              sets: nextEntry.sets,
                              history: <ExerciseHistory>[],
                              workoutFlow: true,
                              exerciseIndex: nextIndex,
                              allEntries: updatedEntries,
                              dayName: widget.dayName,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.arrow_forward),
                      label: Text('Sonraki Egzersize Geç'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  );
                },
              ),
            // Antrenmanı Bitir Butonu - Tüm egzersizler tamamlandığında her ekranda göster
                    if (widget.workoutFlow)
              FutureBuilder<bool>(
                future: awaitAllExercisesCompleted(widget.allEntries),
                builder: (context, snapshot) {
                  final canFinish = snapshot.data == true;
                  if (!canFinish) return SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await NotificationService.cancelQuickSetProgressNotification();
                        print('Antrenman bitiriliyor - tüm egzersizler tamamlandı');
                        
                        // Antrenman tamamlandı olarak işaretle
                        await _completeWorkout();
                        // Aktif oturumu temizle ki gün detayında Finish görünmesin
                        await DataManager.clearActiveWorkout();
                        
                        // Ana ekrana dön ve tebrik mesajı göster
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        
                        // Tebrik mesajı
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              globalLanguage == 'Türkçe'
                                ? '🎉 Tebrikler! Antrenman tamamlandı!'
                                : '🎉 Congratulations! Workout completed!',
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: Icon(Icons.flag),
                      label: Text('Antrenmanı Bitir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  );
                },
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
  
  // Tüm egzersizler tamamlandı mı? Aktif antrenmandaki güncel set durumları ile kontrol et
  Future<bool> awaitAllExercisesCompleted(List<RoutineEntry> entries) async {
    try {
      final active = await DataManager.getActiveWorkout();
      final currentEntries = (active != null && active['entries'] is List<RoutineEntry>)
          ? List<RoutineEntry>.from(active['entries'])
          : entries;
      for (final e in currentEntries) {
        if (!e.sets.every((s) => s.isCompleted)) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
  
  // Bir sonraki tamamlanmamış egzersizin indeksini bul (dairesel arama)
  Future<int?> _findNextIncompleteExerciseIndex(int currentIndex, List<RoutineEntry> entries) async {
    try {
      final active = await DataManager.getActiveWorkout();
      final currentEntries = (active != null && active['entries'] is List<RoutineEntry>)
          ? List<RoutineEntry>.from(active['entries'])
          : entries;

      // Hepsi tamamlandıysa null döndür
      final allCompleted = currentEntries.every((e) => e.sets.every((s) => s.isCompleted));
      if (allCompleted) return null;

      // Önce mevcut indexten sonraki adaylara bak
      for (int i = currentIndex + 1; i < currentEntries.length; i++) {
        final entry = currentEntries[i];
        if (entry.sets.any((s) => !s.isCompleted)) return i;
      }
      // Sonra baştan mevcut indexe kadar bak (dairesel)
      for (int i = 0; i < currentIndex; i++) {
        final entry = currentEntries[i];
        if (entry.sets.any((s) => !s.isCompleted)) return i;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  
  // Egzersiz geçmişini temizleme dialog'u
  Future<void> _showClearHistoryDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          globalLanguage == 'Türkçe' 
            ? 'Egzersiz Geçmişini Temizle' 
            : 'Clear Exercise History',
        ),
        content: Text(
          globalLanguage == 'Türkçe' 
            ? '${widget.exerciseName} egzersizinin tüm geçmiş verilerini silmek istiyor musunuz?\n\nBu işlem geri alınamaz!'
            : 'Do you want to delete all history data for ${widget.exerciseName}?\n\nThis action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              globalLanguage == 'Türkçe' ? 'İptal' : 'Cancel',
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              globalLanguage == 'Türkçe' ? 'Temizle' : 'Clear',
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _clearExerciseHistory();
    }
  }
  
  // Belirli egzersizin geçmişini temizle
  Future<void> _clearExerciseHistory() async {
    try {
      print('DEBUG: Detail.dart - ${widget.exerciseName} egzersiz geçmişi temizleniyor...');
      
      // Mevcut geçmişi al
      final currentHistory = await DataManager.getExerciseHistory();
      final key = widget.exerciseName.trim().toLowerCase();
      
      // Bu egzersizin geçmişini kaldır
      if (currentHistory.containsKey(key)) {
        currentHistory.remove(key);
        print('DEBUG: Detail.dart - $key anahtarı kaldırıldı');
      }
      
      // Güncellenmiş veriyi kaydet
      await DataManager.saveExerciseHistory(currentHistory);
      
      // Yerel state'i temizle
      setState(() {
        _localHistory = [];
      });
      
      // EventBus ile belirli egzersiz temizlendiğini bildir
      eventBus.fire(DataClearedEvent(exerciseName: widget.exerciseName, isGlobalClear: false));
      
      // Kullanıcıya bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            globalLanguage == 'Türkçe' 
              ? '${widget.exerciseName} egzersiz geçmişi temizlendi.' 
              : '${widget.exerciseName} exercise history cleared.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      print('DEBUG: Detail.dart - ${widget.exerciseName} egzersiz geçmişi başarıyla temizlendi');
    } catch (e) {
      print('DEBUG: Detail.dart - Egzersiz geçmişi temizleme hatası: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 