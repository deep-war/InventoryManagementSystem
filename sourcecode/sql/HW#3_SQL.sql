/***************************************************************************************************************************************************
** FileName: HW_3.mysql
** Description: The sql file for an Inventory Management System.
** Author: Group7: Adam Shandi, Deepthi Warrier Edakunni, Sumitha Ravindran
** Date: 23/May/2020
*****************************************************************************************************************************************************/

/****************************************************************************************************************************************************/
/* Drop the database if it already exists. Uncomment this line, if a database named awsrds already exists...
/****************************************************************************************************************************************************/
DROP DATABASE `awsrds`;
CREATE DATABASE `awsrds`;
USE `awsrds`;

/****************************************************************************************************************************************************/
/* category table is to store all the categories for the grocery for example, fruits, vegetables, Toys etc.
/****************************************************************************************************************************************************/

CREATE TABLE IF NOT EXISTS `category` (
  `categoryName` varchar(50) NOT NULL,
  `description` varchar(500) DEFAULT 'category description goes here',
  PRIMARY KEY (`categoryName`)
) COMMENT='A table to store Category of the items';

INSERT INTO `category` VALUES ('Electronics', 'Category of Electronic Items');
INSERT INTO `category` VALUES ('Medicine', 'Category for medications');
INSERT INTO `category` VALUES ('Fruits', 'Category for fruits');
INSERT INTO `category` VALUES ('Vegetables', 'category for vegetables');
INSERT INTO `category` VALUES ('Cleaning Supplies', 'Category for Sanitation Items');
INSERT INTO `category` VALUES ('Frozen Fruits', 'Category for Sanitation Items');
INSERT INTO `category` VALUES ('Mens Clothing', 'Category for Mens Clothing');
INSERT INTO `category` VALUES ('Womens Clothing', 'Category for Womens Clothing');
INSERT INTO `category` VALUES ('Toys', 'Category for Toys');
INSERT INTO `category` VALUES ('Frozen Vegetables', 'Category for Sanitation Items');

/****************************************************************************************************************************************************/
/* ItemDetails table to hold the details of the items served by the grocery store.
/****************************************************************************************************************************************************/

CREATE TABLE IF NOT EXISTS `itemdetails` (
  `itemId` INT NOT NULL AUTO_INCREMENT,
  `itemName` varchar(50) NOT NULL,
  `quantity` INT NOT NULL DEFAULT '0',
  `pricePerItem` double NOT NULL DEFAULT '0',
  `categoryName` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`itemId`),
  UNIQUE KEY `itemdetails_uk` (`itemName`),
  KEY `categoryName` (`categoryName`),
  CONSTRAINT `itemdetails_fk` FOREIGN KEY (`categoryName`) REFERENCES `category` (`categoryName`)
) AUTO_INCREMENT=1 COMMENT='A table to store itemdetails';

INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Ipad', 20, 399.99, 'Electronics');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('IPhone', 75, 299.99, 'Electronics');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Apple', 50, 2, 'Fruits');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Banana', 100, .99, 'Fruits');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Orange', 40, 2.99, 'Fruits');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Grapes', 200, 1.99, 'Fruits');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Carrot', 100, 5, 'Vegetables');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Beetroot', 60, 6, 'Vegetables');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Green Beans', 45, 2.99, 'Vegetables');
INSERT INTO `itemdetails` (`itemName`, `quantity`, `pricePerItem`, `categoryName`) VALUES ('Cilantro', 150, .49, 'Vegetables');

/***************************************************************************************************************************************************/
/* Rip off Items table is to track if the price hikes for an item by more than 5$.
/****************************************************************************************************************************************************/

