rman target / LOG=/bkp/LOG_RMAN_$DATA.log <<EOF
CONFIGURE RETENTION POLICY TO REDUNDANCY 1;
CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/bkp/%F';

run
{

sql "create pfile=''/bkp/P_FILE_$SID.ORA'' from spfile";

shutdown immediate;

startup mount;

allocate channel t1 type disk;
allocate channel t2 type disk;
allocate channel t3 type disk;

backup as compressed backupset full
check logical database
include current controlfile
tag 'bkp_off'
format '/bkp/RMAN_%d_%Y%M%D_%s_%p.rman';

alter database open;

release channel t1;
release channel t2;
release channel t3;
}

crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;

EOF