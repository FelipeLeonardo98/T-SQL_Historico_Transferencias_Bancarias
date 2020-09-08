GO
CREATE TABLE cliente(
	id int primary key IDENTITY(1,1),
	nome varchar(30) not null,
	banco varchar(20) not null,
	agencia char(6) not null,
	conta char(9) not null,
	saldo decimal(8,2),
	dataCriacao date not null default GETDATE()
);
GO
create table historicoTransacao(
	id_transacao int primary key IDENTITY (1,1),
	cliente_origem varchar(30),
	banco_origem varchar (20),
	conta_origem char(9),
	valorTransferencia  decimal(8,2),
	cliente_destino varchar(30),
	banco_destino varchar (20),
	conta_destino char(9),
	dataCriacao date not null default GETDATE()
);

GO
-- FOR INSERTING INSIDE 'Cliente'
INSERT INTO CLIENTE (nome, banco, agencia, conta, saldo) 
	VALUES ('Felipe','Inter S.A','0001','10281', 500);
	select * from cliente;

	INSERT INTO CLIENTE (nome, banco, agencia, conta, saldo) 
	VALUES ('Juliana','Nubank S.A','0001','10391', 100),
	       ('Jaqueline','Inter S.A','0001','10282', 500),
		   ('Leandro','Itaú','0003','20290', 300),
		   ('Bruno','Itaú','0003','20291', 300),
		   ('Diego','Nubank S.A','0001','10392', 100),
		   ('Luiz','Nubank S.A','0001','10393', 100);

-- Testint ind TRANSACTION BLOCK
BEGIN TRAN;
-- Creating Procedure for update
GO
CREATE PROCEDURE sp_TransferByName
	@from varchar(30),
	@destiny varchar(30),
	@value decimal(8,2)
AS
	--Updating saldo of client from --
BEGIN TRY
	UPDATE cliente
		set saldo = saldo - @value
		where nome = @from;

	--Updatig saldo of client destiny ++
	UPDATE cliente
		set saldo = saldo + @value
		where nome = @destiny;
	PRINT CONCAT('Transferência entre Sr(a): ', @from, 'e destinatário Sr(a): ', @destiny, 'com valor de: R$ ', @value , 'realizada com sucesso!') ;
END TRY

BEGIN CATCH
	PRINT CONCAT('Ocorreu o seguinte erro no momento da transação :', ERROR_NUMBER(), ' ' , ERROR_PROCEDURE() );
END CATCH;
	--Felipe tem 500 ('Felipe','Inter S.A','0001','10281', 500);
	-- Juliana tem 100 ('Juliana','Nubank S.A','0001','10391', 100),
	-- Felipe vai transferir R$ 50 par Ju
	--Call Stored Procedure
	EXEC sp_TransferByName 'Felipe','Juliana',50;
	select * from cliente where nome = 'Felipe' or nome = 'Juliana';
ROLLBACK;
COMMIT;
/*												----			                                                 */
--	Creating new table with cliente structure
select * into clienteProvisorio  
	 FROM cliente where id = 100;

	
EXEC sp_columns clienteProvisorio;
-- criou sem o valor default no campo date, por ser um valor DEFAULT, o SQL-Server encara como uma CONSTRAINT
alter table clienteProvisorio 
ADD CONSTRAINT df_date DEFAULT GETDATE() for dataCriacao ;

INSERT INTO clienteProvisorio(nome, banco, agencia, conta, saldo) 
	VALUES ('Juliana','Nubank S.A','0001','10391', 100),
	       ('Jaqueline','Inter S.A','0001','10282', 500),
		   ('Leandro','Itaú','0003','20290', 300);
SELECT * FROM clienteProvisorio;

/*
CREATE TRIGGER trg_testeUpdate
ON clienteProvisorio
AFTER UPDATE 
AS
	BEGIN
		if UPDATE(saldo)
			insert into historicoTransacao
			select nome,banco, conta, saldo where saldo = saldo from inserted;

	END; */