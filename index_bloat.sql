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