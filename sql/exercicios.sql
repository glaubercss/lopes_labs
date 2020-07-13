
-- Avalia��o de Conhecimento de SQL


---------------------
-- EXERC�CIO 1 SQL --
---------------------

-- Na tabela listings existem diversas informa��es relacionadas aos
-- an�ncios presentes no site do Airbnb. Encontre os 10 tipos de
-- im�veis (property type) com maior n�mero de an�ncios �nicos no
-- estado do Rio de Janeiro.	  


-- SOLU��O

-------------
-- PASSO 1 --
-------------

-- Fazendo an�lise explorat�ria no campo state para identificar padr�o da base de dados

SELECT UPPER(state),COUNT(*)
FROM public.listing
GROUP BY UPPER(state)
ORDER BY COUNT(*) desc;



-------------
-- PASSO 2 --
-------------

-- Excluindo padr�es identificados no campo state para verificar o que resta

SELECT state, city, COUNT(DISTINCT id)
FROM public.listing 
GROUP BY state, city
HAVING UPPER(state) not LIKE'%RIO DE JANEIRO%' AND
	   UPPER(state) <> 'RJ' AND
	   UPPER(state) <> 'ESTADO DE R�O DE JANEIRO' 
ORDER BY COUNT(DISTINCT id) desc;


-------------
-- PASSO 3 --
-------------

-- Excluindo tamb�m os padr�es identificados no campo city para verificar o que resta

SELECT state, city,neighbourhood_cleansed, COUNT(DISTINCT id)
FROM public.listing 
GROUP BY state, city,neighbourhood_cleansed
HAVING UPPER(state) NOT LIKE'%RIO DE JANEIRO%' AND
	   UPPER(state) <> 'RJ' AND
	   UPPER(state) <> 'ESTADO DE R�O DE JANEIRO' AND 
       UPPER(city) NOT LIKE '%RIO DE JANEIRO%' AND
	   UPPER(city) NOT LIKE '%RJ - LAPA%' AND
	   UPPER(city) NOT LIKE '%COPACABANA%' AND
	   UPPER(city) <> 'RIO'
ORDER BY COUNT(DISTINCT id) desc;


-- N�o identificado mais nenhum registro do estado RJ


-------------
-- PASSO 4 --
-------------

-- Consulta Final --

-- Na tabela listings existem diversas informa��es relacionadas aos
-- an�ncios presentes no site do Airbnb. Encontre os 10 tipos de
-- im�veis (property type) com maior n�mero de an�ncios �nicos no
-- estado do Rio de Janeiro.	  


SELECT property_type, COUNT(DISTINCT id) qtde_anuncios
FROM public.listing 
WHERE  UPPER(state) LIKE'%RIO DE JANEIRO%' OR
	   UPPER(state) = 'RJ' OR
	   UPPER(state) = 'ESTADO DE R�O DE JANEIRO' OR
       UPPER(city) LIKE '%RIO DE JANEIRO%' OR
	   UPPER(city) LIKE '%RJ - LAPA%' OR
	   UPPER(city) LIKE '%COPACABANA%' OR
	   UPPER(city) = 'RIO'
GROUP BY property_type 
ORDER BY COUNT(DISTINCT id) DESC
LIMIT 10;





---------------------
-- EXERC�CIO 2 SQL --
---------------------


-- Na tabela calendar � poss�vel encontrar a disponibilidade
-- (available, onde 't' indica que est� dispon�vel e 'f' indica
-- indisponibilidade) dos an�ncios de acordo com o dia, o valor e o
-- n�mero de noites. Encontre o n�mero de an�ncios �nicos, do
-- tipo apartamento (Apartment), dispon�veis por semana no m�s de
-- outubro de 2019.


-------------
-- PASSO 1 --
-------------

- Breve an�lise explorat�ria das tabelas

SELECT count(*)
FROM public.calendar c;

-- 12.530.122 LINHAS

SELECT *
FROM public.calendar c 
LIMIT 10;

SELECT *
FROM public.listing l 
LIMIT 10;


-- CONVERTER DT_DATA E EXTRAIR ANO, M�S E SEMANA DO ANO
-- LIMPAR E CONVETER COLUNA PRICE
-- JOIN TABELA LISTING COM CALENDAR FILTRANDO TIPO = 'APARTMENT'
-- CONTAR APARTAMENTOS UNICOS DISPONIVEIS POR SEMANA EM OUTUBRO DE 2019



-------------
-- PASSO 2 --
-------------

-- Criar tabela temporaria filtrando dados de Out'19 de locais dispon�veis para loca��o
-- Converter campo de data para tipo date, substituir cifr�o por nada e extrair ano, m�s e semana do ano

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

-- identificada poss�vel inconsist�ncia de pre�o da di�ria nas sextas e s�bados para listing_id ='13879989'
-- que fica 1000x mais caro que demais dias 1.664.310,00
-- Como n�o afeta an�lise em quest�o � poss�vel averiguar posteriormente se trata-se realmente de erro


      
-- verifica se h� ids duplicados no mesmo dia

SELECT listing_id, date, COUNT(listing_id)
FROM calendar_2019_10_available 
GROUP BY listing_id, date
HAVING COUNT(listing_id) >1
ORDER BY COUNT(listing_id) DESC;


-------------
-- PASSO 3 --
-------------

-- Selecionar apenas loca��es distintas do tipo apartamento agrupando por semana do ano

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