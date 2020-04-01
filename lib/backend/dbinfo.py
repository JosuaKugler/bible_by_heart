import sqlite3
import codecs

conn = sqlite3.connect('../assets/bible.db')
c = conn.cursor()

c.execute("SELECT book, chapter FROM bible WHERE verse = 1;")

rows = c.fetchall()

bookMap = {}
for (book, chapter) in rows:
    try:
        bookMap[book] += 1
    except:
        bookMap[book] = 1

print(bookMap)
#conn.commit()
conn.close()
