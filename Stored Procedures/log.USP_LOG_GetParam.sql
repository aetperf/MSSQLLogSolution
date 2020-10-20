SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [log].[USP_LOG_GetParam]	@p_DatabaseName NVARCHAR(128),
						@p_ParamName NVARCHAR(1000),
						@o_ParamValue NVARCHAR(1000) OUTPUT
AS
BEGIN
	SET @o_ParamValue = NULL;
	SELECT @o_ParamValue = [ParamValue]
	FROM [log].[Params]
	WHERE [ParamName] = @p_ParamName
		AND [DatabaseName] = @p_DatabaseName

	-- Si on n'a pas réussi à récupérer la valeur pour la base renseignée, on récupère la valeur pour toutes les bases par défaut "*"
	IF @o_ParamValue IS NULL
		SELECT @o_ParamValue = [ParamValue]
		FROM [log].[Params]
		WHERE [ParamName] = @p_ParamName
			AND [DatabaseName] = '*'
END
GO
