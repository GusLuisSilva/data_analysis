
--1 Part: Creating a database, schema, and tables for data analysis

-- 1. Create database
CREATE DATABASE cap17_analise_de_dados;
GO

-- 2. Acess the database
USE cap17_analise_de_dados;
GO

-- 3. Create schema within the database
CREATE SCHEMA cap17_analise_de_dados AUTHORIZATION dbo;
GO


-- Client Table
CREATE TABLE cap17_analise_de_dados.clientes (
    Id_Cliente uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    nome VARCHAR(255),
    email VARCHAR(255)
);
GO

-- Product Table
CREATE TABLE cap17_analise_de_dados.produtos (
    Id_Produto uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    nome VARCHAR(255),
    preco DECIMAL(18,2)
);
GO

-- Sales Table
CREATE TABLE cap17_analise_de_dados.vendas (
    Id_Vendas uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    Id_Cliente uniqueidentifier FOREIGN KEY REFERENCES cap17_analise_de_dados.clientes(Id_Cliente),
    Id_Produto uniqueidentifier FOREIGN KEY REFERENCES cap17_analise_de_dados.produtos(Id_Produto),
    Quantidade INT,
    Data_Venda DATE
);
GO

--An error occurred during the direct CSV import into cap17_analise_de_dados.clientes because the Id_Cliente column is of type uniqueidentifier.
--Even after changing the Id_Cliente data type to DT_GUID in SSMS, SSMS was unable to convert the data during the read operation.
--Therefore, the table dbo.clientes was imported from the CSV as an intermediary step, followed by a SELECT INTO statement to populate the cap17_analise_de_dados.clientes table,
--setting the Id_Cliente data type to uniqueidentifier.

-- Check the data in the dbo.clientes table
select * from dbo.clientes

-- Insert data into cap17_analise_de_dados.clientes from dbo.clientes
INSERT INTO cap17_analise_de_dados.clientes (Id_Cliente, nome, email)
SELECT CAST(Id_Cliente AS uniqueidentifier), nome, email
FROM dbo.clientes

-- Check the data in the cap17_analise_de_dados.clientes table
select * from cap17_analise_de_dados.clientes


--Import via the BULK INSERT method; there were no errors.
BULK INSERT cap17_analise_de_dados.produtos
FROM 'C:\Users\guslu\OneDrive\Documentos\cursos\data science academy\sql\Cap17-analise_de_dados\produtos.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2, -- pula o cabe�alho
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n'
);

-- check the data in the cap17_analise_de_dados.produtos table
select * from cap17_analise_de_dados.produtos

--Import cap17_analise_de_dados.vendas via the BULK INSERT method;
BULK INSERT cap17_analise_de_dados.vendas
FROM 'C:\Users\guslu\OneDrive\Documentos\cursos\data science academy\sql\Cap17-analise_de_dados\vendas.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2, -- pula o cabe�alho
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n'
);

-- Check the data in the cap17_analise_de_dados.vendas table
select * from cap17_analise_de_dados.vendas

--summary from main tables
select top 5 * from cap17_analise_de_dados.clientes

select top 5 * from cap17_analise_de_dados.produtos

select top 5 * from cap17_analise_de_dados.vendas


--As you want, turn on the performance statistics for the queries below.
-- Turn on statistics for query performance analysis
SET STATISTICS PROFILE ON;
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- Turn off statistics for query performance analysis
SET STATISTICS PROFILE OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


--2 Part: Data analysis questions

--1. What is the total number of sales and the average quantity sold?
select 
	 count(*) as 'Total de Venda'
	,cast(avg(Quantidade) as decimal(10,2)) as 'M�dia Vendas'
from cap17_analise_de_dados.vendas 

select 
	  Year(Data_Venda) as Ano
	 ,Month(Data_Venda) as M�s
	 ,sum(Quantidade) * sum(preco) as Faturamento
from cap17_analise_de_dados.vendas as v
inner join cap17_analise_de_dados.produtos as p
on v.ID_Produto = p.ID_Produto
group by Year(Data_Venda), Month(Data_Venda)
order by Year(Data_Venda), Month(Data_Venda)


--2. What is the total number of unique products sold?
select
	Count(Distinct(ID_Produto)) as 'Total de Produtos �nicos'
from cap17_analise_de_dados.vendas


--3. How many sales occurred per product? Show the result in descending order.
select
	 p.nome
	,count(*) as Vendas
from cap17_analise_de_dados.vendas as v
inner join cap17_analise_de_dados.produtos as p
on v.ID_Produto = p.ID_Produto
group by p.nome
order by Vendas desc


--4. What are the 5 products with the highest sales volume?
select top 5
	 p.nome
	,count(*) as Vendas
