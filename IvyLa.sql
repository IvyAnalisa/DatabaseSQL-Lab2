--LAB 2
--Namn: Ivy LA
-- Skapa databasen
CREATE DATABASE Bookstore;

-- Anv�nd databasen

USE Bookstore;

-- Skapa tabellen "F�rfattare"
CREATE TABLE F�rfattare (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    F�rnamn VARCHAR(50),
    Efternamn VARCHAR(50),
    F�delsedatum DATE
);
Go
-- Skapa tabellen "B�cker"
CREATE TABLE B�cker (
    ISBN13 VARCHAR(13) PRIMARY KEY,
    Titel VARCHAR(100),
    Spr�k VARCHAR(50),
    Pris DECIMAL(10, 2),
    Utgivningsdatum DATE,
    F�rfattareID INT,
    FOREIGN KEY (F�rfattareID) REFERENCES F�rfattare(ID)
);
Go
-- Skapa tabellen "Butiker"
CREATE TABLE Butiker (
   IdButik INT IDENTITY(1,1) PRIMARY KEY,
    Butiksnamn VARCHAR(100),
    Adress VARCHAR(255)
);
Go
-- Skapa tabellen "LagerSaldo"
CREATE TABLE LagerSaldo (
    ButikID INT,
    ISBN VARCHAR(13),
    Antal INT,
    PRIMARY KEY (ButikID, ISBN),
    FOREIGN KEY (ButikID) REFERENCES Butiker(IdButik),
    FOREIGN KEY (ISBN) REFERENCES B�cker(ISBN13)
);
Go
-- Skapa tabellen "Kunder"
CREATE TABLE Kunder (
    KundID INT IDENTITY(1,1) PRIMARY KEY,
    F�rnamn VARCHAR(50),
    Efternamn VARCHAR(50),
    Email VARCHAR(100),
    Telefon VARCHAR(20),
    Adress VARCHAR(255)
);
GO
-- Skapa tabellen "Ordrar"
CREATE TABLE Ordrar (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    KundID INT,
    Best�llningsdatum DATETIME,
    Leveransdatum DATETIME,
    TotaltBelopp DECIMAL(10, 2),
    Betalningsmetod VARCHAR(50),
    Leveransadress VARCHAR(255),
    FOREIGN KEY (KundID) REFERENCES Kunder(KundID)
);
GO
-- Skapa tabellen "OrderRader"
CREATE TABLE OrderRader (
    OrderRadID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ISBN13 VARCHAR(13),
    Antal INT,
    Pris DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Ordrar(OrderID),
    FOREIGN KEY (ISBN13) REFERENCES B�cker(ISBN13)
);
GO
-- L�gg till testdata f�r Butiker

INSERT INTO Butiker (Butiksnamn, Adress)
VALUES 
    ('HandelsBoken', 'S�dragatan,Lund'),
    ('BokAkademi', 'Norragatan,Malm�'),
    ('S�derbokhandeln Hansson & Bruce', 'Kungsgatan,Stockholm');
GO
-- L�gg till testdata f�r F�rfattare

INSERT INTO F�rfattare (F�rnamn, Efternamn, F�delsedatum)
VALUES 
    ('Astrid', 'Lingren', '1960-01-01'),
    ('Anna', 'Frank', '1930-02-15'),
    ('Stephen', 'King', '1880-05-20'),
    ('Agatha', 'Christie', '1890-09-10');
GO
-- L�gg till testdata f�r B�cker

INSERT INTO B�cker (ISBN13, Titel, Spr�k, Pris, Utgivningsdatum, F�rfattareID)
VALUES 
    ('1234567890123', 'Goes With the Wind', 'Svenska', 150.00, '2020-01-01', 1),
    ('2345678901234', 'Romeo and Juliet', 'Engelska', 200.00, '2021-02-15', 2),
    ('3456789012345', 'Harry Poster', 'Franska', 120.00, '2019-05-20', 3),
    ('4567890123456', 'King of Horror', 'Tyska', 180.00, '2022-09-10', 4),
    ('5678901234567', 'The War and Peace', 'Spanska', 160.00, '2018-04-05', 1);
   
  Go 
  ---l�gg till test data f�r LagerSaldo
  INSERT INTO LagerSaldo (ButikID, ISBN, Antal) VALUES
