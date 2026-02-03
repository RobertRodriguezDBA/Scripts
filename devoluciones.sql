------------------------
-- 1.- Se obtiene el ID de Hijo (srl.id/id_hijo)
SELECT
	sr.id as id_padre,
	sr.name as devolucion,
	sr.state,
	srl.id as id_hijo,
	srl.invoice_id,
	srl.is_invoiced,
	pt.multiple AS multiplo_venta,
	pt.name as producto,
	srl.qty,
	srl.accepted_qty,
	srl.rejected_qty,
	srl.recieved_accepted_qty,
	srl.recieved_rejected_qty
FROM stock_return AS sr
	INNER JOIN stock_return_line AS srl
		ON srl.return_id = sr.id
	INNER JOIN product_product AS pp
		ON pp.id = srl.product_id
	INNER JOIN product_template AS pt
		ON pt.id = pp.product_tmpl_id
WHERE sr.name = 'ZAPMD/2021/0001' AND pt.name in ('F-78A07')
limit 100;

------------------------
-- 2.- Con el srl.id/id_hijo, se consulta el detalle.
select qty, accepted_qty, rejected_qty from stock_return_line where id=3; ---id = id_hijo 

------------------------
-- 3.- se actualizan valores. 
update stock_return_line set qty=1,rejected_qty=0 where id=733589;


