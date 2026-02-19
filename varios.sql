set search_path to public;

select funcname, calls, total_time
from pg_stat_user_functions
order by calls desc;

-------------------------------------------

SELECT proname, prosrc
FROM pg_proc
WHERE proname like 'fix_%';

-------------------------------------------

select registro, * 
from click_carrito
where clave_cte = 'jracmost' 
order by registro desc
limit 100;

-------------------------------------------

SELECT * FROM stock_picking_status LIMIT 10;

-------------------------------------------

SELECT *
FROM res_partner
limit 100;

select * from 



select * from stock_move_queue limit 10;
-------------------------------------------
--ALTER TABLE stock_move_queue ADD COLUMN cost NUMERIC(16,6);
 

 select * from bi_productos 
 where nombre_producto like '%D%'
 limit 10;

 -------------------------------------------

SELECT n.nspname as esquema,
       p.proname as funcion,
       pg_get_function_arguments(p.oid) as argumentos
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname = 'click_guardar_pedido_prime';

-------------------------------------------

--REFRESH MATERIALIZED VIEW vm_statistics_sale;

-------------------------------------------

select * from stock_warehouse
where true 
limit 100;


---------

SELECT tab.table_schema, tab.table_name
FROM information_schema.tables tab
LEFT JOIN information_schema.table_constraints tco 
  ON tab.table_schema = tco.table_schema
  AND tab.table_name = tco.table_name
  AND tco.constraint_type = 'PRIMARY KEY'
WHERE tab.table_schema NOT IN ('information_schema', 'pg_catalog')
  AND tab.table_type = 'BASE TABLE'
  AND tco.constraint_name IS NULL;
---------

select * from imp_stock_receipt
where id = 661
limit 10;

--
update imp_stock_receipt set has_differences = FALSE
where id = 661;
---------

select * 
from ir_cron 
where active 
limit 120;

--update ir_cron set active = FALSE where id 297

select now();

--

select * from click_busqueda_por_aplicacion(28549, 29345, 92, 2005, 8186, 6102, null, null, 28549);

--

select * from click_busqueda_por_aplicacion_new(28549, 29345, 92, 2005, 8186, 6102, null, null, 28549);

python3 "fo_test.py" \
--host database-odoo-qa-new-backup-cluster.cluster-cguayy4huolc.us-east-1.rds.amazonaws.com --user gm_admin_user \
--password 'Hgw3gxh#V2Nz' \
--database VOGMMP \
--port 5432 \
--threads 5 \
--sslmode require

------------------------------------

SELECT table_name 
FROM information_schema.views WHERE table_schema = 'public'; 
--UNION

SELECT matviewname FROM pg_matviews WHERE schemaname = 'public';
LIMIT 1000;

------------------------------------

SELECT 
    event_object_schema AS schema_name,
    event_object_table AS table_name,
    trigger_name,
    action_statement,
    action_timing,
    event_manipulation
FROM 
    information_schema.triggers
ORDER BY 
    event_object_table, trigger_name;



------------------------------------

SELECT relid::regclass, phase, sample_blks_total, sample_blks_scanned 
FROM pg_stat_progress_analyze;

------------------------------------
select * FROM public.stock_warehouse limit 1;

SELECT id, name, active, company_id, partner_id, view_location_id, lot_stock_id, code, reception_steps, delivery_steps, wh_input_stock_loc_id, wh_qc_stock_loc_id, wh_output_stock_loc_id, wh_pack_stock_loc_id, mto_pull_id, pick_type_id, pack_type_id, out_type_id, in_type_id, int_type_id, crossdock_route_id, reception_route_id, delivery_route_id, default_resupply_wh_id, create_uid, create_date, write_uid, write_date, buy_to_resupply, buy_pull_id, branch, location_leftover_id, location_rack_id, location_shipping_id, location_table_id, location_transfer_order_virtual_id, region_id, zone, corporate_ou, location_missing_id, frontier, location_lost_id, counting, gun_user_id, local_journal_id, foreign_journal_id, session_cash_id, location_warranty_id, location_input_dev_id, dev_sequence_id, war_sequence_id, tz, last_statistics_update, location_rack_special_id, skip_route_picking, is_special_pickup, moto_sequence_id, consignment_sequence_id, datetime_cron, location_damage_id, receive_sequence_id, channel_receive, channel_supplier_error, receive_new_version, channel_diff_receive, national_sale_click, parcel_route_id, national_sale_sequence_id, free_ship_minimum, shipping_product_id, time_limit_week, time_limit_weekend, national_sale_detail, local_sale_detail, manage_click_id, missing_channel_id, ot_route_id, ot_origin_restricted, account_xml_analytic_id, consignment_note_id, petty_cash_sequence_id, is_order_prime, prime_orders_sequence_id, prime_product_id, prime_delivery_time, pack_minutes, automatic_assignation, urgent_assignation, delivery_package_lines, quick_table, location_rack_local_id, automatic_picking, automatic_packing, warehouse_classification_id, macro_cedi, macro_cedi_id, cedis_parcel_route_id, cedis_dist_route_id, stock_order_sequence_id, stock_order_task_sequence_id, shipping_sequence_id, max_order_by_group, fast_flow
	FROM public.stock_warehouse
