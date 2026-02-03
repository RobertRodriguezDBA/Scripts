WITH index_col_list AS (
    SELECT 
        indrelid AS table_oid, 
        indexrelid AS index_oid, 
        array_agg(attname ORDER BY ord) AS cols
    FROM (
        SELECT 
            indrelid, 
            indexrelid, 
            attname, 
            CASE WHEN x.indkey[i] IS NULL THEN NULL ELSE i END AS ord
        FROM 
            pg_index, 
            pg_attribute, 
            generate_series(1, pg_index.indnkeyatts) AS i(i)
        WHERE 
            attrelid = indrelid AND 
            attnum = indkey[i]
    ) AS x
    GROUP BY indrelid, indexrelid
), dup_natts AS (
    SELECT indexrelid, indnkeyatts FROM pg_index
)
SELECT 
    userdex.schemaname AS schema_name, 
    userdex.relname AS table_name, 
    userdex.indexrelname AS index_name, 
    array_to_string(cols, ', ') AS index_cols, 
    pg_indexes.indexdef, 
    idx_scan AS index_scans
FROM 
    pg_stat_user_indexes AS userdex
JOIN 
    index_col_list ON index_col_list.table_oid = userdex.relid
JOIN 
    dup_natts ON userdex.indexrelid = dup_natts.indexrelid
JOIN 
    pg_indexes ON userdex.schemaname = pg_indexes.schemaname AND userdex.indexrelname = pg_indexes.indexname
WHERE EXISTS (
    SELECT 1 
    FROM pg_index AS ind2
    JOIN index_col_list AS icl2 ON ind2.indexrelid = icl2.index_oid
    WHERE 
        pg_index.indrelid = ind2.indrelid AND 
        pg_index.indexrelid <> ind2.indexrelid AND
        index_col_list.cols <@ icl2.cols AND -- Check if current index columns are a subset of another index
        pg_index.indisunique IS FALSE -- Exclude unique indexes from being considered redundant by a unique one
)
ORDER BY userdex.schemaname, userdex.relname, cols, userdex.indexrelname;


---


SELECT
    relname,
    indexrelname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid))
FROM
    pg_stat_user_indexes
WHERE
    schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY
    idx_scan ASC;

================================================================

SELECT
    idstat.relname,
    idstat.indexrelname,
    idstat.idx_scan,
    pg_size_pretty(pg_relation_size(idstat.indexrelid)) AS idxSize
FROM
    pg_stat_user_indexes AS idstat
JOIN
    pg_index AS i ON idstat.indexrelid = i.indexrelid
WHERE
    idstat.idx_scan = 0
    AND i.indisunique IS FALSE
    AND i.indisprimary IS FALSE
ORDER BY
    pg_relation_size(idstat.indexrelid) DESC;

================================================================

select * from pg_stat_user_tables where relname = 'mail_message' limit 1;

================================================================

SELECT
    idstat.relname,
    idstat.indexrelname,
    idstat.idx_scan,
    pg_size_pretty(pg_relation_size(idstat.indexrelid)) AS idxSize
FROM
    pg_stat_user_indexes AS idstat
JOIN
    pg_index AS i ON idstat.indexrelid = i.indexrelid
WHERE
    idstat.idx_scan = 0
    AND i.indisunique IS FALSE
    AND i.indisprimary IS FALSE
ORDER BY
    pg_relation_size(idstat.indexrelid) DESC;

================================================================

SELECT
indrelid::regclass AS tabla,
array_agg(indexrelid::regclass) AS indices_duplicados,
indkey AS columnas_id
FROM pg_index
GROUP BY indrelid, indkey
HAVING COUNT(*) > 1;

================================================================

SELECT 
    relname AS tabla, 
    n_live_tup AS filas_estimadas
FROM 
    pg_stat_user_tables
ORDER BY 
    n_live_tup DESC;

================================================================

SELECT
    t.relname AS tabla,
    s.n_live_tup AS filas_estimadas,
    pg_size_pretty(pg_total_relation_size(t.oid)) AS tamaño_total,
    pg_size_pretty(pg_relation_size(t.oid)) AS tamaño_datos,
    pg_size_pretty(pg_total_relation_size(t.oid) - pg_relation_size(t.oid)) AS tamaño_indices
FROM 
    pg_class t
JOIN 
    pg_stat_user_tables s ON t.relname = s.relname
WHERE 
    t.relkind = 'r' -- Solo tablas reales (no vistas ni índices)
ORDER BY 
    pg_total_relation_size(t.oid) DESC;

================================================================

SELECT
    relname,
    n_live_tup,
    n_dead_tup,
    round(n_dead_tup::numeric / (n_live_tup + n_dead_tup + 1) * 100, 2) AS dead_per,
    last_autovacuum,
    last_analyze
FROM
    pg_stat_user_tables
WHERE
    n_live_tup > 1000  -- Ignoramos tablas muy pequeñas
ORDER BY
    dead_per DESC;