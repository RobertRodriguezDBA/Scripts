SELECT matviewname FROM pg_matviews WHERE schemaname = 'public';

--

DO $$ 
DECLARE r RECORD;
BEGIN
    FOR r IN (SELECT matviewname FROM pg_matviews WHERE schemaname = 'public') LOOP
        --EXECUTE 'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || quote_ident(r.matviewname);
        RAISE NOTICE 'Actualizando Vista: %', quote_ident(r.matviewname);
    END LOOP;
END $$;
