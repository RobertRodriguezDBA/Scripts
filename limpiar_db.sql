-- Limpiar DB para un almace en especifico warehouse_id
------------------------------------------------------------------------
SET search_path TO public;
select * from stock_warehouse where id=7614;

------------------------------------------------------------------------
-- Eliminar relacion kart-container
select * from imp_entry_line where warehouse_id not in (7614);
DELETE FROM imp_entry_line where warehouse_id NOT IN (7614);

------------------------------------------------------------------------
-- Eliminar relacion kart-container
select * from imp_stock_kart_container_rel where container_id in (select id from imp_stock_container where warehouse_id not in(7614));
DELETE FROM imp_stock_kart_container_rel where container_id in (select id from imp_stock_container where warehouse_id not in(7614));
-- Container
select * from imp_stock_container where warehouse_id not in(7614);
DELETE FROM imp_stock_container where warehouse_id not in(7614);
-- Kart
select * from imp_stock_kart where warehouse_id not in(7614);
DELETE FROM imp_stock_kart where warehouse_id not in(7614);

------------------------------------------------------------------------
-- Eliminar area-producto
select * from imp_stock_area_product where area_id in (select id from imp_stock_area where warehouse_id not in(7614));
DELETE FROM imp_stock_area_product where area_id in (select id from imp_stock_area where warehouse_id not in(7614));

select * from imp_stock_area where warehouse_id not in(7614);
DELETE FROM imp_stock_area where warehouse_id not in(7614);

------------------------------------------------------------------------
-- Eliminar zona
select id from imp_stock_zone where warehouse_id not in(7614);
DELETE FROM imp_stock_zone where warehouse_id not in(7614);

------------------------------------------------------------------------
-- Eliminar quan-info-line
select * from imp_stock_quant_info_line where info_id in (select id from imp_stock_quant_info where warehouse_id not in(7614));
DELETE FROM imp_stock_quant_info_line where info_id in (select id from imp_stock_quant_info where warehouse_id not in(7614));
--
select * from imp_stock_quant_info where warehouse_id not in(7614);
DELETE FROM imp_stock_quant_info where warehouse_id not in(7614);

------------------------------------------------------------------------