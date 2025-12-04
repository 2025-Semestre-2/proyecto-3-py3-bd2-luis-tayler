-- ==========================================
-- CONSULTAS PARA PAQUETES DIM (DESDE STAGE)
-- Conexión: BikeStoresStage
-- ==========================================

-- Clientes (Dim_Clientes - SCD Tipo 2):
SELECT 
    customer_id AS ClienteID_NK,
    (first_name + ' ' + last_name) AS NombreCompleto,
    email AS Email,
    phone AS Telefono,
    city AS Ciudad,
    state AS Estado,
    zip_code AS CodigoPostal,
    'USA' AS Pais
FROM [dbo].[customers];

-- Empleados (Dim_Empleados - SCD Tipo 2):
SELECT 
    s.staff_id     AS StaffID_NK,
    (s.first_name + ' ' + s.last_name) AS NombreCompleto,
    s.email        AS Email,
    s.phone        AS Telefono,
    'Empleado'     AS Cargo,
    s.store_id     AS TiendaID_NK,
    CASE 
        WHEN s.manager_id IS NULL THEN 1  -- sin jefe = gerente
        ELSE 0                            -- tiene jefe = no gerente
    END          AS EsGerente
FROM [dbo].[staffs] AS s;

-- Productos (Dim_Productos - SCD Tipo 1):
SELECT 
    p.product_id        AS ProductID_NK,
    p.product_name      AS NombreProducto,
    b.brand_name        AS Marca,
    c.category_name     AS Categoria,
    p.model_year        AS ModeloAnio,
    p.list_price        AS PrecioLista,
    NULL                AS Color,        
    NULL                AS Tamaño,        
    NULL                AS EstadoProducto  
FROM [dbo].[products] AS p
INNER JOIN [dbo].[brands]     AS b ON p.brand_id    = b.brand_id
INNER JOIN [dbo].[categories] AS c ON p.category_id = c.category_id;

-- Sucursales/Tiendas (Dim_Sucursales - SCD Tipo 1):
SELECT 
    s.store_id     AS StoreID_NK,
    s.store_name   AS NombreTienda,
    s.phone        AS Telefono,
    s.email        AS Email,
    s.street       AS Calle,
    s.city         AS Ciudad,
    s.state        AS Estado,
    s.zip_code     AS CodigoPostal,
    'USA'          AS Pais      
FROM [dbo].[stores] AS s;

-- Órdenes (Dim_Ordenes - SCD Tipo 1):
SELECT 
    o.order_id AS OrderID_NK,
    CASE o.order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
        ELSE 'Unknown'
    END AS EstadoOrden,
    NULL AS MetodoEnvio,
    NULL AS Comentarios
FROM [dbo].[orders] AS o;

-- Inventario (Dim_Inventario - SCD Tipo 1):
SELECT
    st.store_id   AS StoreID_NK,
    st.product_id AS ProductID_NK,
    NULL          AS TipoInventario
FROM [dbo].[stocks] AS st;


-- ==========================================
-- CONSULTA PARA FACT_VENTAS (DESDE STAGE)
-- ==========================================

-- Fact Ventas:
SELECT
    oi.order_id        AS OrderID_NK,
    o.customer_id      AS ClienteID_NK,
    o.staff_id         AS StaffID_NK,
    o.store_id         AS StoreID_NK,
    oi.product_id      AS ProductID_NK,

    o.order_date       AS FechaOrden,
    o.required_date    AS FechaRequerida,
    o.shipped_date     AS FechaEnvio,

    oi.quantity        AS CantidadVendida,
    oi.list_price      AS PrecioUnitario,
    oi.discount        AS DescuentoUnitario
FROM [dbo].[order_items] AS oi
INNER JOIN [dbo].[orders] AS o
    ON oi.order_id = o.order_id;