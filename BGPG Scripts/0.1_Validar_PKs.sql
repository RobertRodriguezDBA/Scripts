-- 0.1_Validar_PKs
-- Buscar tablas que fallarán en Blue/Green
SELECT tab.*
FROM information_schema.tables tab
LEFT JOIN information_schema.table_constraints tco 
  ON tab.table_schema = tco.table_schema AND tab.table_name = tco.table_name 
  AND tco.constraint_type = 'PRIMARY KEY'
WHERE tab.table_schema = 'public' 
AND tco.constraint_name IS NULL
AND table_type ='BASE TABLE'
LIMIT 17000;

-- Buscar tavistas que fallarán en Blue/Green
SELECT tab.*
FROM information_schema.tables tab
LEFT JOIN information_schema.table_constraints tco 
  ON tab.table_schema = tco.table_schema AND tab.table_name = tco.table_name 
  AND tco.constraint_type = 'PRIMARY KEY'
WHERE tab.table_schema = 'public' 
AND tco.constraint_name IS NULL
AND table_type ='VIEW'
LIMIT 17000;
--------------------------------

SELECT tab.table_type, count(tab.table_type)
FROM information_schema.tables tab
LEFT JOIN information_schema.table_constraints tco 
  ON tab.table_schema = tco.table_schema AND tab.table_name = tco.table_name 
  AND tco.constraint_type = 'PRIMARY KEY'
WHERE tab.table_schema = 'public' 
AND tco.constraint_name IS NULL
--AND table_type ='BASE TABLE'
GROUP BY tab.table_type
LIMIT 17000;