USE BikeStoresDW;
GO

ALTER TABLE Fact_Ventas
ADD CONSTRAINT FK_FactVentas_DimFechaOrden
    FOREIGN KEY (FechaOrdenKey) REFERENCES Dim_Fecha(FechaKey);

ALTER TABLE Fact_Ventas
ADD CONSTRAINT FK_FactVentas_DimFechaReq
    FOREIGN KEY (FechaRequeridaKey) REFERENCES Dim_Fecha(FechaKey);

ALTER TABLE Fact_Ventas
ADD CONSTRAINT FK_FactVentas_DimFechaEnv
    FOREIGN KEY (FechaEnvioKey) REFERENCES Dim_Fecha(FechaKey);

ALTER TABLE Fact_Ventas
ADD CONSTRAINT FK_FactVentas_DimClientes
    FOREIGN KEY (ClienteKey) REFERENCES Dim_Clientes(ClienteKey);

ALTER TABLE Fact_Ventas
ADD CONSTRAINT FK_FactVentas_DimEmpleados
    FOREIGN KEY (EmpleadoKey) REFERENCES Dim_Empleados(EmpleadoKey);

ALTER TABLE Fact_Ventas
ADD CONSTRAINT FK_FactVentas_DimSucursales
    FOREIGN KEY (SucursalKey) REFERENCES Dim_Sucursales(SucursalKey);

ALTER TABLE Fact_Ventas
ADD CONSTRAINT FK_FactVentas_DimProductos
    FOREIGN KEY (ProductoKey) REFERENCES Dim_Productos(ProductoKey);

ALTER TABLE Fact_Ventas
ADD CONSTRAINT FK_FactVentas_DimOrdenes
    FOREIGN KEY (OrdenKey) REFERENCES Dim_Ordenes(OrdenKey);
GO
