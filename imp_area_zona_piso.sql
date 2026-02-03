WITH imp_area_zona_piso AS (
                    SELECT
                        isa.id AS area_id,
                        isz.id AS zone_id,
                        isz.name,
                        isz.warehouse_id
                    FROM imp_stock_zone isz
                    INNER JOIN imp_stock_area isa
                        ON isz.id = isa.zone_id
                            AND isz.warehouse_id = isa.warehouse_id
                    WHERE zone_type IN ('floor','mezzanine')
                        AND isz.warehouse_id = %(warehouse_id)s
                )
                SELECT
                    f.product_id,
                    f.zone_id,
                    CASE
                        WHEN f.qty_invoiced >= f.disponible THEN f.disponible
                        ELSE f.qty_invoiced
                    END AS qty_invoiced,
                    f.multiplo AS multiple,
                    f.master
                FROM (
                    SELECT
                        viazp.zone_id,
                        isap.id,
                        isap.area_id,
                        isap.product_id,
                        lc.quantity AS qty_invoiced,
                        lc.multiplo,
                        lc.master,
                        (lc.quantity / lc.multiplo)::integer AS paquetes,
                        COALESCE(isap.product_max_qty, 0) - COALESCE(isqi.quantity_receipt, 0) - (SUM(COALESCE(isqil.quantity, 0) - COALESCE(isqil.reserved_sale, 0))) AS disponible,
                        ((COALESCE(isap.product_max_qty, 0) - COALESCE(isqi.quantity_receipt, 0) - (SUM(COALESCE(isqil.quantity, 0) - COALESCE(isqil.reserved_sale, 0)))) / lc.multiplo)::integer AS paquetes_disponibles
                    FROM (
                        SELECT
                            stl.product_id,
                            SUM(COALESCE(stl.pick_qty, 0)) AS quantity,
                            multi.multiplo,
                            multi.master
                        FROM stock_transfer_line stl
                        INNER JOIN (
                            SELECT
                                pp.id AS product_id,
                                enable_masters AS master,
                                CASE
                                    WHEN enable_masters THEN masters_pack_multiple
                                    ELSE multiple
                                END AS multiplo
                            FROM product_template pt
                            INNER JOIN product_product pp
                                ON pt.id = pp.product_tmpl_id
                            WHERE pt.type != 'consu'
                        ) multi
                            ON stl.product_id = multi.product_id
/* variable stl.transfer_id IN ot_ids */
                        WHERE stl.transfer_id IN %(ot_ids)s
                            AND stl.pick_qty IS NOT NULL
                            AND stl.pick_qty > 0
                        GROUP BY stl.product_id, multi.multiplo, multi.master
                    ) lc
                    INNER JOIN imp_stock_area_product isap
                        ON lc.product_id = isap.product_id
                    INNER JOIN imp_area_zona_piso viazp
                        ON viazp.area_id = isap.area_id
                    LEFT JOIN imp_stock_quant_info isqi
                        ON isap.product_id = isqi.product_id
/* variable isqi.warehouse_id = warehouse_id */
                            AND isqi.warehouse_id = %(warehouse_id)s
                    LEFT JOIN (
                        imp_stock_quant_info_line isqil
                        INNER JOIN stock_location sl
                            ON isqil.location_id = sl.id
                        INNER JOIN imp_area_zona_piso viazp2
                            ON viazp2.area_id = sl.area_id
                                AND viazp2.zone_id = sl.zone_id
                    )
                        ON isqi.id = isqil.info_id
                    WHERE viazp.zone_id IS NOT NULL
                    GROUP BY
                        isap.id,
                        isap.area_id,
                        isap.product_id,
                        viazp.zone_id,
                        isqi.quantity_receipt,
                        lc.quantity,
                        lc.multiplo,
                        lc.master
                ) f
                WHERE f.paquetes_disponibles > 0
 
                UNION ALL
 
                SELECT
                    s.product_id,
                    isz.id AS id_zone,
                    s.resta AS qty_invoiced,
                    s.multiplo AS multiple,
                    s.master
                FROM (
                    SELECT
                        f.product_id,
                        f.zone_id,
                        CASE
                            WHEN f.paquetes_disponibles < 0 THEN f.paquetes * f.multiplo
                            WHEN f.qty_invoiced > f.disponible THEN f.qty_invoiced - f.disponible
                            ELSE 0
                        END AS resta,
                        f.multiplo,
                        f.master
                    FROM (
                        SELECT
                            viazp.zone_id,
                            isap.id,
                            isap.area_id,
                            isap.product_id,
                            lc.quantity AS qty_invoiced,
                            lc.multiplo,
                            lc.master,
                            (lc.quantity / lc.multiplo)::integer AS paquetes,
                            COALESCE(isap.product_max_qty, 0) - COALESCE(isqi.quantity_receipt, 0) - (SUM(COALESCE(isqil.quantity, 0) - COALESCE(isqil.reserved_sale, 0))) AS disponible,
                            ((COALESCE(isap.product_max_qty, 0) - COALESCE(isqi.quantity_receipt, 0) - (SUM(COALESCE(isqil.quantity, 0) - COALESCE(isqil.reserved_sale, 0)))) / lc.multiplo)::integer AS paquetes_disponibles
                        FROM (
                            SELECT
                                stl.product_id,
                                SUM(COALESCE(stl.pick_qty, 0)) AS quantity,
                                multi.multiplo,
                                multi.master
                            FROM stock_transfer_line stl
                            INNER JOIN (
                                SELECT
                                    pp.id AS product_id,
                                    enable_masters AS master,
                                    CASE
                                        WHEN enable_masters THEN masters_pack_multiple
                                        ELSE multiple
                                    END AS multiplo
                                FROM product_template pt
                                INNER JOIN product_product pp
                                    ON pt.id = pp.product_tmpl_id
                                WHERE pt.type != 'consu'
                            ) multi
                                ON stl.product_id = multi.product_id
/* variable stl.transfer_id IN ot_ids */
                            WHERE stl.transfer_id IN %(ot_ids)s
                            GROUP BY stl.product_id, multi.multiplo, multi.master
                        ) lc
                        INNER JOIN imp_stock_area_product isap
                            ON lc.product_id = isap.product_id
                        INNER JOIN imp_area_zona_piso viazp
                            ON viazp.area_id = isap.area_id
                        LEFT JOIN imp_stock_quant_info isqi
                            ON isap.product_id = isqi.product_id
                                AND isqi.warehouse_id = %(warehouse_id)s
                        LEFT JOIN (
                            imp_stock_quant_info_line isqil
                            INNER JOIN stock_location sl
                                ON isqil.location_id = sl.id
                            INNER JOIN imp_area_zona_piso viazp2
                                ON viazp2.area_id = sl.area_id
                                    AND viazp2.zone_id = sl.zone_id
                        ) ON isqi.id = isqil.info_id
                        WHERE viazp.zone_id IS NOT NULL
                        GROUP BY
                            isap.id,
                            isap.area_id,
                            isap.product_id,
                            viazp.zone_id,
                            isqi.quantity_receipt,
                            lc.quantity,
                            lc.multiplo,
                            lc.master
                    ) f
                    WHERE f.paquetes_disponibles < f.paquetes
                ) s
                LEFT JOIN imp_stock_area_product isap
                    ON s.product_id = isap.product_id
                LEFT JOIN imp_stock_area isa
                    ON isap.area_id = isa.id
                INNER JOIN imp_stock_zone isz
                    ON isa.zone_id = isz.id
                        AND isz.zone_type = 'selective'
/* variable isqi.warehouse_id = warehouse_id */
                        AND isz.warehouse_id = %(warehouse_id)s
                ORDER BY product_id
