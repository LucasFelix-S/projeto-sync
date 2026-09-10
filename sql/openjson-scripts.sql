DECLARE @DadosJson TABLE (
	codigoErp			BIGINT,
	descricao			VARCHAR(150),
	categoriaId			INT,
	estoque				DECIMAL(18,4),
	preco				DECIMAL(18,2),
	statusId			INT
);

BEGIN TRY
	BEGIN TRANSACTION;
		
		INSERT INTO @DadosJson(codigoErp, descricao, categoriaId, estoque, preco, statusId)
		SELECT
			codigoErp,
			descricao,
			categoriaId,
			estoque,
			preco,
			statusId
		FROM TB_JSON_RECEBIDO
		CROSS APPLY OPENJSON(CONTEUDO)
			
		WITH (
			codigoErp BIGINT,
			descricao VARCHAR(150),
			categoriaId INT,
			estoque DECIMAL(18,4),
			preco DECIMAL(18, 2),
			statusId INT
		)
		
		WHERE TIPO = 'produtos'
		  AND PROCESSADO = 'N';
		
		INSERT INTO TB_CADASTRO_PRODUTO(CODIGO_ERP, DESCRICAO, ID_CATEGORIA, ID_STATUS)
		SELECT
			codigoErp,
			descricao,
			categoriaId,
			statusId	
		FROM @DadosJson;
				
		
		INSERT INTO TB_ESTOQUE_PRODUTO(CODIGO_ERP, SALDO_ESTOQUE)
		SELECT
			codigoErp,
			estoque	
		FROM @DadosJson;
		
		
		INSERT INTO TB_PRECO_PRODUTO(CODIGO_ERP, PRECO)
		SELECT
			codigoErp,
			preco
		FROM @DadosJson;
		
		-- adicionar regra para que o PROCESSADO 'N' vire 'S' para os que foram alterados.
		
	COMMIT TRANSACTION;
END TRY
	
	BEGIN CATCH
	
		IF @@TRANCOUNT > 0
    		ROLLBACK TRANSACTION;
		SELECT
		    ERROR_NUMBER() AS numero,
		    ERROR_MESSAGE() AS mensagem;
	
END CATCH
