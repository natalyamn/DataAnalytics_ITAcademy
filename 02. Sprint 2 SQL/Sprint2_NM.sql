/* NIVEL 1 */

-- Ejercicio 1
#Muestra todas las transacciones realizadas por empresas de Alemania. 
-- método 1: con subquery 
#subquery: 
SELECT id
FROM transactions.company
WHERE country='Germany';

#query principal
SELECT *
FROM transactions.transaction
WHERE company_id IN (SELECT id
					FROM transactions.company
					WHERE country='Germany');

-- método 2: con JOIN
SELECT t.*
FROM transactions.transaction t
JOIN transactions.company c
    ON t.company_id=c.id
WHERE country='Germany';


-- Ejercicio 2
/*Marketing está preparando algunos informes de cierres de gestión, te piden que les pases un listado de las empresas que han realizado 
transacciones por una suma superior a la media de todas las transacciones.*/
-- subquery 1: 
SELECT ROUND(AVG(amount),2)
FROM transactions.transaction
WHERE declined=0;
-- subquery 2: 
SELECT company_id, amount
FROM transactions.transaction
WHERE declined=0 AND amount > (SELECT ROUND(AVG(amount),2)
								FROM transactions.transaction
								WHERE declined=0);

-- método 1: query principal con subconsultas en la cláusula JOIN:
SELECT c.*
FROM transactions.company AS c
JOIN (SELECT company_id, amount
		FROM transactions.transaction
		WHERE declined=0 AND amount > (SELECT ROUND(AVG(amount),2)
								FROM transactions.transaction
								WHERE declined=0)
		) AS comp_trans_sup
ON c.id=comp_trans_sup.company_id
GROUP BY company_id
ORDER BY company_id;

-- método 2: query principal con subconsulta en la cláusula HAVING:
SELECT c.*
FROM transactions.company AS c
JOIN transactions.transaction AS t
ON c.id=t.company_id
WHERE declined=0 AND amount > (SELECT ROUND(AVG(amount),2)
								FROM transactions.transaction
								WHERE declined=0)
GROUP BY company_id
ORDER BY company_id;


-- Ejercicio 3
/*El departamento de contabilidad perdió la información de las transacciones realizadas por una empresa, pero no recuerdan su nombre, 
sólo recuerdan que su nombre iniciaba con la letra c. ¿Cómo puedes ayudarles? Coméntelo acompañándolo de la información de las transacciones.*/
-- método 1: con subquery
#subquery:
SELECT id, company_name
FROM transactions.company
WHERE company_name LIKE 'c%';

#query principal 
SELECT compañias_c.company_name AS nombre_compañia, t.* 
FROM transactions.transaction t
JOIN (SELECT id, company_name
	FROM transactions.company
	WHERE company_name LIKE 'c%') compañias_c
ON t.company_id=compañias_c.id;

-- método 2: con JOIN
SELECT c.company_name AS nombre_compañia, t.* 
FROM transactions.company c
JOIN transactions.transaction t
ON c.id=t.company_id
WHERE company_name LIKE 'c%';

    
-- Ejercicio 4
#Eliminaron del sistema a las empresas que no tienen transacciones registradas, entrega el listado de estas empresas.
-- subquery:
SELECT DISTINCT company_id
FROM transactions.transaction;

-- query principal:
SELECT id, company_name
FROM transactions.company c
WHERE NOT EXISTS (SELECT DISTINCT company_id
				FROM transactions.transaction t
                WHERE c.id=t.company_id);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* NIVEL 2 */

-- Ejercicio 1
/*En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía Non Institute. 
Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.*/
-- subquery: 
SELECT country
FROM transactions.company
WHERE company_name='Non Institute';

-- query principal:
SELECT company_name AS nombre_compañia, t.*
FROM transactions.transaction t
JOIN transactions.company c
	ON t.company_id=c.id
WHERE c.country=(SELECT country
				FROM transactions.company
				WHERE company_name='Non Institute');
                

-- Ejercicio 2
#El departamento de contabilidad necesita que encuentres a la empresa que ha realizado la transacción de mayor suma en la base de datos.
-- subquery:
SELECT company_id, SUM(amount) AS suma_transaccion
FROM transactions.transaction
WHERE declined=0
GROUP BY company_id
ORDER BY suma_transaccion DESC
LIMIT 1;

