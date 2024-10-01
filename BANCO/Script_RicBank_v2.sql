CREATE DATABASE Ricbank;
USE Ricbank;

CREATE TABLE [dbo].[Cliente](
                                Id INT IDENTITY(1,1) PRIMARY KEY,
                                Nome VARCHAR(100) NOT NULL,
                                Data_Nascimento DATE NOT NULL
                            );

CREATE TABLE [dbo].[Conta]  (
                                Id INT IDENTITY(1,1) PRIMARY KEY,
                                Id_Cliente INT NOT NULL,
                                Data_Saldo DATETIME NOT NULL,
                                Vlr_SaldoInicial DECIMAL(15,2) NOT NULL,
                                Vlr_Credito DECIMAL(15,2) NOT NULL,
                                Vlr_Debito DECIMAL(15,2) NOT NULL,
                                Data_Abertura DATE NOT NULL,
                                Data_Fechamento DATE
                            );
ALTER TABLE [dbo].[Conta]
    ADD CONSTRAINT [FK_IdCliente_Conta]
        FOREIGN KEY(Id_Cliente)
            REFERENCES [dbo].[Cliente](Id);

CREATE TABLE [dbo].[Lancamento] (
                                    Id INT IDENTITY(1,1) PRIMARY KEY,
                                    Id_Conta INT NOT NULL,
                                    Data_Lancamento DATETIME NOT NULL,
                                    Historico VARCHAR(200) NOT NULL,
                                    Valor_Lancamento DECIMAL(15,2) NOT NULL,
                                    Tipo_Lancamento CHAR(1) NOT NULL,
                                    CONSTRAINT [FK_IdConta_Lancamento]
                                        FOREIGN KEY(Id_Conta)
                                            REFERENCES [dbo].[Conta](Id)
                                )
ALTER TABLE [dbo].[Lancamento]
    WITH CHECK ADD CONSTRAINT [CHK_Tipo_Lancamento_C_D]
        CHECK ([Tipo_Lancamento] = 'C' OR [Tipo_Lancamento] = 'D');