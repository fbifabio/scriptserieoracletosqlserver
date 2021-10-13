/*
10- Analise do Alert , monitorar
*/

-- 1: Consultando o alert xml
SELECT    ORIGINATING_TIMESTAMP, 
          message_text 
FROM      X$DBGALERTEXT 
ORDER BY  1 DESC;

-- 2: Consultando o alert p/ verificar qtde de ocorrencias de deadlock, por mes
SELECT      TO_CHAR(ORIGINATING_TIMESTAMP,'yyyy/mm') DATA, 
            count(1)
FROM        X$DBGALERTEXT 
WHERE       MESSAGE_TEXT LIKE '%Deadlock%'
GROUP BY    TO_CHAR(ORIGINATING_TIMESTAMP,'yyyy/mm')
ORDER BY    1 DESC;

-- 3: Consultar o arquivo texto alert log
    -- a)Consultar o caminho do arquivo texto alert log no Oracle 11G ou superior
    sql>    SELECT  * 
            FROM    V$DIAG_INFO
            where   name in ('Diag Trace');
            
        -- ou no 10G
        SHOW PARAMETER USER_DUMP_DEST
                    
    -- b) No prompt de comandos entrar na pasta indicada no passo anterior
    $> cd $ORACLE_HOME/../../../diag/rdbms/xe/xe/trace
    
    -- c) Ver conteudo do arquivo texto alert log
    $> vi alert_xe.log

    -- Para sair do arquivo, digite:
    $> :q!
	
	-- d) O arquivo pode ser muito grande, podemos ver apenas o final
	$> tail -n 100 alert_xe.log | more

	-- e) Ver o final do arquivo e ver novas entradas conforme elas ocorrem
	$> tail -n 100 -f alert_xe.log
   
    -- d) Para sair digite CTRL+C
    
    

