/* NIVEL 1 */

#Ejercicio 1. Realiza una subconsulta que muestre a todos los usuarios con más de 30 transacciones utilizando al menos 2 tablas. 
-- que campos incluimos? 
SELECT u.*, user_trans.quant_trans 
FROM user u
JOIN (SELECT user_id, COUNT(id) AS quant_trans
		FROM transaction
		GROUP BY user_id
		HAVING quant_trans > 30) user_trans
ON u.id=user_trans.user_id;


#Ejercicio 2. Muestra el promedio de la suma de transacciones por IBAN de las tarjetas de crédito en la compañía Donec Ltd. utilizando al menos 2 tablas.
-- revisar que piden exactamente 
WITH trans_per_card AS 
(
SELECT card_id, SUM(amount) AS suma_trans
FROM transaction
WHERE company_id=(SELECT company_id 
					FROM company 
					WHERE company_name='Donec Ltd')
GROUP BY card_id
)
SELECT iban, AVG(trans_per_card.suma_trans) AS promedio_trans
FROM credit_card
JOIN trans_per_card 
ON credit_card.id=trans_per_card.card_id
GROUP BY iban;

  
/* NIVEL 2 */
/* Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones fueron declinadas. */


#Ejercicio 1. ¿Cuántas tarjetas están activas? 

  
  
/* NIVEL 3 */
/* Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transaction 
tienes product_ids. */
#Ejercicio 1. Necesitamos conocer el número de veces que se ha vendido cada producto. 