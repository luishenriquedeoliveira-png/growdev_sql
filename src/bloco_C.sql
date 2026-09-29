-- Bloco C — Funções agregadas + GROUP BY + HAVING

-- 1. Faturamento total por estado do cliente:

select ocd.customer_state,
       sum(ooid.price) as billing_total
from olist_orders_dataset ood
         join olist_customers_dataset ocd on
    ocd.customer_id = ood.customer_id
         join olist_order_items_dataset ooid on
    ooid.order_id = ood.order_id
where ood.order_status in ('invoiced', 'shipped', 'delivered')
group by ocd.customer_state;


-- 2. Top 10 vendedores por faturamento:
select osd.seller_id,
       sum(ooid.price) as billing_total
from olist_orders_dataset ood
         join olist_order_items_dataset ooid on
    ooid.order_id = ood.order_id
         join olist_sellers_dataset osd on
    osd.seller_id = ooid.seller_id
where ood.order_status in ('invoiced', 'shipped', 'delivered')
group by osd.seller_id
order by billing_total desc
limit 10;

-- 3. Ticket médio por categoria de produto
-- select distinct ood.order_status from olist_orders_dataset ood 
select opd.product_category_name,
       avg(ooid.price) as ticket_avg
from olist_orders_dataset ood
         join olist_order_items_dataset ooid on
    ooid.order_id = ood.order_id
         join olist_products_dataset opd on
    opd.product_id = ooid.product_id
where ood.order_status not in ('canceled', 'unavailable')
group by opd.product_category_name;

-- 4. Vendedores com nota média de avaliação abaixo de 3 (HAVING AVG(...) < 3):
select osd.seller_id,
       avg(oord.review_score) as review_score_avg
from olist_orders_dataset ood
         join olist_order_reviews_dataset oord on
    oord.order_id = ood.order_id
         join olist_order_items_dataset ooid on
    ooid.order_id = ood.order_id
         join olist_sellers_dataset osd on
    osd.seller_id = ooid.seller_id
group by osd.seller_id
having avg(oord.review_score) < 3;

-- 5. Quantidade de pedidos por forma de pagamento (GROUP BY payment_type):
select oopd.payment_type,
       count(distinct oopd.order_id) orders_count
from olist_orders_dataset ood
         join olist_order_payments_dataset oopd on
    oopd.order_id = ood.order_id
group by oopd.payment_type
order by orders_count desc;

-- 6. Peso médio dos produtos por categoria.
select opd.product_category_name,
       avg(opd.product_weight_g) as avg_product_weight_g
from olist_products_dataset opd
group by opd.product_category_name
order by avg_product_weight_g desc;

-- 7. Número médio de parcelas (AVG(payment_installments)) por categoria de produto:
select opd.product_category_name,
       avg(oopd.payment_installments) as payment_installments_avg
from olist_orders_dataset ood
         join olist_order_payments_dataset oopd on
    oopd.order_id = ood.order_id
         join olist_order_items_dataset ooid on
    ooid.order_id = ood.order_id
         join olist_products_dataset opd on
    opd.product_id = ooid.product_id
group by opd.product_category_name
order by payment_installments_avg desc;
