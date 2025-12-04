USE BikeStoresDW;
GO

PRINT 'Eliminando Foreign Keys dinámicamente...';

-- ==============================================
-- 1. DROPEAR TODAS LAS FOREIGN KEYS DEL DW
-- ==============================================
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql +
'ALTER TABLE [' + OBJECT_SCHEMA_NAME(parent_object_id) + '].[' + OBJECT_NAME(parent_object_id) + ']' +
' DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.foreign_keys;

EXEC sp_executesql @sql;

PRINT 'Foreign Keys eliminadas correctamente.';

-- ==============================================
-- 2. DROPEAR TODAS LAS TABLAS DEL DW (orden controlado)
-- ==============================================
PRINT 'Dropping all DW tables...';

DROP TABLE IF EXISTS Fact_Ventas;
DROP TABLE IF EXISTS Dim_Inventario;
DROP TABLE IF EXISTS Dim_Ordenes;
DROP TABLE IF EXISTS Dim_Sucursales;
DROP TABLE IF EXISTS Dim_Productos;
DROP TABLE IF EXISTS Dim_Empleados;
DROP TABLE IF EXISTS Dim_Clientes;
DROP TABLE IF EXISTS Dim_Fecha;

PRINT 'Todas las tablas han sido eliminadas correctamente.';


