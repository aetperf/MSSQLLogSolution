SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [log].[USP_LOG_CheckParams]	@p_RunCommand NVARCHAR(MAX),
									@p_ProcId INT
AS
BEGIN
	DECLARE @v_ParamName sysname;
	DECLARE @v_Check BIT = 1;

	DECLARE cursor_param CURSOR FOR
	SELECT name
	FROM sys.parameters
	WHERE object_id = @p_ProcId;

	OPEN cursor_param;
	FETCH NEXT FROM cursor_param INTO @v_ParamName;
	WHILE @@fetch_status = 0
	BEGIN
		-- On regarde si la chaîne passée en paramètre contient le nom du paramètre
		SET @v_Check = CASE WHEN @p_RunCommand LIKE '%' + @v_ParamName + '%' THEN 1 ELSE 0 END

		-- Si on a trouvé un paramètre manquant on peut arrêter
		IF @v_Check = 0
		BEGIN
			DECLARE @v_ErrorMessage NVARCHAR(4000) = 'Missing parameter ' + @v_ParamName;
			RAISERROR(@v_ErrorMessage, 16, 1);
		END

		FETCH NEXT FROM cursor_param INTO @v_ParamName;
	END
	CLOSE cursor_param;
	DEALLOCATE cursor_param;
END
GO
GRANT EXECUTE ON  [log].[USP_LOG_CheckParams] TO [db_executor_putlog] WITH GRANT OPTION
GO
