#!/bin/bash
# 0.5_Actualizar_Estadisticas


# Priorizar tablas críticas de Odoo
echo 'Ejecutando: ANALYZE VERBOSE res_partner, mail_message, account_move_line, stock_move'
PGPASSWORD='Hgw3gxh#V2Nz' psql -h database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com -U gm_admin_user -p 5432 -d VOGMMP -c "ANALYZE VERBOSE res_partner, mail_message, account_move_line, stock_move;"

# Ejecutar ANALYZE paralelo en toda la DB
echo 'Ejecutando: VACUUMDB VOGMMP'
PGPASSWORD='Hgw3gxh#V2Nz' vacuumdb -h database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com -U gm_admin_user -p 5432 -d VOGMMP  -j 4 -Z -v