(1, '1234567890123', 100),
(1, '2345678901234', 50),
(2, '1234567890123', 75),
(2, '2345678901234', 30);
 GO
 ---- l�gg till test data Ordrar 
INSERT INTO Ordrar (KundID, Best�llningsdatum, Leveransdatum, TotaltBelopp, Betalningsmetod, Leveransadress) VALUES
(1, '2023-01-01', '2023-01-10', 150.00, 'Credit Card', 'Norrgatan 1, 2145,Malm�'),
(2, '2023-02-01', '2023-02-10', 200.00, 'PayPal', 'GUStavgatan 39,4321,Lund');
GO

-- l�gg till test data Kunder
INSERT INTO Kunder (F�rnamn, Efternamn, Email, Telefon, Adress) VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890', 'Landskrona'),
('Alice', 'Smith', 'alice.smith@example.com', '9876543210', 'Lund');

GO
-- Insert values into OrderRader 
INSERT INTO OrderRader (OrderID, ISBN13, Antal, Pris) VALUES
(3, '1234567890123', 2, 59.98),
(5, '2345678901234', 1, 19.99),
(6, '1234567890123', 3, 89.97);

GO
-- Skapa vyn "v_TitlarPerF�rfattare"

CREATE VIEW v_TitlarPerF�rfattare AS
SELECT 
    F.ID AS F�rfattareID,
    F.F�rnamn + ' ' + F.Efternamn AS Namn,
    DATEDIFF(YEAR, F.F�delsedatum, GETDATE()) AS �lder,
    COUNT(B.ISBN13) AS Titlar,
    SUM(B.Pris) AS Lagerv�rde
FROM 
    F�rfattare F
JOIN 
    B�cker B ON F.ID = B.F�rfattareID
JOIN 
    LagerSaldo LS ON B.ISBN13 = LS.ISBN
GROUP BY 
    F.ID, F.F�rnamn, F.Efternamn, F.F�delsedatum;
GO
-- Skapa tabellen "F�rfattareB�cker" f�r att hantera m�nga�m�nga-relationen
-- Flera f�rfattare p� samma bok 

CREATE TABLE F�rfattareB�cker (
    F�rfattareID INT,
    ISBN13 VARCHAR(13),   
    PRIMARY KEY (F�rfattareID, ISBN13),
    FOREIGN KEY (F�rfattareID) REFERENCES F�rfattare(ID),
    FOREIGN KEY (ISBN13) REFERENCES B�cker(ISBN13),    
);

GO
INSERT INTO F�rfattareB�cker (F�rfattareID, ISBN13) VALUES (1, '1234567890123');
GO
-- EXTRA VY f�r att samlar information fr�n B�cker- och OrderRader-tabeller
CREATE VIEW BokhandelSummary AS
SELECT
    B.ISBN13,
    B.Titel,
    B.Pris AS BokPris,
    SUM(ORR.Antal) AS TotalAntal,
    SUM(ORR.Pris) AS TotalPris
FROM
    B�cker B
JOIN
    OrderRader ORR ON B.ISBN13 = ORR.ISBN13
GROUP BY
    B.ISBN13, B.Titel, B.Pris;
GO
-- SKapa stored procedure f�r hitta bok detail  av ISBN
CREATE PROCEDURE GetBookInfo
    @ISBN13 VARCHAR(13)
AS
BEGIN
    -- Check if the book exists
    IF EXISTS (
        SELECT 1
        FROM B�cker
        WHERE ISBN13 = @ISBN13
    )
    BEGIN
        -- Retrieve book information
        SELECT
            ISBN13,
            Titel,
            Spr�k,
            Pris,
            Utgivningsdatum,
            F�rfattareID
        FROM B�cker
        WHERE ISBN13 = @ISBN13;
    END
    ELSE
    BEGIN
        -- Book not found
        PRINT 'Book not found.';
    END
END;
GO
-- Example of calling the stored procedure
EXEC GetBookInfo @ISBN13 = '1234567890123';
GO
SELECT *FROM BokhandelSummary
SELECT * FROM B�cker
SELECT  * FROM v_TitlarPerF�rfattare
SELECT * FROM OrderRader
SELECT *FROM F�rfattareB�cker
SELECT *FROM Ordrar

