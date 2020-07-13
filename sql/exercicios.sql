
-- Avaliação de Conhecimento de SQL


---------------------
-- EXERCÍCIO 1 SQL --
---------------------

-- Na tabela listings existem diversas informações relacionadas aos
-- anúncios presentes no site do Airbnb. Encontre os 10 tipos de
-- imóveis (property type) com maior número de anúncios únicos no
-- estado do Rio de Janeiro.	  


-- SOLUÇÃO

-------------
-- PASSO 1 --
-------------

-- Fazendo análise exploratória no campo state para identificar padrão da base de dados

SELECT UPPER(state),COUNT(*)
FROM public.listing
GROUP BY UPPER(state)
ORDER BY COUNT(*) desc;



-------------
-- PASSO 2 --
-------------

-- Excluindo padrões identificados no campo state para verificar o que resta

SELECT state, city, COUNT(DISTINCT id)
FROM public.listing 
GROUP BY state, city
HAVING UPPER(state) not LIKE'%RIO DE JANEIRO%' AND
	   UPPER(state) <> 'RJ' AND
	   UPPER(state) <> 'ESTADO DE RÍO DE JANEIRO' 
ORDER BY COUNT(DISTINCT id) desc;


-------------
-- PASSO 3 --
-------------

-- Excluindo também os padrões identificados no campo city para verificar o que resta

SELECT state, city,neighbourhood_cleansed, COUNT(DISTINCT id)
FROM public.listing 
GROUP BY state, city,neighbourhood_cleansed
HAVING UPPER(state) NOT LIKE'%RIO DE JANEIRO%' AND
	   UPPER(state) <> 'RJ' AND
	   UPPER(state) <> 'ESTADO DE RÍO DE JANEIRO' AND 
       UPPER(city) NOT LIKE '%RIO DE JANEIRO%' AND
	   UPPER(city) NOT LIKE '%RJ - LAPA%' AND
	   UPPER(city) NOT LIKE '%COPACABANA%' AND
	   UPPER(city) <> 'RIO'
ORDER BY COUNT(DISTINCT id) desc;


-- Não identificado mais nenhum registro do estado RJ


-------------
-- PASSO 4 --
-------------

-- Consulta Final --

-- Na tabela listings existem diversas informações relacionadas aos
-- anúncios presentes no site do Airbnb. Encontre os 10 tipos de
-- imóveis (property type) com maior número de anúncios únicos no
-- estado do Rio de Janeiro.	  


SELECT property_type, COUNT(DISTINCT id) qtde_anuncios
FROM public.listing 
WHERE  UPPER(state) LIKE'%RIO DE JANEIRO%' OR
	   UPPER(state) = 'RJ' OR
	   UPPER(state) = 'ESTADO DE RÍO DE JANEIRO' OR
       UPPER(city) LIKE '%RIO DE JANEIRO%' OR
	   UPPER(city) LIKE '%RJ - LAPA%' OR
	   UPPER(city) LIKE '%COPACABANA%' OR
	   UPPER(city) = 'RIO'
GROUP BY property_type 
ORDER BY COUNT(DISTINCT id) DESC
LIMIT 10;





---------------------
-- EXERCÍCIO 2 SQL --
---------------------


-- Na tabela calendar é possível encontrar a disponibilidade
-- (available, onde 't' indica que está disponível e 'f' indica
-- indisponibilidade) dos anúncios de acordo com o dia, o valor e o
-- número de noites. Encontre o número de anúncios únicos, do
-- tipo apartamento (Apartment), disponíveis por semana no mês de
-- outubro de 2019.


-------------
-- PASSO 1 --
-------------

- Breve análise exploratória das tabelas

SELECT count(*)
FROM public.calendar c;

-- 12.530.122 LINHAS

SELECT *
FROM public.calendar c 
LIMIT 10;

SELECT *
FROM public.listing l 
LIMIT 10;


-- CONVERTER DT_DATA E EXTRAIR ANO, MÊS E SEMANA DO ANO
-- LIMPAR E CONVETER COLUNA PRICE
-- JOIN TABELA LISTING COM CALENDAR FILTRANDO TIPO = 'APARTMENT'
-- CONTAR APARTAMENTOS UNICOS DISPONIVEIS POR SEMANA EM OUTUBRO DE 2019



-------------
-- PASSO 2 --
-------------

-- Criar tabela temporaria filtrando dados de Out'19 de locais disponíveis para locação
-- Converter campo de data para tipo date, substituir cifrão por nada e extrair ano, mês e semana do ano

DROP TABLE IF EXISTS calendar_2019_10_available;

CREATE TEMP TABLE calendar_2019_10_available as
SELECT c.listing_id, 
	   TO_DATE(c.dt_data,'yyyy-mm-dd') AS DATE,
       DATE_PART('week',TO_DATE(c.dt_data,'yyyy-mm-dd')) week_of_year,
       DATE_PART('year',TO_DATE(c.dt_data,'yyyy-mm-dd')) year_,
       DATE_PART('month',TO_DATE(c.dt_data,'yyyy-mm-dd')) month_,
       c.price,
       c.adjusted_price, 
       CAST(REPLACE(REPLACE(c.price,'$',''),',','') AS DOUBLE PRECISION) price_n,
       CAST(REPLACE(REPLACE(c.adjusted_price,'$',''),',','') AS DOUBLE PRECISION) adjusted_price_n,
       c.available,
	   c.minimum_nights,
	   c.maximum_nights 
FROM public.calendar c
WHERE  DATE_PART('year',TO_DATE(c.dt_data,'yyyy-mm-dd')) = 2019 AND
   	   DATE_PART('month',TO_DATE(c.dt_data,'yyyy-mm-dd')) = 10 AND
       c.available ='t';


SELECT * FROM calendar_2019_10_available LIMIT 1000;

SELECT *	
FROM calendar_2019_10_available
WHERE price_n > 100000;

SELECT * 
FROM calendar_2019_10_available
WHERE listing_id = '13879989' 

-- identificada possível inconsistência de preço da diária nas sextas e sábados para listing_id ='13879989'
-- que fica 1000x mais caro que demais dias 1.664.310,00
-- Como não afeta análise em questão é possível averiguar posteriormente se trata-se realmente de erro


      
-- verifica se há ids duplicados no mesmo dia

SELECT listing_id, date, COUNT(listing_id)
FROM calendar_2019_10_available 
GROUP BY listing_id, date
HAVING COUNT(listing_id) >1
ORDER BY COUNT(listing_id) DESC;


-------------
-- PASSO 3 --
-------------

-- Selecionar apenas locações distintas do tipo apartamento agrupando por semana do ano

SELECT c.year_,
	   c.month_,
	   c.week_of_year,
	   COUNT(DISTINCT l.id) AS qtd_apart_available	   
FROM calendar_2019_10_available c 
LEFT JOIN listing l ON c.listing_id = l.id
WHERE UPPER(l.property_type) = 'APARTMENT'
GROUP BY  c.year_,
	      c.month_,
          c.week_of_year
ORDER BY 1 ASC;