-- query principal con subquery en JOIN
SELECT c.*, sum_trans.suma_transaccion
FROM transactions.company AS c
JOIN (SELECT company_id, SUM(amount) AS suma_transaccion
		FROM transactions.transaction
		WHERE declined=0
		GROUP BY company_id
		ORDER BY suma_transaccion DESC
		LIMIT 1) AS sum_trans
ON c.id=sum_trans.company_id;

-- query principal con subquery en HAVING
SELECT c.*, SUM(amount) AS suma_transaccion
FROM transactions.company AS c
JOIN transactions.transaction AS t
	ON c.id=t.company_id
WHERE declined=0
GROUP BY company_id
HAVING suma_transaccion=(SELECT SUM(amount) 
						FROM transactions.transaction
						WHERE declined=0
						GROUP BY company_id
						ORDER BY SUM(amount) DESC
						LIMIT 1);


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* NIVEL 3 */

-- Ejercicio 1
/*Se están estableciendo los objetivos de la empresa para el siguiente trimestre, por lo que necesitan una sólida base para evaluar el rendimiento y 
medir el éxito en los diferentes mercados. Para ello, necesitan el listado de los países cuyo promedio de transacciones sea superior al promedio general.*/
-- subquery:
SELECT round(AVG(amount),2) AS promedio_general
FROM transactions.transaction
WHERE declined=0;

-- query principal: 
SELECT c.country AS pais, 
		round(AVG(amount),2) AS promedio_transacciones
FROM transactions.company c 
JOIN transactions.transaction t 
    ON c.id=t.company_id
WHERE declined=0
GROUP BY pais
HAVING promedio_transacciones > (SELECT round(AVG(amount),2)
								FROM transactions.transaction
								WHERE declined=0);


-- Ejercicio 2
/*Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información sobre 
la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas donde 
especifiques si tienen más de 4 o menos transacciones.*/
-- operaciones aceptadas
SELECT company_id, COUNT(*) AS aceptadas
FROM transactions.transaction t
WHERE declined=0 
GROUP BY company_id;

-- operaciones rechazadas
SELECT company_id, COUNT(*) AS rechazadas
FROM transactions.transaction t
WHERE declined=1
GROUP BY company_id;

-- query principal
SELECT 	c.company_name AS nombre_compañia,
		t_acep.company_id AS identificador_compañia, 
		t_acep.aceptadas AS transacciones_aceptadas, 
		IFNULL(t_rech.rechazadas,0) AS transacciones_rechazadas, 
        CASE
			WHEN (t_acep.aceptadas + IFNULL(t_rech.rechazadas,0)) < 4 THEN 'Menos de 4 transacciones'
            ELSE 'Más de 4 transacciones'
		END AS cantidad_transacciones
FROM (SELECT company_id, COUNT(*) AS aceptadas
		FROM transactions.transaction 
		WHERE declined=0 
		GROUP BY company_id) t_acep
LEFT JOIN (SELECT company_id, COUNT(*) AS rechazadas
			FROM transactions.transaction 
			WHERE declined=1 
			GROUP BY company_id) t_rech
	ON t_acep.company_id=t_rech.company_id
JOIN transactions.company c
	ON t_acep.company_id=c.id
ORDER BY transacciones_aceptadas DESC, identificador_compañia;


-- metodo 2: definiendo las tablas de operaciones aceptadas y rechazadas al inicio y haciendo la consulta a continuación
WITH 
t_acep AS 
(SELECT company_id, COUNT(*) AS aceptadas
FROM transactions.transaction t
WHERE declined=0 
GROUP BY company_id), 
t_rech AS 
(SELECT company_id, COUNT(*) AS rechazadas
FROM transactions.transaction t
WHERE declined=1
GROUP BY company_id)
SELECT 	c.company_name AS nombre_compañia,
		t_acep.company_id AS identificador_compañia, 
		t_acep.aceptadas AS transacciones_aceptadas, 
		IFNULL(t_rech.rechazadas,0) AS transacciones_rechazadas, 
        CASE
			WHEN (t_acep.aceptadas + IFNULL(t_rech.rechazadas,0)) < 4 THEN 'Menos de 4 transacciones'
            ELSE 'Más de 4 transacciones'
		END AS cantidad_transacciones
FROM t_acep
LEFT JOIN t_rech
	ON t_acep.company_id=t_rech.company_id
JOIN transactions.company c
	ON t_acep.company_id=c.id
ORDER BY transacciones_aceptadas DESC, identificador_compañia;