from cap17_analise_de_dados.vendas as v
inner join cap17_analise_de_dados.produtos as p
on v.ID_Produto = p.ID_Produto
group by p.nome
order by Vendas desc


--5. What are the customers who made 6 or more purchases?
select 
	 c.nome
	,count(v.Data_Venda) as Transacoes
from cap17_analise_de_dados.vendas as v
inner join cap17_analise_de_dados.clientes as c
on v.ID_Cliente = c.ID_Cliente
group by c.nome
having count(distinct(Data_Venda)) > 5


--6. What is the total number of commercial transactions per month in the year 2024? Present the month names in the result, which should be ordered by month.
select 
	  DATENAME(Month,Data_Venda) as Mes
	 ,count(*) as Transacoes
from cap17_analise_de_dados.vendas
where DATENAME(YEAR,Data_Venda) = 2024
group by DATENAME(Month,Data_Venda), Month(Data_Venda)
order by Month(Data_Venda)


--7. How many sales of notebooks occurred in June and July of 2023?
select 
	  DATENAME(Month,Data_Venda) as Mes
	 ,sum(Quantidade) as Vendas
from cap17_analise_de_dados.vendas as v
inner join cap17_analise_de_dados.produtos as p
on v.Id_Produto = p.Id_Produto
where DATENAME(YEAR,Data_Venda) = 2023 and DATENAME(Month,Data_Venda) IN ('Junho','Julho') and p.nome = 'Notebook'
group by DATENAME(Month,Data_Venda), Month(Data_Venda)
order by Month(Data_Venda)


--8. What is the total sales volume by month and by year over time?
select 
	  DATENAME(Year,Data_Venda) as Ano
	 ,DATENAME(Month,Data_Venda) as Mes
	 ,sum(Quantidade) as Vendas
	 ,sum(sum(Quantidade)) over (partition by Year(Data_Venda) order by Month(Data_Venda)) as Vendas_YtD
	 ,cast(sum(Quantidade) * 1.0 / sum(sum(Quantidade)) over (partition by Year(Data_Venda)) * 100 as decimal(10,2)) as Percentual
	 ,cast(sum(sum(Quantidade)) over (partition by Year(Data_Venda) order by Month(Data_Venda)) * 1.0 / 
	 sum(sum(Quantidade)) over (partition by Year(Data_Venda)) * 100 as decimal(10,2)) as Percentual_Acumulado
	 ,max(Quantidade) as Maior_Venda
	 ,min(Quantidade) as Menor_Venda
	 ,avg(Quantidade) as M�dia_Venda
	 ,cast(stdev(Quantidade) as decimal(10,2)) as Desvio_Venda
from cap17_analise_de_dados.vendas
group by DATENAME(Year,Data_Venda), DATENAME(Month,Data_Venda), Year(Data_Venda), Month(Data_Venda)
order by Year(Data_Venda), Month(Data_Venda)


--9. Which products had fewer than 100 sales transactions?
select 
	 p.nome
	,count(Data_Venda) as Transacoes
from cap17_analise_de_dados.vendas as v
inner join cap17_analise_de_dados.produtos as p
on v.ID_Produto = p.ID_Produto
group by p.nome
having count(distinct(Data_Venda)) < 100


--10. What are the customers who bought both a smartphone and a smartwatch?
--1 query
select 
	 c.nome
from cap17_analise_de_dados.clientes as c
	inner join cap17_analise_de_dados.vendas as v
on c.Id_Cliente = v.Id_Cliente
	inner join cap17_analise_de_dados.produtos as p
on v.ID_Produto = p.ID_Produto
where p.nome IN ('Smartphone' ,'Smartwatch' )
group by c.nome
having count(distinct(p.nome)) = 2

--2 query
WITH compradores_smartphone AS (
    SELECT v.Id_Cliente
    FROM cap17_analise_de_dados.vendas v
    JOIN cap17_analise_de_dados.produtos p ON v.Id_Produto = p.Id_Produto
    WHERE p.Nome = 'Smartphone'
    GROUP BY v.Id_Cliente
),
compradores_smartwatch AS (
    SELECT v.Id_Cliente
    FROM cap17_analise_de_dados.vendas v
    JOIN cap17_analise_de_dados.produtos p ON v.Id_Produto = p.Id_Produto
    WHERE p.Nome = 'Smartwatch'
    GROUP BY v.Id_Cliente
)
SELECT c.Nome
FROM cap17_analise_de_dados.clientes c
WHERE c.Id_Cliente IN (
    SELECT Id_Cliente FROM compradores_smartphone
    INTERSECT
    SELECT Id_Cliente FROM compradores_smartwatch
)
ORDER BY c.Nome;

--3 query
select 
	 c.nome
from cap17_analise_de_dados.clientes as c
	inner join cap17_analise_de_dados.vendas as v
