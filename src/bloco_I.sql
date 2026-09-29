--Bloco I — Window functions

-- 1. Ranking (RANK()) dos vendedores por faturamento dentro de cada estado:
select osd.seller_state,
       osd.seller_id,
       sum(ooid.price)                    as billing_total,
       rank() over (partition by osd.seller_state
           order by sum(ooid.price) desc) as rank
from olist_orders_dataset ood
         join olist_order_items_dataset ooid
              on ooid.order_id = ood.order_id
         join olist_sellers_dataset osd
              on osd.seller_id = ooid.seller_id
where ood.order_status in ('invoiced', 'shipped', 'delivered')
group by osd.seller_state,
         osd.seller_id
order by seller_state, rank;

-- 2. Faturamento mensal acumulado (SUM(...) OVER (ORDER BY ...)) por
-- vendedor:
with state_month_billing_q as (
    select ooid.seller_id,
           to_char(ood.order_purchase_timestamp::date, 'YYYY/MM') billing_month,
           sum(ooid.price) as                                     billing_total
    from olist_orders_dataset ood
             join olist_customers_dataset ocd on
        ocd.customer_id = ood.customer_id
             join olist_order_items_dataset ooid on
        ooid.order_id = ood.order_id
    where ood.order_status in ('invoiced', 'shipped', 'delivered')
    group by ooid.seller_id,
             to_char(ood.order_purchase_timestamp::date, 'YYYY/MM'))
select q.seller_id,
       q.billing_month,
       q.billing_total,
       sum(q.billing_total)
       over (partition by seller_id
           order by q.billing_month
           rows between unbounded preceding and current row )
           as billing_accumulated
from state_month_billing_q q
order by q.seller_id, q.billing_month;


-- 3. Percentual de participação de cada vendedor no faturamento total do seu estado
-- (SUM(...) OVER (PARTITION BY estado)):
select osd.seller_state,
       osd.seller_id,
       sum(ooid.price)                            as billing_total,
       sum(sum(ooid.price))
       over (partition by osd.seller_state)       as state_billing_total,
       sum(ooid.price) /
       sum(sum(ooid.price))
       over (partition by osd.seller_state) * 100 as seller_state_billing_percent
from olist_orders_dataset ood
         join olist_order_items_dataset ooid
              on ooid.order_id = ood.order_id
         join olist_sellers_dataset osd
              on osd.seller_id = ooid.seller_id
where ood.order_status in ('invoiced', 'shipped', 'delivered')
group by osd.seller_state,
         osd.seller_id
order by seller_state, seller_state_billing_percent desc;

-- 4. Variação de faturamento de um mês para o outro por vendedor, usando LAG():
with state_month_billing_q as (
    select ooid.seller_id,
           to_char(ood.order_purchase_timestamp::date, 'YYYY/MM') billing_month,
           sum(ooid.price) as                                     billing_total
    from olist_orders_dataset ood
             join olist_customers_dataset ocd on
        ocd.customer_id = ood.customer_id
             join olist_order_items_dataset ooid on
        ooid.order_id = ood.order_id
    where ood.order_status in ('invoiced', 'shipped', 'delivered')
    group by ooid.seller_id,
             to_char(ood.order_purchase_timestamp::date, 'YYYY/MM'))
select q.seller_id,
       q.billing_month,
       q.billing_total,
       q.billing_total * 100 /
       lag(q.billing_total)
       over (partition by q.seller_id
           order by q.billing_month) - 100 as billing_month_variation
from state_month_billing_q q
order by q.seller_id, q.billing_month;