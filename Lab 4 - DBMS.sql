CREATE DATABASE E_commerce;

USE E_commerce;

CREATE TABLE Supplier(SUPP_ID int PRIMARY KEY,
					SUPP_NAME varchar(50),
                    SUPP_CITY varchar(30),
                    SUPP_PHONE varchar(12));

CREATE TABLE Customer(CUS_ID int PRIMARY KEY,
					CUS_NAME varchar(50),
                    CUS_PHONE varchar(12),
                    CUS_CITY varchar(30),
                    CUS_GENDER char);

CREATE TABLE Category(CAT_ID int PRIMARY KEY,
					CAT_NAME varchar(50));
                    
CREATE TABLE Product(PRO_ID int PRIMARY KEY,
					PRO_NAME varchar(30),
                    PRO_DESC varchar(50),
                    CAT_ID int,
                    FOREIGN KEY (CAT_ID) REFERENCES Category(CAT_ID));

CREATE TABLE ProductDetails(PROD_ID  int PRIMARY KEY,
							PRO_ID int,
							SUPP_ID int,
                            PRICE double,
                            FOREIGN KEY (PRO_ID) REFERENCES Product(PRO_ID),
                            FOREIGN KEY (SUPP_ID) REFERENCES Supplier(SUPP_ID));

CREATE TABLE `Order`(ORD_ID int PRIMARY KEY,
				ORD_AMOUNT double,
                ORD_DATE date,
                CUS_ID int,
                PROD_ID int,
                FOREIGN KEY (CUS_ID) REFERENCES Customer(CUS_ID),
                FOREIGN KEY (PROD_ID) REFERENCES ProductDetails(PROD_ID));

CREATE TABLE Rating(RAT_ID int PRIMARY KEY,
					CUS_ID int,
                    SUPP_ID int,
                    RAT_RATSTARS int,
                    FOREIGN KEY (CUS_ID) REFERENCES Customer(CUS_ID),
                    FOREIGN KEY (SUPP_ID) REFERENCES Supplier(SUPP_ID));

INSERT INTO supplier VALUES (1,"Rajesh Retails","Delhi","1234567890"),
							(2,"Appario Ltd.","Mumbai","2589631470"),
                            (3,"Knome products","Banglore","9785462315"),
                            (4,"Bansal Retails","Kochi","8975463285"),
							(5,"Mittal Ltd.","Lucknow","7898456532");

INSERT INTO customer VALUES (1,"AAKASH","9999999999","DELHI",'M'),
							(2,"AMAN","9785463215","NOIDA",'M'),
							(3,"NEHA","9999999999","MUMBAI",'F'),
                            (4,"MEGHA","9994562399","KOLKATA",'F'),
                            (5,"PULKIT","7895999999","LUCKNOW",'M');

INSERT INTO category VALUES (1,"BOOKS"),
							(2,"GAMES"),
                            (3,"GROCERIES"),
                            (4,"ELECTRONICS"),
                            (5,"CLOTHES");

INSERT INTO product VALUES (1,"GTA V","DFJDJFDJFDJFDJFJF",2),
							(2,"TSHIRT","DFDFJDFJDKFD",5),
                            (3,"ROG LAPTOP","DFNTTNTNTERND",4),
                            (4,"OATS","REURENTBTOTH",3),
                            (5,"HARRY POTTER","NBEMCTHTJTH",1);

INSERT INTO productdetails VALUES (1,1,2,1500),
								(2,3,5,30000),
                                (3,5,1,3000),
                                (4,2,3,2500),
                                (5,4,1,1000);

INSERT INTO `order` VALUES (20,1500,"2021-10-12",3,5),
							(25,30500,"2021-09-16",5,2),
                            (26,2000,"2021-10-05",1,1),
                            (30,3500,"2021-08-16",4,3),
                            (50,2000,"2021-10-06",2,1);

INSERT INTO rating VALUES(1,2,2,4),
						(2,3,4,3),
                        (3,5,1,5),
                        (4,1,3,2),
                        (5,4,5,4);
                        
