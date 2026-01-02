use pizza_shop;

-- Retrieve the total number of orders placed.
select count(*) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity*pizzas.price),2) as total_revenue from order_details join pizzas on order_details.pizza_id=pizzas.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types_clean.pizza_type_id, pizza_types_clean.name, pizzas.price from pizza_types_clean  join pizzas on pizzas.pizza_type_id = pizza_types_clean.pizza_type_id order by pizzas.price desc limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as most_orders from pizzas join order_details on pizzas.pizza_id = order_details.pizza_id group by pizzas.size order by most_orders desc ;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types_clean.name, sum(order_details.quantity) as quantity
from pizza_types_clean join pizzas on pizza_types_clean.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types_clean.name
order by quantity desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types_clean.category, sum(order_details.quantity) as num
from pizza_types_clean join pizzas on pizza_types_clean.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types_clean.category
order by num desc; 

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as hour, count(order_id) as order_count from orders group by hour(order_time) order by hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types_clean group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(sale),0) as avg_pizza_order_per_day 
from ( select orders.order_date, sum(order_details.quantity) as sale
from orders join order_details on orders.order_id = order_details.order_id
group by orders.order_date ) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types_clean.name, sum(pizzas.price * order_details.quantity) as revenue 
from pizza_types_clean join pizzas on pizzas.pizza_type_id = pizza_types_clean.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types_clean.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types_clean.category, round(sum(order_details.quantity*pizzas.price)/(select round(sum(order_details.quantity*pizzas.price),2)as total_sales
from order_details join pizzas on pizzas.pizza_id=order_details.pizza_id)*100, 2) as revenue
from pizza_types_clean join pizzas on pizza_types_clean.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types_clean.category order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over (order by order_date) as cum_revenue
from (select orders.order_date, sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas on pizzas.pizza_id=order_details.pizza_id
join orders on orders.order_id=order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from (select pizza_types_clean.category, pizza_types_clean.name, sum(order_details.quantity*pizzas.price)as revenue
from pizza_types_clean join pizzas on pizza_types_clean.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types_clean.category, pizza_types_clean.name)as a) as b
where rn <= 3;




