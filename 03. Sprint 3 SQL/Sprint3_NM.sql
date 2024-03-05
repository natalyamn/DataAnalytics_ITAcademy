/* NIVEL 1 */

/*Ejercicio 1. Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. 
La nueva tabla debe ser capaz de identificar de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). 
Después de crear la tabla será necesario que ingreses la información del documento denominado "dades_introduir_credit". 
Recuerda mostrar el diagrama y realizar una breve descripción de este. */

-- creamos la tabla credit_card
DROP TABLE credit_card;
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY, 
    iban VARCHAR(100), 
    pan INT, 
    pin INT, 
    cvv INT, 
    expiring_date VARCHAR(100)
);

ALTER TABLE credit_card 
MODIFY COLUMN pan VARCHAR(100); -- para poder cargar los datos

-- creamos modificaciones en la tabla de transacciones: creamos indices para optimizar las busquedas, creamos foreign keys

CREATE INDEX idx_credit_card_id ON transaction(credit_card_id);
CREATE INDEX idx_user_id ON transaction(user_id);

ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES user(id);

-- expiring_date de la tabla credit_card en formato varchar para poder cargar los datos; vemos a ver si es posible modificarlos a DATE (YYYY-MM-DD)
-- birth_date de la tabla user en formato varchar; a ver si es posible modificarlos a DATE

