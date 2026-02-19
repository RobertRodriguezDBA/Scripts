-- Script rápido para validar que todas las vistas funcionan
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT viewname FROM pg_views WHERE schemaname = 'public') LOOP
        BEGIN
            EXECUTE 'SELECT 1 FROM public.' || quote_ident(r.viewname) || ' LIMIT 0';
            RAISE NOTICE 'View Exist >>>> %: %', r.viewname, '<<<<';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error en vista %: %', r.viewname, SQLERRM;
        END;
    END LOOP;
END $$;

--
--select 1 from public.bi_ventas_eventos limit 0;
SELECT viewname FROM pg_views WHERE schemaname = 'public'; --and viewname like 'f%'


