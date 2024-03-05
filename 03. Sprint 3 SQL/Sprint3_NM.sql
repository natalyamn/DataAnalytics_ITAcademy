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

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- expiring_date de la tabla credit_card en formato varchar para poder cargar los datos; modificamos la fecha string a DATE (YYYY-MM-DD)

# desactivamos el 'guardado' automatico para poder retroceder con ROLLBACK en caso de necesitarlo
SET AUTOCOMMIT = OFF; 
# verificamos si funciona el cambio de formato de string a date: todo OK 
SELECT expiring_date, STR_TO_DATE(expiring_date, '%m/%d/%y')
FROM credit_card; 
# desactivamos temporalmente la actualizacion segura pq de lo contrario salta error
SET SQL_SAFE_UPDATES = 0; 
# hacemos el update de la columna expiring_date a la fecha en formato DATE
UPDATE credit_card
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');
# verificamos que esté bien y activamos el modo de actualizacion segura de nuevo
SET SQL_SAFE_UPDATES = 1; 
# guardamos y activamos el modo de autoguardado de nuevo
COMMIT;
SET AUTOCOMMIT = ON;
#modificamos el formato de varchar a date
ALTER TABLE credit_card
MODIFY expiring_date DATE;


-- birth_date de la tabla user en formato varchar; los modificamos a DATE

UPDATE user
SET birth_date=STR_TO_DATE(birth_date, '%b %d, %Y')
WHERE id > 0;

ALTER TABLE user
MODIFY birth_date DATE;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

