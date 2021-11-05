-- 12: Parâmetros de inicialização

-- ver valor do parametro CONTROL_FILES:
SHOW PARAMETER [parameter_name]

-- ver Parâmetros modificáveis em cada PDB:
select name, value, ispdb_modifiable from v$parameter;

-- Modificando parâmetro no CDB e em todos os PDB's
alter system set open_cursors = 200 container = all;    

-- 5: Modificando parâmetro em um PDB
alter session set container = pdbxe;
alter system set open_cursors = 250 container = current;    

-- Verifica que no CDB não mudou
alter session set container = cdb$root;
show parameter open_cursors;


