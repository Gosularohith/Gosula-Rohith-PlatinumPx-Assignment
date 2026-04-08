-- HOTEL MANAGEMENT QUERIES

-- 1. Get user_id and last booked room_no
SELECT user_id, room_no
FROM bookings b1
WHERE booking_date = (
    SELECT MAX(b2.booking_date)
    FROM bookings b2
    WHERE b1.user_id = b2.user_id
);

-- 2. booking_id and total billing amount for Nov 2021
SELECT booking_id, SUM(item_quantity * item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bill_date) = 11 AND YEAR(bill_date) = 2021
GROUP BY booking_id;

-- 3. bill_id and bill amount >1000 in Oct 2021
SELECT bill_id, SUM(item_quantity * item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bill_date) = 10 AND YEAR(bill_date) = 2021
GROUP BY bill_id
HAVING bill_amount > 1000;

-- 4. Most & least ordered item per month
SELECT MONTH(bill_date) AS month, item_id,
SUM(item_quantity) AS total_qty
FROM booking_commercials
GROUP BY MONTH(bill_date), item_id;

-- 5. Second highest bill per month
SELECT *
FROM (
    SELECT MONTH(bill_date) AS month, bill_id,
           SUM(item_quantity * item_rate) AS bill_amount,
           DENSE_RANK() OVER (PARTITION BY MONTH(bill_date)
                              ORDER BY SUM(item_quantity * item_rate) DESC) AS rnk
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY MONTH(bill_date), bill_id
) t
WHERE rnk = 2;


-- CLINIC MANAGEMENT QUERIES

-- 1. Revenue per sales channel
SELECT sales_channel, SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

-- 2. Top 10 customers
SELECT uid, SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Month-wise revenue, expense, profit
SELECT m.month,
       revenue,
       expense,
       (revenue - expense) AS profit,
       CASE 
           WHEN (revenue - expense) > 0 THEN 'Profitable'
           ELSE 'Not Profitable'
       END AS status
FROM (
    SELECT MONTH(datetime) AS month, SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
) m
LEFT JOIN (
    SELECT MONTH(datetime) AS month, SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
) e ON m.month = e.month;

-- 4. Most profitable clinic per city
SELECT *
FROM (
    SELECT c.city, cs.cid,
           SUM(cs.amount) - IFNULL(SUM(e.amount),0) AS profit,
           RANK() OVER (PARTITION BY c.city ORDER BY SUM(cs.amount) DESC) rnk
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    GROUP BY c.city, cs.cid
) t
WHERE rnk = 1;

-- 5. Second least profitable clinic per state
SELECT *
FROM (
    SELECT c.state, cs.cid,
           SUM(cs.amount) - IFNULL(SUM(e.amount),0) AS profit,
           DENSE_RANK() OVER (PARTITION BY c.state ORDER BY SUM(cs.amount) ASC) rnk
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    GROUP BY c.state, cs.cid
) t
WHERE rnk = 2;
