--create walmart database
create database walmart;

use walmart;

--create table walmart_sales
create table walmart_sales(
Invoice_ID VARCHAR(100),
Branch VARCHAR(100),
City VARCHAR(100),
Customer_type VARCHAR(100),
Gender VARCHAR(100),
Product_line VARCHAR(100),
Unit_price float,
Quantity int,
VAT float,
Total float,
[Date] varchar(max),
[Time] varchar(100),
Payment nvarchar(max),
cogs float,gross_margin_percentage float,
gross_income float,
Rating float);

select * from walmart_sales;


--read the Walmart Dataset
BULK INSERT Walmart_Sales
FROM 'C:\Users\Saurabh\Desktop\Walmart SQL Project\Walmart Sales Data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    DATAFILETYPE = 'char'
);

select * from walmart_sales;

--add column time_of_day , day_name , month_name
alter table walmart_sales
add 
time_of_day varchar(100),
day_name varchar(100), 
month_name varchar(100);

select * from walmart_sales;

--update the values into time_of_day

update walmart_sales
set time_of_day = (case 
	when [time] between '00:00:00' and '12:00:00' then 'Morning'
	when [time] between '12:01:00' and '16:00:00' then 'Afternoon'
	else 'Evening'
end)
from walmart_sales;

--update day_name
update walmart_sales
set day_name = (datename(WEEKDAY,try_cast([Date] as date))) 
from walmart_sales;


--update month name
update walmart_sales
set month_name = (datename(mm,try_cast([Date] as date))) 
from walmart_sales;

select * from walmart_sales;


--Generic Question
--1.How many unique cities does the data have ?
select distinct  city
from walmart_sales;

--2.In which city is each branch
select city,branch,count(invoice_id) as branch_count
from walmart_sales
group by city,Branch;

--Product
--1. How many unique product lines does the data have?
select count(distinct Product_line) as [unique product lines]
from walmart_sales;

--2.What is most common payment method ?
select Payment , COUNT(payment) as [count_of_payment_method]
from walmart_sales
group by Payment
order by count_of_payment_method desc;

--3.What is the most selling product line?
select top 1 Product_line, COUNT(Product_line) as [most selling product line]
from walmart_sales
group by Product_line
order by [most selling product line] desc;

--4.What is the total revenue by month?
select top 1 month_name,[revenue by month]
from(select ws.month_name,datepart(MM,Date) as month_num,SUM(ws.total)[revenue by month]
from walmart_sales as ws
group by month_name,datepart(MM,Date))as result_table
order by month_num asc;


select * from walmart_sales;

--5.What month had the largest COGS?
select top 1 ws.month_name , sum(ws.cogs) [largest cogs]
from walmart_sales as ws
group by ws.month_name
order by [largest cogs] desc;

--6.What product line had the largest revenue?
select top 1 ws.Product_line , sum(ws.Total)[revenue]
from walmart_sales as ws
group by ws.Product_line
order by revenue desc;

--7.What is the city with the largest revenue?
select top 1 ws.City , sum(ws.Total) [revenue]
from walmart_sales as ws
group by ws.City
order by revenue desc;

--8.What product line had the largest VAT ?
select top 1 ws.Product_line , sum(ws.VAT)[Total VAT]
from walmart_sales as ws
group by ws.Product_line
order by [Total VAT];

--9.Fetch each product line and add a column to those product line showing"Good","Bad",Good ifs its greater than average sales

--Add column to table
Alter table walmart_sales
add Product_Category Varchar(20);
--update the table
update walmart_sales
set Product_Category = 
(			
case 
when Total >=(select avg(total)[total]from walmart_sales)
then 'Good Sales'
else 'Bad Sales'
end)
from walmart_sales;

select * from walmart_sales;



--10.Which branch sold more products than average product sold?

