-- Crear la base de datos Stage
--CREATE DATABASE BikeStoresStage;
--GO

USE BikeStoresStage;
GO

/**
Comandos DROP para referencia (se ejecutan desde SSIS):

drop table if exists brands
drop table if exists categories
drop table if exists products
drop table if exists customers
drop table if exists stores
drop table if exists staffs
drop table if exists orders
drop table if exists order_items
drop table if exists stocks
*/

-- Tabla de marcas
CREATE TABLE [dbo].[brands](
	[brand_id] [int] NOT NULL,
	[brand_name] [varchar](255) NOT NULL
)

-- Tabla de categorías
CREATE TABLE [dbo].[categories](
	[category_id] [int] NOT NULL,
	[category_name] [varchar](255) NOT NULL
)

-- Tabla de productos
CREATE TABLE [dbo].[products](
	[product_id] [int] NOT NULL,
	[product_name] [varchar](255) NOT NULL,
	[brand_id] [int] NOT NULL,
	[category_id] [int] NOT NULL,
	[model_year] [smallint] NOT NULL,
	[list_price] [decimal](10, 2) NOT NULL
)

-- Tabla de clientes
CREATE TABLE [dbo].[customers](
	[customer_id] [int] NOT NULL,
	[first_name] [varchar](255) NOT NULL,
	[last_name] [varchar](255) NOT NULL,
	[phone] [varchar](25) NULL,
	[email] [varchar](255) NOT NULL,
	[street] [varchar](255) NULL,
	[city] [varchar](50) NULL,
	[state] [varchar](25) NULL,
	[zip_code] [varchar](5) NULL
)

-- Tabla de tiendas
CREATE TABLE [dbo].[stores](
	[store_id] [int] NOT NULL,
	[store_name] [varchar](255) NOT NULL,
	[phone] [varchar](25) NULL,
	[email] [varchar](255) NULL,
	[street] [varchar](255) NULL,
	[city] [varchar](255) NULL,
	[state] [varchar](10) NULL,
	[zip_code] [varchar](5) NULL
)

-- Tabla de empleados (staff)
CREATE TABLE [dbo].[staffs](
	[staff_id] [int] NOT NULL,
	[first_name] [varchar](50) NOT NULL,
	[last_name] [varchar](50) NOT NULL,
	[email] [varchar](255) NOT NULL,
	[phone] [varchar](25) NULL,
	[active] [tinyint] NOT NULL,
	[store_id] [int] NOT NULL,
	[manager_id] [int] NULL
)

-- Tabla de órdenes
CREATE TABLE [dbo].[orders](
	[order_id] [int] NOT NULL,
	[customer_id] [int] NULL,
	[order_status] [tinyint] NOT NULL,
	[order_date] [date] NOT NULL,
	[required_date] [date] NOT NULL,
	[shipped_date] [date] NULL,
	[store_id] [int] NOT NULL,
	[staff_id] [int] NOT NULL
)

-- Tabla de detalles de orden (order items)
CREATE TABLE [dbo].[order_items](
	[order_id] [int] NOT NULL,
	[item_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[list_price] [decimal](10, 2) NOT NULL,
	[discount] [decimal](4, 2) NOT NULL
)

-- Tabla de inventario (stocks)
CREATE TABLE [dbo].[stocks](
	[store_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[quantity] [int] NULL
)
