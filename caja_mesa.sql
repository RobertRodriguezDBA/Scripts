SELECT
isc.name AS caja, 
COALESCE(ispt.name, '00'::character varying) AS mesa,
--order_id,
--iso.ot_id,
sto.name
   FROM imp_stock_order_container isoc
     JOIN imp_stock_order iso ON iso.id = isoc.order_id
     JOIN imp_stock_container isc ON isc.id = isoc.container_id
     LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id
     LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
     left JOIN stock_transfer_order sto  ON iso.ot_id = sto.id
  WHERE iso.warehouse_id = 7614 AND isoc.packed = false AND isc.container_type::text = 'internal'::text LIMIT 200

  ---------------

    SELECT isc.name AS caja,
    COALESCE(ispt.name, '00'::character varying) AS mesa,
    iso.ot_id as ot_id
   FROM imp_stock_order_container isoc
     JOIN imp_stock_order iso ON iso.id = isoc.order_id
     JOIN imp_stock_container isc ON isc.id = isoc.container_id
     LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id
     LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
     LEFT JOIN stock_transfer_order sto ON isoc.order_id = iso.id
  WHERE iso.warehouse_id = 7614 AND isoc.packed = false AND isc.container_type::text = 'internal'::text
UNION ALL
 SELECT imp_cajas_mesas_convey.caja,
    imp_cajas_mesas_convey.mesa,
    0 as ot_id
   FROM imp_cajas_mesas_convey;

--
select * from imp_cajas_mesas_convey limit 100;