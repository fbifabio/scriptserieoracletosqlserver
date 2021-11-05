-- 12: Par�metros de inicializa��o

-- ver valor do parametro CONTROL_FILES:
SHOW PARAMETER [parameter_name]

-- ver Par�metros modific�veis em cada PDB:
select name, value, ispdb_modifiable from v$parameter;

-- Modificando par�metro no CDB e em todos os PDB's
alter system set open_cursors = 200 container = all;    

-- 5: Modificando par�metro em um PDB
alter session set container = pdbxe;
alter system set open_cursors = 250 container = current;    

-- Verifica que no CDB n�o mudou
alter session set container = cdb$root;
show parameter open_cursors;


