-- Vacuum
--vacuumdb -h <endpoint_rds> -U <usuario> -d <nombre_db> -p 5432 -Z -j 4 --verbose


-- Analyze
--ANALYZE VERBOSE tabla_usuarios;
--ANALYZE VERBOSE tabla_pedidos_activos;

-- Status tablas
select * from pg_stat_user_tables limit 1;

--
SELECT relname AS tabla, n_live_tup AS filas_estimadas
FROM pg_stat_user_tables 
ORDER BY n_live_tup DESC 
LIMIT 20;

--
SELECT relname AS tabla, seq_scan, idx_scan
FROM pg_stat_user_tables 
LIMIT 20;

--------------------------------------------------------------------------
SELECT 
    relname AS tabla,
    seq_scan,
    idx_scan,
    n_live_tup AS filas_vivas,
    n_dead_tup AS filas_muertas,
    CAST(n_dead_tup AS FLOAT) / NULLIF(n_live_tup, 0) AS ratio_muerte,
    last_autovacuum,
    last_vacuum
FROM pg_stat_user_tables
WHERE n_live_tup > 1000
AND n_dead_tup > 0
ORDER BY ratio_muerte DESC;

--
-- Progreso
SELECT relid::regclass, phase, sample_blks_total, sample_blks_scanned 
FROM pg_stat_progress_analyze;

--VACUUM (ANALYZE, PARALLEL 4) stock_inventory_line;







