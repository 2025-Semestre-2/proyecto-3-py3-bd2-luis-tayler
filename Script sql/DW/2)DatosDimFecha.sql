USE BikeStoresDW;
GO

-- Borrar contenido previo si existe
DELETE FROM Dim_Fecha;
GO

;WITH CTE AS (
    SELECT CAST('2015-01-01' AS DATE) AS Fecha
    UNION ALL
    SELECT DATEADD(DAY, 1, Fecha)
    FROM CTE
    WHERE Fecha < '2030-12-31'
)
INSERT INTO Dim_Fecha (
    FechaKey,
    FechaCompleta,
    Anio,
    Mes,
    Dia,
    NombreMes,
    NombreDiaSemana,
    Trimestre,
    EsFinDeSemana
)
SELECT 
    CONVERT(INT, FORMAT(Fecha, 'yyyyMMdd')),
    Fecha,
    YEAR(Fecha),
    MONTH(Fecha),
    DAY(Fecha),
    DATENAME(MONTH, Fecha),
    DATENAME(WEEKDAY, Fecha),
    DATEPART(QUARTER, Fecha),
    CASE WHEN DATENAME(WEEKDAY, Fecha) IN ('Saturday','Sunday') THEN 1 ELSE 0 END
FROM CTE
OPTION (MAXRECURSION 0);
GO
