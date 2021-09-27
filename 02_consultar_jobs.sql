/*
2-Verficar Jobs em execução , falhas e horários schedulaods
      Relatório de Jobs e schedules
      Jobs com sucesso
      Jobs com falhas ‘Detalhes das falhas'
      Owner dos Jobs
 */     

-- Verificar jobs schedulados:
select * from SYS.dba_jobs WHERE BROKEN = 'N'; -- ver INTERVAL  , SCHEMA_USER = owner
select * from SYS.dba_scheduler_jobs where enabled = 'TRUE';  -- ver REPEAT_INTERVAL

-- verificar jobs em execucao:
select * from SYS.dba_jobs_running;
select * from SYS.dba_scheduler_running_jobs;
      
-- verificar jobs executados com falha:      
select * from dba_jobs where failures > 0;  -- deve-se comparar com ultima consulta efetuada pr ver se failures aumentou, se broken = Y o job está desabilitado
select * from SYS.dba_scheduler_job_run_details where status <> 'SUCCEEDED'; -- ver coluna ADDITIONL_INFO




