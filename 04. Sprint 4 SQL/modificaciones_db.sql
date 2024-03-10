-- cambio birth_date a fecha en formato YYYY-MM-DD
UPDATE user
SET birth_date=STR_TO_DATE(birth_date,'%b %e, %Y')
WHERE id > 0;

ALTER TABLE user
MODIFY COLUMN birth_date DATE;

-- cambio expiring_date a fecha en formato YYYY-MM-DD
UPDATE credit_card
SET expiring_date=STR_TO_DATE(expiring_date,'%c/%d/%y')
WHERE id >='CcU-2938';

ALTER TABLE credit_card
MODIFY COLUMN expiring_date DATE;

-- cambio price a DECIMAL (quitar el $)
UPDATE product
SET price=REPLACE(price,'$','')
WHERE id > 0;

ALTER TABLE product
MODIFY COLUMN price DECIMAL(5,2);
