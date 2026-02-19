SELECT
    --schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    (bloat_indicator * 100)::text || '%' AS estimated_bloat
FROM (
    SELECT
        n.nspname AS schemaname,
        t.relname AS tablename,
        c.relname AS indexname,
        i.indexrelid,
        (pg_relation_size(i.indexrelid) - (t.reltuples * 100))::float / NULLIF(pg_relation_size(i.indexrelid), 0) AS bloat_indicator
    FROM pg_index i
    JOIN pg_class c ON c.oid = i.indexrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_class t ON t.oid = i.indrelid
    JOIN pg_stat_user_indexes ind ON ind.indexrelid = i.indexrelid
    WHERE pg_relation_size(i.indexrelid) > 1024 * 1024 -- Solo índices > 1MB
) AS sub
ORDER BY (pg_relation_size(indexrelid) * bloat_indicator) DESC 
LIMIT 20;

---
SELECT relname, n_live_tup, n_dead_tup, 
last_vacuum, last_analyze, 
vacuum_count, analyze_count
FROM pg_stat_user_tables 
ORDER BY n_live_tup DESC 
LIMIT 50;

--

SELECT relname, 
n_live_tup, n_dead_tup, 
seq_scan,
idx_scan,
last_vacuum, last_analyze, 
vacuum_count, analyze_count
FROM pg_stat_user_tables 
ORDER BY n_live_tup DESC 
LIMIT 50;

--

SELECT relname,seq_scan,idx_scan,n_live_tup,n_dead_tup,vacuum_count,analyze_count 
FROM pg_stat_user_tables 
ORDER BY n_dead_tup DESC 
LIMIT 20;

--

SELECT name, setting, unit, short_desc
FROM pg_settings
WHERE name LIKE 'autovacuum%' 
   OR name LIKE 'vacuum%'
ORDER BY name;


/*  PORCENTAJE DE DEAD TUPS */ 
SELECT  
    relname AS table_name,
    n_live_tup, 
    n_dead_tup,
    ROUND(n_dead_tup::float / CASE WHEN n_live_tup = 0 THEN 1 ELSE n_live_tup END * 100) AS current_percent,
    pg_size_pretty(pg_table_size(relid)) AS table_size,
    last_autovacuum,
    autovacuum_count
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
AND ROUND(n_dead_tup::float / CASE WHEN n_live_tup = 0 THEN 1 ELSE n_live_tup END * 100) > 1
ORDER BY last_autovacuum;


--
SELECT
    relname,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(pg_relation_size(relid)) AS data_size,
    n_dead_tup,
    CASE WHEN n_dead_tup > 0 THEN 'Necesita Vacuum' ELSE 'OK' END AS status
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY pg_total_relation_size(relid) DESC;

--


--
select *
from stock_move
limit 20;

-- 2026-02-17
-- se modifico la 
set search_path to public;
/* ALTER TABLERS */
/* 
ALTER TABLE imp_stock_shipping SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE imp_stock_pack_table SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE imp_stock_shipping SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE imp_stock_area SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE stock_move SET (autovacuum_vacuum_scale_factor = 0.05); --17/02/2026
ALTER TABLE stock_move_line SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE stock_picking SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE stock_rack SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE stock_package SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE stock_transfer_order SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE sale_order_line SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE supply_capture_order SET (autovacuum_vacuum_scale_factor = 0.05); -- 18/02/2026
ALTER TABLE account_move SET (autovacuum_vacuum_scale_factor = 0.05); -- 19/02/2026
ALTER TABLE mail_message SET (autovacuum_vacuum_scale_factor = 0.05); -- 19/02/2026
*/

ALTER TABLE mail_message SET (autovacuum_vacuum_scale_factor = 0.05);


SELECT relname, reloptions 
FROM pg_class 
WHERE relname ilike 'mail_%'
--and reloptions NOTNULL;

/* Monitorear: */
SELECT 
    relname,
    n_live_tup,
    n_dead_tup,
    round(n_dead_tup::float / CASE WHEN n_live_tup = 0 THEN 1 ELSE n_live_tup END * 100) as current_percent,
    last_autovacuum,
    autovacuum_count