limit 1;

--

Select * from vm_motor limit 10;

--

SELECT * FROM pg_matviews WHERE schemaname = 'public'

select * from public.bi_pronostico_ventas_hist limit 1;

----------------------------------------------------------------------
SELECT
    pt."name"                   AS id,
    ed."name"                   AS nombre,
    eb."name"                   AS marca,
    es."number"                 AS sistema,
    pt.price_list               AS precio,
    pt.application              AS aplicacion,
    pt.equivalences_product_id  AS equivalencia
FROM product_template pt
INNER JOIN exinno_brand eb ON eb.id = pt.brand_id
INNER JOIN exinno_system es ON es.id = pt.system_id
INNER JOIN exinno_description ed ON ed.id = pt.description_id
WHERE pt."name" = 'B90'
LIMIT 1;


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




------------------------------------------

select id_usuario,nombre||' '||apellido_p as nombre,trim(apellido_p) as paterno,
departamento,
sucursal
from acc_usuarios as a 
where estado='A' 
limit 1;



select id_usuario,nombre||' '||apellido_p as nombre,trim(apellido_p) as paterno,
departamento,
sucursal,
(select nombre_sucursal from cat_sucursales where num_suc=31 limit 1) as nom_suc 
from acc_usuarios as a 
where estado='A' 
and upper(trim(clave))='SALCIDO' limit 1;


--and id_usuario='$usuario' 
--and upper(trim(clave))='$pass' 
--(select nombre_sucursal from cat_sucursales where num_suc=a.sucursal limit 1) as nom_suc 

select id_usuario,nombre||' '||apellido_p as nombre,
trim(apellido_p) as paterno,
departamento,
sucursal,
(select nombre_sucursal from cat_sucursales where num_suc=31 limit 1) as nom_suc 
from acc_usuarios as a 
where estado='A' 
and id_usuario='3244' 
and upper(trim(clave))='SALCIDO' 
limit 1;

select * from acc_usuarios where id_usuario=3342;

--------------------------------

SELECT pid, 
       wait_event_type, 
       wait_event, 
       query, 
       state 
FROM pg_stat_activity 
WHERE wait_event_type = 'Lock';


-------------------------------------
set search_path to public;
SELECT null as product_id,null as product_id_tm, null as codigo_art, null as nombre_art, null as marca, null as aplicacion, null as rating, null as estatus,null as precio,null as precio_original,
                   null as existencia,null as local, null as foraneo, null as multiplo_venta, null as oferta,count(*) as total_registros,null as multi_branch, null as is_outlet,null as descto_outlet 
                   from v_click_busqueda_por_descripcion pt
                   --where pt.system_id
-------------------------------------

set search_path to puvblic;
select count1(system_id) 
from v_click_busqueda_por_descripcion ;


-------------------------------------
select * from stock_warehouse limit 1;

---------------------------------------------------------------------------------------------------------------



select * from v_conveyor_belt_culiacan;
 

SELECT isc.name AS caja,
    COALESCE(ispt.name, '00'::character varying) AS mesa
   FROM imp_stock_order_container isoc
     JOIN imp_stock_order iso ON iso.id = isoc.order_id --ot
     JOIN imp_stock_container isc ON isc.id = isoc.container_id
     LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id --ot
     LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
  WHERE iso.warehouse_id = 7614 AND isoc.packed = false AND isc.container_type::text = 'internal'::text
  UNION ALL
 SELECT imp_cajas_mesas_convey.caja, 
    imp_cajas_mesas_convey.mesa
   FROM imp_cajas_mesas_convey;



