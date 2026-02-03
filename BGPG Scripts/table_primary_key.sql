SELECT --tab.table_schema, tab.table_catalog, tab.table_name, tab.table_type, 
tab.*
FROM information_schema.tables tab
LEFT JOIN information_schema.table_constraints tco 
  ON tab.table_schema = tco.table_schema AND tab.table_name = tco.table_name 
  AND tco.constraint_type = 'PRIMARY KEY'
WHERE tab.table_schema = 'public' AND tco.constraint_name IS NULL;
