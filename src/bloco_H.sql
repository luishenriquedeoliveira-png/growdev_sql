-- Bloco H — Procedure de leitura (parametrizada)

-- 1. Criar a procedure/function sp_relatorio_vendedor(id_vendedor,
-- data_inicio, data_fim), que retorna faturamento, ticket médio e nota média
-- de avaliação do vendedor no período informado — sem alterar nenhum dado:

-- Olhei a documentação do postgres e fiquei em dúvia entre usar este modo
-- de retorno ou usar parâmetros OUT. Escolhi escrever as funções desta
-- forma porque achei que assim podem ser mais reutilizaveis em outras
-- consultas.

create or replace function sp_relatorio_vendedor(id_vendedor varchar,
                                                 data_inicio date,
                                                 data_fim date)
    returns table
            (
                billing_total    real,
                billing_avg      real,
                review_score_avg integer
            )
as
$$
select sum(ooid.price)        as billing_total,
       avg(ooid.price)        as billing_avg,
       avg(oord.review_score) as review_score_avg
from olist_orders_dataset ood
         join olist_order_reviews_dataset oord
              on oord.order_id = ood.order_id
         join olist_order_items_dataset ooid
              on ooid.order_id = ood.order_id
         join olist_sellers_dataset osd
              on osd.seller_id = ooid.seller_id
where ood.order_status in ('invoiced', 'shipped', 'delivered')
  and ood.order_purchase_timestamp::date between data_inicio and data_fim
  and ooid.seller_id = id_vendedor;
$$ language sql;

select *
from sp_relatorio_vendedor('1f50f920176fa81dab994f9023523100', '2017-01-01', '2018-01-01');

-- 2. Criar a procedure/function sp_relatorio_categoria(categoria,
-- data_inicio, data_fim), que retorna faturamento total e ticket médio da
-- categoria de produto no período informado:

create or replace function sp_relatorio_categoria(categoria varchar,
                                                  data_inicio date,
                                                  data_fim date)
    returns table
            (
                billing_total real,
                billing_avg   real
            )
as
$$
select sum(ooid.price) as billing_total,
       avg(ooid.price) as billing_avg
from olist_orders_dataset ood
         join olist_order_items_dataset ooid
              on ooid.order_id = ood.order_id
         join olist_products_dataset opd
              on opd.product_id = ooid.product_id
where ood.order_status in ('invoiced', 'shipped', 'delivered')
  and ood.order_purchase_timestamp::date between data_inicio and data_fim
  and opd.product_category_name = categoria
$$ language sql;

select * from sp_relatorio_categoria('brinquedos', '2017-01-01', '2018-01-01');