# Proyecto 3 – Business Intelligence: BikeStores DW, Cubo OLAP y Reportes

## Integrantes
- **Luis Trejos – 2022437816**  
- **Tayler Wynta – 2024143103**

---

## Estado del proyecto
| Componente | Estado |
|-----------|--------|
| Data Warehouse (BikeStoresDW) | Completado |
| ETL con SSIS | Completado |
| Modelo Multidimensional (SSAS) | Completado |
| KPIs y Jerarquías | Completado |
| Perspectivas del Cubo | Completado |
| Reporte de Ventas (SSRS) | Completado |
| Reporte de Inventario (SSRS) | Completado |

---

## Arquitectura General

El proyecto implementa una solución completa de Business Intelligence siguiendo la arquitectura tradicional de Data Warehousing. El flujo de datos atraviesa cuatro capas principales:

1. **Base de Datos Origen (BikeStores - OLTP)**: Sistema transaccional normalizado con 9 tablas distribuidas en dos esquemas (production y sales).

2. **Staging Area (BikeStoresStage)**: Zona intermedia que actúa como buffer entre el sistema origen y el Data Warehouse. Se implementó para desacoplar los procesos de extracción y transformación, minimizando el impacto en el sistema transaccional y facilitando la recuperación ante fallos.

3. **Data Warehouse (BikeStoresDW - OLAP)**: Repositorio central diseñado con esquema estrella para optimizar consultas analíticas. Contiene datos históricos consolidados y desnormalizados.

4. **Capa de Presentación**: Compuesta por el cubo OLAP (SSAS) y reportes (SSRS) para análisis multidimensional y visualización de información.

## 1. Data Warehouse – BikeStoresDW

### Diseño del Modelo Dimensional

Se implementó un esquema estrella con 7 dimensiones y 1 tabla de hechos. Esta estructura se eligió sobre el esquema copo de nieve para reducir la cantidad de JOINs necesarios en las consultas, mejorando significativamente el rendimiento.

### Dimensiones:

- **Dim_Clientes**: Incluye información demográfica y de contacto. Implementa SCD Tipo 2 para mantener historial de cambios en datos como email, teléfono y ubicación. Los nombres se almacenan concatenados (first_name + last_name) para simplificar las consultas y reportes.

- **Dim_Productos**: Desnormalizada para incluir marca y categoría directamente, eliminando la necesidad de JOINs con tablas de referencia. Implementa SCD Tipo 1 ya que los cambios de precio no requieren historial.

- **Dim_Sucursales**: Contiene información de las tiendas. SCD Tipo 1 debido a que los cambios en datos de contacto o dirección son poco frecuentes y no requieren seguimiento histórico.

- **Dim_Empleados**: Implementa SCD Tipo 2 para rastrear cambios en asignación de tienda o cargo. Incluye un campo calculado EsGerente (basado en manager_id) para facilitar análisis de jerarquía organizacional.

- **Dim_Ordenes**: Almacena atributos descriptivos de las órdenes como estado y método de envío.

- **Dim_Fecha**: Dimensión de tiempo generada con datos precalculados (año, mes, trimestre, día de semana) que cubre el rango 2015-2030. Se utiliza FechaKey en formato entero (yyyyMMdd) para optimizar JOINs.

- **Dim_Inventario**: Relación entre productos y sucursales para análisis de stock.

### Tabla de hechos:

- **Fact_Ventas**: Granularidad a nivel de línea de orden (order_item). Contiene métricas aditivas como cantidad vendida y montos, además de columnas calculadas PERSISTED (MontoBrutoLinea, MontoDescuentoLinea, MontoNetoLinea) para evitar recalcular en cada consulta. Incluye tres claves de fecha (orden, requerida, envío) para permitir análisis temporal desde diferentes perspectivas.

### Decisiones de Diseño:

**Claves Surrogadas**: Se implementaron para independizar el DW del sistema origen y facilitar el manejo de SCD Tipo 2, donde un mismo registro del sistema transaccional puede tener múltiples versiones en el DW.

**SCD Tipo 2 selectivo**: Solo se aplicó a Clientes y Empleados, cumpliendo el requerimiento mínimo y evitando el crecimiento excesivo de las tablas. Los campos EsActual, FechaInicio y FechaFin permiten identificar el registro vigente y reconstruir el estado histórico.

