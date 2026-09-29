-- Bloco E — CASE WHEN

-- 1. Classificar pedidos por prazo de entrega: "adiantado", "no prazo" ou "atrasado"
-- (comparando data real x estimada):
select ood.*,
       case
           when ood.order_estimated_delivery_date < ood.order_delivered_customer_date then 'atrasado'
           when ood.order_estimated_delivery_date > ood.order_delivered_customer_date then 'adiantado'
           else 'no prazo'
           end as delivery_status
from olist_orders_dataset ood
order by ood.order_delivered_customer_date desc;

-- 2. Classificar clientes por faixa de gasto total: "bronze", "prata", "ouro".
-- * aplicadas faixas 20/30/50, com base na média de gastos por client;

with customer_spend_q as (
    select ood.customer_id,
           sum(ooid.price) as total_customer_spend
    from olist_orders_dataset ood
             join olist_order_items_dataset ooid on
        ooid.order_id = ood.order_id
    where ood.order_status not in ('canceled', 'unavailable')
    group by ood.customer_id),
     customers_spend_base_q as (
         select avg(total_customer_spend) + (avg(total_customer_spend) * 0.80) gold_spend_min,
                avg(total_customer_spend)                                      avg_spend
         from customer_spend_q)
select q.*,
       b.*,
       case
           when q.total_customer_spend >= b.gold_spend_min then 'ouro'
           when q.total_customer_spend > b.avg_spend then 'prata'
           else 'bronze'
           end as customer_class
from customer_spend_q q
         cross join customers_spend_base_q b
order by q.total_customer_spend desc;

-- 3. Classificar produtos por faixa de peso: "leve", "médio", "pesado" (com base em product_weight_g):

-- Analisei os diferente pesos nos dados e por comparação decidi distribuir conforme a consulta.

select case
           when opd.product_weight_g >= 25000 then 'pesado'
           when opd.product_weight_g >= 10000 then 'médio'
           else 'leve'
           end weight_class,
       opd.*
from olist_products_dataset opd
where opd.product_weight_g is not null
order by opd.product_weight_g desc

-- 4. Classificar pagamentos como "à vista" ou "parcelado", e dentro de parcelado
-- sinalizar parcelamentos longos (payment_installments > 6):

select ood.order_id,
       max(oopd.payment_installments) as payment_installments,
       case
           when max(oopd.payment_installments) > 1 then 'parcelado'
           else 'á vista'
           end                           payment_class,
       case
           when max(oopd.payment_installments) > 6 then '* parcelamento longo'
           else null
           end                           payment_note
from olist_orders_dataset ood
         join olist_order_payments_dataset oopd on
    oopd.order_id = ood.order_id
group by ood.order_id
order by payment_installments desc;