on c.Id_Cliente = v.Id_Cliente
	inner join cap17_analise_de_dados.produtos as p
on v.ID_Produto = p.ID_Produto
group by c.nome
having 
	SUM(CASE WHEN p.Nome = 'Smartphone' THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN p.Nome = 'Smartwatch' THEN 1 ELSE 0 END) > 0


--11. Which customers bought a smartphone and a smartwatch, but did not buy a notebook?
--1 query
select 
	 c.nome
from cap17_analise_de_dados.clientes as c
	inner join cap17_analise_de_dados.vendas as v
on c.Id_Cliente = v.Id_Cliente
	inner join cap17_analise_de_dados.produtos as p
on v.ID_Produto = p.ID_Produto
group by c.nome
having 
	SUM(CASE WHEN p.Nome = 'Smartphone' THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN p.Nome = 'Smartwatch' THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN p.Nome = 'Notebook' THEN 1 ELSE 0 END) = 0
ORDER BY c.Nome;

--2 query
WITH clientes_smartphone AS (
    SELECT v.Id_Cliente
    FROM cap17_analise_de_dados.vendas v
    JOIN cap17_analise_de_dados.produtos p ON v.Id_Produto = p.Id_Produto
    WHERE p.Nome = 'Smartphone'
),
clientes_smartwatch AS (
    SELECT v.Id_Cliente
    FROM cap17_analise_de_dados.vendas v
    JOIN cap17_analise_de_dados.produtos p ON v.Id_Produto = p.Id_Produto
    WHERE p.Nome = 'Smartwatch'
),
clientes_notebook AS (
    SELECT v.Id_Cliente
    FROM cap17_analise_de_dados.vendas v
    JOIN cap17_analise_de_dados.produtos p ON v.Id_Produto = p.Id_Produto
    WHERE p.Nome = 'Notebook'
)
SELECT c.Nome
FROM cap17_analise_de_dados.clientes c
WHERE c.Id_Cliente IN (
    SELECT Id_Cliente FROM clientes_smartphone
    INTERSECT
    SELECT Id_Cliente FROM clientes_smartwatch
)
AND c.Id_Cliente NOT IN (
    SELECT Id_Cliente FROM clientes_notebook
)
ORDER BY c.Nome;


--12. Which customers bought a smartphone and a smartwatch, but did not buy a laptop in May 2024?
--1 query
select 
	 c.nome
from cap17_analise_de_dados.clientes as c
	inner join cap17_analise_de_dados.vendas as v
on c.Id_Cliente = v.Id_Cliente
	inner join cap17_analise_de_dados.produtos as p
on v.ID_Produto = p.ID_Produto
where Year(v.Data_Venda) = 2024 
	and Month(v.Data_Venda) = 5
group by c.nome
having 
	SUM(CASE WHEN p.Nome = 'Smartphone' THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN p.Nome = 'Smartwatch' THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN p.Nome = 'Notebook' THEN 1 ELSE 0 END) = 0;

--2 query
WITH clientes_smartphone AS (
    SELECT v.Id_Cliente
    FROM cap17_analise_de_dados.vendas v
    JOIN cap17_analise_de_dados.produtos p ON v.Id_Produto = p.Id_Produto
    WHERE p.Nome = 'Smartphone'
	and Year(v.Data_Venda) = 2024 
	and Month(v.Data_Venda) = 5
),
clientes_smartwatch AS (
    SELECT v.Id_Cliente
    FROM cap17_analise_de_dados.vendas v
    JOIN cap17_analise_de_dados.produtos p ON v.Id_Produto = p.Id_Produto
    WHERE p.Nome = 'Smartwatch'
	and Year(v.Data_Venda) = 2024 
	and Month(v.Data_Venda) = 5
),
clientes_notebook AS (
    SELECT v.Id_Cliente
    FROM cap17_analise_de_dados.vendas v
    JOIN cap17_analise_de_dados.produtos p ON v.Id_Produto = p.Id_Produto
    WHERE p.Nome = 'Notebook'
	and Year(v.Data_Venda) = 2024 
	and Month(v.Data_Venda) = 5
)
SELECT c.Nome
FROM cap17_analise_de_dados.clientes c
WHERE c.Id_Cliente IN (
    SELECT Id_Cliente FROM clientes_smartphone
    INTERSECT
    SELECT Id_Cliente FROM clientes_smartwatch
)
AND c.Id_Cliente NOT IN (
    SELECT Id_Cliente FROM clientes_notebook
)
ORDER BY c.Nome;


--13.  What is the moving average of the quantity of units sold over time? Consider a 7-day window.
select 
	 Data_Venda
	 ,sum(Quantidade) as Total_Vendas
	 ,avg(Quantidade) over (order by Data_Venda 
							rows between 3 preceding and 3 following) as Media_Movel_Vendas
