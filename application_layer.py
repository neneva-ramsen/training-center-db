import sqlite3

#  connect to database (this creates gym.db if it does not exist)
conn = sqlite3.connect("gym.db")

# cursor to execute SQL
cur = conn.cursor()