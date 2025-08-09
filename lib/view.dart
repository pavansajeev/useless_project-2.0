import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';  // <-- add this

class ViewPlant extends StatefulWidget {
  const ViewPlant({super.key});

  @override
  State<ViewPlant> createState() => _ViewPlantState();
}

class _ViewPlantState extends State<ViewPlant> {
  String? plantName;
  double waterLevel = 1.0; // 100%
  Timer? timer;

  final AudioPlayer _player = AudioPlayer(); // <-- audio player instance
  String currentAudio = '';

  @override
  void initState() {
    super.initState();
    loadPlantData();
    startWaterDrain();
  }

  Future<void> loadPlantData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      plantName = prefs.getString('plantName');
    });
  }

  void startWaterDrain() {
    timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      setState(() {
        waterLevel -= 0.0017; // drains fully in ~1 min
        if (waterLevel < 0) waterLevel = 0;
        _updateAudio();
      });
    });
  }

  void waterPlant() {
    setState(() {
      waterLevel += 0.2;
      if (waterLevel > 1.0) waterLevel = 1.0;
      _updateAudio();
    });
  }

  String getPlantImage() {
    if (waterLevel > 0.6) {
      return 'assets/happy.jpg';
    } else if (waterLevel > 0.25) {
      return 'assets/weak.jpg';
    } else {
      return 'assets/dead.jpg';
    }
  }

  void _updateAudio() async {
    String newAudio;
    if (waterLevel < 0.25) {
      newAudio = 'assets/dead.OPUS';
    } else if (waterLevel < 0.6) {
      newAudio = 'assets/weak.OPUS';
    } else {
      newAudio = 'assets/happy.OPUS';
    }

    if (newAudio != currentAudio) {
      currentAudio = newAudio;
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(currentAudio.replaceFirst('assets/', '')));
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (plantName == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plantName!),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Center the plant image
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Your Plant's State",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  getPlantImage(),
                  height: 200,
                ),
              ],
            ),
          ),
          // Small vertical water bar on right side
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Container(
              width: 25,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: waterLevel,
                  child: Container(
                    decoration: BoxDecoration(
                      color: waterLevel < 0.25 ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: waterPlant,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.water_drop),
      ),
    );
  }
}
