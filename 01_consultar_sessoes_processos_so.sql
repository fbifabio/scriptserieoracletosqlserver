-- Quais processos estão em execução 
-- Quanto tempo estão em execução 
-- Origem ,Usuario,estação/ip/Servidor
-- Retorna dados das sessoes ativas e seus respectivos SQLs, junto com o hash_value e cursor_id do plano de execucao sendo utilizado
SELECT          /*+ ALL_ROWS */
                a.sid,
                a.serial#, -- identifica objeto de sessao, util para distinguir objeto quando uma sessao possui o mesmo sid de uma sessao anterior
                p.spid, -- id do processo no SO
                a.program,    
                a.username,  
                B.SQL_ID, b.child_number,
                b.optimizer_cost,                
                a.status,  -- active, inactive, killed (marcada p/ finalizar), cached (temporiaramente em cache p/ uso pelo Oracle XA), sniped (inativa, esperando no cliente)
                to_char(a.logon_time, 'DD-MON-YYYY HH24:MI:SS') as logon_time,
                to_char(sysdate - last_call_et / 86400,'DD-MON-YYYY HH24:MI:SS') as last_activity,
                a.osuser,
                a.machine,
                a.event, 
                ROUND(a.last_call_et / 60, 2) AS EXECUTE_SESSION_MINUTES,
                A.SECONDS_IN_WAIT,                
                b.cpu_time/(1000000) as sql_cpu_time_total,
                b.executions AS sql_executions_total,
                b.elapsed_time/(1000000) as sql_elapsed_time_total,
                case 
                    when b.executions > 0 then (b.elapsed_time/(1000000))  / b.executions 
                    else 0
                end as sql_elapsed_time_per_exec,     
                b.rows_processed,
                b.buffer_gets,
                b.disk_reads,                
                --round(((c.CONSISTENT_GETS+c.BLOCK_GETS-c.PHYSICAL_READS) / (c.CONSISTENT_GETS+c.BLOCK_GETS) * 100),2) Ratio,
                b.application_wait_time/(1000000) as application_wait_time_sec,
                b.concurrency_wait_time/(1000000) as concurrency_wait_time_sec,
                b.user_io_wait_time/(1000000) as user_io_wait_time_sec,                          
                b.OPTIMIZER_MODE,                
                (b.sharable_mem + b.persistent_mem + b.runtime_mem) /1024/1024 "used_memory (mb)",
                b.SQL_TEXT,
                listagg(bc.value_string, ', ' ) within group (order by BC.POSITION) AS SQL_BIND_LAST_VALUES                
FROM            V$SESSION A
LEFT JOIN       V$PROCESS P
    ON          a.PADDR = P.ADDR
left join       v$sql b
    on          a.sql_address = b.address
    and         a.sql_hash_value = b.hash_value       
    and         a.sql_child_number = b.child_number
LEFT join       v$sess_io c
    ON          A.SID = C.SID
LEFT JOIN       v$sql_bind_capture bC
    ON          b.address = bc.address
    AND         b.hash_value = bc.hash_value
WHERE           a.status = 'ACTIVE'
and             a.username is not null
GROUP BY        p.spid,
                a.sid,
                a.serial#,
                a.program,    
                a.username,  
                B.SQL_ID, b.child_number,
                b.optimizer_cost,                
                a.status,
                to_char(a.logon_time, 'DD-MON-YYYY HH24:MI:SS'),
                to_char(sysdate - last_call_et / 86400,'DD-MON-YYYY HH24:MI:SS'),
                a.osuser,
                a.machine,
                a.event, 
                ROUND(a.last_call_et / 60, 2),
                A.SECONDS_IN_WAIT,                
                b.cpu_time/(1000000),
                b.executions,
                b.elapsed_time/(1000000),
                case 
                    when b.executions > 0 then (b.elapsed_time/(1000000))  / b.executions 
                    else 0
                end,     
                b.rows_processed,
                b.buffer_gets,
                b.disk_reads,                                
                b.application_wait_time/(1000000),
                b.concurrency_wait_time/(1000000),
                b.user_io_wait_time/(1000000),
                b.OPTIMIZER_MODE,                
                (b.sharable_mem + b.persistent_mem + b.runtime_mem) /1024/1024,                
                b.SQL_TEXT
order by        a.sid, B.SQL_ID, b.child_number ;