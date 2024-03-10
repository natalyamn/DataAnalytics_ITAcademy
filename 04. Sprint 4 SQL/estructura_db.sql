-- creamos una base de datos y la definimos como 'default'

CREATE DATABASE IF NOT EXISTS transactionsdb;
USE transactionsdb;

-- creamos tabla transaction para transactions.csv
DROP TABLE IF EXISTS transaction;
CREATE TABLE IF NOT EXISTS transaction (
	id VARCHAR(50) NOT NULL,
    card_id VARCHAR(15) NOT NULL,
    business_id VARCHAR(10) NOT NULL,
    timestamp TIMESTAMP,
    amount DECIMAL(5,2) NOT NULL,
    declined BOOLEAN NOT NULL,
    product_ids INT NOT NULL,
    user_id INT NOT NULL,
    lat FLOAT,
    longitude FLOAT,
    PRIMARY KEY(id),
    FOREIGN KEY(card_id) REFERENCES credit_card(id), 
    FOREIGN KEY(business_id) REFERENCES company(company_id),
    FOREIGN KEY(product_ids) REFERENCES product(id),
    FOREIGN KEY(user_id) REFERENCES user(id)
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
    user_id INT, 			-- OJO ESTA RELACIONADA CON LA TABLA USER
    iban VARCHAR(100),
    pan VARCHAR(50),
    pin INT, 
    cvv INT,
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(10),
    PRIMARY KEY(id)
);

-- creamos tabla user para users_ca.csv + users_uk.csv + users_usa.csv
CREATE TABLE IF NOT EXISTS user (
	id INT,
    name VARCHAR(50),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(25),
    address VARCHAR(255),
    PRIMARY KEY(id)
);

-- creamos tabla product para products.csv
CREATE TABLE IF NOT EXISTS product (
	id INT,
    product_name VARCHAR(255),
    price VARCHAR(50),
    colour VARCHAR(50),
    weight DECIMAL(5,1),
    warehouse_id VARCHAR(25),
    PRIMARY KEY(id)
);