/*
Queries
--------
3)	Display the number of the customer group by their genders who have placed any order 
	of amount greater than or equal to Rs.3000.
*/
SELECT QRY.GENDER, COUNT(QRY.GENDER) AS No_of_Cust FROM
(SELECT CUS.CUS_GENDER AS GENDER FROM customer AS CUS
INNER JOIN `order` AS ORD 
ON ORD.CUS_ID = CUS.CUS__ID
WHERE ORD.ORD_AMOUNT >= 3000) AS QRY
GROUP BY QRY.GENDER;

/*
4)	Display all the orders along with the product name 
	ordered by a customer having Customer_Id=2.
*/
SELECT ORD.ORD_ID, PRD.PRO_NAME, ORD.ORD_AMOUNT, ORD.ORD_DATE, ORD.CUS_ID FROM `order` AS ORD
INNER JOIN productdetails AS DTLS
ON ORD.PROD_ID = DTLS.PROD_ID
INNER JOIN product AS PRD
ON DTLS.PRO_ID = PRD.PRO_ID
WHERE CUS_ID = 2;

/*
5)	Display the Supplier details who can supply more than one product.
*/
SELECT SUP.SUPP_ID, SUP.SUPP_NAME, SUP.SUPP_CITY, SUP.SUPP_PHONE, No_of_Products FROM supplier AS SUP 
INNER JOIN 
(SELECT SUPP_ID, COUNT(PRO_ID) AS No_of_Products FROM productdetails GROUP BY SUPP_ID) AS SUPPLIES
ON SUP.SUPP_ID = SUPPLIES.SUPP_ID
WHERE No_of_Products > 1;

/*
6)	Find the category of the product whose order amount is minimum.
*/
SELECT cat.CAT_ID, cat.CAT_NAME, prdt.Lowest_Order FROM category AS cat
INNER JOIN
(SELECT prd.CAT_ID, prDtls.Lowest_Order FROM product AS prd
INNER JOIN
(SELECT dtls.PRO_ID, Low.Lowest_Order FROM productdetails AS dtls
INNER JOIN
(SELECT PROD_ID, MIN(ORD_AMOUNT) AS Lowest_Order FROM `order`) AS Low
ON Low.PROD_ID = dtls.PROD_ID) AS prDtls
ON prDtls.PRO_ID = prd.PRO_ID) AS prdt
ON prdt.CAT_ID = cat.CAT_ID;

/*
7)	Display the Id and Name of the Product ordered after “2021-10-05”.
*/
SELECT prd.PRO_ID, prd.PRO_NAME, qry.ORD_DATE FROM product AS prd
INNER JOIN
(SELECT dtls.PRO_ID, ord.ORD_DATE FROM productdetails AS dtls
INNER JOIN
(SELECT * FROM `order` WHERE ORD_DATE > "2021-10-05") AS ord
ON ord.PROD_ID = dtls.PROD_ID) AS qry
ON qry.PRO_ID = prd.PRO_ID;

/*
8)	Display customer name and gender whose names start or end with character 'A'.
*/
SELECT CUS_NAME, CUS_GENDER FROM customer WHERE CUS_NAME LIKE 'A%' OR CUS_NAME LIKE '%A';

/*
9)	Create a stored procedure to display the Rating for a Supplier if any along with 
    the Verdict on that rating if any like if rating >4 then “Genuine Supplier” 
    if rating >2 “Average Supplier” else “Supplier should not be considered”.
*/
DROP PROCEDURE IF EXISTS SupplierRating;
DELIMITER //
CREATE PROCEDURE SupplierRating(id INT)
BEGIN
	SELECT sup.SUPP_ID, rat.RAT_RATSTARS,
		CASE
			WHEN rat.RAT_RATSTARS > 4 THEN "Genuine Supplier"
			WHEN rat.RAT_RATSTARS > 2 THEN "Average Supplier"
			ELSE "Supplier should not be considered"
		END AS Verdict
    FROM Supplier AS sup, Rating AS rat
    WHERE sup.SUPP_ID = rat.SUPP_ID AND sup.SUPP_ID = id;
END;

/* Callig the stored procedure */
CALL SupplierRating(1);