SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [log].[USP_LOG_PutLog]	@p_BatchId BIGINT,
												@p_SystemId INT,
												@o_TypeLogId SMALLINT OUTPUT,
												@p_LogLevelTrace TINYINT,
												@p_LogLevelMessage TINYINT,
												@o_DateLastEventUTC DATETIME2(7) OUTPUT,
												@p_ObjectName sysname,
												@p_DatabaseName sysname = NULL,
												@p_SchemaName sysname = NULL,
												@p_ErrorMessage NVARCHAR(MAX) = NULL,
												@p_ErrorCode NVARCHAR(10) = NULL,
												@p_ErrorSeverity SMALLINT = NULL,
												@p_ErrorState SMALLINT = NULL,
												@p_UserMessage NVARCHAR(MAX) = NULL,
												@p_RunCommand NVARCHAR(MAX) = NULL,
												@p_TargetName NVARCHAR(256) = NULL
AS
BEGIN
	-- On récupère la date de log
	DECLARE @v_EventUTC DATETIME2(7) = GETUTCDATE();

	-- On n'insère de log que si le niveau de log demandé par la procédure est supérieur ou égal au niveau de log de l'évènement
	IF @p_LogLevelTrace >= @p_LogLevelMessage
	BEGIN
		-- On calcule la durée en MS entre le dernier évènement et le nouveau
		DECLARE @v_DurationMS BIGINT = DATEDIFF(MILLISECOND, @o_DateLastEventUTC, @v_EventUTC);

		-- On définit le statut : erreur avec une sévérité >= 11 alors on considère le traitement en erreur
		DECLARE @v_StatusId TINYINT = CASE WHEN @p_ErrorSeverity >= 11 THEN 1 ELSE 0 END;
		
		-- On tronque les chaines de caractères NVARCHAR(MAX) en chaines NVARCHAR(4000)
		DECLARE @v_ErrorMessageTruncated NVARCHAR(4000) = TRY_CAST(@p_ErrorMessage AS NVARCHAR(4000));
		DECLARE @v_UserMessageTruncated NVARCHAR(4000) = TRY_CAST(@p_UserMessage AS NVARCHAR(4000));
		DECLARE @v_RunCommandTruncated NVARCHAR(4000) = TRY_CAST(@p_RunCommand AS NVARCHAR(4000));

		-- On insère la trace de l'évènement
		INSERT INTO log.TraceEvent ([EventTimestampUTC], [BatchId], [SystemId], [TypeLogId], [LogLevel], [DurationMs], [ObjectName], [DatabaseName], [SchemaName], [StatusId], [ErrorMessage], [ErrorCode], [ErrorSeverity], [ErrorState], [UserMessage], [RunUser], [SystemPid], [RunCommand], [TargetName])
		VALUES (@v_EventUTC, @p_BatchId, @p_SystemId, @o_TypeLogId, @p_LogLevelMessage, @v_DurationMS, @p_ObjectName, @p_DatabaseName, @p_SchemaName, @v_StatusId, @v_ErrorMessageTruncated, @p_ErrorCode, @p_ErrorSeverity, @p_ErrorState, @v_UserMessageTruncated, ORIGINAL_LOGIN(), @@spid, @v_RunCommandTruncated, @p_TargetName);

		
	END

	-- On incrémente le numéro d'étape de 1
	SET @o_TypeLogId += 1;

	-- On modifie la date de dernier évènement pour la nouvelle date
	SET @o_DateLastEventUTC = @v_EventUTC;
END
GO
GRANT EXECUTE ON  [log].[USP_LOG_PutLog] TO [db_executor_putlog] WITH GRANT OPTION
GO
