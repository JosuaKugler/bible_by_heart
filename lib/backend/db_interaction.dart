import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';

//this file defines a interface for the dataBase, as well as the Verse and Passage class


LearnStatus intToLearnStatus(int learnStatusInt) {
  switch (learnStatusInt) {
    case 0:{ return LearnStatus.none;}break;
    case 1:{ return LearnStatus.selected;}break;
    case 2:{return LearnStatus.current;}break;
    case 3:{return LearnStatus.learned;}break;
    default:{return null;}
  }
}

int learnStatusToInt(LearnStatus learnStatus) {
  switch (learnStatus) {
    case LearnStatus.none:{return 0;}break;
    case LearnStatus.selected:{return 1;}break;
    case LearnStatus.current:{return 2;}break;
    case LearnStatus.learned:{return 3;}break;
    default:{return null;}
  }
}

class DataBaseHelper {
  Future<Database> db;
  bool initialized = false;
  DataBaseHelper();

  Future<void> initialize() async {
    // Construct a file path to copy database to
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "bible_database.db");

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data = await rootBundle.load(join('assets', 'bible.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
    }
    this.db = openDatabase(path);
    this.initialized = true;
  }

  //returns the whole bible
  Future<List<Verse>> bible() async {
    if (!this.initialized) await this.initialize();
    final Database localDb = await this.db;
    final List<Map<String, dynamic>> maps = await localDb.query('bible');
    return List.generate(maps.length, (i) {
      return Verse(
        id: maps[i]['id'],
        book: maps[i]['book'],
        chapter: maps[i]['chapter'],
        verse: maps[i]['verse'],
        text: maps[i]['text'],
        learnStatus : intToLearnStatus(maps[i]['learnStatus']),
        correct: maps[i]['correct'],
        maxCorrect: maps[i]['maxCorrect'],
      );
    });
  }

  Future<List<Verse>> getChapterFromPassage(Passage passage) async {
    if (!this.initialized) await this.initialize();
    final book = passage.book;
    final chapter = passage.chapter;
    final Database localDb = await this.db;
    final List<Map<String, dynamic>> maps = await localDb.rawQuery(
        "SELECT * FROM bible WHERE book = '$book' AND chapter = $chapter");
    return List.generate(maps.length, (i) {
      return Verse(
        id: maps[i]['id'],
        book: maps[i]['book'],
        chapter: maps[i]['chapter'],
        verse: maps[i]['verse'],
        text: maps[i]['text'],
        learnStatus : intToLearnStatus(maps[i]['learnStatus']),
        correct: maps[i]['correct'],
        maxCorrect: maps[i]['maxCorrect'],
      );
    });
  }

  Future<Verse> getVerseFromId(int id) async {
    if (!this.initialized) await this.initialize();
    final localDb = await this.db;
    final List<Map<String, dynamic>> resultVerseList =
        await localDb.rawQuery("SELECT * FROM bible WHERE id = $id");
    final Map<String, dynamic> resultVerseMap = resultVerseList[0];
    return Verse(
      id: resultVerseMap['id'],
      book: resultVerseMap['book'],
      chapter: resultVerseMap['chapter'],
      verse: resultVerseMap['verse'],
      text: resultVerseMap['text'],
      learnStatus : intToLearnStatus(resultVerseMap['learnStatus']),
      correct: resultVerseMap['correct'],
      maxCorrect: resultVerseMap['maxCorrect'],
    );
  }

  Future<Verse> getVerseFromPassage(Passage passage) async {
    final String book = passage.book;
    final int chapter = passage.chapter;
    final int verse = passage.verse;

    if (!this.initialized) await this.initialize();
    final localDb = await this.db;
    final List<Map<String, dynamic>> resultVerseList = await localDb.rawQuery(
        "SELECT * FROM bible WHERE book = '$book' AND chapter = $chapter AND verse = $verse");
    final Map<String, dynamic> resultVerseMap = resultVerseList[0];
    return Verse(
      id: resultVerseMap['id'],
      book: resultVerseMap['book'],
      chapter: resultVerseMap['chapter'],
      verse: resultVerseMap['verse'],
      text: resultVerseMap['text'],
      learnStatus : intToLearnStatus(resultVerseMap['learnStatus']),
      correct: resultVerseMap['correct'],
      maxCorrect: resultVerseMap['maxCorrect'],
    );
  }

