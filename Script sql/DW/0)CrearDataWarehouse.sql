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
    FechaKey          INT         NOT NULL PRIMARY KEY, -- formato yyyymmdd
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
    NombreCompleto    VARCHAR(520) NOT NULL,  -- Aumentado para first_name (255) + last_name (255) + espacio
    Email             VARCHAR(255) NULL,       -- Coincide con origen
    Telefono          VARCHAR(25)  NULL,       -- Ajustado a origen (25)
    Ciudad            VARCHAR(50)  NULL,       -- Ajustado a origen (50)
    Estado            VARCHAR(25)  NULL,       -- Ajustado a origen (25)
    CodigoPostal      VARCHAR(5)   NULL,       -- Ajustado a origen (5)
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
    StaffID_NK        INT          NOT NULL,              -- Natural Key (staff_id)
    NombreCompleto    VARCHAR(110) NOT NULL,              -- Ajustado: first_name (50) + last_name (50) + espacio
    Email             VARCHAR(255) NULL,                  -- Coincide con origen
    Telefono          VARCHAR(25)  NULL,                  -- Ajustado a origen (25)
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
    ProductID_NK      INT          NOT NULL,              -- product_id original
    NombreProducto    VARCHAR(255) NOT NULL,              -- Coincide con origen
    Marca             VARCHAR(255) NOT NULL,              -- Coincide con origen (brand_name)
    Categoria         VARCHAR(255) NOT NULL,              -- Coincide con origen (category_name)
    ModeloAnio        SMALLINT     NULL,                  -- Cambiado a SMALLINT como en origen
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
    StoreID_NK        INT          NOT NULL,              -- store_id original
    NombreTienda      VARCHAR(255) NOT NULL,              -- Coincide con origen
    Telefono          VARCHAR(25)  NULL,                  -- Ajustado a origen (25)
    Email             VARCHAR(255) NULL,                  -- Coincide con origen
    Calle             VARCHAR(255) NULL,                  -- Coincide con origen
    Ciudad            VARCHAR(255) NULL,                  -- Ajustado a origen (255)
    Estado            VARCHAR(10)  NULL,                  -- Ajustado a origen (10)
    CodigoPostal      VARCHAR(5)   NULL,                  -- Ajustado a origen (5)
    Pais              VARCHAR(100) NULL
);
GO

-- ==========================================
-- Dim_Ordenes - SCD Tipo 1
-- ==========================================
CREATE TABLE Dim_Ordenes (
    OrdenKey          INT IDENTITY(1,1) PRIMARY KEY, 
    OrderID_NK        INT          NOT NULL,              -- order_id original
    EstadoOrden       VARCHAR(50)  NULL,                  -- status
    MetodoEnvio       VARCHAR(100) NULL,             
    Comentarios       VARCHAR(1000) NULL                  -- Aumentado para comentarios largos
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
    DescuentoUnitario     DECIMAL(4,2)  NOT NULL,  -- Ajustado a DECIMAL(4,2) como en origen

    MontoBrutoLinea       AS (CantidadVendida * PrecioUnitario) PERSISTED,
    MontoDescuentoLinea   AS (CantidadVendida * DescuentoUnitario) PERSISTED,
    MontoNetoLinea        AS ((CantidadVendida * PrecioUnitario) 
                              - (CantidadVendida * DescuentoUnitario)) PERSISTED,

    CantidadFacturas      INT NOT NULL DEFAULT 1
);
GO