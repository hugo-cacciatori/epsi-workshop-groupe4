import 'package:alertchain/helpers/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alertchain/models/alert.dart';
import 'package:alertchain/models/user.dart';
import 'package:vibration/vibration.dart'; // For vibration
import 'package:audioplayers/audioplayers.dart'; // For audio playback

class AlertPopup extends StatefulWidget {
  final Alert alert;
  final User currentUser;

  AlertPopup({
    required this.alert,
    required this.currentUser,
  });

  @override
  _AlertPopupState createState() => _AlertPopupState();
}

class _AlertPopupState extends State<AlertPopup> {
  late AudioPlayer _audioPlayer; // Player for audio
  final int _vibrationDuration = 500; // Vibration duration in milliseconds

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playAlarmAndVibrate(); // Call the combined method
  }

  Future<void> _playAlarmAndVibrate() async {
    await Future.wait([
      _playAlarmSound(),
      _vibratePhone(),
    ]);
  }

  Future<void> _playAlarmSound() async {
    await _audioPlayer
        .setSource(AssetSource('ALARM.wav')); // Ensure the path is correct
    await _audioPlayer.setVolume(1.0); // Set volume to maximum
    await _audioPlayer.resume(); // Start playing the sound
  }

  Future<void> _vibratePhone() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(
          duration: _vibrationDuration); // Vibrate for specified duration
      await Future.delayed(
          Duration(milliseconds: 500)); // Delay between vibrations
      await Vibration.vibrate(duration: _vibrationDuration); // Vibrate again
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'ALERT!',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${capitalize(widget.alert.senderDepartmentName)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              'Sent by: ${capitalize(widget.alert.senderFirstName)} ${capitalize(widget.alert.senderLastName)}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              'Time: ${calculateTimeAgo(widget.alert.timestamp)}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _audioPlayer.stop(); // Stop sound on close
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }

  // Calculate time ago for display
  String calculateTimeAgo(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 30) {
      return 'now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      return '${difference.inDays ~/ 30} months ago';
    }
  }
}
