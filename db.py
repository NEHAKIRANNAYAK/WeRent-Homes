import os
import psycopg2

def get_connection():
    # 1) If DATABASE_URL is set (Render / other host), use it
    db_url = os.environ.get("DATABASE_URL")
    if db_url:
        return psycopg2.connect(db_url)

    # 2) Otherwise use your local Postgres for development
    return psycopg2.connect(
        host="localhost",
        database="realestate",
        user="postgres",        # change if your local user is different
        password="yourpassword" # change to your local password
    )

def run_query(sql, params=(), fetch=False):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(sql, params)
    data = None
    if fetch:
        data = cur.fetchall()
    conn.commit()
    cur.close()
    conn.close()
    return data
