-- FUNCTION: public.find_user_by_credentials_refaclub(integer, character varying, integer)

-- DROP FUNCTION IF EXISTS public.find_user_by_credentials_refaclub(integer, character varying, integer);

--CREATE OR REPLACE FUNCTION public.find_user_by_credentials_refaclub(
	p_id_cte_morsa integer,
	p_clave character varying,
	p_suc_morsa integer
    )
    RETURNS SETOF type_find_user_by_credentials 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
    /***************************************************************************** 
    -- Elaboro :  Christian Alberto Bejarano Gaxiola
    -- Fecha : 
    -- Descripcion General:  
    *****************************************************************************/
DECLARE
    /*
    CREATE TYPE type_find_user_by_credentials AS(
        id integer,
        partner_id integer,
        socio integer,
        clave varchar,
        tipo_usuario varchar,
        agente integer,
        email varchar,
        perfil varchar,
        es_credito boolean,
        cliente_nacional boolean,
        url text
        prime_deliver_time integer,
        prime_order boolean,
        costo_envio_prime numeric,
        id_sucursal integer
    );
    DROP TYPE type_find_user_by_credentials CASCADE;
    */
    datos type_find_user_by_credentials;
    ncosto_envio_pedido_prime numeric;
BEGIN
    ncosto_envio_pedido_prime := 0;
    SELECT pt.list_price INTO ncosto_envio_pedido_prime
    FROM stock_warehouse AS sw
    INNER JOIN product_product AS pp ON pp.id = sw.prime_product_id
    INNER JOIN product_template AS pt ON pt.id = pp.product_tmpl_id
    WHERE sw.branch = p_suc_morsa;

    
    FOR datos IN
        SELECT
            ac.cliente AS id,
            rp.partner_id AS partner_id,
            ac.socio AS socio,
            ac.clave_cte AS clave, 
            ac.tipo_usuario AS "tipoUsuario", ac.agente, ac.email, ac.perfil,
            case when cpc.condicion_pago='contado' then false
                 when cpc.condicion_pago='credito' then true
            end es_credito,
            rp.national_sale_client as cliente_nacional,
            mci.url as url,
            vswtp.prime_delivery_time,
            case when sw.is_order_prime and rp.allow_prime_orders then 'true' else 'false' end as order_prime,
            case when rp.prime_orders_without_cost then 0.00 else ncosto_envio_pedido_prime end as costo_envio_prime,
            sw.id as id_sucursal,
            rp.is_rfc_generic
        FROM accesos_clientes ac 
            INNER JOIN res_partner rp ON (ac.cliente = rp.id)
            INNER JOIN res_partner rp2 ON (rp2.id = ac.partner_shipping_id)
            INNER JOIN stock_warehouse sw ON (rp2.warehouse_id = sw.id)
            join condicion_pago_clientes cpc on cpc.partner_id=rp.id
            join manage_click_instances mci on mci.id=sw.manage_click_id
            inner join v_stock_warehouse_time_prime vswtp on vswtp.id = rp2.warehouse_id 
        WHERE rp.partner_id = p_id_cte_morsa 
            AND clave_cte = p_clave
            AND sw.branch = p_suc_morsa 
            AND rp.id = 102679 --Solo accesos del cliente refaclub
    LOOP
        RETURN NEXT datos;
    END LOOP;
END; 
$BODY$;

--ALTER FUNCTION public.find_user_by_credentials_refaclub(integer, character varying, integer)
--    OWNER TO gm_admin_user;

SELECT
    rp.city,
    ac.cliente AS id,
    rp.partner_id AS partner_id,
    ac.socio AS socio,
    ac.clave_cte AS clave, 
    ac.tipo_usuario AS "tipoUsuario", ac.agente, ac.email, ac.perfil,
    case when cpc.condicion_pago='contado' then false
    when cpc.condicion_pago='credito' then true
    end es_credito,
    rp.national_sale_client as cliente_nacional,
    mci.url as url,
    vswtp.prime_delivery_time,
    case when sw.is_order_prime and rp.allow_prime_orders then 'true' else 'false' end as order_prime,
    case when rp.prime_orders_without_cost then 0.00 else 0.0 end as costo_envio_prime,
    sw.id as id_sucursal,
    rp.is_rfc_generic
FROM accesos_clientes ac 
    INNER JOIN res_partner rp ON (ac.cliente = rp.id)
    INNER JOIN res_partner rp2 ON (rp2.id = ac.partner_shipping_id)
    INNER JOIN stock_warehouse sw ON (rp2.warehouse_id = sw.id)
    join condicion_pago_clientes cpc on cpc.partner_id=rp.id
    join manage_click_instances mci on mci.id=sw.manage_click_id
    inner join v_stock_warehouse_time_prime vswtp on vswtp.id = rp2.warehouse_id
--WHERE rp.id = 102679
LIMIT 100;
















