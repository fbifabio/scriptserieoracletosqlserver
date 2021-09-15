/*
6-Planos de execução
   Apos identificar uma query demorada como pegar seu plano de execução
   como pegar as recomendações de melhorias ( indices etc)
*/

-- identificando sql_id (melhor monitorar via oratop):
select sql_id, sql_child_number, s.* from v$session s where username is not null;

-- vendo plano de execucao de sql que foi executado:
select * from table(dbms_xplan.display_cursor(sql_id => '7ws837zynp1zv'));

-- recomendacoes de melhorias de sql tem q executar sql tuning advisor (depende da option TUNING PACK):
-- https://oracle-base.com/articles/10g/automatic-sql-tuning-10g
SET SERVEROUTPUT ON

-- Tuning task created for specific a statement from the AWR.
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          begin_snap  => 764,
                          end_snap    => 938,
                          sql_id      => '19v5guvsgcd1v',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 60,
                          task_name   => '19v5guvsgcd1v_AWR_tuning_task',
                          description => 'Tuning task for statement 19v5guvsgcd1v in AWR.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

-- Tuning task created for specific a statement from the cursor cache.
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id      => '19v5guvsgcd1v',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 60,
                          task_name   => '19v5guvsgcd1v_tuning_task',
                          description => 'Tuning task for statement 19v5guvsgcd1v.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

-- Tuning task created from a SQL tuning set.
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sqlset_name => 'test_sql_tuning_set',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 60,
                          task_name   => 'sqlset_tuning_task',
                          description => 'Tuning task for a SQL tuning set.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

-- Tuning task created for a manually specified statement.
DECLARE
  l_sql               VARCHAR2(500);
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql := 'SELECT e.*, d.* ' ||
           'FROM   emp e JOIN dept d ON e.deptno = d.deptno ' ||
           'WHERE  NVL(empno, ''0'') = :empno';

  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_text    => l_sql,
                          bind_list   => sql_binds(anydata.ConvertNumber(100)),
                          user_name   => 'scott',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 60,
                          task_name   => 'emp_dept_tuning_task',
                          description => 'Tuning task for an EMP to DEPT join query.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

-- ver recomendacoes do sql tuning advisor:
SET LONG 10000;
SET PAGESIZE 1000
SET LINESIZE 200
SELECT DBMS_SQLTUNE.report_tuning_task('emp_dept_tuning_task') AS recommendations FROM dual;
SET PAGESIZE 24