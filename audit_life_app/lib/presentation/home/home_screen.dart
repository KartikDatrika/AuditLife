import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/repositories/check_in_repository_impl.dart';
import '../../domain/entities/check_in.dart';
import '../check_in/check_in_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingIndex;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String path, int index) async {
    if (_playingIndex == index) {
      await _audioPlayer.stop();
      setState(() => _playingIndex = null);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(path));
      setState(() => _playingIndex = index);
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) setState(() => _playingIndex = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkInsAsync = ref.watch(checkInRepositoryProvider).watchAllCheckIns();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit  Life'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<CheckIn>>(
        stream: checkInsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final checkIns = (snapshot.data ?? []).reversed.toList();
          
          if (checkIns.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.history_edu, size: 64, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text('All you have is now !', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                   const SizedBox(height: 8),
                   const Text('Start tracking your life patterns!'),
                 ],
               ),
             );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: checkIns.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final checkIn = checkIns[index];
              final bool isPlaying = _playingIndex == index;
              
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(checkIn.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              checkIn.type,
                              style: TextStyle(
                                color: _getCategoryColor(checkIn.type),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat.jm().format(checkIn.timestamp),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (checkIn.content != null && checkIn.content!.isNotEmpty)
                        Text(
                          checkIn.content!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (checkIn.audioPath != null) ...[
                        if (checkIn.content != null && checkIn.content!.isNotEmpty)
                          const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _playAudio(checkIn.audioPath!, index),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isPlaying ? 'Playing...' : 'Voice Note',
                                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        DateFormat.yMMMMd().format(checkIn.timestamp),
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CheckInScreen()),
          );
        },
        label: const Text('Check In'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'Work': return Colors.blue;
      case 'Sleep': return Colors.indigo;
      case 'Exercise': return Colors.orange;
      case 'Food': return Colors.green;
      case 'Poop': return Colors.brown;
      case 'Mood': return Colors.pink;
      case 'Wellness': return Colors.purple;
      default: return Colors.teal;
    }
  }
}
