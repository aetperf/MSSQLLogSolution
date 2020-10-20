CREATE ROLE [db_executor_putlog]
AUTHORIZATION [dbo]
GO
ALTER ROLE [db_executor_putlog] ADD MEMBER [TEST_LOG]
GO
