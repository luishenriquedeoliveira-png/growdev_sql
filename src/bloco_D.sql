-- Bloco D — Subqueries

-- 1. Clientes cujo gasto total está acima da média geral de gasto por cliente:

with customer_spend_q as (
    select ood.customer_id,
           sum(ooid.price) as total_customer_spend
    from olist_orders_dataset ood
             join olist_order_items_dataset ooid on
        ooid.order_id = ood.order_id
    where ood.order_status not in ('canceled', 'unavailable')
    group by ood.customer_id)
select *
from customer_spend_q q
where q.total_customer_spend > (
    select avg(total_customer_spend)
    from customer_spend_q)
order by q.total_customer_spend desc;

-- 2. Produtos que nunca receberam avaliação (NOT EXISTS / NOT IN):

select distinct opd.product_id,
                opd.product_category_name
from olist_order_items_dataset ooid
         join olist_products_dataset opd on
    opd.product_id = ooid.product_id
where not exists(
        select
        from olist_order_reviews_dataset oord
        where oord.order_id = ooid.order_id)
order by opd.product_category_name;

-- 3. Vendedores que venderam produtos de mais de 5 categorias
-- diferentes (subquery com COUNT(DISTINCT ...)):

select ooid.seller_id,
       count(distinct opd.product_category_name) product_category_count
from olist_order_items_dataset ooid
         join olist_orders_dataset ood on
    ood.order_id = ooid.order_id
         join olist_products_dataset opd on
    opd.product_id = ooid.product_id
where ood.order_status not in ('canceled', 'unavailable')
group by ooid.seller_id
having count(distinct opd.product_category_name) > 5
order by product_category_count desc;

-- 4. Pedidos cujo valor de frete (freight_value) é maior que o valor total dos itens do
-- próprio pedido (subquery correlacionada comparando as duas somas):

select ood.order_id,
       sum(ooid.price)         as items_value,
       sum(ooid.freight_value) as freight_value
from olist_orders_dataset ood
         join olist_order_items_dataset ooid on
    ooid.order_id = ood.order_id
where ood.order_status not in ('canceled', 'unavailable')
group by ood.order_id
having sum(ooid.freight_value) > sum(ooid.price)
order by freight_value desc;