  Future<int> getIdFromPassage(Passage passage) async {
    Verse verse = await getVerseFromPassage(passage);
    return verse.id;
  }

  Future<Verse> getRelativeVerse(Passage passage, int relative) async {
    int id = await getIdFromPassage(passage);
    int nextId = id + relative;
    if (nextId > 31172) {
      nextId = nextId - 31173;
    }
    if (nextId < 0) {
      nextId = 31173 + nextId;
    }
    return getVerseFromId(nextId);
  }

  Future<List<Verse>> getVersesFromPassage(Passage start, Passage end) async {
    int startId = await getIdFromPassage(start);
    int endId = await getIdFromPassage(end);
    int difference = endId - startId;
    List<Verse> ret;
    for (int i = 0; i < difference; i++) {
      ret.add(await getRelativeVerse(start, i));
    }
    return ret;
  }

  //returns the last verse of the previous chapter
  Future<Verse> getPreviousChapterVerse(Passage passage) async {
    Passage temp = Passage(passage.book, passage.chapter, 1);
    return await getRelativeVerse(temp, -1);
  }

  //returns the first verse of the next chapter
  Future<Verse> getNextChapterVerse(Passage passage) async {
    if (!this.initialized) {this.initialize();}
    final localDb = await this.db;
    final maps = await localDb.rawQuery(
        "SELECT * FROM bible WHERE book = '${passage.book}' AND chapter = ${passage.chapter}");
    Passage temp = Passage(passage.book, passage.chapter, maps.length);
    return await getRelativeVerse(temp, 1);
  }

  Future<int> getNumberOfChapters(String book) async {
    if (!this.initialized) {this.initialize();}
    final localDb = await this.db;
    final maps = await localDb.rawQuery(
        "SELECT chapter FROM bible WHERE book = '$book' AND verse = 1"
    );
    return maps.length;
  }

  Future<LearnStatus> getLearnStatus(int id) async {
    if (!this.initialized) {this.initialize();}
    final localDb = await this.db;
    final totalArray = await localDb.rawQuery(
      "SELECT * FROM bible WHERE id = $id"
    );
    return intToLearnStatus(totalArray[0]["learnStatus"]);
  }

  void setLearnStatus(int id, LearnStatus newLearnStatus) async {
    if (!this.initialized) {this.initialize();}
    final localDb = await this.db;
    int learnStatusInt = learnStatusToInt(newLearnStatus);
    await localDb.execute("UPDATE bible SET learnStatus = $learnStatusInt WHERE id = $id");
  }

  Future<List<Verse>> getVersesOnLearnStatus(LearnStatus learnStatus) async {
    if (!this.initialized) await this.initialize();
    final localDb = await this.db;
    int learnStatusInt = learnStatusToInt(learnStatus);
    final maps = await localDb.rawQuery(
        "SELECT * FROM bible WHERE learnStatus = $learnStatusInt"
    );
    return List.generate(maps.length, (i) {
      return Verse(
        id: maps[i]['id'],
        book: maps[i]['book'],
        chapter: maps[i]['chapter'],
        verse: maps[i]['verse'],
        text: maps[i]['text'],
        learnStatus : intToLearnStatus(maps[i]['learnStatus']),
        correct: maps[i]['correct'],
        maxCorrect: maps[i]['maxCorrect'],
      );
    });
  }

  void increaseCorrect(int id) async {
    if (!this.initialized) await this.initialize();
    final localDb = await this.db;
    await localDb.execute("UPDATE bible SET correct = correct + 1 WHERE id = $id");
  }

  void decreaseCorrect(int id, int amount) async {
    if (!this.initialized) await this.initialize();
    final localDb = await this.db;
    await localDb.execute("UPDATE bible SET correct = correct - $amount WHERE id = $id");
  }

