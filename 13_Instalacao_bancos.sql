/*
13 - Localização dos bancos
     Onde está instalado o banco de dados 
*/

-- binarios do software Oracle:
--  $   echo $ORACLE_HOME

-- caminho dos datafiles:
select * from dba_data_files;

show user

alter session set container = cdb$root;
alter session set container = pdbxe;

-- caminho dos tempfiles:
select * from dba_temp_files;

-- caminho dos redo logs:
select * from v$logfile;

-- caminho dos controlfiles:
show parameter CONTROL_files;

-- caminho dos archive logs:
show parameter log_archive_dest

select * from v$database;

alter system switch logfile;

show parameter recovery
show parameter 

select * from v$flash_recovery_area_usage

