# Proyecto 3 – Business Intelligence: BikeStores DW, Cubo OLAP y Reportes

## Integrantes
- **Luis Trejos – 2022437816**  
- **Tayler Wynta – 2024143103**

---

## Estado del proyecto
| Componente | Estado |
|-----------|--------|
| Data Warehouse (BikeStoresDW) | ✔ Completado |
| ETL con SSIS | ✔ Completado |
| Modelo Multidimensional (SSAS) | ✔ Completado |
| KPIs y Jerarquías | ✔ Completado |
| Perspectivas del Cubo | ✔ Completado |
| Reporte de Ventas (SSRS) | ✔ Completado |
| Reporte de Inventario (SSRS) | ✔ Completado |

---

## 1. Data Warehouse – BikeStoresDW
Estructura en estrella con:

### Dimensiones:
- Dim_Clientes  
- Dim_Productos  
- Dim_Sucursales  
- Dim_Empleados  
- Dim_Ordenes  
- Dim_Fecha (Orden, Requerida, Envío)

### Tabla de hechos:
- **Fact_Ventas**

Incluye:
- Surrogate keys  
- Manejo de SCD  
- Formato estándar de fechas

---

## 2. ETL con SSIS
Paquetes desarrollados para:
- Carga de dimensiones  
- Carga de hechos  
- Lookups de fechas (Orden, Requerida, Envío)  
- Transformaciones y validaciones  
- Manejo de errores  
- Procesamiento incremental

---

## 3. Cubo OLAP – SSAS
Cubo: **BikeStores_CuboVentas**

### Measure Group:
- Fact Ventas

### Medidas (Measures):
- Cantidad Vendida  
- Cantidad Facturas  
- Monto Bruto Línea  
- Monto Neto Línea  
- Descuento Unitario  
- Precio Unitario  

### KPIs:
- Monto Total  
- Margen Neto  
- Cantidad de Facturas  

### Jerarquías:
- Calendario → Año > Trimestre > Mes > Día  
- Producto → Categoría > Producto  
- Cliente → Ubicación  

### Acciones:
- Drillthrough de detalle de ventas

### Perspectivas:
- **Ventas**  
- **Gerencia**

---

## 4. Reportes SSRS

### ✔ Reporte de Ventas (consulta al DW)
Muestra:
- Total vendido  
- Cantidad vendida por producto  
- Agrupado por categoría  
- Subtotales y total general  

Filtros:
- Cliente  
- Marca  
- Rango de fechas  

### ✔ Reporte de Inventario (consulta al BikeStores original)
Muestra:
- Total de inventario por producto  
- Marca y sucursal  

Filtros:
- Sucursal  
- Categoría  
- Marca  

Incluye subtotales y enumeración por marca.

TEC II SEMESTRE 2025 BASES DE DATOS II 
CRISTIAN CAMPOS AGUERO