**Desnormalización**: Las dimensiones de Productos incluyen marca y categoría directamente, sacrificando normalización por velocidad de consulta, lo cual es apropiado en entornos OLAP.

---

## 2. Staging Area y ETL con SSIS

### Propósito del Staging Area

El staging area (BikeStoresStage) se desarrolló como capa intermedia entre el sistema OLTP y el Data Warehouse por las siguientes razones técnicas:

1. **Desacoplamiento de procesos**: Permite separar la extracción (que debe ser rápida para no afectar el sistema transaccional) de la transformación (que puede ser intensiva en recursos).

2. **Recuperación ante fallos**: Si el proceso de transformación falla, los datos ya están extraídos en el stage y no es necesario volver a impactar el sistema origen.

3. **Ventana de procesamiento**: Facilita la ejecución de transformaciones complejas sin mantener conexiones prolongadas al sistema transaccional.

4. **Auditoría**: Proporciona un punto de validación donde se puede verificar qué datos se extrajeron antes de aplicar transformaciones.

### Características del Stage:

- Tablas sin constraints (Primary Keys, Foreign Keys) para maximizar velocidad de carga
- Estructura idéntica a las tablas origen para facilitar extracción 1:1
- Procesamiento Full Load (truncate y recarga completa en cada ejecución)
- Sin esquemas adicionales, todas las tablas en dbo para simplificar acceso

### Arquitectura ETL

El proceso ETL se divide en dos fases orquestadas:

**Fase 1 - Extracción (Secuencial)**:
Nueve paquetes SSIS que copian datos desde BikeStores hacia el staging area. Se ejecutan uno a uno de forma secuencial por legibilidad y simplicidad en el desarrollo. Aunque estas extracciones son independientes entre sí y podrían ejecutarse en paralelo, se optó por mantener una estructura secuencial consistente.

Paquetes: Ext_Brands, Ext_Categories, Ext_Products, Ext_Customers, Ext_Stores, Ext_Staffs, Ext_Orders, Ext_OrderItems, Ext_Stocks.

**Fase 2 - Transformación y Carga (Secuencial)**:
Ocho paquetes SSIS que cargan las dimensiones y hechos al DW. La ejecución secuencial es necesaria porque Fact_Ventas depende de todas las dimensiones (integridad referencial).

Orden de ejecución:

0. Limpieza de Fact_Ventas
1. ETL_Dim_Fecha (independiente, genera datos)
2. ETL_DimClientes (SCD2 con concatenación de nombres)
3. ETL_DimEmpleados (SCD2 con cálculo de EsGerente)
4. ETL_DimProductos (SCD1 con desnormalización)
5. ETL_DimSucursales (SCD1)
6. ETL_Dim_Ordenes (SCD1)
7. ETL_Dim_Inventario (SCD1)
8. ETL_Fact_Ventas (requiere todas las dimensiones, 7 lookups)

### Transformaciones Principales:

**Concatenación de Nombres**: Los campos first_name y last_name se combinan en un único campo NombreCompleto en las dimensiones de Clientes y Empleados, cumpliendo el requerimiento del proyecto y simplificando la presentación en reportes.

**Implementación de SCD Tipo 2**: Utiliza Lookup para detectar cambios en atributos, OLE DB Command para actualizar registros anteriores (EsActual=0, FechaFin=NOW), y Derived Column para establecer valores de control en nuevos registros.

**Conversión de Fechas**: Las fechas tipo DATE se convierten a enteros en formato yyyyMMdd para utilizarse como claves foráneas hacia Dim_Fecha.

**Lookups en Fact_Ventas**: Siete transformaciones Lookup convierten las claves naturales (IDs del sistema origen) en claves surrogadas del DW. Para dimensiones SCD2, se filtra por EsActual=1 para obtener la versión vigente.

### Orquestador

Un paquete maestro (Orquestador.dtsx) coordina la ejecución de las dos fases mediante Sequence Containers y Precedence Constraints. Si la Fase 1 falla, la Fase 2 no se ejecuta, previniendo inconsistencias en el DW.

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
