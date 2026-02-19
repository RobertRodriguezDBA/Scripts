SELECT 
        substring(query, 1, 50) AS short_query,
        calls,
        round(total_exec_time::numeric, 2) AS total_time,
        round(mean_exec_time::numeric, 2) AS avg_ms,
        round((shared_blks_hit * 100.0) / NULLIF(shared_blks_hit + shared_blks_read, 0), 2) AS cache_hit_ratio
    FROM pg_stat_statements
    WHERE query NOT LIKE '%%pg_stat_statements%%'  -- No monitorearnos a nosotros mismos
    ORDER BY total_exec_time DESC
    LIMIT 5;