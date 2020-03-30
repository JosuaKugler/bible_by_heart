import sqlite3
import codecs

conn = sqlite3.connect('bible.db')
c = conn.cursor()

c.execute('''CREATE''')

rows = c.fetchall()
print(rows[0])
print(rows[-1])

#conn.commit()
conn.close()
