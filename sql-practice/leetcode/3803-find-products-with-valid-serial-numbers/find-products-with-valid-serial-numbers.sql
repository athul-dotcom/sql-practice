# Write your MySQL query statement below
select *
from products
where description regexp '(^| )(?-i:SN)[0-9]{4}-[0-9]{4}( |$)'
order by product_id asc