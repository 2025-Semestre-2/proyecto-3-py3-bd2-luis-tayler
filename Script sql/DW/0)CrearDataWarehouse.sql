/* borrar completamente la BD si ya existe
IF DB_ID('BikeStoresDW') IS NOT NULL
BEGIN
    ALTER DATABASE BikeStoresDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BikeStoresDW;
END;
GO
*/

CREATE DATABASE BikeStoresDW;
GO

USE BikeStoresDW;
GO

-- ==========================================
-- Dim_Fecha (Dimensión de Tiempo)
-- ==========================================
CREATE TABLE Dim_Fecha (
    FechaKey          INT         NOT NULL PRIMARY KEY,
    FechaCompleta     DATE        NOT NULL,
    Anio              INT         NOT NULL,
    Mes               INT         NOT NULL,
    Dia               INT         NOT NULL,
    NombreMes         VARCHAR(20) NOT NULL,
    NombreDiaSemana   VARCHAR(20) NOT NULL,
    Trimestre         INT         NOT NULL,
    EsFinDeSemana     BIT         NOT NULL
);
GO

-- ==========================================
-- Dim_Clientes (SCD Tipo 2)
-- ==========================================
CREATE TABLE Dim_Clientes (
    ClienteKey        INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID_NK      INT          NOT NULL,
    NombreCompleto    VARCHAR(520) NOT NULL,
    Email             VARCHAR(255) NULL,     
    Telefono          VARCHAR(25)  NULL,       
    Ciudad            VARCHAR(50)  NULL,     
    Estado            VARCHAR(25)  NULL,     
    CodigoPostal      VARCHAR(5)   NULL,       
    Pais              VARCHAR(100) NULL,

    EsActual          BIT          NOT NULL 
        CONSTRAINT DF_DimClientes_EsActual DEFAULT (1),

    FechaInicio       DATETIME     NOT NULL,
    FechaFin          DATETIME     NULL
);
GO

-- ==========================================
-- Dim_Empleados (SCD Tipo 2)
-- ==========================================
CREATE TABLE Dim_Empleados (
    EmpleadoKey       INT IDENTITY(1,1) PRIMARY KEY,
    StaffID_NK        INT          NOT NULL,              
    NombreCompleto    VARCHAR(110) NOT NULL,              
    Email             VARCHAR(255) NULL,                 
    Telefono          VARCHAR(25)  NULL,                  
    Cargo             VARCHAR(100) NULL,
    TiendaID_NK       INT          NULL,                     
    EsGerente         BIT          NULL,

    EsActual          BIT          NOT NULL 
        CONSTRAINT DF_DimEmpleados_EsActual DEFAULT (1),

    FechaInicio       DATETIME     NOT NULL,
    FechaFin          DATETIME     NULL
);
GO

-- ==========================================
-- Dim_Productos (SCD Tipo 1)
-- ==========================================
CREATE TABLE Dim_Productos (
    ProductoKey       INT IDENTITY(1,1) PRIMARY KEY,
    ProductID_NK      INT          NOT NULL,             
    NombreProducto    VARCHAR(255) NOT NULL,             
    Marca             VARCHAR(255) NOT NULL,              
    Categoria         VARCHAR(255) NOT NULL,              
    ModeloAnio        SMALLINT     NULL,                  
    PrecioLista       DECIMAL(10,2) NULL,
    Color             VARCHAR(150)  NULL,
    Tamaño            VARCHAR(150)  NULL,
    EstadoProducto    VARCHAR(150)  NULL             
);
GO

-- ==========================================
-- Dim_Sucursales (Tiendas) - SCD Tipo 1
-- ==========================================
CREATE TABLE Dim_Sucursales (
    SucursalKey       INT IDENTITY(1,1) PRIMARY KEY,
    StoreID_NK        INT          NOT NULL,              
    NombreTienda      VARCHAR(255) NOT NULL,              
    Telefono          VARCHAR(25)  NULL,                  
    Email             VARCHAR(255) NULL,                  
    Calle             VARCHAR(255) NULL,                  
    Ciudad            VARCHAR(255) NULL,                  
    Estado            VARCHAR(10)  NULL,                  
    CodigoPostal      VARCHAR(5)   NULL,                 
    Pais              VARCHAR(100) NULL
);
GO

-- ==========================================
-- Dim_Ordenes - SCD Tipo 1
-- ==========================================
CREATE TABLE Dim_Ordenes (
    OrdenKey          INT IDENTITY(1,1) PRIMARY KEY, 
    OrderID_NK        INT          NOT NULL,              
    EstadoOrden       VARCHAR(50)  NULL,                  
    MetodoEnvio       VARCHAR(100) NULL,             
    Comentarios       VARCHAR(1000) NULL                 
);
GO

-- ==========================================
-- Dim_Inventario - SCD Tipo 1
-- ==========================================
CREATE TABLE Dim_Inventario (
    InventarioKey     INT IDENTITY(1,1) PRIMARY KEY,
    StoreID_NK        INT          NOT NULL, 
    ProductID_NK      INT          NOT NULL,   
    TipoInventario    VARCHAR(50)  NULL
);
GO

-- ==========================================
-- Fact_Ventas
-- ==========================================
CREATE TABLE Fact_Ventas (
    VentaKey              INT IDENTITY(1,1) PRIMARY KEY,

    -- Claves foráneas a dimensiones
    FechaOrdenKey         INT NOT NULL,   -- FK -> Dim_Fecha(FechaKey)
    FechaRequeridaKey     INT NULL,       -- FK -> Dim_Fecha(FechaKey)
    FechaEnvioKey         INT NULL,       -- FK -> Dim_Fecha(FechaKey)

    ClienteKey            INT NOT NULL,   -- FK -> Dim_Clientes
    EmpleadoKey           INT NOT NULL,   -- FK -> Dim_Empleados
    SucursalKey           INT NOT NULL,   -- FK -> Dim_Sucursales
    ProductoKey           INT NOT NULL,   -- FK -> Dim_Productos
    OrdenKey              INT NOT NULL,   -- FK -> Dim_Ordenes

    -- Métricas
    CantidadVendida       INT           NOT NULL,
    PrecioUnitario        DECIMAL(10,2) NOT NULL,
    DescuentoUnitario     DECIMAL(4,2)  NOT NULL, 

    MontoBrutoLinea       AS (CantidadVendida * PrecioUnitario) PERSISTED,
    MontoDescuentoLinea   AS (CantidadVendida * DescuentoUnitario) PERSISTED,
    MontoNetoLinea        AS ((CantidadVendida * PrecioUnitario) 
                              - (CantidadVendida * DescuentoUnitario)) PERSISTED,

    CantidadFacturas      INT NOT NULL DEFAULT 1
);
GO