select * from bi_productos limit 100;

select * from stock_quant 
limit 10;

select 
--iso.*,
pp.*
--isz.name Zona,
--isa.name Area
from 
imp_stock_order_line isol
join imp_stock_order iso on isol.order_id = iso.id
join imp_stock_zone isz on iso.zone_id = isz.id
join imp_stock_area isa on isz.id = isa.zone_id
join product_product pp on isol.product_id = pp.id
limit 100;


--
set search_path to public;
--
select * from exinno_description limit 100;