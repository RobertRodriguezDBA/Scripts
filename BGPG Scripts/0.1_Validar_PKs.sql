-- 0.1_Validar_PKs

-- ========================================================================
-- Buscar tablas que fallarán en Blue/Green por no contar con Primary Key
-- Clasifica tablas sin PK por tamaño para decidir estrategia
-- ========================================================================
SELECT tab.table_schema, tab.table_name
FROM information_schema.tables tab
LEFT JOIN information_schema.table_constraints tco 
  ON tab.table_schema = tco.table_schema 
  AND tab.table_name = tco.table_name 
  AND tco.constraint_type = 'PRIMARY KEY'
WHERE tab.table_schema NOT IN ('information_schema', 'pg_catalog') 
  AND tab.table_type = 'BASE TABLE' 
  AND tco.constraint_name IS NULL;
--Total 576
-----------------------------------------------------------------------------

DO $$ 
DECLARE 
    r RECORD;
BEGIN
    -- Buscamos tablas en esquemas públicos/de usuario que no tengan PK
    FOR r IN (
        SELECT tab.table_schema, tab.table_name
        FROM information_schema.tables tab
        LEFT JOIN information_schema.table_constraints tco 
          ON tab.table_schema = tco.table_schema 
          AND tab.table_name = tco.table_name 
          AND tco.constraint_type = 'PRIMARY KEY'
        WHERE tab.table_schema NOT IN ('information_schema', 'pg_catalog') 
          AND tab.table_type = 'BASE TABLE' 
          AND tco.constraint_name IS NULL
    ) LOOP
        -- Ejecutamos el cambio para cada tabla encontrada
        RAISE NOTICE 'Aplicado REPLICA IDENTITY FULL a: %.%', r.table_schema, r.table_name;
        EXECUTE format('ALTER TABLE %I.%I REPLICA IDENTITY FULL', r.table_schema, r.table_name);
        --RAISE NOTICE 'ALTER TABLE %.% REPLICA IDENTITY FULL', r.table_schema, r.table_name;
        
    END LOOP;
END $$;


-- ========================================================================
-- 0.1.1 Identificación de Tablas Críticas para Replicación Lógica
-- Clasifica tablas sin PK por tamaño para decidir estrategia
-- ========================================================================

SELECT 
    --n.nspname AS esquema,
    c.relname AS tabla,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano_total,
    CASE 
        WHEN pg_total_relation_size(c.oid) > 1024 * 1024 * 100 THEN 'CRÍTICO: Intentar agregar PK'
        ELSE 'ACEPTABLE: Usar REPLICA IDENTITY FULL'
    END AS recomendacion_estrategia
FROM 
    pg_class c
JOIN 
    pg_namespace n ON n.oid = c.relnamespace
WHERE 
    c.relkind = 'r' -- Solo tablas ordinarias
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
    AND NOT EXISTS (
        SELECT 1 
        FROM pg_index i 
        WHERE i.indrelid = c.oid 
        AND i.indisprimary = 't'
    )
ORDER BY 
    pg_total_relation_size(c.oid) DESC;

-- ========================================================================
-- 0.1.2 Aplicando ALTER REPLICA IDENTITY FULL de Tablas para Replicación Lógica
-- Clasifica tablas sin PK por tamaño para decidir estrategia
-- ========================================================================

DO $$
DECLARE
    r RECORD;
    v_umbral_mb INTEGER := 100; -- Umbral de seguridad en Megabytes
BEGIN
    FOR r IN 
        SELECT 
            n.nspname AS esquema,
            c.relname AS tabla,
            pg_total_relation_size(c.oid) / (1024 * 1024) AS tamano_mb
        FROM 
            pg_class c
        JOIN 
            pg_namespace n ON n.oid = c.relnamespace
        WHERE 
            c.relkind = 'r' 
            AND n.nspname NOT IN ('pg_catalog', 'information_schema')
            AND NOT EXISTS (
                SELECT 1 FROM pg_index i 
                WHERE i.indrelid = c.oid AND i.indisprimary = 't'
            )
    LOOP
        -- Solo aplicamos si está por debajo del umbral
        IF r.tamano_mb < v_umbral_mb THEN
            EXECUTE format('ALTER TABLE %I.%I REPLICA IDENTITY FULL', r.esquema, r.tabla);
            RAISE NOTICE 'Aplicado REPLICA IDENTITY FULL a: %.% (% MB)', r.esquema, r.tabla, r.tamano_mb;
        ELSE
            RAISE WARNING 'OMITIDA por tamaño (% MB): %.%. Requiere revisión manual.', r.tamano_mb, r.esquema, r.tabla;
        END IF;
    END LOOP;
END $$;

-- ========================================================================
-- 0.1.3 ROLLBACK ALTER REPLICA IDENTITY FULL de Tablas para Replicación Lógica
-- Clasifica tablas sin PK por tamaño para decidir estrategia
-- ========================================================================
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT n.nspname AS esquema, c.relname AS tabla
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relreplident = 'f' -- 'f' significa FULL
          AND n.nspname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE format('ALTER TABLE %I.%I REPLICA IDENTITY DEFAULT', r.esquema, r.tabla);
        RAISE NOTICE 'Rollback aplicado a: %.%', r.esquema, r.tabla;
    END LOOP;
END $$;



-- ========================================================================
-- 0.1.4 Valida las tablas con Replicación Lógica
-- d = Default (usa PK), f= Full (todos los valores), i = Index (Indice unico), n = Nothing (Ninguna identificacion) 
-- ========================================================================

SELECT c.relreplident, count(c.relreplident)
FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
GROUP BY c.relreplident;

--

SELECT 
    relname AS tabla, 
    relreplident AS identidad_tipo,
    CASE relreplident
        WHEN 'd' THEN 'Usa Primary Key (Default)'
        WHEN 'f' THEN 'Usa Toda la Fila (Full)'
        WHEN 'i' THEN 'Usa Índice Único'
        WHEN 'n' THEN 'Nada (No permite UPDATE/DELETE)'
    END AS descripcion
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' -- o el esquema de tu base Odoo
--AND c.relkind = 'r' -- Solo tablas ordinarias
AND relreplident = 'n';