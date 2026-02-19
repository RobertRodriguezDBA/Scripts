#!/bin/bash
# 0.5_Actualizar_Estadisticas

# Tiempo inicial
start_time=$(date +%s)

# Ejecutar ANALYZE paralelo en toda la DB
echo 'Ejecutando: VACUUMDB VOGMMP'
PGPASSWORD='Hgw3gxh#V2Nz' vacuumdb -h database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com -U gm_admin_user -p 5432 -d VOGMMP -j 4 --analyze-in-stages -Z -v > vacuum.log
echo 'Vacuum VOGMMP Finalizado'

# Tiempo final
end_time=$(date +%s)

# Calcular diferencia
elapsed_time=$((end_time - start_time))

#echo "Tiempo de inicio: $start_time"
#echo "Tiempo final: $end_time"
echo "Tiempo de ejecucion: $elapsed_time segundos"