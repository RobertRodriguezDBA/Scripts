-- Lista extenciones instaladas
SELECT * FROM pg_available_extensions WHERE installed_version IS NOT NULL;
/*
        name        | default_version | installed_version |                                comment
--------------------+-----------------+-------------------+------------------------------------------------------------------------
 pg_trgm            | 1.5             | 1.4               | text similarity measurement and index searching based on trigrams
 pgstattuple        | 1.5             | 1.5               | show tuple-level statistics
 tablefunc          | 1.0             | 1.0               | functions that manipulate whole tables, including crosstab
 pg_stat_statements | 1.8             | 1.7               | track planning and execution statistics of all SQL statements executed
 plpgsql            | 1.0             | 1.0               | PL/pgSQL procedural language
*/

-- Actualizar extenciones
ALTER EXTENSION pg_trgm UPDATE;
ALTER EXTENSION pgstattuple UPDATE;
ALTER EXTENSION tablefunc UPDATE;
ALTER EXTENSION pg_stat_statements UPDATE;
