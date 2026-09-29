--Bloco F — CTE / tabela temporária

--1. Construir uma CTE de faturamento mensal por estado e, a partir dela, calcular a
-- variação percentual de um mês para o outro:

-- Não fica claro na estrutura quais são os pedidos que devem ser considerados para
-- representar faturamento. Então fiz um select distinct dos diferente status dos
-- pedidos, e selecionei status que julguei indicar fases em que o pedido já estaria
-- de fato faturado;

with state_month_billing_q as (
    select ocd.customer_state,
           to_char((ood.order_purchase_timestamp::date - interval '1 month'), 'YYYY/MM') billing_previous_month,
           to_char(ood.order_purchase_timestamp::date, 'YYYY/MM')                        billing_month,
           sum(ooid.price) as                                                            billing_total
    from olist_orders_dataset ood
             join olist_customers_dataset ocd on
        ocd.customer_id = ood.customer_id
             join olist_order_items_dataset ooid on
        ooid.order_id = ood.order_id
    where ood.order_status in ('invoiced', 'shipped', 'delivered')
    group by ocd.customer_state,
             to_char((ood.order_purchase_timestamp::date - interval '1 month'), 'YYYY/MM'),
             to_char(ood.order_purchase_timestamp::date, 'YYYY/MM'))
select sbq.customer_state,
       sbq.billing_month,
       sbq.billing_total,
       case
           when psb.billing_total is not null then sbq.billing_total * 100 / psb.billing_total - 100
           else null
           end billing_month_variation
from state_month_billing_q sbq
         left join state_month_billing_q psb on
        psb.customer_state = sbq.customer_state
        and psb.billing_month = sbq.billing_previous_month
order by sbq.customer_state,
         sbq.billing_month;

-- 2. Construir uma CTE com volume de avaliações e nota média por categoria de
-- produto, usada para identificar as categorias com pior reputação (nota média mais
-- baixa e volume relevante de avaliações):

-- Primeiro criei um CTE que agrega por categoria de produto e score (1..5), a
-- quantidade distinta de reviews;
-- Depois fiz um novo CTE, fazendo uma sub-query sobre o primeiro para para
-- acrescentar uma coluna com a soma de reviews por categoria (independente de score).
-- Por fim o objetivo era criar um taxa ou proporção de review negativos de uma categoria.
-- E para isso eu subtrai a coluna review_score de 5, pois o que falta para atingir um
-- score maximo é a parte "negativa" de um score, e multipliquei pelo número de ocorrências
-- do score, dividindo pelo total de scores da categoria. Com isso, usando MAX, obtive a
-- "taxa de negatividade" mais significativa para a categoria. Então ordenei por ela para
-- que as mais altas se destacassem listando em primeiro.
with product_review_score_q as (
    select opd.product_category_name,
           oord.review_score,
           count(distinct oord.review_id) as review_score_count
    from olist_order_items_dataset ooid
             join olist_order_reviews_dataset oord on
        oord.order_id = ooid.order_id
             join olist_products_dataset opd on
        opd.product_id = ooid.product_id
    group by opd.product_category_name,
             oord.review_score),
     product_review_q as (
         select q.product_category_name,
                q.review_score,
                q.review_score_count,
                (select sum(review_score_count)
                 from product_review_score_q s
                 where s.product_category_name = q.product_category_name) as sum_review_score_count
         from product_review_score_q q)
select r.product_category_name,
       r.sum_review_score_count                                                    as review_score_count,
       sum(r.review_score * r.review_score_count / r.sum_review_score_count)       as review_score_avg,
       max((5 - r.review_score) * r.review_score_count / r.sum_review_score_count) as negative_reputation_ratio
from product_review_q r
group by r.product_category_name,
         r.sum_review_score_count
order by negative_reputation_ratio desc;

-- 3. Construir uma CTE de frete médio por estado do cliente, usada para comparar cada
-- estado com a média geral de frete.
with state_freight_q as (
    select ocd.customer_state,
           avg(ooid.freight_value) as freight_value_avg
    from olist_orders_dataset ood
             join olist_customers_dataset ocd on
        ocd.customer_id = ood.customer_id
             join olist_order_items_dataset ooid on
        ooid.order_id = ood.order_id
    where ood.order_status in ('invoiced', 'shipped', 'delivered')
    group by ocd.customer_state),
     general_state_freight_q as (
         select sum(b.freight_value_avg) as total_freight_value
         from state_freight_q b)
select q.customer_state,
       q.freight_value_avg,
       t.total_freight_value,
       q.freight_value_avg / t.total_freight_value * 100 as freight_value_percentage
from state_freight_q q
         cross join general_state_freight_q t
order by q.freight_value_avg desc