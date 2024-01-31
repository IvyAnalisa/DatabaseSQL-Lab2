--LAB 2
--Namn: Ivy LA
-- Skapa databasen
CREATE DATABASE Bookstore;

-- Använd databasen

USE Bookstore;

-- Skapa tabellen "Författare"
CREATE TABLE Författare (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn VARCHAR(50),
    Efternamn VARCHAR(50),
    Födelsedatum DATE
);
Go
-- Skapa tabellen "Böcker"
CREATE TABLE Böcker (
    ISBN13 VARCHAR(13) PRIMARY KEY,
    Titel VARCHAR(100),
    Språk VARCHAR(50),
    Pris DECIMAL(10, 2),
    Utgivningsdatum DATE,
    FörfattareID INT,
    FOREIGN KEY (FörfattareID) REFERENCES Författare(ID)
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
    FOREIGN KEY (ISBN) REFERENCES Böcker(ISBN13)
);
Go
-- Skapa tabellen "Kunder"
CREATE TABLE Kunder (
    KundID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn VARCHAR(50),
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
    Beställningsdatum DATETIME,
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
    FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13)
);
GO
-- Lägg till testdata för Butiker

INSERT INTO Butiker (Butiksnamn, Adress)
VALUES 
    ('HandelsBoken', 'Södragatan,Lund'),
    ('BokAkademi', 'Norragatan,Malmö'),
    ('Söderbokhandeln Hansson & Bruce', 'Kungsgatan,Stockholm');
GO
-- Lägg till testdata för Författare

INSERT INTO Författare (Förnamn, Efternamn, Födelsedatum)
VALUES 
    ('Astrid', 'Lingren', '1960-01-01'),
    ('Anna', 'Frank', '1930-02-15'),
    ('Stephen', 'King', '1880-05-20'),
    ('Agatha', 'Christie', '1890-09-10');
GO
-- Lägg till testdata för Böcker

INSERT INTO Böcker (ISBN13, Titel, Språk, Pris, Utgivningsdatum, FörfattareID)
VALUES 
    ('1234567890123', 'Goes With the Wind', 'Svenska', 150.00, '2020-01-01', 1),
    ('2345678901234', 'Romeo and Juliet', 'Engelska', 200.00, '2021-02-15', 2),
    ('3456789012345', 'Harry Poster', 'Franska', 120.00, '2019-05-20', 3),
    ('4567890123456', 'King of Horror', 'Tyska', 180.00, '2022-09-10', 4),
    ('5678901234567', 'The War and Peace', 'Spanska', 160.00, '2018-04-05', 1);
   
  Go 
  ---lägg till test data för LagerSaldo
  INSERT INTO LagerSaldo (ButikID, ISBN, Antal) VALUES
(1, '1234567890123', 100),
(1, '2345678901234', 50),
(2, '1234567890123', 75),
(2, '2345678901234', 30);
 GO
 ---- lägg till test data Ordrar 
INSERT INTO Ordrar (KundID, Beställningsdatum, Leveransdatum, TotaltBelopp, Betalningsmetod, Leveransadress) VALUES
(1, '2023-01-01', '2023-01-10', 150.00, 'Credit Card', 'Norrgatan 1, 2145,Malmö'),
(2, '2023-02-01', '2023-02-10', 200.00, 'PayPal', 'GUStavgatan 39,4321,Lund');
GO

-- lägg till test data Kunder
INSERT INTO Kunder (Förnamn, Efternamn, Email, Telefon, Adress) VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890', 'Landskrona'),
('Alice', 'Smith', 'alice.smith@example.com', '9876543210', 'Lund');

GO
-- Insert values into OrderRader 
INSERT INTO OrderRader (OrderID, ISBN13, Antal, Pris) VALUES
(3, '1234567890123', 2, 59.98),
(5, '2345678901234', 1, 19.99),
(6, '1234567890123', 3, 89.97);

GO
-- Skapa vyn "v_TitlarPerFörfattare"

CREATE VIEW v_TitlarPerFörfattare AS
SELECT 
    F.ID AS FörfattareID,
    F.Förnamn + ' ' + F.Efternamn AS Namn,
    DATEDIFF(YEAR, F.Födelsedatum, GETDATE()) AS Ålder,
    COUNT(B.ISBN13) AS Titlar,
    SUM(B.Pris) AS Lagervärde
FROM 
    Författare F
JOIN 
    Böcker B ON F.ID = B.FörfattareID
JOIN 
    LagerSaldo LS ON B.ISBN13 = LS.ISBN
GROUP BY 
    F.ID, F.Förnamn, F.Efternamn, F.Födelsedatum;
GO
-- Skapa tabellen "FörfattareBöcker" för att hantera många–många-relationen
-- Flera författare på samma bok 

CREATE TABLE FörfattareBöcker (
    FörfattareID INT,
    ISBN13 VARCHAR(13),   
    PRIMARY KEY (FörfattareID, ISBN13),
    FOREIGN KEY (FörfattareID) REFERENCES Författare(ID),
    FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13),    
);

GO
INSERT INTO FörfattareBöcker (FörfattareID, ISBN13) VALUES (1, '1234567890123');
GO
-- EXTRA VY för att samlar information från Böcker- och OrderRader-tabeller
CREATE VIEW BokhandelSummary AS
SELECT
    B.ISBN13,
    B.Titel,
    B.Pris AS BokPris,
    SUM(ORR.Antal) AS TotalAntal,
    SUM(ORR.Pris) AS TotalPris
FROM
    Böcker B
JOIN
    OrderRader ORR ON B.ISBN13 = ORR.ISBN13
GROUP BY
    B.ISBN13, B.Titel, B.Pris;
GO
-- SKapa stored procedure för hitta bok detail  av ISBN
CREATE PROCEDURE GetBookInfo
    @ISBN13 VARCHAR(13)
AS
BEGIN
    -- Check if the book exists
    IF EXISTS (
        SELECT 1
        FROM Böcker
        WHERE ISBN13 = @ISBN13
    )
    BEGIN
        -- Retrieve book information
        SELECT
            ISBN13,
            Titel,
            Språk,
            Pris,
            Utgivningsdatum,
            FörfattareID
        FROM Böcker
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
SELECT * FROM Böcker
SELECT  * FROM v_TitlarPerFörfattare
SELECT * FROM OrderRader
SELECT *FROM FörfattareBöcker
SELECT *FROM Ordrar

