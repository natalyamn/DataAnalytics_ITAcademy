USE transactions_2;

/* NIVEL 1 */

-- Ejercicio 1
#Muestra todas las transacciones realizadas por empresas de Alemania. 
SELECT *
FROM transaction
WHERE company_id IN (SELECT id
					FROM company
					WHERE country='Germany');


-- Ejercicio 2
/*Marketing está preparando algunos informes de cierres de gestión, te piden que les pases un listado de las empresas que han realizado 
transacciones por una suma superior a la media de todas las transacciones.*/
SELECT *
FROM company
WHERE id IN (SELECT company_id
			FROM transaction
			WHERE amount > (
							SELECT AVG(amount)
							FROM transaction
                            )
			);


-- Ejercicio 3 
/*El departamento de contabilidad perdió la información de las transacciones realizadas por una empresa, pero no recuerdan su nombre, 
sólo recuerdan que su nombre iniciaba con la letra c. ¿Cómo puedes ayudarles? Coméntelo acompañándolo de la información de las transacciones.*/
SELECT company_c.company_name, t.* 
FROM transaction t, 
	(SELECT id, company_name
	FROM company
	WHERE company_name LIKE 'c%') company_c
WHERE t.company_id=company_c.id;

     
-- Ejercicio 4
#Eliminaron del sistema a las empresas que no tienen transacciones registradas, entrega el listado de estas empresas.
SELECT id, company_name
FROM company c
WHERE NOT EXISTS (SELECT 1
				FROM transaction t
                WHERE c.id=t.company_id);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* NIVEL 2 */

-- Ejercicio 1 --> CORRECCION: utilizo subquery correlacionada en SELECT
/*En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía Non Institute. 
Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.*/
SELECT (SELECT company_name FROM company c WHERE c.id=t.company_id) AS nombre_compañia,
		t.*
FROM transaction t 
WHERE company_id IN (SELECT id
					FROM company
					WHERE country =	(SELECT country
									FROM company
									WHERE company_name='Non Institute')
					);

                    
-- Ejercicio 2 --> CORRECCION: calculo el monto máximo con subquery
#El departamento de contabilidad necesita que encuentres a la empresa que ha realizado la transacción de mayor suma en la base de datos.
SELECT 	*,
		(SELECT MAX(amount) FROM transaction) AS monto_transaccion
FROM company
WHERE id = (SELECT company_id
			FROM transaction
			ORDER BY amount DESC
			LIMIT 1);


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* NIVEL 3 */

-- Ejercicio 1 --> CORRECCION: utilizo subquery correlacionada en SELECT
/*Se están estableciendo los objetivos de la empresa para el siguiente trimestre, por lo que necesitan una sólida base para evaluar el rendimiento y 
medir el éxito en los diferentes mercados. Para ello, necesitan el listado de los países cuyo promedio de transacciones sea superior al promedio general.*/
SELECT (SELECT country FROM company c WHERE c.id=t.company_id) AS pais,
		ROUND(AVG(amount),2) AS promedio_transacciones
FROM transaction t
GROUP BY pais
HAVING promedio_transacciones > (
								SELECT AVG(amount) 
								FROM transaction
                                )
ORDER BY promedio_transacciones DESC;


-- Ejercicio 2 --> CORRECCION: utilizo subquery correlacionada en SELECT
/*Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información sobre 
la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas donde 
especifiques si tienen más de 4 o menos transacciones.*/
SELECT 	(SELECT company_name FROM company c WHERE c.id=t.company_id) AS nombre_compañia,
		company_id AS identificador_compañia,
		SUM(CASE WHEN declined=0 THEN 1 ELSE 0 END) AS transacciones_aceptadas,
		IFNULL(SUM(CASE WHEN declined=1 THEN 1 END),0) AS transacciones_rechazadas,
		COUNT(*) AS total_transacciones, 
        CASE
			WHEN COUNT(*) < 4 THEN 'Menos de 4 transacciones'
            WHEN COUNT(*) = 4 THEN '4 transacciones'
            ELSE 'Más de 4 transacciones'
		END AS descripcion_transacciones
FROM transaction t
GROUP BY identificador_compañia
ORDER BY total_transacciones DESC, identificador_compañia;
