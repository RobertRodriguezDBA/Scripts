SELECT 
	t.id AS task_id,
    isa.name as area,
	so.name as zona,
    isol.state,
	isol.id,
	isol.origin AS location_name,
	isol.product_id AS product_id,
	pt.name AS product_name,
	pt.xl_product,
	isol.destination AS location_dest_name,
	isol.quantity_done,
	isol.quantity AS total_qty,
	t.uuid,
	infc.name AS nfc_tag,
	COALESCE(pt.partner_barcode, '') AS partner_barcode,
	COALESCE(p.barcode, '') AS barcode,
	COALESCE(pt.alternative_barcode_1, '') AS alternative_barcode_1,
	COALESCE(pt.alternative_barcode_2, '') AS alternative_barcode_2,
	COALESCE(pt.alternative_barcode_3, '') AS alternative_barcode_3
FROM imp_stock_order_line isol
LEFT JOIN imp_stock_order so ON isol.order_id = so.id
LEFT JOIN imp_stock_order_task t ON so.task_id = t.id
LEFT JOIN stock_location AS sl ON isol.location_id = sl.id
LEFT JOIN imp_nfc AS infc ON sl.nfc_id = infc.id
LEFT JOIN imp_stock_area isa on isa.zone_id = so.zone_id
LEFT JOIN imp_stock_zone isz on isa.zone_id = isz.id
LEFT JOIN product_product p ON isol.product_id = p.id
LEFT JOIN product_template pt ON p.product_tmpl_id = pt.id
WHERE isol.state = 'in_progress'
and t.id = 958
ORDER BY isol.sequence;








select * from imp_stock_order_task 
where state = 'in_progress'

select * from imp_stock_order limit 100;

select * from imp_stock_zone limit 100;

select * from imp_stock_order_line 
where order_id = 1057
limit 100;

select * from imp_stock_order 
where id = 1057
limit 100;

select * from imp_stock_order_task
where id=958;

update imp_stock_order_task set state='in_progress'
where id=925

select * from imp_stock_area;

SELECT * FROM stock_location LIMIT 100;


-----------------------------------------------
SELECT so.*
FROM imp_stock_order_line isol
LEFT JOIN imp_stock_order so ON isol.order_id = so.id
LEFT JOIN imp_stock_order_task t ON so.task_id = t.id
LEFT JOIN stock_location AS sl ON isol.location_id = sl.id
LEFT JOIN imp_nfc AS infc ON sl.nfc_id = infc.id
LEFT JOIN imp_stock_area isa on isa.id = so.zone_id
LEFT JOIN imp_stock_zone isz on isa.zone_id = isz.id
LEFT JOIN product_product p ON isol.product_id = p.id
LEFT JOIN product_template pt ON p.product_tmpl_id = pt.id
where isol.state = 'in_progress';










---------------------------------------------

SELECT
isol.id,
isol.origin AS location_name,
isol.product_id AS product_id,
pt.name AS product_name,
pt.xl_product,
isol.destination AS location_dest_name,
isol.quantity_done,
isol.quantity AS total_qty,
t.uuid,
t.id AS task_id,
infc.name AS nfc_tag,
COALESCE(pt.partner_barcode, '') AS partner_barcode,
COALESCE(p.barcode, '') AS barcode,
COALESCE(pt.alternative_barcode_1, '') AS alternative_barcode_1,
COALESCE(pt.alternative_barcode_2, '') AS alternative_barcode_2,
COALESCE(pt.alternative_barcode_3, '') AS alternative_barcode_3,
isa.name as area,
isz.name zona
FROM imp_stock_order_line isol
LEFT JOIN product_product p ON isol.product_id = p.id
LEFT JOIN product_template pt ON p.product_tmpl_id = pt.id
LEFT JOIN imp_stock_order so ON isol.order_id = so.id
LEFT JOIN imp_stock_order_task t ON so.task_id = t.id
LEFT JOIN stock_location sl ON isol.location_id = sl.id
LEFT JOIN imp_nfc infc ON sl.nfc_id = infc.id
LEFT JOIN imp_stock_area isa on isa.zone_id = so.zone_id
LEFT JOIN imp_stock_zone isz on isa.zone_id = isz.id
WHERE t.id = 958
--AND isol.state = 'in_progress'
ORDER BY isol.sequence;


