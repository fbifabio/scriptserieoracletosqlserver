/*
4-Estatisticas desatualizadas
   Identificar estatísticas desatualizadas
   Gerar script para atualizar
*/

-- Verificar tabelas com estatiscas mais velhas que N dias (isso nao significa que a tabela tem estatisticas desatualizadas):
select OWNER, TABLE_NAME, NUM_ROWS, BLOCKS, AVG_ROW_LEN , last_analyzed
from dba_tables where table_name = 'CARD_DETAILS';

-- Verificar indexes com estatiscas mais velhas que N dias (isso nao significa que o indexes tem estatisticas desatualizadas):
select  owner, index_name, table_owner, table_name, blevel, leaf_blocks, distinct_keys, clustering_factor, num_rows, last_analyzed 
from    dba_indexes 
where   last_analyzed > sysdate -10 and owner not in ('SYS');

-- verificar atualizacoes que ainda nao constam nas estatisticas
select      table_owner, table_name, partition_name, inserts, updates, deletes, to_char(timestamp, 'yyyy/mm/dd hh24:mi:ss') AS "TIMESTAMP"            
from        dba_tab_modifications 
where       table_name = 'CARD_DETAILS'
order by    6 desc;



-- verificar historico de estatisticas coletadas (retencao PADRAO de 31 dias):
select * from dba_tab_stats_history 
order by 5 desc;

-- Verificar operacoes de coletas de estatisticas que foram realizadas no BD (manuais e automaticas). Coluna NOTES contem parametros utilizados na coleta.
SELECT      OPERATION, TARGET, START_TIME, 
            (END_TIME - START_TIME) DAY(1) TO SECOND(0) AS DURATION,
            STATUS, NOTES 
FROM        DBA_OPTSTAT_OPERATIONS
ORDER BY    start_time DESC;

-- Coletando estatisticas de uma tabela:
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'SOE', TABNAME=>'CARD_DETAILS');

-- Coletando estatisticas de um schema:
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SOE');

-- Coletando estatisticas do BD:
EXEC DBMS_STATS.GATHER_DATABASE_STATS;