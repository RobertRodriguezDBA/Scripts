-- FUNCTION: public.click_guardar_pedido_prime(integer, character, character, integer, character, character, character, integer, integer, character varying, character varying, character, integer, boolean, boolean)

-- DROP FUNCTION IF EXISTS public.click_guardar_pedido_prime(integer, character, character, integer, character, character, character, integer, integer, character varying, character varying, character, integer, boolean, boolean);

CREATE OR REPLACE FUNCTION public.click_guardar_pedido_prime(
	icliente integer,
	iclave character,
	itipo_venta character,
	iflete integer,
	icomentarios character,
	itipo_usuario character,
	iclave_cte character,
	isocio integer,
	ipartner_shopping_id integer,
	p_tipo_envio character varying,
	p_tipe_dist_morsa character varying,
	c_metodo_pago character,
	imeses integer,
	bprime boolean,
	bgeneric_rfc boolean,
	OUT id_pedido integer,
	OUT flag boolean,
	OUT mensaje character varying,
	OUT sale_order_id integer)
    RETURNS SETOF record 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
        
    DECLARE 
        --Declarar Variables de Trabajo
      v_tipo_factura integer;
      v_factura integer;
      v_fecha_factura integer;
      v_hora_factura integer;
      v_estado_factura character(1);
      v_empleado integer;
      ifolio integer;
      iorden integer;
      row_cliente RECORD;
      linea RECORD;
      row_product RECORD;
      row_prime RECORD;
      v_clave_cte character(8);
      v_socio integer;
      sale_order_flag    boolean;
      iname   varchar;
      iamount_untaxed numeric; 
      iamount_tax numeric; 
      iamount_total numeric;
      desc_pronto numeric;
      itotal_con_iva numeric(12,2);
      isubtotal_sin_iva numeric(12,2);
      id_origen integer;
      id_crm_team integer;
      iWarehouse_id integer;
      iJournal_id integer;
      iPayment_term_id integer;
      --i_metodo_pago integer;
      iuser_id integer;
      isucursal record;
      lin record;
      isale record;
      row_sucursal record;
      ifolio_nac varchar;
      iyear integer;
      icarrier_id integer;
      ishipping_types varchar;
      idist_morsa varchar;
      icount integer;
      iquery text;
      ifolio_origen varchar;
      sale_bool boolean;
      ipayment_term_month_id integer;
      binsertar_prime boolean;
      iprime_without_cost boolean; --Bandera para saber si es cliente sin costo prime
      bpedido_prime boolean;       --Toma valor true cuando el parametro bprime es true y la paqueteria es REPARTO MORSA
      tparams text;
    BEGIN
      --Inicializar Variables de Salida
      id_pedido  := 0;
      flag       := false;
      mensaje    := 'Error al guardar pedido';
      sale_order_id := null;
      ipayment_term_month_id:=1;
        
      --Inicializar Variables Default Pedido
      v_tipo_factura:= 120;
      v_factura:= 0;
      v_fecha_factura:= 0;
      v_hora_factura:= 0;
      v_estado_factura:= 'V';
      v_empleado:=0;
      sale_bool:=false;
      binsertar_prime := false;
      bpedido_prime:=false;
      --i_metodo_pago:=26;
      --Definir Clave Cte 
      IF itipo_usuario = 'A'  THEN
         v_clave_cte:= iclave_cte;
      ELSE
         v_clave_cte:= iclave;
      END IF;
      IF p_tipo_envio is null or p_tipo_envio = '' THEN 
         id_pedido  := 0;
         flag       := true;
         mensaje    := 'Error, el pedido no contiene tipo de envio';
         RETURN NEXT;
         RETURN;
      END IF;

      IF (SELECT count(*) FROM click_carrito WHERE cliente=icliente AND upper(trim(clave_cte))=upper(trim(iclave)) AND flag_actvo = true AND tipo_usuario = itipo_usuario)  < 1 THEN 
         id_pedido  := 0;
         flag       := true;
         mensaje    := 'Error, el pedido no contiene lineas para guardar';
         RETURN NEXT;
         RETURN;
      END IF;
                  
      SELECT "value"::numeric INTO desc_pronto FROM ir_config_parameter WHERE key = 'descuento.pronto_pago';
    
      --IF itipo_venta='D' THEN 
       --  select id INTO i_metodo_pago from l10n_mx_way_pay mp where name='99';
      --ELSE 
      --select id INTO i_metodo_pago from l10n_mx_way_pay mp where name=lpad(c_metodo_pago,2,'0');
      --END IF;
      IF c_metodo_pago = '99' THEN
        c_metodo_pago:= '26';
      END IF;
      --Obtener el Socio y Agente de la sesión
      SELECT a.socio, a.agente, c.warehouse_id, case when c.advance_payment=true then coalesce(desc_pronto,0) else 0 end as descto_pronto_pago,c.user_id,c.credit_status::integer as estatus_credito INTO row_cliente
      FROM accesos_clientes AS a
      INNER JOIN res_partner AS c ON(c.id = a.partner_shipping_id)
      WHERE a.cliente = icliente AND a.clave_cte = v_clave_cte;
        
      --Definir Socio
      IF itipo_usuario = 'A' THEN
         v_socio:= isocio;
      ELSE
         v_socio:= row_cliente.socio;
      END IF;
      /*Agregamos esto para la aplicacion de meses sin intereses*/
      IF itipo_venta = 'C' THEN
         IF imeses > 1 THEN 
            select odescto,opayment_term_month_id INTO desc_pronto,ipayment_term_month_id from click_descuento_pedido(c_metodo_pago,imeses);
         ELSE 
            desc_pronto := CASE WHEN row_cliente.estatus_credito = ANY(ARRAY[1,4]) THEN desc_pronto ELSE 0::numeric END;
         END IF;
      ELSE 
         desc_pronto := 0;   
      END IF;
      --desc_pronto := CASE WHEN itipo_venta = 'C' AND row_cliente.estatus_credito = ANY(ARRAY[1,4]) THEN desc_pronto ELSE 0::numeric END;
      /*Hasta aqui lo agregado*/
    
      --Obtener id de plazo de pago
      IF itipo_venta = 'D' THEN
         select split_part(value_reference,',',2)::integer INTO iPayment_term_id FROM ir_property WHERE name = 'property_payment_term_id' and  res_id = 'res.partner,'||icliente;
      ELSE
         iPayment_term_id := 1;
      END IF;
    
      select id INTO id_origen from utm_source where case when iclave = iclave_cte THEN upper(name) = 'CLICK-CLIENTE' else upper(name) = 'CLICK-VENDEDOR' end;
      select id INTO id_crm_team from crm_team where name = 'Website';
        
      SELECT warehouse_id, user_id INTO iWarehouse_id,iuser_id FROM res_partner WHERE id = ipartner_shopping_id;
       
      SELECT concat(prefix,'/',EXTRACT(YEAR FROM now()),'/',lpad(nextval('ir_sequence_'||is2.id||'')::text, padding, '0'),suffix) INTO ifolio_origen from stock_warehouse sw 
      JOIN ir_sequence is2 on is2.id=sw.national_sale_sequence_id
      WHERE sw.id=iWarehouse_id;
       
      IF (SELECT count(distinct cc.sucursal_id) from click_carrito cc WHERE cliente=icliente AND upper(trim(clave_cte))=upper(trim(iclave)) AND flag_actvo = true AND tipo_usuario = itipo_usuario) > 1 then
         SELECT concat(prefix,'/',EXTRACT(YEAR FROM now()),'/',lpad(nextval('ir_sequence_'||is2.id||'')::text, padding, '0'),suffix) INTO ifolio_nac FROM stock_warehouse sw 
         JOIN ir_sequence is2 on is2.id=sw.national_sale_sequence_id
         WHERE sw.id=iWarehouse_id;
         icount:=(select count(distinct cc.sucursal_id) from click_carrito cc WHERE cliente=icliente AND upper(trim(clave_cte))=upper(trim(iclave)) AND flag_actvo = true AND tipo_usuario = itipo_usuario);
      ELSE
         ifolio_nac:=null;
      END IF;
    
        
      FOR isucursal IN SELECT DISTINCT(sucursal_id) as sucursal_id  from click_carrito cc WHERE cliente=icliente AND upper(trim(clave_cte))=upper(trim(iclave)) AND flag_actvo = true AND tipo_usuario =itipo_usuario
      LOOP 
          /*28523,'pruebaec'*/
          --iJournal_id
          FOR row_sucursal IN SELECT sw.id as suc_id,local_journal_id,foreign_journal_id,free_ship_minimum,parcel_route_id FROM stock_warehouse sw where sw.id=isucursal.sucursal_id
          LOOP       
             --Obtener Consecutivo de Pedido
             bpedido_prime:=false;
             SELECT nextval('sale_order_id_seq') into ifolio;
             IF row_sucursal.suc_id<>iWarehouse_id THEN
                SELECT concat(prefix,'/',EXTRACT(YEAR FROM now()),'/',lpad(nextval('ir_sequence_'||is2.id||'')::text, padding, '0'),suffix) INTO iname FROM stock_warehouse sw 
                JOIN ir_sequence is2 on is2.id=sw.national_sale_sequence_id
                  WHERE sw.id=row_sucursal.suc_id;
                  ifolio_nac:=ifolio_origen;
             ELSE
                IF bprime AND p_tipe_dist_morsa = 'REPARTO MORSA' THEN
                   --raise notice 'Entro en if bprime';
                   SELECT concat(prefix,'/',EXTRACT(YEAR FROM now()),'/',lpad(nextval('ir_sequence_'||is2.id||'')::text, padding, '0'),suffix) INTO iname FROM stock_warehouse sw 
                   JOIN ir_sequence is2 on is2.id=sw.prime_orders_sequence_id
                   WHERE sw.id=iWarehouse_id;
                   SELECT coalesce(prime_orders_without_cost,false) INTO iprime_without_cost FROM res_partner WHERE id = icliente;
                   bpedido_prime:=true;
                   IF iprime_without_cost = false THEN
                      binsertar_prime := true;
                   END IF;
                ELSE 
                  --raise notice 'Entro en else bprime';
                   bpedido_prime:=false;
                   SELECT concat(prefix,lpad(nextval('ir_sequence_526')::text, padding, '0'),suffix) INTO iname FROM ir_sequence where code= 'CK'; 
                END IF;
             END IF;   
                
             IF iWarehouse_id = row_sucursal.suc_id THEN
                --raise notice 'Entro sucursales iguales';
                    sale_bool:=false;
                    iJournal_id:=(SELECT account_journal_id FROM res_partner rp WHERE rp.id=ipartner_shopping_id);--icliente --row_sucursal.local_journal_id;
    
                  IF p_tipo_envio = 'parcel_service' THEN 
                     icarrier_id:=iflete;
                  ELSE
                     icarrier_id:=null;
                  END IF;
                  ishipping_types:=p_tipo_envio;
                  SELECT case when p_tipe_dist_morsa = 'REPARTO MORSA' THEN 'dist_morsa' ELSE NULL END INTO idist_morsa;
               ELSE 
                  iJournal_id:=row_sucursal.foreign_journal_id;
                  sale_bool:=true;
                  icarrier_id:=(SELECT id FROM delivery_carrier WHERE name='ESTAFETA');
                    ishipping_types:='parcel_service';
                    idist_morsa:=null;  
               END IF;
           
         
             --Guardar los codigos no facturables
             INSERT INTO click_lineas_no_facturables(codigo,cantidad,surtido,precio,preciooriginal,precio_oferta,oferta,importe,cliente,estatus,clave_cte,tipo_usuario)
             SELECT cc.codigo_art,cc.cantidad,cc.surtido,cc.precio,cc.precio_original,cc.precio_oferta,cc.oferta,0.00,cc.cliente,pt.status_id,cc.clave_cte,cc.tipo_usuario FROM click_carrito AS cc
             INNER JOIN product_template AS pt ON cc.codigo_art = pt.name
             INNER JOIN exinno_status es ON es.id = pt.status_id
             WHERE upper(trim(cc.clave_cte))=upper(trim(iclave)) 
             AND cc.cliente=icliente AND (es.code = 4 OR (es.code IN (2,3) AND cc.surtido=0))  
             AND cc.flag_actvo = true AND cc.tipo_usuario = itipo_usuario and cc.sucursal_id =row_sucursal.suc_id;
    
             --Eliminar Codigos no Facturables del Carrito 
             DELETE FROM click_carrito WHERE id IN
             (
               SELECT cc.id FROM click_carrito AS cc 
               INNER JOIN product_template AS pt ON cc.codigo_art = pt.name
               INNER JOIN exinno_status es ON es.id = pt.status_id
               WHERE upper(trim(cc.clave_cte))=upper(trim(iclave)) 
               AND cc.cliente=icliente 
               AND (es.code = 4 OR (es.code IN (2,3) AND cc.surtido=0))  
               AND cc.flag_actvo = true AND cc.tipo_usuario = itipo_usuario and cc.sucursal_id=row_sucursal.suc_id
             );
             
             INSERT INTO sale_order(id, name, state, date_order, create_date, partner_id, partner_invoice_id, partner_shipping_id, pricelist_id, invoice_status, note, amount_untaxed, amount_tax, amount_total, company_id, team_id,
                                    warehouse_id, delivery_price, delivery_rating_success,invoice_shipping_on_delivery, is_in_rack,carrier_id,payment_term_id,picking_policy,source_id,user_id,shipping_types,account_journal_id,way_pay_id,dist_morsa,
                                    national_sale_foil,origin_warehouse_id,parcel_route_id,national_sale_bool,payment_term_month_id,is_prime,rfc_generic)
             values (ifolio, iname, 'draft', now(), now(), icliente, icliente, ipartner_shopping_id, 1,'no', icomentarios, 0, 0,0,1,id_crm_team,
                     row_sucursal.suc_id,0.0,false, false, false,icarrier_id,COALESCE(iPayment_term_id,1),'one',id_origen,iuser_id,ishipping_types,iJournal_id,c_metodo_pago::integer,idist_morsa,
                     ifolio_nac,iWarehouse_id,row_sucursal.parcel_route_id,sale_bool,ipayment_term_month_id,bpedido_prime,bgeneric_rfc);  
                   
               FOR linea IN SELECT ifolio as id,cc.codigo_art,cc.cantidad,cc.surtido,CASE WHEN cc.precio_oferta > 0 THEN cc.precio_oferta ELSE cc.precio END AS precio,cc.cliente::char AS cliente,cc.sucursal_id as sucursal,cc.flag_urgente,
                          pro.uom_id,pp.id as product_id,pro.supplier_id,pro.line_id,pro.currency_two_id,tax.amount::numeric as iva,tax.id as tax_id,cc.precio_sin_redondeo FROM click_carrito cc
                          left JOIN product_template pro on cc.codigo_art = pro.name
                          left JOIN product_product pp on pp.product_tmpl_id = pro.id
                          left JOIN product_taxes_rel ptr on ptr.prod_id = pro.id
                          left JOIN account_tax tax on tax.id = ptr.tax_id
                          WHERE cc.cliente=icliente AND upper(trim(cc.clave_cte))=upper(trim(iclave)) AND cc.flag_actvo = true AND cc.tipo_usuario =itipo_usuario and cc.sucursal_id =row_sucursal.suc_id
               LOOP
                --Obtener Consecutivo de Orden
                SELECT nextval('sale_order_line_id_seq') INTO iorden;
                -- sale_order_flag = true; -- Se cambia a true para que solo inserte encabezado una vez
                sale_order_id := ifolio;
                isubtotal_sin_iva := 0;
                itotal_con_iva := 0;
                itotal_con_iva := (linea.cantidad * linea.precio) * (1 + (linea.iva / 100));
                isubtotal_sin_iva := linea.cantidad * linea.precio;
    
                INSERT INTO sale_order_line(id,order_id, name,invoice_status,price_unit,price_subtotal,price_tax,price_total,price_reduce,price_reduce_taxinc,price_reduce_taxexcl,discount,product_id,product_uom_qty,product_uom,qty_delivered,
                            qty_to_invoice,qty_invoiced,currency_id,company_id, order_partner_id,is_downpayment,state,customer_lead,amt_to_invoice,amt_invoiced,create_date,write_date,is_delivery,supplier_id,line_id,original_price)
                VALUES(iorden,ifolio,linea.codigo_art,'no',linea.precio,/*price_unit*/(linea.cantidad * linea.precio), /*price_subtotal*/(linea.cantidad * linea.precio) * (linea.iva / 100), /*price_tax*/
                (linea.cantidad * linea.precio) * (1 + (linea.iva / 100)),/*price_total*/linea.precio - (linea.precio * desc_pronto / 100), /*price_reduce*/
                CASE WHEN linea.cantidad > 0 THEN itotal_con_iva / linea.cantidad ELSE 0 END,/*price_reduce_taxinc */
                CASE WHEN linea.cantidad > 0 THEN isubtotal_sin_iva ELSE 0 END,/*price_reduce_taxexcl*/
                desc_pronto,linea.product_id,linea.cantidad,linea.uom_id,0,0,0,linea.currency_two_id,1,icliente,false,'draft',0.0,0.00,0.00,now(),now(),false,linea.supplier_id,linea.line_id,linea.precio_sin_redondeo);
    
                INSERT INTO account_tax_sale_order_line_rel(sale_order_line_id,account_tax_id)
                VALUES(iorden,linea.tax_id);
                /*2024-06-18 Se agrega esta parte para ingreso de producto prime*/
                IF binsertar_prime THEN
                   FOR row_prime IN SELECT pp.id as product_id,pt.name as codigo_art,pt.list_price as precio,pt.supplier_id,pt.line_id,pt.currency_two_id,tax.amount::numeric as iva,tax.id as tax_id,pt.uom_id
                                    FROM stock_warehouse AS sw
                                    INNER JOIN product_product AS pp ON pp.id = sw.prime_product_id
                                    INNER JOIN product_template AS pt ON pt.id = pp.product_tmpl_id
                                    left JOIN product_taxes_rel ptr on ptr.prod_id = pt.id
                                    left JOIN account_tax tax on tax.id = ptr.tax_id
                                    WHERE sw.id = iWarehouse_id 
                   LOOP
                     SELECT nextval('sale_order_line_id_seq') INTO iorden;
                     sale_order_id := ifolio;
                     isubtotal_sin_iva := 0;
                     itotal_con_iva := 0;
                     itotal_con_iva := row_prime.precio * (1 + (row_prime.iva / 100));
                     isubtotal_sin_iva := row_prime.precio;
    
                     INSERT INTO sale_order_line(id,order_id,name,invoice_status,price_unit,price_subtotal,price_tax,price_total,price_reduce,price_reduce_taxinc,price_reduce_taxexcl,discount,product_id,product_uom_qty,product_uom,qty_delivered,
                                 qty_to_invoice,qty_invoiced,currency_id,company_id, order_partner_id,is_downpayment,state,customer_lead,amt_to_invoice,amt_invoiced,create_date,write_date,is_delivery,supplier_id,line_id,original_price)
                     VALUES(iorden,ifolio,row_prime.codigo_art,'no',row_prime.precio,/*price_unit*/row_prime.precio, /*price_subtotal*/row_prime.precio * (row_prime.iva / 100), /*price_tax*/
                           row_prime.precio * (1 + (row_prime.iva / 100)),/*price_total*/row_prime.precio - (row_prime.precio * desc_pronto / 100), /*price_reduce*/
                           itotal_con_iva,/*price_reduce_taxinc */
                           isubtotal_sin_iva,/*price_reduce_taxexcl*/
                           desc_pronto,row_prime.product_id,1,row_prime.uom_id,0,0,0,row_prime.currency_two_id,1,icliente,false,'draft',0.0,0.00,0.00,now(),now(),false,row_prime.supplier_id,row_prime.line_id,row_prime.precio);
    
                     INSERT INTO account_tax_sale_order_line_rel(sale_order_line_id,account_tax_id)
                     VALUES(iorden,row_prime.tax_id);
                     binsertar_prime := false;
                   END LOOP;    
                END IF;
                /*Aqui termina la parte agregada el 2024-06-18*/
             END LOOP;
    
             SELECT sum(sol.product_uom_qty * sol.price_unit),sum(sol.product_uom_qty * sol.price_unit) * (tax.amount::numeric / 100), sum(sol.product_uom_qty * sol.price_unit) * (1 + (tax.amount::numeric / 100)) INTO iamount_untaxed,iamount_tax,iamount_total
             FROM sale_order_line sol 
             INNER JOIN account_tax_sale_order_line_rel atr on atr.sale_order_line_id = sol.id
             INNER JOIN account_tax tax on tax.id = atr.account_tax_id
             WHERE sol.order_id = ifolio
             GROUP BY tax.amount;
    
             UPDATE sale_order set amount_untaxed = iamount_untaxed, amount_tax = iamount_tax,amount_total = iamount_total WHERE id = ifolio;
             id_pedido  := ifolio;
             flag       := true;
             mensaje    := 'Se guardo correctamente el pedido';
             sale_order_id := ifolio;
             RETURN NEXT;
          END LOOP;
      END LOOP;
      --Respaldar carrito 
      tparams:='';
      tparams:='cliente:'||coalesce(icliente,0)||' clave:'||coalesce(iclave,' ')||' tipo_venta:'||coalesce(itipo_venta,' ')||' flete:'||coalesce(iflete,0)||' comentarios:'||coalesce(icomentarios,' ')||' tipo_usuario:'||
      coalesce(itipo_usuario,' ')||' clave_cte:'||coalesce(iclave_cte,' ')||' socio:'||coalesce(isocio,0)||' partner_shipping_id:'||coalesce(ipartner_shopping_id,0)||' tipo_envio:'||coalesce(p_tipo_envio,' ')||
      ' p_tipe_dist_morsa:'||coalesce(p_tipe_dist_morsa,' ')||' metodo_pago:'||coalesce(c_metodo_pago,' ')||' meses:'||coalesce(imeses,0)||' prime:'||coalesce(bprime,'false')||' generic rfc:'||coalesce(bgeneric_rfc,'false');
      insert into click_carrito_bak (cliente,product_id,clave_cte,codigo_art,cantidad,surtido,precio,precio_original,precio_oferta,oferta,flag_urgente,flag_actvo,tipo_usuario,registro,partner_shipping_id,sucursal_id,id_pedido,parametros,precio_sin_redondeo)
      SELECT cliente,product_id,clave_cte,codigo_art,cantidad,surtido,precio,precio_original,precio_oferta,oferta,flag_urgente,flag_actvo,tipo_usuario,registro,partner_shipping_id,sucursal_id,ifolio,tparams,precio_sin_redondeo 
      FROM click_carrito cc WHERE upper(trim(clave_cte))=upper(trim(iclave)) AND cliente=icliente AND flag_actvo = true AND tipo_usuario = itipo_usuario;
           --Eliminar Codigos del Carrito
      DELETE FROM click_carrito cc  WHERE upper(trim(clave_cte))=upper(trim(iclave)) AND cliente=icliente AND flag_actvo = true AND tipo_usuario = itipo_usuario;
      -- EXCEPTION WHEN OTHERS THEN --Recibe todas las excepciones 
      -- id_pedido  := 0;
      -- flag       := false;
      -- mensaje    := 'click_guardar_pedido: ' || SQLERRM;  
      -- RETURN NEXT; 
    END;
    
$BODY$;

ALTER FUNCTION public.click_guardar_pedido_prime(integer, character, character, integer, character, character, character, integer, integer, character varying, character varying, character, integer, boolean, boolean)
    OWNER TO gm_admin_user;