-----------------------------------------------------

SELECT
    isol.id,
    isol.origin AS location_name,
    isol.product_id AS product_id,
    pt.name AS product_name,
    pt.xl_product,
    isol.destination AS location_dest_name,
    isol.quantity_done,
    isol.quantity AS total_qty,
    t.uuid,
    t.id AS task_id,
    infc.name AS nfc_tag,
    COALESCE(pt.partner_barcode, '') AS partner_barcode,
    COALESCE(p.barcode, '') AS barcode,
    COALESCE(pt.alternative_barcode_1, '') AS alternative_barcode_1,
    COALESCE(pt.alternative_barcode_2, '') AS alternative_barcode_2,
    COALESCE(pt.alternative_barcode_3, '') AS alternative_barcode_3,
    isa.name as area,
    isz.name zona
FROM imp_stock_order_line isol
JOIN product_product p ON isol.product_id = p.id
JOIN product_template pt ON p.product_tmpl_id = pt.id
JOIN imp_stock_order so ON isol.order_id = so.id
JOIN imp_stock_order_task t ON so.task_id = t.id
JOIN stock_location AS sl ON isol.location_id = sl.id
JOIN imp_nfc AS infc ON sl.nfc_id = infc.id
JOIN imp_stock_area isa on isa.zone_id = so.zone_id
JOIN imp_stock_zone isz on isa.zone_id = isz.id
WHERE t.id = 1090
--AND isol.state = 'in_progress'
ORDER BY isol.sequence;


------

select * 
from v_estatus_pedido 
limit 30;


----------------------------------------------------------------------------------------------

SELECT so.warehouse_id,
    so.name AS id_pedido,
    so.partner_id,
        CASE
            WHEN oe.entrega_cliente IS NOT NULL THEN 'Entregado'::text
            WHEN oe.salida IS NOT NULL THEN 'En camino para entrega'::text
            WHEN so.invoice_datetime IS NOT NULL THEN 'Listo para envio'::text
            WHEN oe.fin_picking IS NOT NULL THEN 'Empacando'::text
            WHEN oe.inicio_picking IS NOT NULL THEN 'Empacando'::text
            WHEN oe.asignacion IS NOT NULL THEN 'Surtiendo'::text
            ELSE 'Pedido creado'::text
        END AS estatus
   FROM sale_order so
     LEFT JOIN otras_entregas oe ON oe.id_pedido = so.id
  WHERE so.shipping_types::text <> 'counter'::text AND so.state::text = 'sale'::text
UNION ALL
 SELECT so.warehouse_id,
    so.name AS id_pedido,
    so.partner_id,
        CASE
            WHEN cr.entrega_cliente IS NOT NULL THEN 'Entregado'::text
            WHEN cr.salida IS NOT NULL THEN 'En camino para entrega'::text
            WHEN so.invoice_datetime IS NOT NULL THEN 'Listo para envio'::text
            WHEN cr.fin_picking IS NOT NULL THEN 'Empacando'::text
            WHEN cr.inicio_picking IS NOT NULL THEN 'Empacando'::text
            WHEN cr.asignacion IS NOT NULL THEN 'Surtiendo'::text
            ELSE 'Pedido creado'::text
        END AS estatus
   FROM sale_order so
     LEFT JOIN cliente_recoge cr ON cr.id_pedido = so.id
  WHERE so.shipping_types::text = 'counter'::text AND so.state::text = 'sale'::text;

----------------------------------------------------------------------------------------------

select * 
from cliente_recoge
limit 10; 