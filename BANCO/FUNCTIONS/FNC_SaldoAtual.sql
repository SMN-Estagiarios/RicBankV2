IF EXISTS   (
                SELECT 1
                    FROM [dbo].[sysobjects]
                    WHERE Id = OBJECT_ID(N'[dbo].[FNC_SaldoAtual]')
                        AND OBJECTPROPERTY(Id, N'IsScalarFunction') = 1
            )
    BEGIN
        DROP FUNCTION [dbo].[FNC_SaldoAtual];
    END;
GO

CREATE FUNCTION [dbo].[FNC_SaldoAtual]
    (@Id_Conta INT)
    
    RETURNS DECIMAL(15,2)
    AS
    /*
        DOCUMENTAÇÃO
        Objetivo......: Calcular o saldo atual da conta informada
        Autor.........: Olívio Freitas
        Data..........: 24/09/2024
		ObjetivoAlt...: N/A
		AutorAlt......: N/A
		DataAlt.......: N/A
        Exemplo.......: DBCC DROPCLEANBUFFERS;
                        DBCC FREEPROCCACHE;

                        DECLARE @Data_Inicio DATETIME = GETDATE(),
                                @Id INT = 2;

                        SELECT * FROM Conta WITH(NOLOCK) WHERE Id = @Id
                        SELECT  [dbo].[FNC_SaldoAtual] (2) AS SaldoAtual,
                                DATEDIFF(MILLISECOND, @Data_Inicio, GETDATE()) AS Tempo_Execucao
    */
    BEGIN
    -- Declaro as variáveis que preciso para resolver o problema
    DECLARE @SaldoInicial DECIMAL(15,2),
            @Credito DECIMAL(15,2),
            @Debito DECIMAL(15,2)
    -- Verifico se a conta passada por parâmetro existe
    IF EXISTS   (
                    SELECT TOP 1 1
                        FROM [dbo].[Conta] WITH(NOLOCK)
                        WHERE Id = @Id_Conta
                )
            BEGIN
        -- Recupero os valores e atribuo às variáveis
        SELECT  @SaldoInicial = Vlr_SaldoInicial,
                @Credito = Vlr_Credito,
                @Debito = Vlr_Debito
            FROM [dbo].[Conta] WITH(NOLOCK)
            WHERE Id = @Id_Conta
    END
    -- Calculo os valores e retorno
    RETURN @SaldoInicial + @Credito - @Debito
END
GO
