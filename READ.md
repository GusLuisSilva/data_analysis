# Advanced T-SQL Analytics Project: Data Analysis Hands-On

A comprehensive SQL Server project demonstrating enterprise-level data engineering, advanced query optimization, and analytical techniques for real-world business intelligence scenarios.

## 🎯 Project Overview

This hands-on project showcases a complete data analytics workflow using T-SQL, from database design and data import to complex analytical queries. The project covers customer sales analysis, product performance metrics, trend analysis, and advanced statistical techniques for outlier detection.

**Key Focus Areas:**
- Database architecture and schema design
- ETL processes using BULK INSERT
- Advanced SQL query optimization
- Window functions and CTEs for analytics
- Outlier detection methods
- Performance analysis and tuning

---

## 📊 Database Structure
*Database is in Portuguese*

### Schema: `cap17_analise_de_dados`

**Tables:**

1. **clientes** (Customers)
   - `Id_Cliente` (GUID Primary Key)
   - `nome` (Customer Name)
   - `email` (Email Address)

2. **produtos** (Products)
   - `Id_Produto` (GUID Primary Key)
   - `nome` (Product Name)
   - `preco` (Price - Decimal 18,2)

3. **vendas** (Sales Transactions)
   - `Id_Vendas` (GUID Primary Key)
   - `Id_Cliente` (Foreign Key)
   - `Id_Produto` (Foreign Key)
   - `Quantidade` (Quantity Sold)
   - `Data_Venda` (Transaction Date)

---

## 🔧 Technical Highlights

### 1. **Data Import Strategy**
- Direct CSV import handling for GUID data types
- BULK INSERT implementation for large datasets
- Data type conversion and validation

### 2. **Window Functions & Analytics**
```sql
-- Moving average with 7-day window
SELECT 
    Data_Venda,
    SUM(Quantidade) as Total_Vendas,
    AVG(Quantidade) OVER (
        ORDER BY Data_Venda 
        ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
    ) as Moving_Average
FROM cap17_analise_de_dados.vendas
```

### 3. **Common Table Expressions (CTEs)**
- Multi-step analytical queries
- Improved readability and maintainability
- Efficient customer segmentation and filtering

### 4. **Complex Joins & Subqueries**
- Inner and left joins for data correlation
- Conditional aggregation with CASE statements
- Set operations (INTERSECT) for customer analysis

### 5. **Advanced Analytics**
- **YTD Calculations**: Year-to-date sales tracking
- **Cumulative Percentages**: Sales contribution analysis
- **Moving Statistics**: 7-day moving average and standard deviation
- **Outlier Detection**: IQR (Interquartile Range) and Z-score methods

---

## 📈 Key Analytical Queries

### Sales Performance
- Total sales volume and average quantity sold
- Monthly revenue and transaction counts
- Product-specific sales analysis
- Top-performing products ranking

### Customer Insights
- High-value customer identification (6+ purchases)
- Customer segmentation by purchase patterns
- Inactive customer detection (registered but no purchases)
- Cross-product purchase analysis

### Advanced Analytics
```sql
-- YTD Sales with Moving Average
SELECT 
    YEAR(Data_Venda) as Ano,
    MONTH(Data_Venda) as Mes,
    SUM(Quantidade) as Monthly_Sales,
    SUM(SUM(Quantidade)) OVER (
        PARTITION BY YEAR(Data_Venda) 
        ORDER BY MONTH(Data_Venda)
    ) as YTD_Sales,
    AVG(Quantidade) OVER (
        ORDER BY Data_Venda 
        ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
    ) as Moving_Average
FROM cap17_analise_de_dados.vendas
GROUP BY YEAR(Data_Venda), MONTH(Data_Venda), Data_Venda
```

---

## 🎯 Outlier Detection Methods

### Method 1: Interquartile Range (IQR)
Uses the boxplot approach with Q1, Q3, and 1.5× IQR margins to identify statistical outliers.

### Method 2: Standard Deviation (Z-Score)
Identifies values beyond 1.5 standard deviations from the mean—ideal for normally distributed data.

---

## 🚀 Performance Optimization

The project demonstrates SQL Server performance analysis using:
- `SET STATISTICS PROFILE ON` - Query execution plan analysis
- `SET STATISTICS TIME ON` - Execution timing metrics
- `SET STATISTICS IO ON` - Disk I/O analysis
- Proper indexing with Primary Keys and Foreign Keys

---

## 📋 Query Categories

1. **Descriptive Analytics** - Summary statistics and aggregations
2. **Trend Analysis** - Time-series moving averages and YTD metrics
3. **Customer Analytics** - Segmentation and behavior patterns
4. **Comparative Analysis** - Product rankings and cross-product purchases
5. **Statistical Analysis** - Outlier detection and distribution analysis

---

## 🛠️ How to Use

### Prerequisites
- SQL Server 2016 or later
- Sample CSV files for bulk import
  - `clientes.csv`
  - `produtos.csv`
  - `vendas.csv`

### Setup
1. Create the database:
   ```sql
   CREATE DATABASE cap17_analise_de_dados
   GO
   ```

2. Execute the schema and table creation scripts

3. Import data using BULK INSERT (update file paths in the script)

4. Run analytical queries to generate insights

### Query Execution
- Enable statistics for performance monitoring
- Modify date ranges and filters as needed for different analyses
- Adjust BULK INSERT paths to match your environment

---

## 📊 Business Applications

This project demonstrates real-world applications for:

- **Revenue Analytics**: Monthly trends, YTD performance, forecast planning
- **Customer Lifetime Value**: Purchase frequency, product preferences, segmentation
- **Inventory Management**: Product performance, demand forecasting
- **Marketing Intelligence**: Customer clustering, campaign targeting
- **Quality Assurance**: Outlier detection in pricing and inventory data

---

## 🎓 Learning Outcomes

By exploring this project, you'll understand:

✅ T-SQL advanced query techniques  
✅ Window functions for time-series analysis  
✅ CTEs for complex data transformations  
✅ Performance optimization strategies  
✅ Statistical methods in SQL  
✅ Real-world data analytics workflows  

---

## 📝 Notes

- All data types use appropriate precision (e.g., `DECIMAL(18,2)` for prices)
- GUIDs provide database-agnostic primary keys
- Foreign keys ensure referential integrity
- Queries are optimized for readability and performance

---

## 📞 Contact & Contribution

This project is designed as a hands-on demonstration of advanced SQL skills. Feel free to fork, modify, and adapt for your learning or projects!

**Technologies Used:**
- T-SQL (SQL Server)
- Window Functions & Analytics
- Data Aggregation & Reporting
- Statistical Analysis

---

**Last Updated:** September 2024  
**Version:** 1.0  
**Status:** Complete ✅

---

*A practical demonstration of enterprise-level SQL expertise for data-driven decision making.*
