--1. Relatório com categoria do produto (traduzida), valor do item, cidade do vendedor:

select distinct opd.product_category_name,
                pcnt.product_category_name_english,
                ooid.price,
                osd.seller_city
from olist_order_items_dataset ooid
         join olist_sellers_dataset osd
              on osd.seller_id = ooid.seller_id
         join olist_products_dataset opd
              on opd.product_id = ooid.product_id
         join product_category_name_translation pcnt
              on pcnt.product_category_name = opd.product_category_name
order by opd.product_category_name;

-- 2. Identificar pedidos com atraso na entrega, comparando data estimada com data real
-- de entrega (join entre orders e customers):

select ood.*,
       ocd.customer_unique_id,
       ocd.customer_zip_code_prefix,
       ocd.customer_city,
       ocd.customer_state
from olist_orders_dataset ood
         join olist_customers_dataset ocd on ocd.customer_id = ood.customer_id
where ood.order_estimated_delivery_date < ood.order_delivered_customer_date
order by ood.order_delivered_customer_date desc;

-- 3. Listar pedidos e suas formas de pagamento, incluindo pedidos pagos em mais de
-- uma parcela (join entre orders e order_payments):

select ood.*,
       oopd.payment_sequential,
       oopd.payment_type,
       oopd.payment_value
from olist_orders_dataset ood
         join olist_order_payments_dataset oopd on
    oopd.order_id = ood.order_id
order by ood.order_id,
         oopd.payment_sequential;

-- 4. Listar produtos junto com a categoria traduzida, incluindo produtos cuja categoria
-- não possui tradução cadastrada (LEFT JOIN com product_category_name_translation):
select p.*,
       nt.product_category_name_english
from olist_products_dataset p
         left join product_category_name_translation nt on
    nt.product_category_name = p.product_category_name;

--5. Identificar pedidos em que o cliente e o vendedor são do mesmo estado (join entre
-- customers, orders, order_items e sellers):

select distinct ood.*,
                ocd.customer_state,
                osd.seller_state
from olist_orders_dataset ood
         join olist_customers_dataset ocd on
    ocd.customer_id = ood.customer_id
         join olist_order_items_dataset ooid on
    ooid.order_id = ood.order_id
         join olist_sellers_dataset osd
              on
                  osd.seller_id = ooid.seller_id
where ocd.customer_state = osd.seller_state
order by ocd.customer_state,
         ood.order_purchase_timestamp desc;

