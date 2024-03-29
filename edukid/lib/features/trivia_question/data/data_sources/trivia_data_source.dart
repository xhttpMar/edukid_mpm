import 'dart:convert';
import 'dart:math';

import 'package:edukid/features/trivia_question/data/models/trivia_model.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class TriviaDataSource {
  Future<TriviaModel> getTrivia(String typeQuestion);
  Future<void> updateUserStatistics(bool isAnswerCorrect, String userUID, String typeQuestion);
  Future<void> updateUserPoints(bool isAnswerCorrect, String userUID);
}

class TriviaDataSourceImpl implements TriviaDataSource {
  final _database = FirebaseDatabase.instance.ref();

  @override
  Future<TriviaModel> getTrivia(String typeQuestion) async {
    try {
      final response = await _database.child("/subject")
          .child("/$typeQuestion")
          .get();
      if (response.exists) {
        final random = Random().nextInt(response.children.length - 1) + 1;
        final selectedQuestion =
        await _database.child("/subject")
            .child("/$typeQuestion")
            .child("question$random")
            .get();
        return TriviaModel.fromJson(
            jsonDecode(jsonEncode(selectedQuestion.value)));
      } else {
        throw Exception("Unknown error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateUserStatistics(bool isAnswerCorrect, String userUID, String typeQuestion) async {
    final userRef = _database.child("users").child(userUID);
    await _currentCorrectUpdate(userRef, typeQuestion, isAnswerCorrect);
    await _currentDoneUpdate(userRef, typeQuestion);
    await _totalCorrectUpdate(userRef, typeQuestion, isAnswerCorrect);
    await _totalDoneUpdate(userRef, typeQuestion);
    await _globalCorrectUpdate(userRef, isAnswerCorrect);
    await _globalDoneUpdate(userRef);
    await _setTimestampLastAnswer(userUID, typeQuestion);
  }

  @override
  Future<void> updateUserPoints(bool isAnswerCorrect, String userUID) async {
    final userRef = _database.child("users").child(userUID);
    final currentPointsSnapshot =
      await userRef
          .child("points")
          .once();
    final currentPoints = currentPointsSnapshot.snapshot.value as int;
    final newPoints = currentPoints + (isAnswerCorrect ? 5 : -3);
    await userRef
        .child("points")
        .set(newPoints);
  }
  
  Future<void> _currentCorrectUpdate(DatabaseReference userRef, String typeQuestion, bool isAnswerCorrect) async {

    final valueCorrectSnapshot =
      await userRef
          .child("statistics")
          .child(typeQuestion)
          .child("current")
          .child("correct")
          .once();
    final currentCorrect = valueCorrectSnapshot.snapshot.value as int;
    final newCorrect = currentCorrect + (isAnswerCorrect ? 1 : 0);
    await userRef
        .child("statistics")
        .child(typeQuestion)
        .child("current")
        .child("correct")
        .set(newCorrect);
  }

  Future<void> _currentDoneUpdate(DatabaseReference userRef, String typeQuestion) async {

    final valueDoneSnapshot =
    await userRef
        .child("statistics")
        .child(typeQuestion)
        .child("current")
        .child("done")
        .once();
    final currentDone = valueDoneSnapshot.snapshot.value as int;
    final newDone = currentDone + 1;
    await userRef
        .child("statistics")
        .child(typeQuestion)
        .child("current")
        .child("done")
        .set(newDone);
  }

  Future<void> _totalCorrectUpdate(DatabaseReference userRef, String typeQuestion, bool isAnswerCorrect) async {
    final valueCorrectSnapshot =
    await userRef
        .child("statistics")
        .child(typeQuestion)
        .child("total")
        .child("correct")
        .once();
    final totalCorrect = valueCorrectSnapshot.snapshot.value as int;
    final newCorrect = totalCorrect + (isAnswerCorrect ? 1 : 0);
    await userRef
        .child("statistics")
        .child(typeQuestion)
        .child("total")
        .child("correct")
        .set(newCorrect);
  }
  Future<void> _totalDoneUpdate(DatabaseReference userRef, String typeQuestion) async {
    final valueDoneSnapshot =
    await userRef
        .child("statistics")
        .child(typeQuestion)
        .child("total")
        .child("done")
        .once();
    final totalDone = valueDoneSnapshot.snapshot.value as int;
    final newDone = totalDone + 1;
    await userRef
        .child("statistics")
        .child(typeQuestion)
        .child("total")
        .child("done")
        .set(newDone);
  }

  Future<void> _globalCorrectUpdate(DatabaseReference userRef, bool isAnswerCorrect) async {

    final valueGlobalCorrectSnapshot =
    await userRef
        .child("statistics")
        .child("Global")
        .child("correct")
        .once();
    final valueGlobalCorrect = valueGlobalCorrectSnapshot.snapshot.value as int;
    final newGlobalCorrect = valueGlobalCorrect + (isAnswerCorrect ? 1 : 0);
    await userRef
        .child("statistics")
        .child("Global")
        .child("correct")
        .set(newGlobalCorrect);
  }

  Future<void> _globalDoneUpdate(DatabaseReference userRef) async {

    final valueGlobalDoneSnapshot =
    await userRef
        .child("statistics")
        .child("Global")
        .child("done")
        .once();
    final currentGlobalDone = valueGlobalDoneSnapshot.snapshot.value as int;
    final newGlobalDone = currentGlobalDone + 1;
    await userRef
        .child("statistics")
        .child("Global")
        .child("done")
        .set(newGlobalDone);
  }

  Future<void> _setTimestampLastAnswer(String userUID, String typeQuestion) async {
    final timestampLastAnswer = (DateTime.now().millisecondsSinceEpoch/1000).floor();
    await _database
        .child("users")
        .child(userUID)
        .child("statistics")
        .child("Global")
        .child('timestamp')
        .set(timestampLastAnswer);
    await _database
        .child("users")
        .child(userUID)
        .child("statistics")
        .child(typeQuestion)
        .child("current")
        .child('timestamp')
        .set(timestampLastAnswer);
  }
}