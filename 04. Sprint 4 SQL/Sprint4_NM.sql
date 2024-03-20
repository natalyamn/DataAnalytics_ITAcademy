USE operations;

/* NIVEL 1 */

#Ejercicio 1. Realiza una subconsulta que muestre a todos los usuarios con más de 30 transacciones utilizando al menos 2 tablas. 
SELECT u.*, user_trans.cant_trans 
FROM user u
JOIN (SELECT user_id, COUNT(id) AS cant_trans
		FROM transaction
		GROUP BY user_id
		HAVING cant_trans > 30) user_trans
ON u.id=user_trans.user_id;


#Ejercicio 2. Muestra el promedio de las transacciones por IBAN de las tarjetas de crédito en la compañía Donec Ltd. utilizando al menos 2 tablas.
WITH avg_trans_card AS 
(
SELECT card_id, ROUND(AVG(amount),2) AS avg_amount
FROM transaction
WHERE company_id = (SELECT company_id 
					FROM company 
					WHERE company_name='Donec Ltd')
GROUP BY card_id
)
SELECT iban, atc.avg_amount AS promedio_transaccion
FROM credit_card cc
JOIN avg_trans_card atc
ON cc.id=atc.card_id;
 
 
/* NIVEL 2 */
/* Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones fueron declinadas. */
CREATE TABLE IF NOT EXISTS card_status AS
(WITH trans_card AS 
(
SELECT 	card_id, 
		timestamp, 
        declined, 
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS row_transaction
FROM transaction
)
SELECT 	card_id AS id_tarjeta,
		CASE 
			WHEN SUM(declined) <= 2 THEN 'operativa'
			ELSE 'inoperativa'
		END AS estado_tarjeta
FROM trans_card
WHERE row_transaction <= 3 
GROUP BY id_tarjeta
HAVING COUNT(card_id) = 3
);

SELECT * FROM card_status;

#Ejercicio 1. ¿Cuántas tarjetas están activas? 
SELECT COUNT(id_tarjeta) AS 'cantidad tarjetas activas'
FROM card_status
WHERE estado_tarjeta='operativa';
 
  
/* NIVEL 3 */
/* Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transaction 
tienes product_ids. */
#Ejercicio 1. Necesitamos conocer el número de veces que se ha vendido cada producto. 
WITH ventas AS
(
SELECT 	product_id,
		SUM(CASE WHEN declined = 0 THEN 1 ELSE 0 END) AS cant_acept,
		SUM(CASE WHEN declined = 1 THEN 1 ELSE 0 END) AS cant_rech,
        COUNT(product_id) AS cant_tot
FROM transaction_product tp
JOIN transaction t 
ON tp.transaction_id = t.id
GROUP BY product_id
ORDER BY product_id
)
SELECT 	p.*,
        IFNULL(v.cant_acept,0) AS cantidad_vendida,
        IFNULL(v.cant_rech,0) AS cantidad_rechazada,
        IFNULL(cant_tot,0) AS cantidad_total
FROM product p
LEFT JOIN ventas v
ON v.product_id=p.id;

----------------------------------------------------------------------------

WITH transacciones AS
(
SELECT 	tp.*, t.declined
FROM transaction_product tp
JOIN transaction t
ON tp.transaction_id=t.id
)
SELECT 	product_name AS producto, 
		SUM(CASE WHEN declined=0 THEN 1 ELSE 0 END) AS cantidad_vendida,
        SUM(CASE when declined=1 THEN 1 ELSE 0 END) AS cantidad_rechazada,
        COUNT(product_id) AS cantidad_total
FROM product p
LEFT JOIN transacciones t
	ON t.product_id=p.id
GROUP BY producto
ORDER BY cantidad_total DESC, producto;