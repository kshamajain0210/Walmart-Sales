-- Create database
create database if not exists walwalmartsalesmart_sales;

-- Create table
select *, row_number() over() from walmartsales;

/* Data Cleaning */

-- All data in table 
SELECT	* FROM walmartsales;

-- To check if there is any duplicate in data
with cte as (
select *, dense_rank() over(partition by Invoice_ID, Branch, City, Customer_type, Gender, Product_line, Unit_price, Quantity, Tax, Total, Date, Time, Payment, cogs, gross_margin_percentage, gross_income, Rating ) dr from walmartsales)
select * from cte where dr >= 2;

-- To convert the sring type to date type 
UPDATE walmartsDateales SET date = STR_TO_DATE(date, '%d-%m-%Y');

-- Add the time_of_day column
SELECT	*,	(CASE WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"  WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon" ELSE "Evening"  END) AS time_of_day FROM walmartsales;
alter table walmartsales add column time_of_day varchar(20);
update walmartsales set time_of_day =	(CASE WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning" WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon" ELSE "Evening" END);

-- Add day_name column
SELECT *, DAYNAME( Date ) AS day_name FROM walmartsales;
alter table walmartsales add column day_name varchar(20);
update walmartsales set day_name= DAYNAME( Date );

-- Add month_name column
select *,monthname(date) month_name from walmartsales;
alter table walmartsales add column month_name varchar(20);
update walmartsales set month_name = monthname(date);


/* Exploratory Data Analysis (EDA) */


-- 1. How many unique cities does the data have? 
select distinct(city) from walmartsales;

-- 2. In which city is each branch?
select distinct(city), branch from walmartsales;
 
-- 3. How many unique product lines does the data have?
select distinct(Product_line) from walmartsales;

-- 4. What is the most common payment method?
select payment, count(payment) as pay from walmartsales group by payment order by pay desc;
    
-- 5. What is the most selling product line?
select Product_line, sum(Quantity) from walmartsales group by Product_line order by sum(Quantity) desc;

-- 6. What is the total revenue by month?
select month_name, sum(total) total_revenue from walmartsales group by month_name ORDER BY total_revenue;

-- 7. What month had the largest COGS? 
select sum(cogs)cogs, month_name from walmartsales group by month_name order by cogs desc;

-- 8. What product line had the largest revenue?
select Product_line, sum(total) as total from walmartsales group by Product_line order by total desc;

-- 9.What is the city with the largest revenue? 
select city, sum(total) from walmartsales group by city order by sum(total) ;

-- 10.What product line had the largest VAT?
select avg(tax), Product_line from walmartsales group by Product_line order by avg(tax) desc;

-- 11.Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
with cte as( select *, avg(Quantity) over (partition by Product_line) as avgsales from walmartsales) 
select *, case when avgsales< Quantity then 'good' else 'bad' end  as status from cte;

-- 12.Which branch sold more products than average product sold?
WITH cte AS (SELECT branch, SUM(quantity) AS total_quantity, AVG(SUM(quantity)) OVER () AS avg_quantity FROM walmartsales GROUP BY branch)
SELECT branch, total_quantity FROM cte WHERE total_quantity > avg_quantity;

-- 13.What is the most common product line by gender
SELECT gender, product_line, COUNT(*) AS count FROM walmartsales GROUP BY gender, product_line ORDER BY count DESC;

-- 14. What is the average rating of each product line?
select product_line, round(avg(rating),2) from walmartsales group by Product_line;

-- 15.Number of sales made in each time of the day on weekdays
SELECT time_of_day, count(QUANTITY) quantity FROM WALMARTSALES where day_name not in('sunday', 'saturday') GROUP BY time_of_day order by quantity desc ;

-- 16. Which of the customer types brings the most revenue?
select Customer_type, sum(total) revenue from walmartsales group by Customer_type order by Customer_type desc;

-- 17.Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, ROUND(AVG(tax)) tax from walmartsales group by city order by tax desc;

-- 18. Which customer type pays the most in VAT?
select Customer_type, round(avg(tax),2)tax from walmartsales group by Customer_type order by tax desc;

-- 19.How many unique customer types does the data have?
select distinct(Customer_type) from walmartsales;

-- 20.How many unique payment methods does the data have?
select distinct(payment) from walmartsales;

-- 21. What is the most common customer type?
select Customer_type, count(*) from walmartsales group by Customer_type;

-- 22. Which customer type buys the most?
select Customer_type, count(*)quantity from walmartsales group by Customer_type;

-- 23. What is the gender of most of the customers?
select gender, count(gender) from walmartsales group by gender;

-- 24. What is the gender distribution per branch?
SELECT branch, 
    SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_count
FROM WALMARTSALES GROUP BY branch;

-- 25. Which time of the day do customers give most ratings?
select time_of_day, avg(rating)rating from walmartsales group by time_of_day order by rating desc;

-- 26. Which time of the day do customers give most ratings per branch?
select time_of_day, branch , count(*)rating from walmartsales group by branch,time_of_day order by rating desc;
WITH RatingsPerTime AS (SELECT branch, time_of_day, COUNT(*) AS rating_count FROM WALMARTSALES GROUP BY branch, time_of_day)
SELECT branch, time_of_day, rating_count FROM RatingsPerTime WHERE (branch, rating_count) IN (SELECT branch, MAX(rating_count)FROM RatingsPerTime GROUP BY branch) ORDER BY branch, rating_count DESC;

-- 27. Which day of the week has the best avg ratings?
select day_name, avg(rating) rating from walmartsales group by day_name order by rating desc;

-- 28. Which day of the week has the best average ratings per branch?
SELECT day_name, branch, AVG(rating) AS avg_rating FROM WALMARTSALES GROUP BY day_name, branch ORDER BY avg_rating DESC;





-- All data in table 
SELECT	* from walmartsales;