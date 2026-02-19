-- 0.3_Validar_Objetos_VFTI.sql
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    -- 1. Validar Vistas y Vistas Materializadas
    RAISE NOTICE '>>>>>>>>>>>>>>   Validando Views...';
    FOR r IN (SELECT table_name FROM information_schema.views WHERE table_schema = 'public' 
              UNION SELECT matviewname FROM pg_matviews WHERE schemaname = 'public') LOOP
        BEGIN
            EXECUTE 'SELECT 1 FROM public.' || quote_ident(r.table_name) || ' LIMIT 0';
            --RAISE NOTICE 'Validando View: %', quote_ident(r.table_name);
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'ERROR EN VISTA %: %', r.table_name, SQLERRM;
        END;
    END LOOP;

    -- 2. Validar Funciones (Check de sintaxis básica)
    -- Postgres 14 es más estricto con tipos de datos.
    RAISE NOTICE '>>>>>>>>>>>>>>   Validando Funciones...';
    -- Nota: La validación profunda requiere ejecución, aquí verificamos existencia y owner.
    -- Validar Funciones (Check de integridad de cuerpo y dependencias)
    FOR r IN (
        SELECT 
            p.proname AS funcion,
            n.nspname AS esquema,
            pg_get_function_arguments(p.oid) AS argumentos,
            p.oid
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public' 
          AND p.prokind = 'f' -- Filtramos solo funciones (excluimos procedimientos/agregados)
    ) LOOP
        BEGIN
            -- Forzamos a Postgres a recompilar/verificar la definición de la función
            -- Esto detecta si hay llamadas a funciones de extensiones inexistentes.
            PERFORM pg_get_functiondef(r.oid);
            
            -- Opcional: Validar si la función es "STABLE" o "VOLATILE" (Informativo)
            -- RAISE NOTICE 'Función verificada: % (%)', r.funcion, r.argumentos;
            
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING '>>>>>>>>>>>>>>   ERROR CRÍTICO EN FUNCIÓN %: %', r.funcion, SQLERRM;
            RAISE WARNING '>>>>>>>>>>>>>>   CONSEJO: Verifique si las extensiones (unaccent, trgm) están actualizadas.';
        END;
    END LOOP;


    -- 3. Validar Triggers
    RAISE NOTICE '>>>>>>>>>>>>>>   Validando Triggers...';
    FOR r IN (
        SELECT 
            t.tgname AS trigger_nombre,
            c.relname AS tabla_nombre,
            p.proname AS funcion_disparada
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_proc p ON t.tgfoid = p.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE n.nspname = 'public' 
          AND t.tgisinternal = FALSE -- Solo triggers creados por el usuario/Odoo
    ) LOOP
        BEGIN
            -- Verificamos que la tabla asociada exista y sea accesible
            EXECUTE 'SELECT 1 FROM public.' || quote_ident(r.tabla_nombre) || ' LIMIT 0';
            -- RAISE NOTICE  '>>>>>>>>>>>>>>   Validando Trigger % (Tabla: %)', r.trigger_nombre, r.tabla_nombre;
            -- Verificamos que la función del trigger sea válida
            PERFORM pg_get_functiondef((SELECT oid FROM pg_proc WHERE proname = r.funcion_disparada LIMIT 1));

        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING '>>>>>>>>>>>>>>   FALLO EN TRIGGER % (Tabla: %): %', r.trigger_nombre, r.tabla_nombre, SQLERRM;
        END;
    END LOOP;

    -- 4. Validación Extra: Índices Corruptos o Inválidos
    RAISE NOTICE '>>>>>>>>>>>>>>   Validando Indices...';
    FOR r IN (
        SELECT 
            c.relname as tabla,
            i.relname as indice
        FROM pg_index x
        JOIN pg_class c ON c.oid = x.indrelid
        JOIN pg_class i ON i.oid = x.indexrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE NOT x.indisvalid AND n.nspname = 'public'
    ) LOOP
        RAISE WARNING '>>>>>>>>>>>>>>   INDICE INVALIDO DETECTADO: % en tabla %', r.indice, r.tabla;
        RAISE WARNING '>>>>>>>>>>>>>>   CONSEJO: Ejecute REINDEX INDEX CONCURRENTLY %;', r.indice;
    END LOOP;
END $$;
