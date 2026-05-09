-------------------------------------------------------------
-- Data Cleaning & Transformation
SELECT
  `year`,
  UPPER(`make`) AS make,
  `model`,
  `body`,
  `transmission`,
  `state`,
  `seller`,
  CAST(`odometer` AS INT) AS mileage,
  CAST(`sellingprice` AS DOUBLE) AS selling_price,
  CAST(`mmr` AS DOUBLE) AS market_price,
  TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss') AS sale_date
FROM `workspace`.`default`.`car_sales_data`
WHERE `sellingprice` IS NOT NULL
  AND year IS NOT NULL;



-- Feature Engineering
SELECT
  *,
  `sellingprice`                                   AS total_revenue,
  `sellingprice` - `mmr`                           AS profit_amount,
  ROUND(( `sellingprice` - `mmr`)
       / `sellingprice` * 100, 2)                  AS profit_margin_pct,
  YEAR(TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss'))   AS sale_year,
  MONTH(TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss'))  AS sale_month
FROM `workspace`.`default`.`car_sales_data`;


-- Top 10 Revenue-Generating Models
SELECT
  `make`,
  `model`,
  COUNT(*)            AS units_sold,
  SUM(`sellingprice`)  AS total_revenue
FROM `workspace`.`default`.`car_sales_data`
GROUP BY `make`, `model`
ORDER BY total_revenue DESC
LIMIT 10;


--  Mileage Impact on Price
SELECT
  `odometer`,
  ROUND(AVG(`sellingprice`), 2) AS avg_selling_price
FROM `workspace`.`default`.`car_sales_data`
WHERE `odometer` IS NOT NULL
GROUP BY `odometer`
ORDER BY `odometer`;


-- Average Price by Vehicle Year
SELECT
  `year`,
  ROUND(AVG(`sellingprice`), 2) AS avg_price
FROM `workspace`.`default`.`car_sales_data`
GROUP BY `year`
ORDER BY `year` DESC;


-- Seller Performance Summary
SELECT
  `seller`,
  COUNT(*)                   AS vehicles_sold,
  ROUND(AVG(`sellingprice`),2) AS avg_price,
  ROUND(SUM(`sellingprice`),2) AS total_revenue
FROM `workspace`.`default`.`car_sales_data`
GROUP BY `seller`
ORDER BY vehicles_sold DESC
LIMIT 15;


-- Margin Tier Classification
SELECT *,
((`sellingprice` - `mmr`) / `sellingprice`) * 100 AS profit_margin_pct,
  CASE
    WHEN profit_margin_pct >= 15 THEN 'High Margin'
    WHEN profit_margin_pct BETWEEN 5 AND 14.99 THEN 'Medium Margin'
    ELSE 'Low Margin'
  END AS margin_category
FROM `workspace`.`default`.`car_sales_data`;


-- Split Sale Date into Components
SELECT
    *,

    -- Convert STRING → TIMESTAMP safely
    TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss') AS saledate_ts,

    -- Day of week
    date_format(
        TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss'),
        'EEEE'
    ) AS sale_day_of_week,

    -- Month number
    month(
        TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss')
    ) AS sale_month,

    -- Month name

date_format(
  from_unixtime(
    unix_timestamp(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss')
  ),
  'MMM'
) AS sale_month_name,


    -- Year
    year(
        TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss')
    ) AS sale_year,

    -- Time
    date_format(
        TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss'),
        'HH:mm:ss'
    ) AS sale_time

FROM `workspace`.`default`.`car_sales_data`;


-- Final Code
SELECT 
    `year`,
    `make`, 
    `model`,
    `trim`,
    `body`,
    `transmission`,
    `state`,
    `color`,
    `odometer`,
    `sellingprice`,

((`sellingprice` - `mmr`) / `sellingprice`) * 100 AS Profit_Margin,
    CASE 
        WHEN ((`sellingprice` - `mmr`) / `sellingprice`) * 100 >= 20 THEN 'High Margin'
        WHEN ((`sellingprice` - `mmr`) / `sellingprice`) * 100 BETWEEN 10 AND 19.99 THEN 'Medium Margin'
        ELSE 'Low Margin'
    END AS Margin_Category,

    COUNT(*) AS total_sales,
    ----Comparison of the selling price to the market price
    CASE 
        WHEN `sellingprice` > `mmr` THEN 'High Priced'
        WHEN `sellingprice` < `mmr` THEN 'Low Priced'
        ELSE 'Fair Priced'
    END AS Price_Range,
  TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss') AS saledate_ts,

      -- Convert STRING → TIMESTAMP safely
    TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss') AS saledate_ts,

    -- Day of week
    date_format(
        TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss'),
        'EEEE'
    ) AS sale_day_of_week,

    -- Month number
    month(
        TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss')
    ) AS sale_month,

    -- Month name
    date_format(
          from_unixtime(
           unix_timestamp(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss')
         ),
            'MMM'
        ) AS sale_month_name,

    -- Year
    year(
        TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss')
    ) AS sale_year,

    -- Time
    date_format(
        TO_TIMESTAMP(SUBSTRING(`saledate`, 5), 'MMM dd yyyy HH:mm:ss'),
        'HH:mm:ss'
    ) AS sale_time
    
FROM `workspace`.`default`.`car_sales_data`
--WHERE TRY_TO_TIMESTAMP(`saledate`, 'DY MON DD YYYY HH24:MI:SS') IS NOT NULL
GROUP BY ALL;
