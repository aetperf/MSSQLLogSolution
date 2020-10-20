SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [log].[USP_LOG_GetParamLogLevel]	@p_DatabaseName NVARCHAR(128) = NULL,
											@o_ParamValue TINYINT OUTPUT
AS
BEGIN
	DECLARE @v_ParamValue_Varchar NVARCHAR(1000) = 'a';
	EXEC [log].[USP_LOG_GetParam]	@p_DatabaseName = @p_DatabaseName,
									@p_ParamName = 'LogLevel',
									@o_ParamValue = @v_ParamValue_Varchar OUTPUT;
	SET @o_ParamValue = TRY_CAST(@v_ParamValue_Varchar AS TINYINT);
END
GO
GRANT EXECUTE ON  [log].[USP_LOG_GetParamLogLevel] TO [db_executor_putlog] WITH GRANT OPTION
GO
