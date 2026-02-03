begin;

UPDATE stock_package SET 
    is_validate_uuid = TRUE 
WHERE id IN (SELECT
    sp.id
FROM stock_package AS sp
INNER JOIN res_users_stock_package_rel AS ruspr
    ON ruspr.stock_package_id = sp.id
WHERE
    ruspr.res_users_id IN (

        SELECT 
            id 
        FROM res_users 
        WHERE 
            login IN ('VEAUXALM1',
                'VEAUXALM10',
                'VEAUXALM11',
                'VEAUXALM12',
                'VEAUXALM13',
                'VEAUXALM15',
                'VEAUXALM17',
                'VEAUXALM19',
                'VEAUXALM2',
                'VEAUXALM20',
                'VEAUXALM21',
                'VEAUXALM22',
                'VEAUXALM23',
                'VEAUXALM24',
                'VEAUXALM25',
                'VEAUXALM26',
                'VEAUXALM29',
                'VEAUXALM3',
                'VEAUXALM30',
                'VEAUXALM4',
                'VEAUXALM5',
                'VEAUXALM6',
                'VEAUXALM7',
                'VEAUXALM9',
                'VEAUXINV1',
                'VEAUXINV2',
                'VEEMPAQUE1',
                'VEEMPAQUE2',
                'VEEMPAQUE3',
                'VEEMPAQUE4',
                'VEEMPAQUE5',
                'VECOORDEMB',
                'VECOORDINV',
                'VECOORDREC',
                'VECOORDSURT')
    
    )
    AND sp.validate_by_picker = TRUE
    AND (sp.is_validate_uuid = FALSE OR sp.is_validate_uuid IS NULL)
    AND sp.create_date > (NOW() - INTERVAL '1 MONTH'))

/*
    Este bloqueo se genera cuando se asigna un pedido
    pero lo cancelan desde el picking o no funciona la cancelación de pedido

    SOLUCIÓN.
        Moficar el stock_rack  (state) a done

*/
SELECT
    1,
    sr.id,
    sr.origin,
	ru.login
FROM stock_rack AS sr
	INNER JOIN res_users AS ru
		ON ru.id = sr.user_id
WHERE ru.login IN ('VEAUXALM1',
                'VEAUXALM10',
                'VEAUXALM11',
                'VEAUXALM12')
    AND sr.state in ('pending', 'transfer', 'missing')
    AND sr.create_date > (NOW() - INTERVAL '1 MONTH')
UNION
 
 /*
    Este bloqueo se genera cuando se asigna un pedido
    se surte pero no lo han comenzado a empacar

    SOLUCIÓN.
        Modificar el stock_rack (state) a done (si es cancelado)

*/
SELECT
    2,
    sr.id,
    sr.origin,
	ru.login
FROM stock_rack AS sr
	INNER JOIN res_users AS ru
		ON ru.id = sr.user_id
WHERE ru.login IN ('VEAUXALM1',
                'VEAUXALM10',
                'VEAUXALM11',
                'VEAUXALM12')
    AND sr.state = 'ready'
    AND sr.validate_by_picker = TRUE
    AND sr.create_date > (NOW() - INTERVAL '1 MONTH')
 
UNION
 
  /*
    Este bloqueo se genera cuando se asigna un pedido
    se surte, se empaca pero no se escanea el QR del pedido y de la ubicación

    SOLUCIÓN.
        Modificar el stock_package (IS_VALIDATE_UID) a TRUE

*/
SELECT
    3,
    sp.id,
    sp.origin,
	ru.login,
    null
FROM stock_package AS sp
	INNER JOIN res_users_stock_package_rel AS ruspr
    	ON ruspr.stock_package_id = sp.id
	INNER JOIN res_users AS ru
		ON ru.id = ruspr.res_users_id
WHERE
    ru.login IN ('VEAUXALM1',
                'VEAUXALM10',
                'VEAUXALM11',
                'VEAUXALM12')
    AND sp.validate_by_picker = TRUE
    AND (sp.is_validate_uuid = FALSE OR sp.is_validate_uuid IS NULL)
    AND sp.create_date > (NOW() - INTERVAL '1 MONTH')
