----
SHOW search_path;
set search_path to public;

SELECT *
--id, product_id, company_id, location_id, lot_id, package_id, owner_id, quantity, reserved_quantity, in_date, create_uid, create_date, write_uid, write_date, imei, number_card, brand, model, model_year, vehicle_key, engine_number
	FROM stock_quant
where true
and product_id = 336428
order by in_date desc
limit 120;

---

SELECT * --id, product_id, quantity_receipt, warehouse_id, create_uid, create_date, write_uid, write_date
FROM imp_stock_quant_info
where TRUE
and product_id = 336428
limit 100;

---

select slq.product_id , sq.product_id , slq.location_id,  sq.location_id 
from stock_logical_quant slq 
join stock_quant sq on slq.product_id = sq.product_id and slq.location_id = sq.location_id 
--where sq.product_id = 336428
limit 100;

---

select coalesce(sum(sq.quantity-sq.reserved_quantity),0) into rec.existencia
      from stock_quant sq
      inner join stock_location sl on sl.id = sq.location_id
      where sq.product_id = rec.product_id
      and sl.warehouse_id = isucursal
      and sl.is_stock = true;


--
select * 
from accesos_clientes 
order by fecha_reg desc
limit 10;
--

select *
from click_generar_linea('TH-143', 39989, 'cujamost');

--

select * from res_partner limit 10;
--28258

--
select *
from click_locate_item('TH-143', 39989, 'cujamost', 100, 1, false, 28258);

select coalesce(sum(sq.quantity-sq.reserved_quantity),0) into reg.existencia
from stock_quant sq
inner join stock_location sl on sl.id = sq.location_id
where sq.product_id = reg.product_id
and sl.warehouse_id = iWarehouse_id
and sl.is_stock = true;
