select * from imp_stock_order_task limit 100;
--

select * from imp_stock_area limit 100;

--

select * from imp_stock_zone limit 100; 


select * from 
imp_stock_area isa 
join imp_stock_zone isz on isa.zone_id = isz.id 


set search_path to public;
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
    COALESCE(pt.alternative_barcode_3, '') AS alternative_barcode_3
FROM imp_stock_order_line isol
JOIN product_product p ON isol.product_id = p.id
JOIN product_template pt ON p.product_tmpl_id = pt.id
JOIN imp_stock_order so ON isol.order_id = so.id
JOIN imp_stock_order_task t ON so.task_id = t.id
JOIN stock_location AS sl ON isol.location_id = sl.id
JOIN imp_nfc AS infc ON sl.nfc_id = infc.id
WHERE t.id = 826
AND isol.state = 'in_progress'
ORDER BY isol.sequence
limit 100;