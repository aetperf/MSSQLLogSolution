CREATE TABLE [log].[LogLevel]
(
[LogLevel] [tinyint] NOT NULL,
[LogLevelDescriptionEN] [nvarchar] (100) COLLATE French_CI_AS NULL,
[LogLevelDescriptionFR] [nvarchar] (100) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [log].[LogLevel] ADD CONSTRAINT [PK_LOGLEVEL] PRIMARY KEY CLUSTERED  ([LogLevel]) ON [PRIMARY]
GO
