-- 1. Listar os 20 pedidos com status delivered mais recentes,ordenados pela data de
-- entrega:

select o.order_id,
       o.order_status,
       o.order_delivered_customer_date
from olist_orders_dataset o
where o.order_status = 'delivered'
order by o.order_delivered_customer_date desc
limit 20;

-- 2. Listar todos os produtos de uma categoria específica (usando a tabela de tradução
--para filtrar pelo nome em português):

select p.*,
       nt.product_category_name_english
from olist_products_dataset p
         join product_category_name_translation nt on
    nt.product_category_name = p.product_category_name
where p.product_category_name = 'bebes';

-- 3. Listar os métodos de pagamento distintos utilizados na base (SELECT DISTINCT
-- payment_type):

select distinct op.payment_type
from olist_order_payments_dataset op

-- 4. Listar os produtos com peso (product_weight_g) acima de 10kg, ordenados do
-- mais pesado para o mais leve:

select opd.*
from olist_products_dataset opd
where opd.product_weight_g > 10000
order by opd.product_weight_g desc;