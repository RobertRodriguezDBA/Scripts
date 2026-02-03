#---------------------------------------------------------------------------------------
# SCRIPT FOR OS AND POSTGRESQL DB HEALTH CHECK 
# THIS SCRIPT CAN BE USED FOR SINGLE INSTANCE HEALTH CHECK
# SCRIPT WILL BE SENT ON THE EMAIL IN MAILTO VARIABLE (INSTALL PACKAGE MUTT)
# SCRIPT HAS BEEN TESTED ON UBUNTU OS 
# IT'S RECOMMENDED TO TEST THE SCRIPT ON TEST MACHINE FIRST BEFORE DEPLOYING IT ON LIVE
# REACH ME OUT ON UMI.VICK@GMAIL.COM IF YOU HAVE ANY QUESTIONS REGARDING THIS SCRIPT 
# REMEMBER ME IN YOUR PRAYERS
#---------------------------------------------------------------------------------------

DT=`date +"%B-%d-%G"`; export DT

Day=`date +"%a"`; export Day

MAILTO='local@local'; export MAILTO

echo "\n----------------------------------------------------------------------------" >> HealthCheck_$DT.txt

echo "-------------------------- POSTGRESQL HEALTHCHECK --------------------------" >> HealthCheck_$DT.txt

echo "----------------------------------------------------------------------------" >> HealthCheck_$DT.txt

echo "\n\t\t------------------------------------------------------" >> HealthCheck_$DT.txt

echo "\t\t---------------- Database Health Check ---------------" >> HealthCheck_$DT.txt

echo "\t\t------------------------------------------------------" >> HealthCheck_$DT.txt

echo "\n\n--------------------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%% DATABASE IP AND HOSTNAME %%%%%%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "--------------------------------------------------------------" >> HealthCheck_$DT.txt

hostname -I | awk '{print $1}' >> HealthCheck_$DT.txt;

hostname >> HealthCheck_$DT.txt;

echo "\n\n------------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%% DATABASE UPTIME %%%%%%%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "------------------------------------------------------" >> HealthCheck_$DT.txt

PGPASSWORD='Hgw3gxh#V2Nz' psql -h database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com -U gm_admin_user -p 5432 -d VOGMMP -c "SELECT pg_postmaster_start_time() as uptime;" >> HealthCheck_$DT.txt

echo "\n\n----------------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%% REPLICATION_SYNCED_UNTIL %%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "----------------------------------------------------------" >> HealthCheck_$DT.txt

/usr/lib/postgresql/12/bin/psql -U hc -d postgres -c "SELECT CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() THEN 0 ELSE EXTRACT (hour FROM now() - pg_last_xact_replay_timestamp()) END AS log_delay;" >> HealthCheck_$DT.txt

echo "\n\n----------------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%%%%% WAL RECIEVER %%%%%%%%%%%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "----------------------------------------------------------" >> HealthCheck_$DT.txt

/usr/lib/postgresql/12/bin/psql -U hc -d postgres -c "\x" -c "SELECT * FROM pg_stat_wal_receiver" >> HealthCheck_$DT.txt

echo "\n\n----------------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%%%%% WAL SENDER %%%%%%%%%%%%%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "----------------------------------------------------------" >> HealthCheck_$DT.txt

/usr/lib/postgresql/12/bin/psql -U hc -d postgres -c "\x" -c "select usename, client_addr , state , replay_lag , sync_state, reply_time from pg_catalog.pg_stat_replication" >> HealthCheck_$DT.txt

echo "\n\n----------------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%% Queries Running Since 5 Mints %%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "----------------------------------------------------------" >> HealthCheck_$DT.txt

/usr/lib/postgresql/12/bin/psql -U hc -d postgres -c "SELECT pid, now() - query_start as "runtime", usename, datname, state, query FROM pg_stat_activity WHERE now() - query_start > '5 minutes'::interval and state = 'active' ORDER BY runtime DESC" >> HealthCheck_$DT.txt

echo "\n\t\t-----------------------------------------------------" >> HealthCheck_$DT.txt

echo "\t\t------------------ OS HEALTH CHECK ------------------" >> HealthCheck_$DT.txt

echo "\t\t-----------------------------------------------------" >> HealthCheck_$DT.txt

echo "\n\n--------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%% MOUNT POINTS %%%%%%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "--------------------------------------------------" >> HealthCheck_$DT.txt

df -h >> HealthCheck_$DT.txt

echo "\n" >> HealthCheck_$DT.txt

echo "\n\n--------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%% UPTIME %%%%%%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "--------------------------------------------" >> HealthCheck_$DT.txt

uptime >> HealthCheck_$DT.txt

echo "\n" >> HealthCheck_$DT.txt

echo "\n\n------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%% ERROR LOGS %%%%%%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "------------------------------------------------" >> HealthCheck_$DT.txt

egrep -i -E 'error|warn|criti|pg_hba' /var/lib/postgresql/12/main/log/postgresql-$Day.log >> HealthCheck_$DT.txt

echo "\n" >> HealthCheck_$DT.txt

echo "\n\n-------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%%%%%%%%% TOP COMMAND %%%%%%%%%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "-------------------------------------------------" >> HealthCheck_$DT.txt

top -b -n 1| head -n 30 >> HealthCheck_$DT.txt

echo "\n\n-------------------------------------------------" >> HealthCheck_$DT.txt

echo "%%%%%%%%%%% POSTGRESQL SERVICE STATUS %%%%%%%%%%%" >> HealthCheck_$DT.txt

echo "-------------------------------------------------" >> HealthCheck_$DT.txt

/usr/bin/systemctl status postgresql >> HealthCheck_$DT.txt

echo "" | mutt -s "HealthCheck" $MAILTO -i /body.txt -a HealthCheck_$DT.txt