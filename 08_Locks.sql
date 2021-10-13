/*
8-Análise de Locks
   Identificar locks 
   Gerar script de  kill
*/

-- verificar sessoes bloqueadas, evento que causou o bloqueio e qto tempo ja durou o bloqueio
select  sid, 
        serial#,
        status,
        username,
        osuser,
        program,
        blocking_session blocking,
        event,
        seconds_in_wait
from    v$session
where   blocking_session is not null;

-- ver na consulta acima retornar algum resultado, execute a consulta abaixo para verificar quais objetos estao bloqueados (ver linha 'Sessions begin blocked')
SET SERVEROUTPUT ON
BEGIN
  DBMS_OUTPUT.enable (1000000);
  
  FOR linha IN (  SELECT      a.session_id,
                              s.username,
                              a.object_id,
                              xidsqn,
                              oracle_username,
                              b.owner owner,
                              b.object_name object_name,
                              b.object_type object_type
                    FROM      v$locked_object a
                    JOIN      dba_objects b
                      ON      b.object_id = a.object_id
                    JOIN      v$session s
                      on      s.sid = a.session_id
                    WHERE     xidsqn != 0
                  )
    LOOP
        DBMS_OUTPUT.put_line ('.');
        DBMS_OUTPUT.put_line ('Blocking Session   : ' || linha.session_id);
        DBMS_OUTPUT.put_line ('Blocking Username  : ' || linha.username);
        DBMS_OUTPUT.put_line ('Object (Owner/Name): ' || linha.owner || '.' || linha.object_name); 
        DBMS_OUTPUT.put_line ('Object Type        : ' || linha.object_type);
      
        FOR next_loop  IN (SELECT   sid
                           FROM     v$lock
                           WHERE    id2 = linha.xidsqn
                           AND      sid != linha.session_id
                            )
        LOOP
            DBMS_OUTPUT.put_line('Sessions being blocked   :  ' || next_loop.sid);
        END LOOP;
    END LOOP;
END;
/



-- matar sessoes pelo PID (pegue o resultado e execute-o no prompt do SO:
SELECT        'kill -9 ' || P.SPID
FROM          V$SESSION S
INNER JOIN    V$PROCESS P
    ON        S.PADDR = P.ADDR
where         S.username = UPPER('&USERNAME');

-- consultar/matar todas as sessoes bloqueadoras (pegar resultado e executar em script SQL):
with s as (select * from v$session),
     l as (select * from v$lock),
     P AS (select * from v$process)

SELECT  'ALTER system DISCONNECT SESSION '''||s.sid||', '||s.serial#||''' IMMEDIATE;',
        'kill -9 ' || p.spid
FROM        s
inner join  p 
    on      s.PADDR = p.ADDR
where (s.USERNAME, s.SID) in (select    s1.username, s1.sid                  
                                from    l l1
                                join    s s1
                                  on    s1.sid=l1.sid
                                join    l l2
                                  on    l1.id1 = l2.id1
                                 and    l1.id2 = l2.id2
                                join    s s2
                                  on    s2.sid=l2.sid
                                where   l1.BLOCK=1 and l2.request > 0
                              );
                              
                              
-- eliminar todas as sessões de um determinado usuário conectado no Bd:
SET SERVEROUTPUT ON
BEGIN    
    DBMS_OUTPUT.ENABLE(NULL);
    FOR CUR_TAB IN (SELECT  SID, 
                            USERNAME,
                            'ALTER system DISCONNECT SESSION '''||sid||', '||serial#||''' IMMEDIATE' as cmd
                    FROM    V$SESSION 
                    WHERE   USERNAME = UPPER('&USER')
                    AND     USERNAME IS NOT NULL) LOOP
        BEGIN
          EXECUTE IMMEDIATE CUR_TAB.CMD;
          dbms_output.put_line('Sessão ' || CUR_TAB.SID || ' do usuário ' ||  CUR_TAB.USERNAME || ' eliminada!');
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao eliminar sessão ' || CUR_TAB.SID || '. ' || SQLERRM);
        END;
    END LOOP;
END;


                              
-- eliminar SQLS de sessões de um determinado usuário conectado no BD:
SET SERVEROUTPUT ON
BEGIN   
    DBMS_OUTPUT.ENABLE(NULL);
    FOR CUR_TAB IN (SELECT  SID, 
                            USERNAME,                            
                            'ALTER SYSTEM CANCEL SQL ''' || SID || ', ' || SERIAL# || '''' as cmd
                    FROM    V$SESSION 
                    WHERE   USERNAME = UPPER('&USER')
                    AND     USERNAME IS NOT NULL) LOOP
        BEGIN
          EXECUTE IMMEDIATE CUR_TAB.CMD;
          dbms_output.put_line('O SQL da sessão ' || CUR_TAB.SID || ' do usuário ' ||  CUR_TAB.USERNAME || ' foi cancelado!');
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao cancelar o SQL da sessão ' || CUR_TAB.SID || '. ' || SQLERRM);
        END;
    END LOOP;
END;
                              
                              