-- FUNCTION: public.click_busqueda_por_descripcion_sys(text, integer, text, integer, integer, boolean, integer)

-- DROP FUNCTION IF EXISTS public.click_busqueda_por_descripcion_sys(text, integer, text, integer, integer, boolean, integer);

CREATE OR REPLACE FUNCTION public.api_busqueda_por_descripcion_sys(
	iquery text,
	icliente integer,
	iclave_cte text,
	ilimit integer,
	ioffset integer,
	icount boolean,
	p_partner_shipping_id integer)
    RETURNS SETOF type_click_busqueda_por_descripcion_new 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  reg type_click_busqueda_por_descripcion_new;
  str_search2 text;
  str_search3 text;
  frags record;
  vcount integer;
  v_socio integer;
  v_valor_venta numeric(10, 4);
  iWarehouse_id integer;
  vquery text;
  tquery text;
  vcliente integer;
  vlimit text;
  exist_local integer;
  exist_foraneo integer;
  ilocal text;
  iforaneo text;
  isystem integer;
BEGIN
/*
 CREATE TYPE public.type_click_busqueda_por_descripcion_new AS (
    product_id int4,
    product_id_tm int4,
    codigo_art varchar(50),
    nombre_art bpchar(40),
    marca bpchar(30),
    aplicacion text,
    rating int4,
    estatus int4,
    precio numeric,
    precio_original numeric,
    existencia int4,
    "local" bool,
    foraneo bool,
    multiplo_venta int4,
    oferta bool,
    total_registros int4,
    multi_branch bool,
    is_outlet boolean,
    descto_outlet numeric(5,2),
    categoria varchar,
    descto_matriz numeric); */

  v_socio:=0;
  vcliente:=0;
  tquery:='';  
  vlimit:='limit '||ilimit||' offset '|| ioffset;
  select warehouse_id into iWarehouse_id from res_partner where id = p_partner_shipping_id;
  select count(*) into vcount from v_click_busqueda_por_descripcion pt where pt.codigo_art = upper(iquery);
  IF substr(iquery,1,18) = 'SEARCHOUTLETSYSTEM' THEN
     isystem:= substr(iquery,19,2)::integer;
     IF icount = true THEN
        FOR reg IN SELECT null as product_id,null as product_id_tm, null as codigo_art, null as nombre_art, null as marca, null as aplicacion, null as rating, null as estatus,null as precio,null as precio_original,
                   null as existencia,null as local, null as foraneo, null as multiplo_venta, null as oferta,count(*) as total_registros,null as multi_branch, null as is_outlet,null as descto_outlet from v_click_busqueda_por_descripcion pt
                   where pt.system_id = isystem
        LOOP
           RETURN NEXT reg;
       END LOOP;
     ELSE 
         FOR reg IN SELECT pt.pp_id as product_id,pt.pt_id,trim(pt.codigo_art) as codigo_art,pt.descrip as nombre_art,pt.marca,pt.application as aplicacion,6 as raiting,pt.code::integer as estatus,0 as precio,
                    pt.standard_price_morsa::numeric(10,2) as precio_original,
                    (SELECT coalesce(sum(sq.quantity-sq.reserved_quantity),0)
                     from stock_quant sq
                     inner join stock_location sl on sl.id = sq.location_id
                     where sq.product_id = pt.pp_id and sl.warehouse_id = iWarehouse_id and sl.is_stock = true
                    ) as existencia,
                    false as local, false as foraneo,pt.multiple as multiplo_venta,pt.oferta,null as total_registros,pt.multi_branch,
                    case when veo.codigo_art is not null then 'true' else 'false' end as is_outlet,
                    case when veo.codigo_art is not null then pt.outlet_discount else 0 end as descto_outlet,'e' as categoria,0.00 as descto_matriz  
                    from v_click_busqueda_por_descripcion pt left join v_exis_outlet_x_suc veo on veo.codigo_art=pt.codigo_art and veo.warehouse_id=iWarehouse_id 
                    where pt.system_id = isystem order by existencia desc,pt.codigo_art limit ilimit offset  ioffset
         LOOP
            reg.existencia := case when reg.existencia < 0 then 0 else  reg.existencia end;
                
            select v.existencia into exist_local from exis_sucursal_producto v where v.product_id=reg.product_id and v.sucursal_id=iWarehouse_id;
            IF NOT FOUND THEN 
               reg.local=false;
            ELSE 
               reg.local=true;
            END IF;
                  
            SELECT v.existencia into exist_foraneo from exis_sucursal_producto v where v.product_id=reg.product_id and v.sucursal_id<>iWarehouse_id;
            IF NOT FOUND THEN 
               reg.foraneo=false;
            ELSE 
               reg.foraneo=true;
            END IF; 
            SELECT categoria,descto_matriz INTO reg.categoria,reg.descto_matriz FROM click_categoria_dscto(icliente,reg.product_id);
            RETURN NEXT reg;
         END LOOP;
     END IF;
  ELSE --System 
      IF vcount = 1 THEN
         IF icount = true THEN
            FOR reg IN SELECT null as product_id,null as product_id_tm, null as codigo_art, null as nombre_art, null as marca, null as aplicacion, null as rating, null as estatus,null as precio,null as precio_original,
                       null as existencia,null as local, null as foraneo, null as multiplo_venta, null as oferta,count(*) as total_registros,null as multi_branch, null as is_outlet,null as descto_outlet 
                       from v_click_busqueda_por_descripcion pt
                       where pt.codigo_art = upper(iquery) 
            LOOP
               RETURN NEXT reg;
            END LOOP;
         ELSE 
            FOR reg IN SELECT pt.pp_id as product_id,pt.pt_id,trim(pt.codigo_art) as codigo_art,pt.descrip as nombre_art,pt.marca,pt.application as aplicacion,6 as raiting,pt.code::integer as estatus,0 as precio,
                       pt.standard_price_morsa::numeric(10,2) as precio_original, 0 as existencia,false as local, false as foraneo,pt.multiple as multiplo_venta,pt.oferta,null as total_registros,pt.multi_branch,
                       case when veo.codigo_art is not null then 'true' else 'false' end as is_outlet,
                       case when veo.codigo_art is not null then pt.outlet_discount else 0 end as descto_outlet,'e' as categoria,0.0 as descto_matriz
                       from v_click_busqueda_por_descripcion pt left join v_exis_outlet_x_suc veo on veo.codigo_art=pt.codigo_art and veo.warehouse_id=iWarehouse_id
                       where pt.codigo_art = upper(iquery) 
            LOOP
               SELECT coalesce(sum(sq.quantity-sq.reserved_quantity),0) into reg.existencia from stock_quant sq
               inner join stock_location sl on sl.id = sq.location_id
               where sq.product_id = reg.product_id and sl.warehouse_id = iWarehouse_id and sl.is_stock = true;
               
               reg.existencia := case when reg.existencia < 0 then 0 else  reg.existencia end;
                
               select v.existencia into exist_local from exis_sucursal_producto v where v.product_id=reg.product_id and v.sucursal_id=iWarehouse_id;
               IF NOT FOUND THEN 
                  reg.local=false;
               ELSE 
                  reg.local=true;
               END IF;
                  
               SELECT v.existencia into exist_foraneo from exis_sucursal_producto v where v.product_id=reg.product_id and v.sucursal_id<>iWarehouse_id;
               IF NOT FOUND THEN 
                  reg.foraneo=false;
               ELSE 
                  reg.foraneo=true;
               END IF; 
               SELECT categoria,descto_matriz INTO reg.categoria,reg.descto_matriz FROM click_categoria_dscto(icliente,reg.product_id);
               RETURN NEXT reg;
            END LOOP;
         END IF;
      ELSE
           --tquery:='%'||replace(replace(replace(replace(replace(replace(replace(replace(iquery,' de ',' '),' DE ',' '),' para ',' '),' PARA ',' '),'''', ''),'.', ''), '-', ''), '*', '')||'%';
         tquery:='%'||iquery||'%';
         select count(*) into vcount from v_click_busqueda_por_descripcion pt where pt.codigo ilike tquery;
         IF vcount >= 1 THEN
            IF icount = true THEN
               vquery:='';
               vquery:='select null as product_id,null as product_idtm ,null as codigo_art, null as nombre_art, null as marca, null as aplicacion, null as rating, null as estatus,null as precio,null as precio_original,
                        null as existencia,null as local, null as foraneo, null as multiplo_venta,null as oferta,count(*) as total_registros,null as multi_branch, null as is_outlet,null as descto_outlet
                        from v_click_busqueda_por_descripcion pt
                        where pt.codigo ilike '''||tquery||''' ';
                       raise notice 'query 1: %',vquery;
               FOR reg IN EXECUTE vquery
               LOOP
                  RETURN NEXT reg;
               END LOOP;
            ELSE
               vquery:='';
               vquery:='select pt.pp_id as id,pt.pt_id,pt.codigo_art,pt.descrip as nombre_art,pt.marca,pt.application as aplicacion,6 as raiting,pt.code::integer as estatus, 0 as precio,
                        pt.standard_price_morsa::numeric(10,2) as precio_original,
                        coalesce((select sum(sq.quantity-sq.reserved_quantity) from stock_quant sq inner join stock_location sl on sl.id=sq.location_id where sq.product_id = pt.pp_id and sl.is_stock 
                                  and sl.warehouse_id ='||iWarehouse_id||' group by sq.product_id),0) as existencia,
                        false as local,false as foraneo,pt.multiple as multiplo_venta,pt.oferta, null as total_registros,pt.multi_branch,
                        case when veo.codigo_art is not null then '''||'true'||''' else '''||'false'||''' end as is_outlet,
                        case when veo.codigo_art is not null then pt.outlet_discount else 0 end as descto_outlet,'''||'e'||''' as categoria,0.0 as descto_matriz
                        from v_click_busqueda_por_descripcion pt left join v_exis_outlet_x_suc veo on veo.codigo_art=pt.codigo_art and veo.warehouse_id='||iWarehouse_id||'
                        where pt.codigo ilike '''||tquery||''' ORDER BY existencia Desc '||vlimit;
                    raise notice 'query 2: %',vquery;
               FOR reg IN EXECUTE vquery
               LOOP
                  reg.existencia := case when reg.existencia < 0 then 0 else  reg.existencia end;   
                  select v.existencia into exist_local from exis_sucursal_producto v where v.product_id=reg.product_id and v.sucursal_id=iWarehouse_id;
                  IF NOT FOUND THEN 
                    reg.local=false;
                  ELSE 
                    reg.local=true;
                  END IF;
                  
                  select v.existencia into exist_foraneo from exis_sucursal_producto v where v.product_id=reg.product_id and v.sucursal_id<>iWarehouse_id;
                  IF NOT FOUND THEN 
                    reg.foraneo=false;
                  ELSE 
                    reg.foraneo=true;
                  END IF; 
                  SELECT categoria,descto_matriz INTO reg.categoria,reg.descto_matriz FROM click_categoria_dscto(icliente,reg.product_id);
                  RETURN NEXT reg;
               END LOOP;
            END IF;
         ELSE
            str_search2 := ' ';
            FOR frags in select unnest(regexp_split_to_array(replace(replace(replace(replace(replace(replace(replace(iquery,' de ',' '),' DE ',' '),' para ',' '),' PARA ',' '),'''', ''),'-', ''), '*', ''),E'\\s+')) as campo 
            LOOP
               IF str_search2 = ' ' THEN
                  str_search2 = str_search2 || ' tsl.description ilike E''%' || frags.campo || '%''';
               ELSE
                  str_search2 = str_search2 || ' and tsl.description ilike E''%' || frags.campo || '%''';
               END IF;
            END LOOP;
              
            str_search3='select tsl.pp_id,tsl.pt_id,tsl.codigo_art,tsl.status_id,tsl.marca,descrip,tsl.application,tsl.standard_price_morsa,tsl.multiple,tsl.oferta,tsl.code,tsl.multi_branch,
                         case when veo.codigo_art is not null then '''||'true'||''' else '''||'false'||''' end as is_outlet,
                         case when veo.codigo_art is not null then tsl.outlet_discount else 0 end as descto_outlet,'''||'e'||''' as categoria,0.00 as descto_matriz
                         from v_click_busqueda_por_descripcion tsl left join 
                         v_exis_outlet_x_suc veo on veo.codigo_art=tsl.codigo_art and veo.warehouse_id='||iWarehouse_id||'
                         where ' || str_search2;
            IF icount = true THEN
               vquery:='select null as product_id,null as product_id_tm,null as codigo_art,null as nombre_art,null as marca,null as aplicacion,null as rating,null as status,null as precio,null as precio_original,
                        null as existencia,null as local,null as foraneo,null as multiplo_venta,null as oferta,count(*) as total_registros,null as multi_branch,null as is_outlet,null as descto_outlet 
                        from (select l.codigo_art,l.status_id from ('||str_search3||') l) pp';
                        raise notice 'query 3: %',vquery;   
               FOR reg IN EXECUTE vquery
               LOOP
                  RETURN NEXT reg;
               END LOOP;
            ELSE 
               vquery:='select r.pp_id,r.pt_id,r.codigo_art,r.descrip as nombre_art,r.marca,r.application as aplicacion,6 AS num_clasif,r.code::integer as estatus,0 as precio,r.standard_price_morsa::numeric(10,2) as precio_original,
                        case when r.existencia<0 then 0 else r.existencia end as existencia,false as local,false as foraneo,r.multiple as multiplo_venta,r.oferta,0 as total_registros,r.multi_branch,r.is_outlet,r.descto_outlet,r.categoria
                        from (select l.pp_id,l.pt_id,l.codigo_art,l.marca,l.descrip,l.application,l.status_id,l.standard_price_morsa,l.multiple,l.oferta,l.code,coalesce((select sum(sq.quantity-sq.reserved_quantity)
                              from stock_quant sq inner join stock_location sl on sl.id = sq.location_id 
                              where l.standard_price_morsa is not null and sq.product_id = l.pp_id and sl.is_stock = true and sl.warehouse_id ='||iWarehouse_id||' 
                              group by sq.product_id),0) as existencia,l.multi_branch,l.is_outlet,l.descto_outlet,l.categoria,l.descto_matriz
                              from ('||str_search3||') l 
                              order by existencia desc,l.codigo_art limit '||ilimit||' offset  '||ioffset||'
                             ) as r order by r.existencia desc,r.descrip';
                raise notice 'query 4: %',vquery;
                FOR reg IN execute vquery
                LOOP
                   reg.existencia := case when reg.existencia < 0 then 0 else  reg.existencia end;
                   select v.existencia into exist_local from exis_sucursal_producto v where v.product_id=reg.product_id and v.sucursal_id=iWarehouse_id;
                
                   IF NOT FOUND THEN 
                      reg.local=false;
                   ELSE 
                      reg.local=true;
                   END IF;
                  
                   select v.existencia into exist_foraneo from exis_sucursal_producto v where v.product_id=reg.product_id and v.sucursal_id<>iWarehouse_id;
                 
                   IF NOT FOUND THEN 
                      reg.foraneo=false;
                   ELSE 
                      reg.foraneo=true;
                   END IF; 
                   SELECT categoria,descto_matriz INTO reg.categoria,reg.descto_matriz FROM click_categoria_dscto(icliente,reg.product_id); 
                   RETURN NEXT reg;
                END LOOP;
            END IF;  
         END IF;
      END IF;
  END IF; --System
END;
$BODY$;

ALTER FUNCTION public.click_busqueda_por_descripcion_sys(text, integer, text, integer, integer, boolean, integer)
    OWNER TO gm_admin_user;

