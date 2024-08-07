USE transactions;

/* NIVEL 1 */

/*Ejercicio 1. Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. 
La nueva tabla debe ser capaz de identificar de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). 
Después de crear la tabla será necesario que ingreses la información del documento denominado "dades_introduir_credit". 
Recuerda mostrar el diagrama y realizar una breve descripción de este. */

-- creamos la tabla credit_card
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY, 
    iban VARCHAR(100), 
    pan VARCHAR(100), 
    pin INT, 
    cvv INT, 
    expiring_date VARCHAR(100)
);

ALTER TABLE credit_card
MODIFY COLUMN cvv VARCHAR(3);

-- hacemos modificaciones en la tabla de transacciones: creamos indices para optimizar las busquedas, creamos foreign keys
CREATE INDEX idx_credit_card_id ON transaction(credit_card_id);
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

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

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Ejercicio 2. El departamento de Recursos Humanos ha identificado un error en el número de cuenta del usuario con ID CcU-2938. 
Se requiere actualizar la información que identifica una cuenta bancaria a nivel internacional (identificado como "IBAN"): TR323456312213576817699999. 
*/
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id= 'CcU-2938';

SELECT * 
FROM credit_card 
WHERE id='CcU-2938'; 


#Ejercicio 3. En la tabla "transaction" ingresa un nuevo usuario con la información especificada. 
/*Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails */
#Añadimos el identificador de compañía en company, identificador de tarjeta en credit_card, identificador de usuario en user
INSERT INTO company (id)
VALUES ('b-9999');

INSERT INTO credit_card (id)
VALUES ('CcU-9999');

INSERT INTO user (id)
VALUES ('9999');

#Ya no habría problemas para cargar los datos en la tabla de transacciones
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');

SELECT * 
FROM transaction
WHERE id='108B1D1D-5B23-A76C-55EF-C568E49A99DD';

SELECT * FROM transaction;

#Ejercicio 4. Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado. 
ALTER TABLE credit_card
DROP COLUMN pan;

SHOW COLUMNS FROM credit_card;


/* NIVEL 2 */

#Ejercicio 1. Elimina el registro 02C6201E-D90A-1859-B4EE-88D2986D3B02 (id transacción) de la base de datos. 
DELETE FROM transaction 
WHERE id='02C6201E-D90A-1859-B4EE-88D2986D3B02';

SELECT * 
FROM transaction
WHERE id='02C6201E-D90A-1859-B4EE-88D2986D3B02';


/*Ejercicio 2. La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. 
Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: 
Nombre de la compañía. Teléfono de contacto. País de residencia. Promedio de compra realizado por cada compañía. 
Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra. 
*/
CREATE VIEW VistaMarketing AS
(
SELECT 	c.company_name AS nombre_compañia,
		c.phone AS telefono_contacto,
		c.country AS pais_residencia,
        ROUND(AVG(t.amount),2) AS promedio_compras
FROM company c
JOIN transaction t 
ON c.id=t.company_id
WHERE declined=0
GROUP BY c.id
);

SELECT * 
FROM VistaMarketing
ORDER BY promedio_compras DESC; 

 
#Ejercicio 3. Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany". 
SELECT * 
FROM VistaMarketing 
WHERE pais_residencia = 'Germany'
ORDER BY promedio_compras DESC; 


/* NIVEL 3 */

CREATE INDEX idx_user_id ON transaction(user_id);
ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES user(id);
---------------------------------------------------------------------------
-- birth_date de la tabla user en formato varchar; lo modificamos a DATE
UPDATE user
SET birth_date=STR_TO_DATE(birth_date, '%b %d, %Y')
WHERE id > 0;

ALTER TABLE user
MODIFY birth_date DATE;

/* Ejercicio 1. La próxima semana tendrás una nueva reunión con los gerentes de marketing. Un compañero de tu equipo realizó modificaciones en la base de datos, 
pero no recuerda cómo las realizó. Te pide que le ayudes a dejar los comandos ejecutados para obtener las modificaciones. 
*/
-- cambio nombre de columna email en la tabla user
ALTER TABLE user
RENAME COLUMN email TO personal_email;

-- borrar columna website de la tabla company
ALTER TABLE company
DROP COLUMN website;

-- añadir columna fecha_actual en la tabla credit_card
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

UPDATE credit_card
SET fecha_actual = CURRENT_DATE()
WHERE id BETWEEN 'CcU-2938' AND 'CcU-9999';

-- modificar tipo de dato de columna pin de la tabla credit_card
ALTER TABLE credit_card
MODIFY COLUMN pin VARCHAR(4);

-- otros posibles cambios en la tabal credit_card
ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20);

ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(50);


/* Ejercicio 2. La empresa también te solicita crear una vista llamada "InformeTecnico" que contenga la siguiente información: 
ID de la transacción 
Nombre del usuario/a 
Apellido del usuario/a 
IBAN de la tarjeta de crédito usada 
Nombre de la compañía de la transacción realizada 
Asegúrate de incluir información relevante de las tablas y utiliza alias para cambiar de nombre columnas según sea necesario. 
Muestra los resultados de la vista, ordena los resultados de forma descendente en función de la variable ID de transacción. */
CREATE VIEW InformeTecnico AS
(
SELECT 	t.id AS ID_transaccion, 
		u.name AS Nombre_usuario, 
        u.surname AS Apellido_usuario, 
        cred.iban AS IBAN_tarjeta,
        c.company_name AS Nombre_compañia
FROM transaction t
JOIN user u
	ON t.user_id=u.id
JOIN credit_card cred
	ON t.credit_card_id=cred.id
JOIN company c
	ON t.company_id=c.id
);

SELECT * 
FROM InformeTecnico
ORDER BY ID_transaccion DESC;