create table IF NOT EXISTS `RipoffItems`(
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`itemName` varchar(45),
  `oldPrice` double,
	`pricePerItem` double,
	`categoryName` varchar(45),
  `updatedOn` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

/* Sample Data - Just for reference - The data gets added when a pricehike of more than 5$ happens */
/*INSERT INTO awsrds.RipoffItems (`itemName`,`oldPrice`,`pricePerItem`, `categoryName`) values('Sugar Donut', '6' , '12', 'Donuts');
INSERT INTO awsrds.RipoffItems (`itemName`,`oldPrice`,`pricePerItem`, `categoryName`) values('playdough', '10' , '40', 'Donuts'); */

/***************************************************************************************************************************************************/
/*The manager details table will hold the following information about the manager: managerID - Auto Incremented, firstname, last name, email, phone, gender.
/****************************************************************************************************************************************************/

CREATE TABLE IF NOT EXISTS `managers` (
				`managerID` INT NOT NULL AUTO_INCREMENT,
				`firstname` VARCHAR(255)    NOT NULL,
				`lastname`  VARCHAR(255)    NOT NULL,				
				`email`     VARCHAR(255)    NOT NULL,
				`phone`     VARCHAR(255)    NOT NULL,
				`gender`    VARCHAR(10)     DEFAULT 'Unknown',				
				`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 				
				PRIMARY KEY(`managerID`)
) ENGINE=InnoDB DEFAULT CHARSET= utf8mb4;

INSERT INTO awsrds.managers (`firstname`, `lastname`,`email`, `phone`, `gender`) values ('John', 'Smith', 'jsmith@gmail.com','12345678', 'male');
INSERT INTO awsrds.managers (`firstname`, `lastname`,`email`, `phone`, `gender`) values ('Jack', 'Williams', 'jwilliams@gmail.com','1212121212', 'male');

/***************************************************************************************************************************************************/
/*The users table is for storing the login username and password. It has the following columns: userID - Auto Incremented , username, password.
/****************************************************************************************************************************************************/

CREATE TABLE IF NOT EXISTS `users` (
				`userId` INT NOT NULL AUTO_INCREMENT,
				`username`  VARCHAR(255)    UNIQUE 			DEFAULT 'UW',
				`password`  VARCHAR(255)    NOT NULL,
					PRIMARY KEY(`userId`)
) ENGINE=InnoDB DEFAULT CHARSET= utf8mb4;

INSERT INTO awsrds.users (`username`, `password`) values ('jsmith', '1234');
INSERT INTO awsrds.users (`username`, `password`) values ('jwilliams', '1234');

/***************************************************************************************************************************************************/
/* create custom index for attribute itemName in itemdetails table */
/***************************************************************************************************************************************************/
ALTER TABLE itemdetails ADD INDEX itemname_index(itemName);

/***************************************************************************************************************************************************/
/*  This trigger is called when an item is added to the inventory. When adding an item to the inventory if the category of the item does not exist in the category table, the new category will be added to the category table.
/***************************************************************************************************************************************************/

DELIMITER $$
CREATE TRIGGER categoryTrig
	BEFORE INSERT ON awsrds.itemdetails
	FOR EACH ROW
    BEGIN
	IF (NEW.categoryName NOT IN
		(SELECT categoryName FROM awsrds.category))  THEN
	INSERT INTO category(categoryName)
		VALUES(NEW.categoryName);
	END IF;
END$$

/******************************************************************************************************************************************************/
/* Using itemdetails table and a unary RipoffItems(itemName) maintains a list of itemnames raised by 5.00*
/***************************************************************************************************************************************************/

DELIMITER $$
CREATE TRIGGER ItemPriceTrig
	AFTER UPDATE ON itemdetails
    FOR EACH ROW
    BEGIN
		IF (NEW.pricePerItem>(OLD.pricePerItem+5.00)) THEN
		INSERT INTO RipoffItems (itemName, oldPrice, pricePerItem, categoryName)
		VALUES(OLD.itemName, OLD.pricePerItem,NEW.pricePerItem, OLD.categoryName);
        END IF;
END$$

/***************************************************************************************************************************************************/
/* Created view called priceHike to view the hike in price which is more than 20 dollars from RipoffItems table 
 ***************************************************************************************************************************************************/

CREATE VIEW priceHike AS
SELECT id, itemName, (pricePerItem - oldPrice) AS priceHike, categoryName, updatedOn
FROM RipoffItems
WHERE (pricePerItem - oldPrice) > 20;

/**************************************************************************************************************************************************/
