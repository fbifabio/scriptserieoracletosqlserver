/*
3-Numeros de conexões ativas
    Verificar processos no banco que consomem recurso e nao estão  perdidos
    monitora limite de conexao do banco  com base na show parameter process
*/


-- Verificar processos no banco que consomem recurso e nao estão  perdidos
select * from v$session where username is not null;

-- monitora limite de conexao do banco  com base na show parameter process
show parameter process
show parameter sessions 
select count(1) from v$session where username is not null;
