# Write your MySQL query statement below
select c.name as Customers from Customers c
left join Orders o
on c.id = o.customerId
where c.id not in 
(select customerId from Orders)