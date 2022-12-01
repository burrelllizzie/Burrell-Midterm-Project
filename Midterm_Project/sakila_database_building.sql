# creating new database/dimensional schema
#DROP DATABASE `Sakila_DW` ; 
CREATE DATABASE `Sakila_DW` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

# creating dimension tables (customer, store, film, and staff)
#DROP TABLE `dim_customer` ; 
CREATE TABLE `dim_customer` (
  `customer_key` smallint unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `address_id` smallint unsigned NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `create_date` datetime NOT NULL,
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_key`),
  KEY `idx_fk_address_id` (`address_id`),
  KEY `idx_last_name` (`last_name`)
) ENGINE=InnoDB AUTO_INCREMENT=600 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#DROP TABLE `dim_store` ; 
CREATE TABLE `dim_store` (
  `store_key` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `manager_staff_id` tinyint unsigned NOT NULL,
  `address_id` smallint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`store_key`),
  UNIQUE KEY `idx_unique_manager` (`manager_staff_id`),
  KEY `idx_fk_address_id` (`address_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#DROP TABLE `dim_staff` ; 
CREATE TABLE `dim_staff` (
  `staff_key` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `address_id` smallint unsigned NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `store_key` tinyint unsigned NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `username` varchar(16) NOT NULL,
  `password` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`staff_key`),
  KEY `idx_fk_store_id` (`store_key`),
  KEY `idx_fk_address_id` (`address_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#DROP TABLE `dim_film` ;
CREATE TABLE `dim_film` (
  `film_key` smallint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text,
  `release_year` year DEFAULT NULL,
  `language_id` tinyint unsigned NOT NULL,
  `original_language_id` tinyint unsigned DEFAULT NULL,
  `rental_duration` tinyint unsigned NOT NULL DEFAULT '3',
  `rental_rate` decimal(4,2) NOT NULL DEFAULT '4.99',
  `length` smallint unsigned DEFAULT NULL,
  `replacement_cost` decimal(5,2) NOT NULL DEFAULT '19.99',
  `rating` enum('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  `special_features` set('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`film_key`),
  KEY `idx_title` (`title`),
  KEY `idx_fk_language_id` (`language_id`),
  KEY `idx_fk_original_language_id` (`original_language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# creating fact table (for the fact table I combined the rental and payment tables since both 
# represent the numerical transactions occuring in this business

CREATE TABLE `fact_rentals` (
  `rental_key` int NOT NULL AUTO_INCREMENT,
  `rental_date` datetime NOT NULL,
  `inventory_id` mediumint unsigned NOT NULL,
  `customer_key` smallint unsigned NOT NULL,
  `return_date` datetime DEFAULT NULL,
  `staff_key` tinyint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  #payment
  #`payment_key` smallint unsigned NOT NULL AUTO_INCREMENT,
  `amount` decimal(5,2) NOT NULL,
  `payment_date` datetime NOT NULL,
  #PRIMARY KEY (`payment_id`),
  
  PRIMARY KEY (`rental_key`),
  UNIQUE KEY `rental_date` (`rental_date`,`inventory_id`,`customer_key`),
  KEY `idx_fk_inventory_id` (`inventory_id`),
  KEY `idx_fk_customer_key` (`customer_key`),
  KEY `idx_fk_staff_key` (`staff_key`)
) ENGINE=InnoDB AUTO_INCREMENT=16050 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/* LOADING THE DIMENSION TABLES
	Fill dimension tables from corresponding sakila tables
   Dim:  Insert into, remove values
   Sakila source table: select all and remove any column names 
   that don't appear in column list of INSERT INTO */
   
   INSERT INTO `sakila_dw`.`dim_customer`
(`customer_key`,
`first_name`,
`last_name`,
`email`,
`address_id`,
`active`,
`create_date`,
`last_update`)
SELECT `customer`.`customer_id`,
    `customer`.`first_name`,
    `customer`.`last_name`,
    `customer`.`email`,
    `customer`.`address_id`,
    `customer`.`active`,
    `customer`.`create_date`,
    `customer`.`last_update`
FROM `sakila`.`customer`;

INSERT INTO `sakila_dw`.`dim_film`
(`film_key`,
`title`,
`description`,
`release_year`,
`language_id`,
`original_language_id`,
`rental_duration`,
`rental_rate`,
`length`,
`replacement_cost`,
`rating`,
`special_features`,
`last_update`)
SELECT `film`.`film_id`,
    `film`.`title`,
    `film`.`description`,
    `film`.`release_year`,
    `film`.`language_id`,
    `film`.`original_language_id`,
    `film`.`rental_duration`,
    `film`.`rental_rate`,
    `film`.`length`,
    `film`.`replacement_cost`,
    `film`.`rating`,
    `film`.`special_features`,
    `film`.`last_update`
FROM `sakila`.`film`;

INSERT INTO `sakila_dw`.`dim_staff`
(`staff_key`,
`first_name`,
`last_name`,
`address_id`,
`email`,
`store_key`,
`active`,
`username`,
`password`,
`last_update`)
SELECT `staff`.`staff_id`,
    `staff`.`first_name`,
    `staff`.`last_name`,
    `staff`.`address_id`,
    `staff`.`email`,
    `staff`.`store_id`,
    `staff`.`active`,
    `staff`.`username`,
    `staff`.`password`,
    `staff`.`last_update`
FROM `sakila`.`staff`;

INSERT INTO `sakila_dw`.`dim_store`
(`store_key`,
`manager_staff_id`,
`address_id`,
`last_update`)
SELECT `store`.`store_id`,
    `store`.`manager_staff_id`,
    `store`.`address_id`,
    `store`.`last_update`
FROM `sakila`.`store`;

#insert in fact_rentals
#the payment table had a many to one relationship with the rental table, but I thought the rental_id was the most important column to join them on
INSERT INTO `sakila_dw`.`fact_rentals`
(`rental_key`,
`rental_date`,
`inventory_id`,
`customer_key`,
`return_date`,
`staff_key`,
`last_update`,
`amount`,
`payment_date`)
SELECT r.rental_id,
    r.rental_date,
	r.inventory_id,
    r.customer_id,
    r.return_date,
    r.staff_id,
    r.last_update, 

    p.amount,
    p.payment_date

FROM sakila.rental as r
INNER JOIN sakila.payment as p
ON r.rental_id = p.rental_id;

# Test by selecting data
# (select data from at least three tables, and perform aggragation (need grouping operation))

# Want the statement to return: Customer’s Last Name
#								Total amount of payment associated with each customer

SELECT customers.`last_name` AS `customer_name`,
	SUM(fact_rentals.`amount`) AS `total_rental_payment`
    FROM `sakila_dw`.`fact_rentals` AS rentals
    INNER JOIN `sakila_dw`.`dim_customer` AS customers
    ON rentals.customer_key = customers.customer_key
    GROUP BY customers.`last_name`
    ORDER BY total_rental_payment DESC;

# Want this statement to return the amount of payment for rentals facilitated by each staff member
SELECT * FROM sakila_dw.fact_rentals;
SELECT staff.`last_name` AS `staff_name`,
        SUM(rentals.`amount`) AS `total_rental_payment`
    FROM `sakila_dw`.`fact_rentals` AS rentals
    INNER JOIN `sakila_dw`.`dim_staff` AS staff
    ON rentals.staff_key = staff.staff_key
    GROUP BY staff.`last_name`
    ORDER BY total_rental_payment DESC;
    
    #SELECT * FROM sakila.customer ;
	#SELECT * FROM sakila.actor ;
	#SELECT * FROM sakila.rentals ;
	#SELECT * FROM sakila.inventory



   
   