FROM pg_stat_user_tables
WHERE  round(n_dead_tup::float / CASE WHEN n_live_tup = 0 THEN 1 ELSE n_live_tup END * 100)  > 1
-- and relname ilike 'res_%';
ORDER BY last_autovacuum;

select * 
from pg_stat_user_tables

--

select * 
from pg_stat_activity ;
-- where query ilike 'autovacuum' 
-- wait_event = 'AutoVacuumMain'
-- limit 40;
-- ------------------------------------------------------------------------------------------

SELECT 
    relname, 
    n_dead_tup, 
    n_live_tup, 
    round(n_dead_tup::float / NULLIF(n_live_tup, 0)::float) as current_ratio
FROM pg_stat_user_tables
WHERE n_live_tup > 1000
ORDER BY current_ratio DESC;

--

VACUUM (ANALYZE, VERBOSE) imp_stock_shipping;

--
SELECT "stock_box".id FROM "stock_box" WHERE








--
SELECT pid, phase, heap_blks_scanned, heap_blks_total, index_vacuum_count
FROM pg_stat_progress_vacuum;

--
SELECT
    relname AS table,
    pg_size_pretty(pg_relation_size(relid)) AS data_size,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS index_size,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    CASE WHEN (pg_relation_size(relid)) < (pg_total_relation_size(relid) - pg_relation_size(relid)) 
    THEN 'Vacuum' ELSE 'OK' END AS current_percent
FROM pg_stat_user_tables;
--WHERE relname = 'stock_location';


python3 "fo_test.py" 
--host database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com 
--user gm_admin_user 
--password 'Hgw3gxh#V2Nz' 
--database VOGMMP 
--port 5432 
--threads 5 
--sslmode require
----------------------------
"dbname": "VOGMMP",
"user": "gm_admin_user",
"passwiord": "Hgw3gxh#V2Nz",
"host": "database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com",
"port": "5432"

--

SELECT pid, now() - xact_start AS duration, query, state 
FROM pg_stat_activity 
WHERE (now() - xact_start) > interval '5 minutes' AND state <> 'idle';

------------------------------------
/* Lista con el idx ratio */
WITH long_xact AS (
    SELECT count(*) as long_running 
    FROM pg_stat_activity 
    WHERE state <> 'idle' 
    AND (now() - xact_start) > interval '5 minutes'
)
SELECT 
    t.relname, 
    t.seq_scan, 
    t.idx_scan, 
    CASE 
        WHEN (t.seq_scan + t.idx_scan) = 0 THEN 0 
        ELSE ROUND((t.idx_scan * 100.0) / (t.seq_scan + t.idx_scan), 2) 
    END as idx_ratio,
    t.n_live_tup, 
    t.n_dead_tup, 
    t.vacuum_count,
    (SELECT long_running FROM long_xact) as long_queries
FROM pg_stat_user_tables t
ORDER BY n_dead_tup DESC 
LIMIT 40;

------------------------------------------------
/* CHECK BLOAT */
SELECT 
    relname AS table_name,
    n_dead_tup, 
    n_live_tup,
    (n_dead_tup::float / NULLIF(n_live_tup, 0)) AS dead_ratio,
    last_autovacuum
FROM pg_stat_user_tables
WHERE (n_dead_tup::float / NULLIF(n_live_tup, 0)) > 0.05
ORDER BY last_autovacuum;

--

SELECT 
    relname, 
    pg_size_pretty(pg_total_relation_size(relid)) as size
FROM pg_stat_user_tables 
--WHERE pg_total_relation_size(relid) > (0.5 * 1024 * 1024 * 1024)

-------------------------
/* INDICES FANTASMA */
SELECT 
        relname AS table_name, 
        indexrelname AS index_name, 
        idx_scan, 
        pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
    FROM pg_stat_user_indexes
    JOIN pg_index USING (indexrelid)
    WHERE idx_scan = 0 
      AND indisunique IS FALSE 
      AND schemaname = 'public'
    ORDER BY pg_relation_size(indexrelid) DESC;