-- Bloco G — View

-- 1. Criar a view vw_pedidos_completos, consolidando pedido, cliente, itens,
-- pagamento e vendedor, para servir de base a consultas analíticas futuras.

-- Acrescentei a view todas as colunas das tabelas envolvidas, mas cuidei
-- para não repetir colunas de relacionamento e comuns entre as tabelas.
create or replace view vw_pedidos_completos as
select ood.*,
       ocd.customer_unique_id,
       ocd.customer_zip_code_prefix,
       ocd.customer_state,
       ocd.customer_city,
       oopd.payment_type,
       oopd.payment_installments,
       oopd.payment_sequential,
       oopd.payment_value,
       ooid.order_item_id,
       ooid.product_id,
       ooid.price,
       ooid.freight_value,
       ooid.seller_id,
       ooid.shipping_limit_date,
       osd.seller_zip_code_prefix,
       osd.seller_city,
       osd.seller_state
from olist_orders_dataset ood
         join olist_customers_dataset ocd on ocd.customer_id = ood.customer_id
         join olist_order_payments_dataset oopd on oopd.order_id = ood.order_id
         join olist_order_items_dataset ooid on ooid.order_id = ood.order_id
         join olist_sellers_dataset osd on osd.seller_id = ooid.seller_id;

-- 2. Criar a view vw_avaliacoes_categoria, consolidando nota média e volume de
-- avaliações por categoria de produto.

create or replace view vw_avaliacoes_categoria as
select opd.product_category_name,
       avg(oord.review_score)         as review_score_avg,
       count(distinct oord.review_id) as review_score_count
from olist_order_items_dataset ooid
         join olist_order_reviews_dataset oord on
    oord.order_id = ooid.order_id
         join olist_products_dataset opd on
    opd.product_id = ooid.product_id
group by opd.product_category_name;