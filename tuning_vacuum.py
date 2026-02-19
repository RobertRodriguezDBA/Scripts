import psycopg2
from psycopg2 import sql

# Configuración de conexión (Usa variables de entorno en producción)
DB_CONFIG = {
    "dbname": "VOGMMP",
    "user": "gm_admin_user",
    "passwiord": "Hgw3gxh#V2Nz",
    "host": "database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com",
    "port": "5432"
}

# Umbral: Tablas mayores a 5GB recibirán un tuning específico
SIZE_THRESHOLD_GB = 5 
NEW_SCALE_FACTOR = "0.01"

def tune_autovacuum():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True  # Necesario para ejecutar ALTER TABLE
        cur = conn.cursor()

        # Query para hallar tablas grandes que aún tienen el scale_factor por defecto (o alto)
        query = """
        SELECT 
            relname, 
            pg_size_pretty(pg_total_relation_size(relid)) as size
        FROM pg_stat_user_tables 
        WHERE pg_total_relation_size(relid) > (%s * 1024 * 1024 * 1024)
        """
        
        cur.execute(query, (SIZE_THRESHOLD_GB,))
        tables = cur.fetchall()

        if not tables:
            print("No se encontraron tablas que requieran ajuste preventivo.")
            return

        for table_name, size in tables:
            print(f"Ajustando {table_name} (Tamaño: {size})...")
            alter_query = sql.SQL("ALTER TABLE {tbl} SET (autovacuum_vacuum_scale_factor = {sf})").format(
                tbl=sql.Identifier(table_name),
                sf=sql.Literal(NEW_SCALE_FACTOR)
            )
            cur.execute(alter_query)
            print(f"   Confirmado: scale_factor seteado a {NEW_SCALE_FACTOR}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        if conn:
            cur.close()
            conn.close()

if __name__ == "__main__":
    tune_autovacuum()