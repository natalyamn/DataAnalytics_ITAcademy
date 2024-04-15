USE transactions_2;

/* NIVEL 1 */

-- Ejercicio 1
/* A partir de los documentos adjuntos (estructura_datos y datos_introducir), importa las dos tablas.
Muestra las principales características del esquema creado y explica las diferentes tablas y variables que existen.
Asegúrate de incluir un diagrama que ilustre la relación entre las distintas tablas y variables. */

-- Ejercicio 2
#Realiza la siguiente consulta: Tienes que obtener el nombre, email y país de cada compañía, ordena los datos en función del nombre de las compañías.
SELECT 	company_name, 
		email, 
        country
FROM company
ORDER BY company_name;

-- Ejercicio 3
#Desde la sección de marketing te solicitan que les pases un listado de los países que están realizando compras.
SELECT DISTINCT country AS pais
FROM company
ORDER BY pais;

-- Ejercicio 4
#Desde marketing también quieren saber desde cuántos países se realizan las compras.
SELECT COUNT(DISTINCT country) AS cantidad_paises
FROM company;

-- Ejercicio 5
#Tu jefe identifica un error con la compañía que tiene identificador 'b-2354'. Por tanto, te solicita que le indiques el país y nombre de compañía de este identificador. 
SELECT country, company_name
FROM company
WHERE id='b-2354';

-- Ejercicio 6
#Además, tu jefe te solicita que indiques ¿cuál es la compañía con mayor gasto medio? 
SELECT 	company_id, 
		company_name, 
        round(AVG(t.amount),2) AS gasto_promedio
FROM transaction t
JOIN company c	
	ON t.company_id=c.id
WHERE declined=0 
GROUP BY company_id
ORDER BY gasto_promedio DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* NIVEL 2 */

-- Ejercicio 1
/* Tu jefe está redactando un informe de cierre del año y te solicita que le envíes información relevante para el documento. 
Para ello te solicita verificar si en la base de datos existen compañías con identificadores (id) duplicados.*/
SELECT COUNT(id) - COUNT(DISTINCT id) AS 'cantidad compañias duplicadas'
FROM company;

SELECT COUNT(company_id) AS 'cantidad total de compañias', 
	COUNT(DISTINCT company_id) AS 'cantidad de compañias unicas'
FROM transaction; 

-- Ejercicio 2
#¿En qué día se realizaron las cinco ventas más costosas? Muestra la fecha de la transacción y la sumatoria de la cantidad de dinero.
SELECT DATE(timestamp) AS Fecha_transacción,
		SUM(amount) AS cantidad_dinero
FROM transaction
WHERE declined=0
GROUP BY Fecha_transacción
ORDER BY cantidad_dinero DESC
LIMIT 5;

-- Ejercicio 3
#¿En qué día se realizaron las cinco ventas de menor valor? Muestra la fecha de la transacción y la sumatoria de la cantidad de dinero. 
SELECT DATE(timestamp) AS Fecha_transacción,
		SUM(amount) AS cantidad_dinero
FROM transaction
WHERE declined=0
GROUP BY Fecha_transacción
ORDER BY cantidad_dinero ASC
LIMIT 5;

-- Ejercicio 4
#¿Cuál es el promedio de gasto por país? Presenta los resultados ordenados de mayor a menor promedio.
SELECT 	country AS pais, 
		ROUND(AVG(amount),2) AS gasto_promedio
FROM company c
JOIN transaction t
	ON c.id=t.company_id
WHERE declined=0
GROUP BY pais
ORDER BY gasto_promedio DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* NIVEL 3 */

-- Ejercicio 1
/* Presenta el nombre, teléfono y país de las compañías, junto con la cantidad total gastada, de aquellas que realizaron transacciones con un gasto comprendido 
entre 100 y 200 euros. Ordena los resultados de mayor a menor cantidad gastada. */
SELECT 	company_name, 
        phone, 
        country,
        amount
FROM company c
JOIN transaction t
    ON c.id=t.company_id
WHERE declined=0 AND amount BETWEEN 100 AND 200
ORDER BY amount DESC;

-- Ejercicio 2
#Indica el nombre de las compañías que realizaron compras el 16 de marzo de 2022, 28 de febrero de 2022 y 13 de febrero de 2022.
-- Nombre de las compañias y detalles sobre las transacciones efectuadas en las fechas indicadas
SELECT 	company_id, 
		company_name, 
        amount, 
        timestamp AS Fecha_hora_transaccion
FROM company c
JOIN transaction t
    ON c.id=t.company_id
WHERE DATE(timestamp) IN ('2022-03-16', '2022-02-28', '2022-02-13')
ORDER BY Fecha_hora_transaccion;

-- Nombre e identificativo de las compañias 
SELECT 	company_id, 
		company_name
FROM company c
JOIN transaction t
    ON c.id=t.company_id
WHERE DATE(timestamp) IN ('2022-03-16', '2022-02-28', '2022-02-13')
GROUP BY company_id;