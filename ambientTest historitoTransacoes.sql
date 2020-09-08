use TestAmbient;
exec sp_columns clienteProvisorio;
exec sp_columns historicoTransacao;
-- Testint ind TRANSACTION BLOCK
BEGIN TRAN;
-- Creating Procedure for update
GO
CREATE PROCEDURE sp_Testando
	@from varchar(30),
	@fromBank varchar(20),
	@fromAccount varchar(20),
	@value decimal(8,2),
	@destiny varchar(30),
	@destinyBank varchar(20),
	@destinyAccount varchar(20)
	
AS
	--Updating saldo of client from --
BEGIN TRY
	UPDATE clienteProvisorio
		set saldo = saldo - @value
		where conta = @fromAccount;

	--Updatig saldo of client destiny ++
	UPDATE clienteProvisorio
		set saldo = saldo + @value
		where conta = @destinyAccount;
	PRINT CONCAT('Transferência entre Sr(a): ', @from, ' e destinatário Sr(a): ', @destiny, ' com valor de: R$ ', @value , ' realizada com sucesso!') ;
	-- Inserting values into historcoTransacao with paramters
		insert into historicoTransacao (cliente_origem, banco_origem, conta_origem, valorTransferencia, cliente_destino, banco_destino, conta_destino)
							VALUES		(@from, @fromBank, @fromAccount, @value, @destiny, @destinyBank, @destinyAccount);
END TRY

BEGIN CATCH
	PRINT CONCAT('Ocorreu o seguinte erro no momento da transação : ', ERROR_NUMBER(), ' ' , ERROR_PROCEDURE() );
END CATCH;

	-- Juliana tem 100 ('Juliana','Nubank S.A','0001','10391', 100)
	--Jaqueline tem 500 ('Jaqueline','Inter S.A','0001','10282', 500);
	 -- Leandro tem 300 ('Leandro'	,'Itaú', '0003' ,	'20290'  , '300.00'	, '2020-04-29')
		select * from clienteProvisorio;
	--Call Stored Procedure
	EXEC sp_Testando 'Juliana','Nubank S.A','10391',50,'Jaqueline','Inter S.A','10282';
	-- Testing is updated
	select * from clienteProvisorio where nome = 'Jaqueline' or nome = 'Juliana';
	select * from historicoTransacao;
		-- WIIIIIIIINS !!!!
	EXEC sp_Testando 'Jaqueline','Inter S.A','10282',200,'Leandro','Itaú','20290';
	-- Juliana: R$ 50, Jaqueline: R$ 350 , Leandro: 500
	-- Tete Mensal
	select * from historicoTransacao where conta_origem = '10282' and DATEPART(month,dataCriacao) = 4;
	select name from sys.objects where type = 'P';
	-- A Trigger abaixo não deu certo, retornou duas linha e mostrando como
	  --se o @from tivesse transferido para si próprio
/*
GO
CREATE TRIGGER trg_testeUpdate
ON clienteProvisorio
AFTER UPDATE 
AS
	BEGIN
		if UPDATE(saldo)
			insert into historicoTransacao
			select nome, banco, conta, saldo, nome, banco,conta ,getDATE() from inserted;

	END; */
ROLLBACK;
COMMIT;

-- 04/Maio : Star Wars Day
EXEC sp_Testando 'Juliana','Nubank S.A','10391', 25, 'Leandro','Itaú','20290';
select * from clienteProvisorio;
select * from historicoTransacao;
select * from historicoTransacao where cliente_destino = 'Jaqueline';