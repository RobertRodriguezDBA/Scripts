set search_path to public;

 select * from imp_stock_container limit 10;


SELECT 
    isoc.container_id,
    isc.name caja,
    ispt.name mesa,
    iso.ot_id,
    iso.name ot_nombre,
    CASE 
        WHEN isc.availability = TRUE THEN 'DISPONIBLE'
        ELSE 'NO DISPONIBLE'
    END
    FROM imp_stock_order_container isoc
        JOIN imp_stock_order iso ON iso.id = isoc.order_id
        JOIN imp_stock_container isc ON isc.id = isoc.container_id
        LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id
        LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
    WHERE iso.warehouse_id = 7614
    AND isc.container_type = 'internal' 
    AND isc.name ilike '%cvb-045%';
    ;
--UNION ALL

SELECT 
    NULL  container_id,
    icmc.caja,
    icmc.mesa,
    NULL  ot_id,
    NULL  ot_nombre,
    NULL availability
   FROM imp_cajas_mesas_convey icmc
   WHERE caja ilike '%cvb-045%';

--
DROP FUNCTION buscar_contbox;
CREATE OR REPLACE FUNCTION buscar_contbox(buscar TEXT)
RETURNS TABLE(
    container_id INT,
    caja TEXT, 
    mesa TEXT, 
    ot_id INT, 
    ot_nombre TEXT, 
    disponible TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        isoc.container_id::INT,
        isc.name::TEXT caja,
        ispt.name::TEXT mesa,
        iso.ot_id::INT,
        iso.name::TEXT ot_nombre,
        CASE 
            WHEN isc.availability = TRUE THEN 'DISPONIBLE'::TEXT
            ELSE 'NO DISPONIBLE'::TEXT
        END
        FROM imp_stock_order_container isoc
            JOIN imp_stock_order iso ON iso.id = isoc.order_id
            JOIN imp_stock_container isc ON isc.id = isoc.container_id
            LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id
            LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
        WHERE iso.warehouse_id = 7614
        AND isc.container_type = 'internal' 
        AND isc.name ilike '%' || buscar || '%'
    UNION ALL
    SELECT 
            NULL::INT container_id,
            imp_cajas_mesas_convey.caja::TEXT,
            imp_cajas_mesas_convey.mesa::TEXT,
            NULL::INT  ot_id,
            NULL::TEXT ot_nombre,
            'N/A'::TEXT availability
        FROM imp_cajas_mesas_convey
        WHERE imp_cajas_mesas_convey.caja ilike '%' || buscar || '%';
END;
$$ LANGUAGE plpgsql;

--

SELECT * FROM buscar_contbox('CVB-04');
----------------------------------------------------------------------
select * from imp_cajas_mesas_convey;

select 
ispbu.ot_id,
ispbu.route_id,
ispb.name codigo
--spr.name ruta
--ispb.*
--ispbu.* 
from imp_stock_pack_box ispb
join imp_stock_pack_bundle ispbu on ispb.bundle_id = ispbu.id
--join stock_package_route spr on spr.route_id = ispbu.route_id

select * from imp_stock_pack_bundle;

select * from imp_stock_pack_box;

select * from stock_package_route;

select * from imp_stock_order;

SELECT * FROM imp_cajas_mesas_convey;

select * from stock_package_route;

-------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION buscar_contbox(buscar TEXT)
RETURNS TABLE(
    resultado TEXT, 
    tipo TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Bloque 1: Contenedores en Stock
    SELECT 
        isc.name::TEXT,
        'CONTENEDOR'::TEXT -- Bandera para el primer bloque
    FROM imp_stock_order_container isoc
        JOIN imp_stock_order iso ON iso.id = isoc.order_id
        JOIN imp_stock_container isc ON isc.id = isoc.container_id
    WHERE iso.warehouse_id = 7614
        AND isc.container_type = 'internal' 
        AND isc.name ILIKE '%' || buscar || '%'

    UNION ALL

    -- Bloque 2: Cajas en Convey
    SELECT 
        icmc.caja::TEXT,
        'CAJA'::TEXT -- Bandera para el segundo bloque
    FROM imp_cajas_mesas_convey icmc
    WHERE icmc.caja ILIKE '%' || buscar || '%'
       OR icmc.mesa ILIKE '%' || buscar || '%';
END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------

SELECT * FROM buscar_contbox('CVB-045');


-- BUSCAR
SELECT

'----ISOC',isoc.*,
'----ISO',iso.*, 
'----ISC',isc.*,
'----ISPBU',ispbu.*,
'----ISPT',ispt.*,
'----ISPB',ispb.*

FROM imp_stock_order_container isoc
    LEFT JOIN imp_stock_order iso ON iso.id = isoc.order_id
    LEFT JOIN imp_stock_container isc ON isc.id = isoc.container_id
    LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id
    LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
    LEFT JOIN imp_stock_pack_box ispb on ispb.bundle_id = ispbu.id
WHERE iso.warehouse_id = 7614
AND isc.container_type = 'internal'
--AND isc.name ilike 'CVB-008'
LIMIT 100;

/* - CVB-007
isc.name as contenedor,
ispt.availability as disponibilidad,
ispb.name as pedido_ot,
ispt.name as mesa_d
*/
/* - OT/048116.1

*/

-------------------------------------------------
Contenedor: CVB-XXX | CVB-007 | isc.name as contenedor
Disponibilidad: V/F | false | ispt.availability as disponibilidad
Pedido/OT: OT | OT/048116.1 | ispb.name as pedido_ot
Mesa destino: ispt.name as mesa_d

----------------------------------------------------

Codigo: 
Pedido:
Ruta:


 SELECT imp_cajas_mesas_convey.caja,
    imp_cajas_mesas_convey.mesa
   FROM imp_cajas_mesas_convey;

select * from v_conveyor_belt_culiacan;

--delete from imp_cajas_mesas_convey;

-------------------------------

   SELECT isc.name AS caja,
    COALESCE(ispt.name, '00'::character varying) AS mesa
   FROM imp_stock_order_container isoc
     JOIN imp_stock_order iso ON iso.id = isoc.order_id
     JOIN imp_stock_container isc ON isc.id = isoc.container_id
     LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id
     LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
  WHERE iso.warehouse_id = 7614 AND isoc.packed = false AND isc.container_type::text = 'internal'::text

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-- NUEVA FUNCION
DROP FUNCTION buscar_contbox;
----------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION buscar_contbox(buscar TEXT)
RETURNS TABLE(
    container_id INT,
    cc_nombre TEXT, 
    mesa TEXT, 
    ot_id INT, 
    ot_nombre TEXT, 
    disponible TEXT
) AS $$
BEGIN
    IF buscar ~* '^CVB-\d{3,}$' THEN
        RETURN QUERY
        SELECT 
            isoc.container_id::INT,
            isc.name::TEXT cc_nombre,
            ispt.name::TEXT mesa,
            iso.ot_id::INT,
            ispbu.name::TEXT ot_nombre,
            CASE 
                WHEN isc.availability = TRUE THEN 'DISPONIBLE'::TEXT
                ELSE 'NO DISPONIBLE'::TEXT
            END
            FROM imp_stock_order_container isoc
                JOIN imp_stock_order iso ON iso.id = isoc.order_id
                JOIN imp_stock_container isc ON isc.id = isoc.container_id
                LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id
                LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
            WHERE iso.warehouse_id = 7614
            AND isc.container_type = 'internal' 
            AND isoc.packed = false
            AND isc.name ilike '%' || buscar || '%';
        ELSIF buscar ~* '^OT\/\d+\.?\d*$' THEN
            RETURN QUERY
            SELECT 
                isoc.container_id::INT,
                isc.name::TEXT cc_nombre,
                ispt.name::TEXT mesa,
                iso.ot_id::INT,
                ispbu.name::TEXT ot_nombre,
                CASE 
                WHEN isc.availability = TRUE THEN 'DISPONIBLE'::TEXT
                ELSE 'NO DISPONIBLE'::TEXT
                END
            FROM imp_stock_order_container isoc
                JOIN imp_stock_order iso ON iso.id = isoc.order_id
                JOIN imp_stock_container isc ON isc.id = isoc.container_id
                LEFT JOIN imp_stock_pack_bundle ispbu ON ispbu.id = isoc.bundle_id
                LEFT JOIN imp_stock_pack_table ispt ON ispt.id = ispbu.table_id
            WHERE iso.warehouse_id = 7614
            AND isc.container_type = 'internal'
            AND isoc.packed = false 
            AND ispbu.name ilike '%' || buscar || '%';
    END IF;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------

SELECT * FROM buscar_contbox('CVB-144');
SELECT * FROM buscar_contbox('OT/048742.1');

set search_path to public;
select * from v_conveyor_belt_culiacan where caja = 'CVB-144';


