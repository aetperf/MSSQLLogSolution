CREATE TABLE [log].[Params]
(
[DatabaseName] [nvarchar] (128) COLLATE French_CI_AS NOT NULL,
[ParamName] [nvarchar] (1000) COLLATE French_CI_AS NOT NULL,
[ParamValue] [nvarchar] (1000) COLLATE French_CI_AS NULL,
[LUD] [datetime2] NULL,
[LUU] [sys].[sysname] NULL
) ON [PRIMARY]
GO
ALTER TABLE [log].[Params] ADD CONSTRAINT [PK_PARAMS] PRIMARY KEY CLUSTERED  ([DatabaseName], [ParamName]) ON [PRIMARY]
GO
