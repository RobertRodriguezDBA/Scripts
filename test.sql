select * 
from v_diario_picking
order by creacion desc
limit 100;

--
select is_validate_uuid, count(is_validate_uuid)
from stock_package 
group by is_validate_uuid

--

select 
ru.id, ru.login, ru.company_id, ru.partner_id,
rc.name
from res_users ru
join res_company rc on ru.company_id = rc.id
where active 
-- and partner_id=1211516
and login like 'ZAP%'
-- limit 200;