from cap17_analise_de_dados.vendas
group by Data_Venda, Quantidade


--14. What is the moving average and standard deviation of the quantity of units sold over time? Consider a 7-day window.
select 
	 Data_Venda
	 ,sum(Quantidade) as Total_Vendas
	 ,avg(Quantidade) over (order by Data_Venda rows between 3 preceding and 3 following) as Media_Movel_Vendas
	 ,coalesce(cast(stdev(Quantidade) over (order by Data_Venda rows between 3 preceding and 3 following) as decimal(10,0)),0) as Desvio_Movel_Vendas
from cap17_analise_de_dados.vendas
group by Data_Venda, Quantidade


--15. What are the customers who are registered but have not made any transactions?
select	c.nome
from cap17_analise_de_dados.clientes as c
left join cap17_analise_de_dados.vendas as v
on c.Id_Cliente = v.Id_Cliente
where v.Data_Venda is null


--Extra Task
--Identifying outliers with a boxplot

WITH Estatisticas AS (
    SELECT
         Data_Venda
		,sum(Quantidade) as Vendas
        ,PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Quantidade) OVER (PARTITION BY Data_Venda) AS q1 
        ,PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Quantidade) OVER (PARTITION BY Data_Venda) AS q3
    FROM
        cap17_analise_de_dados.vendas
    GROUP BY Data_Venda, Quantidade
),
LimitesOutliers AS (
	SELECT
		 Data_Venda
		,Vendas
		,q1
		,q3
		,q1 - 0.5 * (q3 - q1) AS limite_inferior
        ,q3 + 0.5 * (q3 - q1) AS limite_superior
	 FROM Estatisticas
)
	 SELECT
		 L.Data_Venda
		,L.Quantidade
	 FROM cap17_analise_de_dados.vendas AS L
		INNER JOIN LimitesOutliers AS E
	 ON 
		L.Data_Venda = E.Data_Venda 
	 WHERE
		L.Quantidade < E.limite_inferior OR L.Quantidade > E.limite_superior
	 

-- Temporary product table
CREATE TABLE cap17_analise_de_dados.produtos_temp (
    nome VARCHAR(255),
    preco DECIMAL(18,2)
);
GO

-- insert records from the original table
INSERT INTO cap17_analise_de_dados.produtos_temp (nome, preco)
SELECT nome, preco
FROM cap17_analise_de_dados.produtos


--Identifying outliers with standard deviation

--Add outlier column
alter table cap17_analise_de_dados.produtos_temp
ADD tem_outlier BIT DEFAULT 0 NOT NULL;

--check the data in the temp table
select * from cap17_analise_de_dados.produtos_temp

--record outliers in the dataset
WITH Estatisticas AS (
    SELECT
         nome
		,sum(preco) as preco
        ,PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY preco) OVER (PARTITION BY nome) AS q1 
        ,PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY preco) OVER (PARTITION BY nome) AS q3
    FROM
        cap17_analise_de_dados.produtos_temp
    GROUP BY nome, preco
),
LimitesOutliers AS (
	SELECT
		 nome
		,preco
		,q1
		,q3
		,q1 - 0.5 * (q3 - q1) AS limite_inferior
        ,q3 + 0.5 * (q3 - q1) AS limite_superior
	 FROM Estatisticas
)
	 UPDATE cap17_analise_de_dados.produtos_temp
	 SET tem_outlier = 1
	 FROM cap17_analise_de_dados.produtos_temp AS L
		INNER JOIN LimitesOutliers AS E
	 ON 
		L.nome = E.nome 
	 WHERE
		L.preco < E.limite_inferior OR L.preco > E.limite_superior


--final temp base
SELECT * FROM cap17_analise_de_dados.produtos_temp
--where nome = 'Smartphone'
order by preco


--Adds an outlier column for the standard deviation.
ALTER TABLE cap17_analise_de_dados.produtos_temp
ADD tem_outlier_1 BIT DEFAULT 0 NOT NULL;

--insert records outside the standard deviation
WITH Estatisticas AS (
    SELECT
        AVG(preco) AS avg_preco,
        STDEV(preco) AS stdev_preco
    FROM
        cap17_analise_de_dados.produtos_temp
)
UPDATE cap17_analise_de_dados.produtos_temp
SET tem_outlier_1 = 1
FROM Estatisticas
WHERE
    preco < (avg_preco - 1.5 * stdev_preco) OR 
    preco > (avg_preco + 1.5 * stdev_preco) 

--final temp base
SELECT * FROM cap17_analise_de_dados.produtos_temp
order by preco


--3 Part: Drop database, schema and table
DROP TABLE IF EXISTS cap17_analise_de_dados
drop schema cap17_analise_de_dados
drop database cap17_analise_de_dados