  Future<int> getCorrect(int id) async {
    if (!this.initialized) await this.initialize();
    final localDb = await this.db;
    final maps = await localDb.rawQuery("SELECT correct FROM bible WHERE id = $id");
    return maps[0]['correct'];
  }

  void setMaxCorrect(int id, int newMaxCorrect) async {
    if (!this.initialized) await this.initialize();
    final localDb = await this.db;
    await localDb.execute("UPDATE bible SET maxCorrect = $newMaxCorrect WHERE id = $id");
  }

  Future<int> getMaxCorrect(int id) async {
    if (!this.initialized) await this.initialize();
    final localDb = await this.db;
    final maps = await localDb.rawQuery("SELECT maxCorrect FROM bible WHERE id = $id");
    return maps[0]['maxCorrect'];
  }
}

class Passage {
  final String book;
  final int chapter;
  final int verse;

  Passage(this.book, this.chapter, this.verse);

  @override
  String toString() {
    return 'Passage{ book : $book, chapter: $chapter, verse: $verse}';
  }
}

enum LearnStatus {
  none,
  selected,
  current,
  learned
}

class Verse {
  final int id;
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final LearnStatus learnStatus;
  final int correct;
  final int maxCorrect;

  Verse({this.id, this.book, this.chapter, this.verse, this.text, this.learnStatus, this.correct, this.maxCorrect});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'learnStatus': learnStatus,
      'correct' : correct,
      'maxCorrect' : maxCorrect,
    };
  }

  Passage toPassage() {
    return Passage(this.book, this.chapter, this.verse);
  }

  @override
  String toString() {
    return 'Verse{id: $id, book: $book, chapter: $chapter, verse: $verse, text: $text, learnStatus $learnStatus}, correct $correct, maxCorrect $maxCorrect';
  }
}

final Map<String, String> short2long = {
  "Gen": "Genesis",
  "Exo": "Exodus",
  "Lev": "Levitikus",
  "Num": "Numeri",
  "Deu": "Deuteronomium",
  "Jos": "Josua",
  "Jdg": "Richter",
  "Rut": "Ruth",
  "1Sa": "1. Samuel",
  "2Sa": "2. Samuel",
  "1Ki": "1. Könige",
  "2Ki": "2. Könige",
  "1Ch": "1. Chronik",
  "2Ch": "2. Chronik",
  "Ezr": "Esra",
  "Neh": "Nehemia",
  "Est": "Esther",
  "Job": "Hiob",
  "Psa": "Psalmen",
  "Pro": "Sprüche",
  "Ecc": "Prediger",
  "Sol": "Hoheslied",
  "Isa": "Jesaja",
  "Jer": "Jeremia",
  "Lam": "Klagelieder",
  "Eze": "Hesekiel",
  "Dan": "Daniel",
  "Hos": "Hosea",
  "Joe": "Joel",
  "Amo": "Amos",
  "Abd": "Obadja",
  "Jon": "Jona",
  "Mic": "Micha",
  "Nah": "Nahum",
  "Hab": "Habakuk",
  "Zep": "Zefanja",
  "Hag": "Haggai",
  "Zec": "Sacharja",
  "Mal": "Maleachi",
  "Mat": "Matthäus",
  "Mar": "Markus",
  "Luk": "Lukas",
  "Joh": "Johannes",
  "Act": "Apostelgeschichte",
  "Rom": "Römer",
  "1Co": "1. Korinther",
  "2Co": "2. Korinther",
  "Gal": "Galater",
  "Eph": "Epheser",
  "Phi": "Philipper",
  "Col": "Kolosser",
  "1Th": "1. Thessalonicher",
  "2Th": "2. Thessalonicher",
  "1Ti": "1. Timotheus",
  "2Ti": "2. Timotheus",
  "Tit": "Titus",
  "Phm": "Philemon",
  "Heb": "Hebräer",
  "Jam": "Jakobus",
  "1Pe": "1. Petrus",
  "2Pe": "2. Petrus",
  "1Jo": "1. Johannes",
  "2Jo": "2. Johannes",
  "3Jo": "3. Johannes",
  "Jud": "Judas",
  "Rev": "Offenbarung",
};
