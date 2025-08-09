import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SunFlowerPage extends StatefulWidget {
  const SunFlowerPage({super.key});

  @override
  State<SunFlowerPage> createState() => _SunFlowerPageState();
}

class _SunFlowerPageState extends State<SunFlowerPage> {
  double waterLevel = 1.0;
  Timer? _drainTimer;
  final AudioPlayer _player = AudioPlayer();

  String currentImage = '';
  String currentAudio = '';

  @override
  void initState() {
    super.initState();
    startWaterDrain();
    _updateImageAndAudio(); // Start with full water image/audio
  }

  void startWaterDrain() {
    _drainTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      setState(() {
        waterLevel -= 0.0017; // drains fully in ~1 min
        if (waterLevel < 0) waterLevel = 0;
        _updateImageAndAudio();
      });
    });
  }

  void waterPlant() {
    setState(() {
      waterLevel += 0.2;
      if (waterLevel > 1.0) waterLevel = 1.0;
      _updateImageAndAudio();
    });
  }

  void _updateImageAndAudio() async {
    String newImage;
    String newAudio;

    if (waterLevel < 0.25) {
      newImage = 'assets/ssdead.jpg';
      newAudio = 'assets/dead.OPUS';
    } else if (waterLevel < 0.6) {
      newImage = 'assets/sweak.jpg';
      newAudio = 'assets/weak.OPUS';
    } else {
      newImage = 'assets/shappy.jpg';
      newAudio = 'assets/happy.OPUS';
    }

    // Only change audio if the state changes
    if (newImage != currentImage) {
      currentImage = newImage;
      currentAudio = newAudio;
      await _playAudio(currentAudio);
    }
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(path.replaceFirst('assets/', '')));
  }

  @override
  void dispose() {
    _drainTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sunflower 🌻"),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Stack(
        children: [
          // Centered Plant Image
          Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Your Plant's State",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
             Image.asset(
              currentImage,
              height: 250,
              fit: BoxFit.contain,
            ),
              ],
          ),
          ),

          // Right-side Water bar + Button
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Water bar
                  SizedBox(
                    height: 150,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 150 * waterLevel,
                          decoration: BoxDecoration(
                            color: waterLevel < 0.25 ? Colors.red : Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Floating action button below water bar
                  FloatingActionButton(
                    onPressed: waterPlant,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.water_drop, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
