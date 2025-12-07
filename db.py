import psycopg2

def get_connection():
    return psycopg2.connect(
        host="localhost",
        database="realestate",   # name of your DB
        user="postgres",         # your Postgres username
        password="neha1610"  # your Postgres password
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