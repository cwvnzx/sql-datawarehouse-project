--===========================
-- For gold.dim_customers
--===========================
/* Checking if joining the the tables caused any duplicates.*/
SELECT cst_id, COUNT(*) FROM 
(
	SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1


	SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender Info
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid
	ORDER BY 1,2

SELECT * FROM gold.dim_customers

SELECT DISTINCT gender FROM gold.dim_customers

--===========================
-- For gold.dim_products
--===========================
SELECT prd_key, COUNT(*) FROM (
SELECT 
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line, 
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance
--pn.prd_end_dt  since it is always a NULL value
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON        pn.cat_id = pc.id
WHERE prd_end_dt IS NULL   -- Filter out all historical data
)t GROUP BY prd_key
HAVING COUNT(*) > 1

SELECT * FROM gold.dim_products

SELECT * FROM gold.fact_sales

--===========================
-- For gold.fact_sales f
--===========================
-- Foreign Key Integrity (Dimensions)
/* Checking if all dimension tables can successfully join to the fact table. */

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON        c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p 
ON        p.product_key = f.product_key
WHERE c.customer_key IS NULL
