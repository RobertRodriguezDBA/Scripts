-- ========================================================================
-- Validación: Vistas Materializadas
-- Verificar cuales cuentan con indice unico o no
-- ========================================================================
SELECT 
    mv.schemaname AS esquema,
    mv.matviewname AS vista_materializada,
    mv.ispopulated AS esta_poblada,
    -- Verifica si tiene el índice único necesario para CONCURRENTLY
    EXISTS (
        SELECT 1 FROM pg_index i
        JOIN pg_class c ON c.oid = i.indrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = mv.matviewname 
          AND n.nspname = mv.schemaname
          AND i.indisunique = true
    ) AS listo_para_refresh_concurrente,
    -- Fecha de la última vez que se actualizaron estadísticas (post-refresh)
    stat.last_analyze AS fecha_ultimo_warmup,
    -- Sugerencia de comando según el Draft 2
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_index i 
            JOIN pg_class c ON c.oid = i.indrelid 
            WHERE c.relname = mv.matviewname AND i.indisunique = true
        ) THEN 'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || mv.schemaname || '.' || mv.matviewname || ';'
        ELSE 'REFRESH MATERIALIZED VIEW ' || mv.schemaname || '.' || mv.matviewname || ';'
    END AS comando_sugerido
FROM 
    pg_matviews mv
LEFT JOIN 
    pg_stat_user_tables stat ON mv.matviewname = stat.relname AND mv.schemaname = stat.schemaname
WHERE 
    mv.schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 
    listo_para_refresh_concurrente DESC, fecha_ultimo_warmup DESC;


-- ========================================================================
-- Aplicar REFRESH CON Y SIN CONCURRENTLY: Vistas Materializadas
-- 
-- ========================================================================
DO $$
DECLARE
    r RECORD;
    start_time TIMESTAMP;
    duration INTERVAL;
    -- Definimos el orden: primero las que tienen índice único (TRUE), luego las que no (FALSE)
    prioridades BOOLEAN[] := ARRAY[TRUE, FALSE];
    p BOOLEAN;
BEGIN
    FOREACH p IN ARRAY prioridades
    LOOP
        IF p THEN
            RAISE NOTICE '--- INICIANDO FASE 1: REFRESH CONCURRENT (No bloqueante) ---';
        ELSE
            RAISE NOTICE '--- INICIANDO FASE 2: REFRESH ESTÁNDAR (Bloqueante) ---';
        END IF;

        FOR r IN 
            SELECT 
                schemaname AS esquema, 
                matviewname AS vista,
                p AS tiene_indice
            FROM pg_matviews mv
            WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
              AND EXISTS (
                  SELECT 1 FROM pg_index i 
                  JOIN pg_class c ON c.oid = i.indrelid 
                  WHERE c.relname = mv.matviewname 
                  AND i.indisunique = 't'
              ) = p
        LOOP
            start_time := clock_timestamp();
            
            IF p THEN
                RAISE NOTICE 'Procesando: %.%', r.esquema, r.vista;
                --EXECUTE format('REFRESH MATERIALIZED VIEW CONCURRENTLY %I.%I', r.esquema, r.vista);
            ELSE
                RAISE NOTICE 'Procesando (BLOQUEANTE): %.%', r.esquema, r.vista;
                --EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', r.esquema, r.vista);
            END IF;
            
            duration := clock_timestamp() - start_time;
            RAISE NOTICE 'Finalizado: %.% | Tiempo: %', r.esquema, r.vista, duration;
        END LOOP;
    END LOOP;

    RAISE NOTICE '--- PROCESO DE VISTAS MATERIALIZADAS FINALIZADO ---';
END $$;



