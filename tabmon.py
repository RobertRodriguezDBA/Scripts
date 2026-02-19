import psycopg2
from psycopg2 import extras
import time
import os
from datetime import datetime

DB_CONFIG = {
    "dbname": "VOGMMP",
    "user": "gm_admin_user",
    "password": "Hgw3gxh#V2Nz",
    "host": "database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com",
    "port": "5432"
}

# Query optimizada para calcular Ratios
QUERY = """
SELECT
    relname,
    seq_scan,
    idx_scan,
    CASE
        WHEN (seq_scan + idx_scan) = 0 THEN 0
        ELSE ROUND((idx_scan * 100.0) / (seq_scan + idx_scan), 2)
    END as idx_ratio,
    n_live_tup,
    n_dead_tup,
    vacuum_count
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 40;
"""

def get_color(ratio, dead_tups):
    # Rojo si el índice se usa poco (< 70%) en tablas con datos
    if ratio < 70 and ratio > 0: return "\033[91m"
    # Amarillo si hay muchas tuplas muertas
    if dead_tups > 50000: return "\033[93m"
    return "\033[92m" # Verde todo ok

def main():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor(cursor_factory=extras.DictCursor)

        while True:
            cur.execute(QUERY)
            rows = cur.fetchall()
            os.system('clear' if os.name == 'posix' else 'cls')

            print(f"\033[1;36mPG-HEALTH-MONITOR v14.20\033[0m | {datetime.now().strftime('%H:%M:%S')}")
            print(f"{'TABLA':<25} | {'% IDX':<8} | {'SEQ_SCN':<8} | {'IDX_SCN':<8} | {'DEAD_TUP':<10} | {'VAC'}")
            print("-" * 85)

            for row in rows:
                color = get_color(row['idx_ratio'], row['n_dead_tup'])
                reset = "\033[0m"

                print(f"{row['relname'][:25]:<25} | "
                      f"{color}{row['idx_ratio']:>6}%{reset} | "
                      f"{row['seq_scan']:<8} | "
                      f"{row['idx_scan']:<8} | "
                      f"{row['n_dead_tup']:<10} | "
                      f"{row['vacuum_count']}")

            time.sleep(10)
    except KeyboardInterrupt:
        print("\nSaliendo...")
    finally:
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    main()