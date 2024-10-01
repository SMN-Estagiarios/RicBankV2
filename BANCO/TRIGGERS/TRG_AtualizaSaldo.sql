IF EXISTS   (
                SELECT 1
                    FROM [dbo].[sysobjects]
                    WHERE Id = OBJECT_ID(N'[dbo].[TRG_AtualizaSaldo]')
                        AND TYPE = 'TR'
            )
    BEGIN
        DROP TRIGGER [dbo].[TRG_AtualizaSaldo]
    END;
GO

CREATE TRIGGER [dbo].[TRG_AtualizaSaldo]
    ON [dbo].[Lancamento]
    FOR INSERT, UPDATE, DELETE
    AS
    /*
        DOCUMENTAÇÃO
        Objetivo......: Atualizar o saldo da conta a partir de um lançamento gerado
        Autor.........: Olívio Freitas
        Data..........: 30/09/2024
		ObjetivoAlt...: N/A
		AutorAlt......: N/A
		DataAlt.......: N/A
        Exemplo.......: BEGIN TRAN
                            DBCC DROPCLEANBUFFERS;
                            DBCC FREEPROCCACHE;

                            DECLARE @Data_Inicio DATETIME = GETDATE(),
                                    @Id_Conta INT = 5

                            SELECT  Id,
                                    Data_Saldo,
                                    Vlr_SaldoInicial,
                                    Vlr_Credito,
                                    Vlr_Debito    
                                FROM Conta
                                WHERE Id = @Id_Conta;

                            INSERT INTO [dbo].[Lancamento]  (
                                                                Id_Conta,
                                                                Data_Lancamento,
                                                                Historico,
                                                                Valor_Lancamento,
                                                                Tipo_Lancamento
                                                            )
                                                    VALUES
                                                            (
                                                                @Id_Conta,
                                                                GETDATE(),
                                                                'Testando trigger Crédito',
                                                                150,
                                                                'C'
                                                            )

                             SELECT Id,
                                    Id_Conta,
                                    Data_Lancamento,
                                    Historico,
                                    Valor_Lancamento,
                                    Tipo_Lancamento
                                FROM Lancamento
                                WHERE Id_Conta = @Id_Conta;

                             SELECT  Id,
                                    Data_Saldo,
                                    Vlr_SaldoInicial,
                                    Vlr_Credito,
                                    Vlr_Debito    
                                FROM Conta
                                WHERE Id = @Id_Conta;

                            SELECT  DATEDIFF(MILLISECOND, @Data_Inicio, GETDATE()) AS Tempo_Execucao
                        ROLLBACK TRAN
    */
    BEGIN
        -- Declaro as variáveis que vou usar
        DECLARE @Id_Conta INT,
                @Data_Lancamento DATETIME,
                @Valor_Lancamento DECIMAL(15,2),
                @Tipo_Lancamento CHAR(1)

        -- Atribuo os valores capturados da tabela inserted
        SELECT  @Id_Conta = Id_Conta,
                @Data_Lancamento = Data_Lancamento,
                @Valor_Lancamento = Valor_Lancamento,
                @Tipo_Lancamento = Tipo_Lancamento
            FROM inserted

        -- Atualizo registro da conta
        UPDATE [dbo].[Conta]
            SET Vlr_SaldoInicial =  (
                                        CASE WHEN @Data_Lancamento < Data_Saldo
                                            THEN Vlr_SaldoInicial + (
                                                                        CASE WHEN @Tipo_Lancamento = 'C'
                                                                                THEN @Valor_Lancamento
                                                                            ELSE @Valor_Lancamento * (-1)
                                                                        END
                                                                    )
                                            ELSE Vlr_SaldoInicial
                                        END
                                    ),
                Vlr_Credito =   (
                                    CASE WHEN @Data_Lancamento < Data_Saldo OR @Tipo_Lancamento = 'D'
                                        THEN Vlr_Credito
                                        ELSE (Vlr_Credito + @Valor_Lancamento)
                                    END
                                ),
                Vlr_Debito =    (
                                    CASE WHEN @Data_Lancamento < Data_Saldo OR @Tipo_Lancamento = 'C'
                                        THEN Vlr_Debito
                                        ELSE (Vlr_Debito + @Valor_Lancamento)
                                    END
                                )
            WHERE Id = @Id_Conta

    END;
GO