SELECT Branch, SUM(Quantity) AS total_products
FROM walmart_sales
GROUP BY Branch
HAVING SUM(Quantity) > (
    SELECT AVG(total_products)
    FROM (
        SELECT SUM(Quantity) AS total_products
        FROM walmart_sales
        GROUP BY Branch
    ) AS t
)
ORDER BY total_products DESC;

--11.What is the most common product line by gender?

select ws.Gender ,ws.Product_line, count(ws.Product_line)[total] 
from walmart_sales as ws 
group by ws.Gender,ws.Product_line 
order by total asc ,ws.gender ;

-- Most common product line by gender
WITH ranked_sales AS (
    SELECT 
        ws.Gender,
        ws.Product_line,
        COUNT(ws.Product_line) AS total,
        ROW_NUMBER() OVER (PARTITION BY ws.Gender ORDER BY COUNT(ws.Product_line) DESC) AS rn
    FROM walmart_sales AS ws
    GROUP BY ws.Gender, ws.Product_line
)
SELECT Gender, Product_line, total
FROM ranked_sales
WHERE rn = 1;


--12.What is the average rating of each product line?
select ws.Product_line , AVG(rating)[average rating]
from walmart_sales as ws
group by ws.Product_line;

select * from walmart_sales;
--Sales

--1.Number of sales made in each time of day per weekday
select ws.day_name,ws.time_of_day , count(*)[total sales]
from walmart_sales as ws
group by ws.time_of_day,ws.day_name
having ws.day_name not in ('Saturday','Sunday')
order by ws.day_name,[total sales] DESC;

--2.Which of the customer types brings the most revenue ?
select ws.Customer_type ,sum(total)[total revenue]
from walmart_sales as ws
group by ws.Customer_type
order by [total revenue];

--3.Which city has the largest tax percentage/VAT(Value Added Tax)?
select top 1 ws.City , max(VAT)[Largest VAT]
from walmart_sales as ws
group by ws.City
order by [Largest VAT] desc;

--4.Which customer type pays the most in VAT?
select ws.Customer_type , sum(VAT)[Total VAT]
from walmart_sales as ws
group by ws.Customer_type;


--Customer
--1. How many unique customer types does the data have?
select distinct ws.customer_type
from walmart_sales as ws;

--2. How many unique payment methods does the data have?
select distinct ws.Payment
from walmart_sales as ws;

--3. What is the most common customer type?
select ws.Customer_type , COUNT(ws.Customer_type) as [common customer type]
from walmart_sales as ws
group by ws.Customer_type;

--4. Which customer type buys the most?
select ws.Customer_type ,sum(total) as [revenue collection]
from walmart_sales as ws
group by ws.Customer_type
order by [revenue collection] desc;

--5. What is the gender of most of the customers?
select ws.Gender , count(*)[most customer]
from walmart_sales as ws
group by ws.Gender
order by [most customer] desc;

--6. What is the gender distribution per branch?
select ws.Branch ,ws.Gender, count(*)[distribution per branch]
from walmart_sales as ws
group by ws.Branch , ws.Gender
order by ws.[Branch], [distribution per branch]desc;


--7. Which time of the day do customers give most ratings?
select ws.time_of_day ,AVG(ws.rating)[avg_rating]
from walmart_sales as ws
group by ws.time_of_day
order by avg_rating desc;

--8. Which time of the day do customers give most ratings per branch?
select ws.Branch,ws.time_of_day,count(ws.Rating)[most_rating]
from walmart_sales as ws
group by ws.time_of_day , ws.Branch
order by Branch;

--9. Which day fo the week has the best avg ratings?
select top 1 ws.day_name,AVG(rating)[best rating]
from walmart_sales as ws
group by ws.day_name
order by [best rating] desc;

--10. Which day of the week has the best average ratings per branch?
select ws.Branch,ws.day_name, avg(Rating)[average rating]
from walmart_sales as ws
group by ws.Branch , ws.day_name
order by ws.Branch;