SELECT *
   FROM imp_cajas_mesas_convey;



SELECT n.nspname AS esquema, c.relname AS tabla, c.relreplident
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
        AND c.relreplident = 'f'; -- 'f' significa FULL


---------------------------------------------------------------------------------------------------------------


WITH facts AS (
         SELECT sw.name AS sucursal,
            ai.date_invoice AS fecha,
            ai.id AS id_factura,
                CASE
                    WHEN aj.order_type::text = 'local'::text THEN 'Local'::text
                    ELSE 'Foraneo'::text
                END AS tipo_pedido
           FROM account_invoice ai
             JOIN account_journal aj ON aj.id = ai.journal_id
             JOIN stock_warehouse sw ON sw.id = ai.warehouse_id
          WHERE ai.type::text = 'out_invoice'::text AND (ai.state::text = ANY (ARRAY['open'::character varying::text, 'paid'::character varying::text])) AND ai.date_invoice >= '2022-01-01'::date AND ai.date_invoice <= '2025-06-25'::date AND (aj.order_type::text = ANY (ARRAY['local'::character varying::text, 'foreign'::character varying::text]))
        )
 SELECT fc.sucursal,
    fc.fecha,
    fc.id_factura,
    pt.name AS codigo,
    ail.quantity AS cantidad,
    round(ail.price_unit * (1::numeric - COALESCE(ail.discount, 0::numeric) / 100.0), 2) AS precio_unitario,
        CASE
            WHEN pt.currency_two_id = 3 THEN (pt.replacement_cost / COALESCE(rcr.rate, 0.05365206529209621993)::double precision)::numeric(10,2)
            ELSE pt.replacement_cost::numeric(10,2)
        END AS costo_reposicion,
    fc.tipo_pedido
   FROM facts fc
     JOIN account_invoice_line ail ON fc.id_factura = ail.invoice_id
     JOIN product_product pp ON pp.id = ail.product_id
     JOIN product_template pt ON pt.id = pp.product_tmpl_id
     LEFT JOIN res_currency_rate rcr ON rcr.currency_id = pt.currency_two_id AND rcr.name = fc.fecha
  WHERE pt.type::text = 'product'::text
  
limit 100;

set search_path to public;


SELECT sw.name AS sucursal,
ai.date_invoice AS fecha,
ai.id AS id_factura,
    CASE
        WHEN aj.order_type::text = 'local'::text THEN 'Local'::text
        ELSE 'Foraneo'::text
    END AS tipo_pedido
FROM account_invoice ai
    JOIN account_journal aj ON aj.id = ai.journal_id
    JOIN stock_warehouse sw ON sw.id = ai.warehouse_id
WHERE ai.type::text = 'out_invoice'::text AND (ai.state::text = ANY (ARRAY['open'::character varying::text, 'paid'::character varying::text])) AND ai.date_invoice >= '2022-01-01'::date AND ai.date_invoice <= '2025-06-25'::date AND (aj.order_type::text = ANY (ARRAY['local'::character varying::text, 'foreign'::character varying::text]))












set search_path to public;
SELECT
    isc.id
FROM imp_stock_container AS isc
WHERE
    isc.name = 'CVB-045'
    AND isc.container_type = 'internal'
    AND isc.availability = FALSE
    AND isc.warehouse_id = 7614;


------
/* CRON IR ODOO */
--UPDATE ir_cron SET active = false WHERE active = true;
SELECT * FROM ir_cron WHERE active = FALSE;

------
set search_path to public;
SELECT
    queryid,
    calls,
    round(total_time::numeric,2) AS total_time_ms,
    round(mean_time::numeric,2) AS avg_time_ms,
    rows,
    shared_blks_hit,
    shared_blks_read,
    round(100 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read,0), 2) AS cache_hit_ratio,
    query
FROM
    pg_stat_statements WHERE query like '%stock_rack%'
ORDER BY
    total_time DESC
LIMIT 20;

---

SELECT 
    relname, 
    pg_size_pretty(pg_total_relation_size(relid)) as size
FROM pg_stat_user_tables 
WHERE pg_total_relation_size(relid) > (5 * 1024 * 1024 * 1024);

---
SELECT n.nspname as schema, t.typname as type_name
FROM pg_type t
LEFT JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_class c WHERE c.oid = t.typrelid))
  AND NOT EXISTS(SELECT 1 FROM pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
  AND n.nspname NOT IN ('pg_catalog', 'information_schema');