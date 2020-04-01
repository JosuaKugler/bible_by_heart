# -*- coding: utf8 -*-
import sqlite3
import codecs

conn = sqlite3.connect('bible.db')
c = conn.cursor()
c.execute("DROP TABLE IF EXISTS bible")
c.execute("DROP TABLE IF EXISTS learn")

c.execute(
    "CREATE TABLE bible (id INTEGER PRIMARY KEY,book TEXT NOT NULL,chapter INTEGER NOT NULL,verse INTEGER NOT NULL,text TEXT NOT NULL, learnStatus INTEGER NOT NULL);"
)

conn.commit()

rawAscii = codecs.open("Martin_Luther_Uebersetzung_1912.txt", "r", "utf8")
bible = rawAscii.read()
verses = bible.splitlines()
verseMap = []
for verse in verses[:-13]:
    numbers = verse[4:].split()[0].split(":")
    verseStart = 4 + len(numbers[0]) + 1 + len(numbers[1]) + 1 #remove book, whitespace and numbers
    text = verse[verseStart:]
    if "<RF>" in text:
        text = text.replace("<RF>", " (")#removes annotations
        text = text.replace("<Rf>", ")")
    if "HErr" in text:
        text = text.replace("HErr", "HERR")
        text = text.replace("HERRn", "HERRN")

    if verse[:3] == "Mal":
        print(text)
    verseMap.append(
        {
            "book": verse[:3], 
            "chapter": int(numbers[0]), 
            "verse": int(numbers[1]), 
            "text": text,
            "learnStatus" : 0
        }
    )

for id, verse in enumerate(verseMap):
    c.execute(
        f'''INSERT INTO bible VALUES ({id}, "{verse['book']}", {verse['chapter']}, {verse['verse']}, "{verse['text']}", {verse['learnStatus']})'''
        )

conn.commit()
conn.close()
