/*
5-Planos de manutenção 
   Validar últimos planos executados
*/


-- ver se coleta esta habilitada ou nao (STATUS = ENABLED):
SELECT 	client_name, status 
FROM 	dba_autotask_operation;

-- desabilita coleta:
BEGIN
  DBMS_AUTO_TASK_ADMIN.disable(  client_name => 'auto optimizer stats collection',
                    operation => NULL,  window_name => NULL);
END;

-- habilita coleta:
BEGIN
  DBMS_AUTO_TASK_ADMIN.enable(  client_name => 'auto optimizer stats collection',
                    operation => NULL,  window_name => NULL);
END;