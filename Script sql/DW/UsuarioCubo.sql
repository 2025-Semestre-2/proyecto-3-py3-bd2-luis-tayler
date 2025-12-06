-- Login a nivel de servidor
CREATE LOGIN CubeUser WITH PASSWORD = 'CubeUser#2025', CHECK_POLICY = OFF;
GO

-- Usuario dentro de la BD del DW
USE BikeStoresDW;
GO
CREATE USER CubeUser FOR LOGIN CubeUser;
GO

-- Dar permisos de solo lectura sobre el DW
EXEC sp_addrolemember 'db_datareader', 'CubeUser';
GO
USE master;
GO

ALTER DATABASE BikeStoresDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE BikeStoresDW SET ALLOW_SNAPSHOT_ISOLATION ON;
ALTER DATABASE BikeStoresDW SET READ_COMMITTED_SNAPSHOT ON;
GO

ALTER DATABASE BikeStoresDW SET MULTI_USER;
GO