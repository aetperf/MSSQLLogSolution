CREATE TABLE [log].[TraceEvent]
(
[EventTimestampUTC] [datetime2] NOT NULL,
[BatchId] [bigint] NOT NULL,
[SystemId] [int] NOT NULL,
[TypeLogId] [smallint] NOT NULL,
[LogLevel] [tinyint] NOT NULL,
[DurationMs] [bigint] NOT NULL,
[ObjectName] [sys].[sysname] NOT NULL,
[DatabaseName] [sys].[sysname] NULL,
[SchemaName] [sys].[sysname] NULL,
[StatusId] [tinyint] NOT NULL,
[ErrorMessage] [nvarchar] (4000) COLLATE French_CI_AS NULL,
[ErrorCode] [nvarchar] (10) COLLATE French_CI_AS NULL,
[ErrorSeverity] [smallint] NULL,
[ErrorState] [smallint] NULL,
[UserMessage] [nvarchar] (4000) COLLATE French_CI_AS NULL,
[RunUser] [sys].[sysname] NULL,
[SystemPid] [int] NULL,
[RunCommand] [nvarchar] (4000) COLLATE French_CI_AS NULL,
[TargetName] [nvarchar] (256) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [log].[TraceEvent] ADD CONSTRAINT [PK_TRACEEVENT] PRIMARY KEY CLUSTERED  ([SystemId], [BatchId], [TypeLogId], [EventTimestampUTC]) ON [PRIMARY]
GO
ALTER TABLE [log].[TraceEvent] ADD CONSTRAINT [FK_TRACEEVE_FK_TRACEE_SYSTEM] FOREIGN KEY ([SystemId]) REFERENCES [log].[System] ([SystemId])
GO
ALTER TABLE [log].[TraceEvent] ADD CONSTRAINT [FK_TRACEEVE_FK_TRANCE_LOGLEVEL] FOREIGN KEY ([LogLevel]) REFERENCES [log].[LogLevel] ([LogLevel])
GO
