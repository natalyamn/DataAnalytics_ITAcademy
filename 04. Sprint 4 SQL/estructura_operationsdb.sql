CREATE DATABASE IF NOT EXISTS operations; 
USE operations;

-- creamos tabla user para users_ca.csv + users_uk.csv + users_usa.csv
CREATE TABLE IF NOT EXISTS user (
	id INT,
    name VARCHAR(50),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(25),
    address VARCHAR(255),
    PRIMARY KEY(id)
);

-- creamos tabla company para companies.csv
CREATE TABLE IF NOT EXISTS company (
	company_id VARCHAR(10),
    company_name VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(100),
    PRIMARY KEY(company_id)
);

-- creamos tabla credit_card para credit_cards.csv 
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15),
    user_id INT, 			
    iban VARCHAR(100),
    pan VARCHAR(50),
    pin INT, 
    cvv INT,
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date DATE,
    PRIMARY KEY(id)
);
#CORRECCION POSTERIOR A LA CREACIÓN DE LA TABLA: modifico tipo de dato de columna pin y cvv a VARCHAR
ALTER TABLE credit_card
MODIFY COLUMN pin VARCHAR(4);

ALTER TABLE credit_card
MODIFY COLUMN cvv VARCHAR(3);

-- creamos tabla product para products.csv
CREATE TABLE IF NOT EXISTS product (
	id INT,
    product_name VARCHAR(255),
    price DECIMAL(5,2),
    colour VARCHAR(50),
    weight DECIMAL(5,1),
    warehouse_id VARCHAR(25),
    PRIMARY KEY(id)
);

-- creamos la tabla transacciones para transactions.csv
CREATE TABLE IF NOT EXISTS transaction (
	id VARCHAR(50) NOT NULL,
    card_id VARCHAR(15) NOT NULL,
    company_id VARCHAR(10) NOT NULL,
    timestamp TIMESTAMP,
    amount DECIMAL(5,2) NOT NULL,
    declined BOOLEAN NOT NULL,
    user_id INT NOT NULL,
    lat FLOAT,
    longitude FLOAT,
    PRIMARY KEY(id),
    FOREIGN KEY(card_id) REFERENCES credit_card(id), 
    FOREIGN KEY(company_id) REFERENCES company(company_id),
    FOREIGN KEY(user_id) REFERENCES user(id)
);

-- creamos tabla transaction_product para saber los productos que se compraron en cada transacción
CREATE TABLE IF NOT EXISTS transaction_product (
	transaction_id VARCHAR(50) NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY(transaction_id) REFERENCES transaction(id),
    FOREIGN KEY(product_id) REFERENCES product(id)
);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- select @@secure_file_priv;

-- cargamos datos a la tabla user -- OK!!
-- usuarios de USA:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv' 
INTO TABLE user
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code,address)
SET birth_date=STR_TO_DATE(@birth_date,'%b %e, %Y');

-- usuarios de UK:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv' 
INTO TABLE user
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code,address)
SET birth_date=STR_TO_DATE(@birth_date,'%b %e, %Y');

-- usuarios de CANADA:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv' 
INTO TABLE user
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code,address)
SET birth_date=STR_TO_DATE(@birth_date,'%b %e, %Y');

SELECT * FROM user;


-- cargamos datos a la tabla company -- OK!!
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv' 
INTO TABLE company
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

SELECT * FROM company;


-- cargamos datos a la tabla credit_card -- OK!!
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv' 
INTO TABLE credit_card
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date)
SET expiring_date=STR_TO_DATE(@expiring_date,'%c/%d/%y');

SELECT * FROM credit_card;


-- cargamos datos a la tabla product -- OK!!
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv' 
INTO TABLE product
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id)
SET price=REPLACE(@price,'$','');

SELECT * FROM product;


-- cargamos datos a la tabla transaction -- OK!! 
-- importante: @dummy para ignorar las columnas de csv que no nos interesan
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv' 
INTO TABLE transaction 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, card_id, company_id, timestamp, amount, declined, @dummy, user_id, lat, longitude);

SELECT * FROM transaction;


-- cargamos datos a la tabla transaction_product -- OK :')

-- PASO 1: creamos tabla temporal para cargar los datos de product_ids en formato VARCHAR y separarlos posteriormente
CREATE TEMPORARY TABLE transaction_product_temp (
    transaction_id VARCHAR(50),
    product_ids VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv' 
INTO TABLE transaction_product_temp
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(transaction_id, @dummy, @dummy, @dummy, @dummy, @dummy, product_ids, @dummy, @dummy, @dummy);

SELECT * FROM transaction_product_temp;

-- PASO 2: separamos los valores de columna en fila y los insertamos en la tabla transaction_product que usaremos en nuestro modelo
INSERT INTO transaction_product (transaction_id, product_id)
(SELECT 	transaction_id,
		SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', numbers.n), ',', -1) AS product_id
FROM transaction_product_temp
JOIN (	SELECT 1 AS n 
		UNION ALL SELECT 2 
        UNION ALL SELECT 3 
        UNION ALL SELECT 4	) AS numbers 
ON CHAR_LENGTH(product_ids) - CHAR_LENGTH(REPLACE(product_ids, ',', '')) >= n - 1);

SELECT * FROM transaction_product;

-- PASO 3: eliminamos la tabla temporal transaction_product_temp
DROP TEMPORARY TABLE transaction_product_temp;