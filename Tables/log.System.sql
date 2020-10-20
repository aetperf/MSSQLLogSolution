CREATE TABLE [log].[System]
(
[SystemId] [int] NOT NULL,
[SystemType] [nvarchar] (100) COLLATE French_CI_AS NULL,
[SystemName] [nvarchar] (1000) COLLATE French_CI_AS NULL,
[SystemCategory] [nvarchar] (100) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [log].[System] ADD CONSTRAINT [PK_SYSTEM] PRIMARY KEY CLUSTERED  ([SystemId]) ON [PRIMARY]
GO
