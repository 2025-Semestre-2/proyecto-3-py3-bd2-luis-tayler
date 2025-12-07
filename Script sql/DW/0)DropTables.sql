USE BikeStoresDW;
GO

PRINT 'Eliminando Foreign Keys...';
-- ==============================================
-- 1. ELIMINAR TODAS LAS FOREIGN KEYS
-- ==============================================
ALTER TABLE Fact_Ventas DROP CONSTRAINT IF EXISTS FK_FactVentas_DimFechaOrden;
ALTER TABLE Fact_Ventas DROP CONSTRAINT IF EXISTS FK_FactVentas_DimFechaReq;
ALTER TABLE Fact_Ventas DROP CONSTRAINT IF EXISTS FK_FactVentas_DimFechaEnv;
ALTER TABLE Fact_Ventas DROP CONSTRAINT IF EXISTS FK_FactVentas_DimClientes;
ALTER TABLE Fact_Ventas DROP CONSTRAINT IF EXISTS FK_FactVentas_DimEmpleados;
ALTER TABLE Fact_Ventas DROP CONSTRAINT IF EXISTS FK_FactVentas_DimSucursales;
ALTER TABLE Fact_Ventas DROP CONSTRAINT IF EXISTS FK_FactVentas_DimProductos;
ALTER TABLE Fact_Ventas DROP CONSTRAINT IF EXISTS FK_FactVentas_DimOrdenes;

PRINT 'Foreign Keys eliminadas correctamente.';

-- ==============================================
-- 2. ELIMINAR TODAS LAS TABLAS DEL DW
-- ==============================================
PRINT 'Eliminando todas las tablas del DW...';

DROP TABLE IF EXISTS Fact_Ventas;
DROP TABLE IF EXISTS Dim_Inventario;
DROP TABLE IF EXISTS Dim_Ordenes;
DROP TABLE IF EXISTS Dim_Sucursales;
DROP TABLE IF EXISTS Dim_Productos;
DROP TABLE IF EXISTS Dim_Empleados;
DROP TABLE IF EXISTS Dim_Clientes;
DROP TABLE IF EXISTS Dim_Fecha;

PRINT 'Todas las tablas han sido eliminadas correctamente.';
GO