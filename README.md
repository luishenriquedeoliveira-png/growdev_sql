# growdev_sql
scripts do desafio de sql do growdev vem data.

Bloco A
-Na questão 2 foi adicionada uma coluna com o nome da categoria em inglês resaltar a presença da tradução e porque o enunciado menciona;

Bloco B
-Na questão 1 foi adicionada uma coluna com o nome da categoria em inglês para resaltar a presença da tradução;

Bloco C
-Nas questões 1 e 2 foi considerado somentes os pedidos com o status ('invoiced', 'shipped', 'delivered'), pois, entendo que somente esses pedidos estão de fato faturados;
-Na questão 3 não foi considerado os pedidos com o status ('canceled', 'unavailable'), pois, entendo que esses pedidos não foram de fato faturados;

Bloco D
-Nas questões 1,3 e 4 não foi considerado os pedidos com o status ('canceled', 'unavailable'), pois, entendo que esses pedidos não foram de fato faturados;

Bloco E
-Na questão 2 não foi considerado os pedidos com o status ('canceled', 'unavailable'), pois, entendo que esses pedidos não foram de fato faturados;
-Na questão 2 foram aplicadas as faixas 20%/30%/50%, com base na média de gastos por cliente para classificar as respectivas categorias solicitadas;
-Na questão 3 analisei os diferente pesos nos dados e por comparação decidi distribuir conforme a consulta.

Bloco F
-Nas questões 1 e 3 foi considerado somente os pedidos com o status ('invoiced', 'shipped', 'delivered'), pois, entendo que somente esses pedidos foram de fato faturados;
-Na questão 2 primeiro criei um CTE que agrega por categoria de produto e score (1..5), a
quantidade distinta de reviews, depois fiz um novo CTE, fazendo uma sub-query sobre o primeiro para
acrescentar uma coluna com a soma de reviews por categoria (independente de score).
o objetivo era criar um taxa ou proporção de review negativos de uma categoria
e para isso eu subtrai a coluna review_score de 5, pois, o que falta para atingir um
score maximo é a parte "negativa" de um score e multipliquei pelo número de ocorrências
do score, dividindo pelo total de scores da categoria. com isso, usando MAX, obtive a
"taxa de negatividade" mais significativa para a categoria, então ordenei por ela para
que as mais altas se destacassem listando em primeiro.

Bloco G
-Na questão 1 acrescentei a view todas as colunas das tabelas envolvidas, mas cuidei
para não repetir colunas de relacionamento entre as tabelas.

Bloco H
-Na questão 1 olhei a documentação do postgres e fiquei em dúvida entre usar este modo
de retorno ou usar parâmetros OUT ,então escolhi escrever as funções desta
forma porque achei que assim podem ser mais reutilizaveis em outras consultas.
-Nas questões 1 e 2 foi considerado somente os pedidos com o status ('invoiced', 'shipped', 'delivered'), pois, entendo que somente esses pedidos foram de fato faturados;

Bloco I
-Em todas as questões foi considerado somente os pedidos com o status ('invoiced', 'shipped', 'delivered'), pois, entendo que somente esses pedidos foram de fato faturados;