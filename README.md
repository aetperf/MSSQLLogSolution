# MSSQLLogSolution

## Install Instructions :

0) Database 
```sql
CREATE DATABASE ADM_LOG
GO
```

1) Schema
  ```sql
  USE ADM_LOG
  GO
  CREATE SCHEMA log;
  GO
  ```
2) Tables
    - 2a) [log.LogLevel](Tables/log.LogLevel.sql)
    - 2b) [log.Params.sql](Tables/log.Params.sql)
    - 2c) [log.System.sql](Tables/log.System.sql)
    - 2d) [log.TraceEvent.sql](Tables/log.TraceEvent.sql)
3) Data
4) Sequences
5) Stored Procedures :
  - log.\*Get\* first
  - log.\*Put\* next
  - dbo.USM\* end
6) Security
