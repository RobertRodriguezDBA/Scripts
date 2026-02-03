SELECT 
    --schemaname AS esquema,
    relname AS tabla,
    -- Suma de escaneos (índices + secuenciales)
    (seq_scan + idx_scan) AS lecturas_totales,
    -- Suma de modificaciones
    (n_tup_ins + n_tup_upd + n_tup_del) AS escrituras_totales,
    -- Uso total
    (seq_scan + idx_scan + n_tup_ins + n_tup_upd + n_tup_del) AS uso_global,
    -- Información de tamaño para contexto
    pg_size_pretty(pg_total_relation_size(relid)) AS tamano_total,
    n_live_tup AS filas_estimadas
FROM 
    pg_stat_user_tables
WHERE 
    schemaname NOT IN ('information_schema', 'pg_catalog')
ORDER BY 
    uso_global DESC;

----------------------------------------

SELECT
    relname AS tabla,
    seq_scan,
    idx_scan,
    n_live_tup AS filas_vivas,
    n_dead_tup AS filas_muertas,
    CAST(n_dead_tup AS FLOAT) / NULLIF(n_live_tup, 0) AS ratio_muerte,
    pg_size_pretty(pg_total_relation_size(relid)) AS tamano_total,
    last_autovacuum,
    last_vacuum
FROM pg_stat_user_tables
WHERE n_live_tup > 1000
AND n_dead_tup > 0
ORDER BY ratio_muerte;


-- Progreso
SELECT relid::regclass, phase, sample_blks_total, sample_blks_scanned 
FROM pg_stat_progress_analyze;
