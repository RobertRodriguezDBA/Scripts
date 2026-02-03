SELECT * FROM stock_quant WHERE product_id = 336388 AND location_id = 544724;
 
SELECT id, name, is_stock, company_id FROM stock_location WHERE id = 544724;
 
SELECT * FROM stock_move_queue WHERE product_id = 336388 AND location_dest_id = 544724 AND state = 'pending';
 
SELECT
    product_id,
    location_dest_id AS location_id,
    SUM(qty) AS delta
FROM stock_move_queue
WHERE product_id = 336388 AND location_dest_id = 544724 AND state = 'pending'
GROUP BY product_id, location_dest_id;

--

select * 
from receive_pallet 
order by create_date desc
limit 10;

--

select * 
from receive_folio_pallet 
order by create_date desc
limit 10;

--

select * 
from receive_pallet_line 
order by create_date desc
limit 10;

--