-- Column: public.otras_entregas.id_ot

-- ALTER TABLE IF EXISTS public.otras_entregas DROP COLUMN IF EXISTS id_ot;

ALTER TABLE IF EXISTS public.otras_entregas
    ADD COLUMN id_ot integer;

-- Constraint: otras_entregas_stock_transfer_order_fkey

-- ALTER TABLE IF EXISTS public.otras_entregas DROP CONSTRAINT IF EXISTS otras_entregas_stock_transfer_order_fkey;

ALTER TABLE IF EXISTS public.otras_entregas
    ADD CONSTRAINT otras_entregas_stock_transfer_order_fkey FOREIGN KEY (id_ot)
    REFERENCES public.stock_transfer_order (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;