SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/******************************************************************************************************
-- PROJET: TEST
-- NOM SCRIPT: USP_ProcName
-- DESCRIPTION: Model for Logging Table
-- NOTES: 
-- USAGE : EXEC [dbo].[TestProcedure] @p_LogLevelTrace=5, @p_SystemId=0
-- HISTORY:
-- Date              | Developper                   | Ticket			 |Description
-------------------------------------------------------------------------------------------------------
-- 2020-10-20        | ABL                          |{Ticket Number}     | script creation
-- {date}            | {nom ou trigramme}           |{Ticket Number}     | {description modification }
******************************************************************************************************/


CREATE     PROCEDURE [dbo].[USM_ModelProcedure]	@p_BatchId BIGINT = NULL,
									@p_LogLevelTrace TINYINT = NULL,
									@p_SystemId INT = 0
AS
BEGIN
	
	SET NOCOUNT ON;

	/************************************************************************
	*							1a. User Variables							*
	*************************************************************************/
	DECLARE @p_TargetName NVARCHAR(256) = 'dbo.MaTable';

	
	/************************************************************************
	*							1b. Tech Variables							*
	*************************************************************************/
	DECLARE @v_ErrorCode INT;
	DECLARE @v_ErrorSeverity INT;
	DECLARE @v_ErrorState INT;
	DECLARE @v_ErrorMessage NVARCHAR(4000);
	DECLARE @v_UserMessage NVARCHAR(4000);
	DECLARE @v_RunCommand NVARCHAR(MAX);
	DECLARE @v_DatabaseName sysname = DB_NAME();
	DECLARE @v_TypeLogId SMALLINT = 1; -- Numéro du premier évènement;
	DECLARE @v_DateFirstEventUTC DATETIME2(7) = GETUTCDATE();
	DECLARE @v_DateLastEventUTC DATETIME2(7) = @v_DateFirstEventUTC;
	DECLARE @v_ObjectName SYSNAME = OBJECT_NAME(@@PROCID);
	DECLARE @v_SchemaName SYSNAME = OBJECT_SCHEMA_NAME(@@PROCID);
	DECLARE @v_LastTypeLogId INT = 9999;
	DECLARE @v_ProcedureFullName NVARCHAR(1000) = QUOTENAME(@v_SchemaName) + '.' + QUOTENAME(@v_ObjectName);
	DECLARE @v_Step NVARCHAR(1000);

	-- Log level constant definition
	DECLARE @c_LOGLEVEL_CRITICAL TINYINT = 1;
	DECLARE @c_LOGLEVEL_ERROR TINYINT = 2;
	DECLARE @c_LOGLEVEL_WARNING TINYINT = 3;
	DECLARE @c_LOGLEVEL_INFO TINYINT = 4;
	DECLARE @c_LOGLEVEL_VERBOSE TINYINT = 5;
	DECLARE @c_LOGLEVEL_DEBUG TINYINT = 6;
	

	/************************************************************************
	*							2. Get BatchId								*
	*************************************************************************/
	-- If no BatchId from call then we will generate a new BatchId

	IF @p_BatchId IS NULL
		SET @p_BatchId = NEXT VALUE FOR [ADM_LOG].[log].[SEQ_LOG_BATCHID];


	/************************************************************************
	*							3. Get LogLevel								*
	*************************************************************************/
	BEGIN TRY
		IF @p_LogLevelTrace IS NULL
		BEGIN
			EXEC [ADM_LOG].[log].[USP_LOG_GetParamLogLevel]	@p_DatabaseName = @v_DatabaseName, @o_ParamValue = @p_LogLevelTrace OUTPUT; -- Retrieve Default LogLevel for database or global

			SET @v_UserMessage = 'Execution of the procedure [ADM_LOG].[log].[USP_LOG_GetParamLogLevel], procedure return @p_LogLevelTrace = ' + TRY_CAST(@p_LogLevelTrace AS VARCHAR(100));
			EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_RunCommand = @v_RunCommand, @p_TargetName = @p_TargetName, @p_UserMessage = @v_UserMessage,
										@p_LogLevelMessage = @c_LOGLEVEL_DEBUG;
		END
	END TRY
	BEGIN CATCH
		SET @v_UserMessage = 'Error retrieving Default LogLevel.';
		SELECT @v_ErrorMessage = ERROR_MESSAGE(), @v_ErrorCode = ERROR_NUMBER(), @v_ErrorSeverity = ERROR_SEVERITY(), @v_ErrorState = ERROR_STATE();
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_ErrorMessage = @v_ErrorMessage, @p_ErrorCode = @v_ErrorCode, @p_ErrorSeverity = @v_ErrorSeverity, @p_ErrorState = @v_ErrorState, @p_UserMessage = @v_UserMessage, @p_TargetName = @p_TargetName,
									@p_LogLevelMessage = @c_LOGLEVEL_ERROR;
	
		SET @v_UserMessage = 'End of procedure ' + @v_ProcedureFullName + ' with error :' + @v_UserMessage;
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_LastTypeLogId, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateFirstEventUTC, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_ErrorMessage = @v_ErrorMessage, @p_ErrorCode = @v_ErrorCode, @p_ErrorSeverity = @v_ErrorSeverity, @p_ErrorState = @v_ErrorState, @p_UserMessage = @v_UserMessage, @p_TargetName = @p_TargetName,
									@p_LogLevelMessage = @c_LOGLEVEL_ERROR;
		THROW; -- Will Exit procedure with error
	END CATCH

	IF @p_LogLevelTrace >= @c_LOGLEVEL_DEBUG
		SET NOCOUNT OFF;

	/************************************************************************
	*							4. Recup Param								*
	*************************************************************************/
	BEGIN TRY
		SET @v_RunCommand = 'EXEC ' + QUOTENAME(DB_NAME()) + '.' + QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID))
				+ ' @p_BatchId = ' + COALESCE(TRY_CAST(@p_BatchId AS VARCHAR(MAX)), 'NULL')
				+ ', @p_LogLevelTrace = ' + COALESCE(TRY_CAST(@p_LogLevelTrace AS VARCHAR(MAX)), 'NULL')
				+ ', @p_SystemId = ' + COALESCE(TRY_CAST(@p_SystemId AS VARCHAR(MAX)), 'NULL')
			/*  + ', @paramVarchar = ' + COALESCE('''' + @paramVarchar + '''', 'NULL') -- Cas d'un paramètre de type varchar ou nvarchar
				+ ', @paramInt = ' + COALESCE(TRY_CAST(@paramInt AS VARCHAR(MAX)), 'NULL'); -- Cas d'un paramètre de type entier, numeric, bit ... */
		SET @v_UserMessage = 'Init procedure run command build : ' + @v_RunCommand;
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog] @p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_RunCommand = @v_RunCommand, @p_TargetName = @p_TargetName, @p_UserMessage = @v_UserMessage,
									@p_LogLevelMessage = @c_LOGLEVEL_VERBOSE;
	END TRY
	BEGIN CATCH
		SET @v_UserMessage = 'Error retrieving parameters';
		SELECT @v_ErrorMessage = ERROR_MESSAGE(), @v_ErrorCode = ERROR_NUMBER(), @v_ErrorSeverity = ERROR_SEVERITY(), @v_ErrorState = ERROR_STATE();
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_ErrorMessage = @v_ErrorMessage, @p_ErrorCode = @v_ErrorCode, @p_ErrorSeverity = @v_ErrorSeverity, @p_ErrorState = @v_ErrorState, @p_UserMessage = @v_UserMessage, @p_TargetName = @p_TargetName,
									@p_LogLevelMessage = @c_LOGLEVEL_ERROR;
	
		SET @v_UserMessage = 'End of procedure ' + @v_ProcedureFullName + ' with error : ' + @v_UserMessage;
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_LastTypeLogId, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateFirstEventUTC, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_ErrorMessage = @v_ErrorMessage, @p_ErrorCode = @v_ErrorCode, @p_ErrorSeverity = @v_ErrorSeverity, @p_ErrorState = @v_ErrorState, @p_UserMessage = @v_UserMessage, @p_TargetName = @p_TargetName,
									@p_LogLevelMessage = @c_LOGLEVEL_ERROR;
		THROW; -- Will Exit procedure with error
	END CATCH
	

	/************************************************************************
	*							5. Check Param								*
	*************************************************************************/
	BEGIN TRY
		EXEC [ADM_LOG].[log].[USP_LOG_CheckParams]	@p_RunCommand = @v_RunCommand, 
											@p_ProcId = @@procid;

		SET @v_UserMessage = 'Execution of procedure [ADM_LOG].[log].[USP_LOG_CheckParams]';
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_RunCommand = NULL, @p_TargetName = @p_TargetName, @p_UserMessage = @v_UserMessage,
									@p_LogLevelMessage = @c_LOGLEVEL_DEBUG;
	END TRY
	BEGIN CATCH
		SET @v_UserMessage = 'Error in parameters checks';
		SELECT @v_ErrorMessage = ERROR_MESSAGE(), @v_ErrorCode = ERROR_NUMBER(), @v_ErrorSeverity = ERROR_SEVERITY(), @v_ErrorState = ERROR_STATE();
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_ErrorMessage = @v_ErrorMessage, @p_ErrorCode = @v_ErrorCode, @p_ErrorSeverity = @v_ErrorSeverity, @p_ErrorState = @v_ErrorState, @p_UserMessage = @v_UserMessage, @p_TargetName = @p_TargetName,
									@p_LogLevelMessage = @c_LOGLEVEL_ERROR;
	
		SET @v_UserMessage = 'End of procedure ' + @v_ProcedureFullName + ' with error : ' + @v_UserMessage;
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_LastTypeLogId, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateFirstEventUTC, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_ErrorMessage = @v_ErrorMessage, @p_ErrorCode = @v_ErrorCode, @p_ErrorSeverity = @v_ErrorSeverity, @p_ErrorState = @v_ErrorState, @p_UserMessage = @v_UserMessage, @p_TargetName = @p_TargetName,
									@p_LogLevelMessage = @c_LOGLEVEL_ERROR;
		THROW; -- Will Exit procedure with error
	END CATCH


	/************************************************************************
	*							99. Log Start Business Part					*
	*************************************************************************/
	SET @v_TypeLogId = 99;
	SET @v_UserMessage = 'Start of the procedure ' + @v_ProcedureFullName;
	EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_RunCommand = @v_RunCommand, @p_TargetName = @p_TargetName, @p_UserMessage = @v_UserMessage,
								@p_LogLevelMessage = @c_LOGLEVEL_INFO;
	

	/************************************************************************
	*							100. Business Part							*
	*																		*
	*																		*
	*																		*
	*																		*
	*																		*
	*************************************************************************/
	BEGIN TRY


		SET @v_Step='Step 1 : Init';
		SELECT 1
		WAITFOR DELAY '00:00:05';

		SET @v_UserMessage = N'End of Step '+ @v_Step;
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_RunCommand = NULL, @p_TargetName = @p_TargetName, @p_UserMessage = @v_UserMessage,
								@p_LogLevelMessage = @c_LOGLEVEL_VERBOSE;

		
		SET @v_Step='Step 2 : Wait 5';
		WAITFOR DELAY '00:00:05';
		--SELECT 1/0;

		SET @v_UserMessage = N'End of Step ' + @v_Step;
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_RunCommand = NULL, @p_TargetName = @p_TargetName, @p_UserMessage = @v_UserMessage,
								@p_LogLevelMessage = @c_LOGLEVEL_VERBOSE;


	END TRY
	BEGIN CATCH
		SET @v_UserMessage = 'Error for Step ' + @v_Step;
		SELECT @v_ErrorMessage = ERROR_MESSAGE(), @v_ErrorCode = ERROR_NUMBER(), @v_ErrorSeverity = ERROR_SEVERITY(), @v_ErrorState = ERROR_STATE();
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_TypeLogId OUTPUT, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateLastEventUTC OUTPUT, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_ErrorMessage = @v_ErrorMessage, @p_ErrorCode = @v_ErrorCode, @p_ErrorSeverity = @v_ErrorSeverity, @p_ErrorState = @v_ErrorState, @p_UserMessage = @v_UserMessage, @p_TargetName = @p_TargetName,
									@p_LogLevelMessage = @c_LOGLEVEL_ERROR;
	
		SET @v_UserMessage = 'End of procedure ' + @v_ProcedureFullName + ' with error : ' + @v_UserMessage;
		EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_LastTypeLogId, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateFirstEventUTC, @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_ErrorMessage = @v_ErrorMessage, @p_ErrorCode = @v_ErrorCode, @p_ErrorSeverity = @v_ErrorSeverity, @p_ErrorState = @v_ErrorState, @p_UserMessage = @v_UserMessage, @p_TargetName = @p_TargetName,
									@p_LogLevelMessage = @c_LOGLEVEL_ERROR;
		THROW; -- Will Exit procedure with error 
	END CATCH


	/************************************************************************
	*							9999. Log End of procedure					*
	*************************************************************************/
	SET @v_UserMessage = 'End of the procedure ' + @v_ProcedureFullName + ' with success.';
	EXEC [ADM_LOG].[log].[USP_LOG_PutLog]	@p_BatchId = @p_BatchId, @p_SystemId = @p_SystemId, @o_TypeLogId = @v_LastTypeLogId, @p_LogLevelTrace = @p_LogLevelTrace, @o_DateLastEventUTC = @v_DateFirstEventUTC , @p_ObjectName = @v_ObjectName, @p_DatabaseName = @v_DatabaseName, @p_SchemaName = @v_SchemaName, @p_RunCommand = @v_RunCommand, @p_TargetName = @p_TargetName, @p_UserMessage = @v_UserMessage, 
								@p_LogLevelMessage = @c_LOGLEVEL_INFO;
END
GO
