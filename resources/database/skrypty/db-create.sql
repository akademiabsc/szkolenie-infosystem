/* 2018-11-02
*
* Baza danych do przeprowadzenia szkolenia
*/


CREATE DATABASE 'C:\info-sys_groszek\db\klienci-n.fdb' USER 'SYSDBA' PASSWORD 'masterkey' PAGE_SIZE 8192 DEFAULT CHARACTER SET WIN1250;

-- DB_VERSIONS

CREATE TABLE DB_VERSIONS
(
   VERSION INTEGER NOT NULL,
   INFO VARCHAR(100) NOT NULL,
      CONSTRAINT DB_PK_VERSIONS PRIMARY KEY (VERSION)
);

INSERT INTO DB_VERSIONS (VERSION, INFO) VALUES (1,'2018-10-24: Pocz�tkowa wersja bazy');
INSERT INTO DB_VERSIONS (VERSION, INFO) VALUES (2,'2018-11-02: Dodano tabele systemu PD: PD_KONTA, PD_PODATNICY, PD_RODZAJE_SKL, PD_SKLADNIKI oraz uprawnienia dla nich');
INSERT INTO DB_VERSIONS (VERSION, INFO) VALUES (3,'2018-11-25: Dodano tabel� DB_VERSIONS');

-- OP_OPER

CREATE TABLE OP_OPER
(
   ID_OPER INTEGER NOT NULL,
   NAZWA VARCHAR(30) COLLATE PXW_PLK,
   HASLO VARCHAR(30),
   IMIE VARCHAR(30) COLLATE PXW_PLK,
   NAZWISKO VARCHAR(60) COLLATE PXW_PLK,
   STATUS CHARACTER(1),
      CONSTRAINT OP_PK_OPER PRIMARY KEY (ID_OPER)
);

ALTER TABLE OP_OPER ADD CONSTRAINT OP_CST_OPR_NAZWA CHECK( NAZWA IS NOT NULL AND NAZWA <> '' );
ALTER TABLE OP_OPER ADD CONSTRAINT OP_CST_OPR_STATUS CHECK( STATUS IS NOT NULL AND STATUS IN ('A', 'B', 'U', 'Z') );

CREATE UNIQUE INDEX OP_IDX_OPR_NAZWA ON OP_OPER COMPUTED BY (UPPER(NAZWA));

CREATE SEQUENCE OP_SEQ_OPER_ID;
ALTER SEQUENCE OP_SEQ_OPER_ID RESTART WITH 100;


-- OP_SLFUN

CREATE TABLE OP_SLFUN
(   
   KOD_FUNSYS VARCHAR(10) NOT NULL,
   OPIS VARCHAR(100),
      CONSTRAINT OP_PK_SLFUN PRIMARY KEY (KOD_FUNSYS)
);


-- OP_OPFUN

CREATE TABLE OP_OPFUN
(  
   ID_OPER INTEGER NOT NULL,
   KOD_FUNSYS VARCHAR(10) NOT NULL,
      CONSTRAINT OP_PK_OPFUN PRIMARY KEY (ID_OPER, KOD_FUNSYS)
);

ALTER TABLE OP_OPFUN ADD CONSTRAINT OP_REF_OPR2OPF FOREIGN KEY (ID_OPER)
REFERENCES OP_OPER (ID_OPER)
ON UPDATE CASCADE;

ALTER TABLE OP_OPFUN ADD CONSTRAINT OP_REF_SLF2OPF FOREIGN KEY (KOD_FUNSYS)
REFERENCES OP_SLFUN (KOD_FUNSYS)
ON UPDATE CASCADE;


-- BO_MAIN

CREATE TABLE BO_MAIN
( 
   ID_OSOBY INTEGER NOT NULL,
   RODZAJ_OSB CHAR(1),
   NAZWA VARCHAR(80) COLLATE PXW_PLK,
   NIP VARCHAR(13),
   KOD_KRAJU CHAR(2),
   REGON VARCHAR(15),
   EMAIL VARCHAR(40),
   TELEFON VARCHAR(20),
   RB_NUMER VARCHAR(40),
   REJ_DATA TIMESTAMP NOT NULL,
   REJ_OPER INTEGER NOT NULL,
   MOD_DATA TIMESTAMP,
   MOD_OPER INTEGER,
      CONSTRAINT BO_PK_MAIN PRIMARY KEY (ID_OSOBY)
);

ALTER TABLE BO_MAIN ADD CONSTRAINT BO_CST_MN_RODZAJ_OSB CHECK( RODZAJ_OSB IS NOT NULL AND RODZAJ_OSB IN ('F', 'P') );

ALTER TABLE BO_MAIN ADD CONSTRAINT BO_REL_OPR2MN_R FOREIGN KEY (REJ_OPER)
REFERENCES OP_OPER (ID_OPER)
ON UPDATE CASCADE;

ALTER TABLE BO_MAIN ADD CONSTRAINT BO_REL_OPR2MN_M FOREIGN KEY (MOD_OPER)
REFERENCES OP_OPER (ID_OPER)
ON UPDATE CASCADE;

CREATE INDEX BO_IDX_MN_NAZWA ON BO_MAIN COMPUTED BY (UPPER(NAZWA));

CREATE SEQUENCE BO_SEQ_OSOBA_ID;
ALTER SEQUENCE BO_SEQ_OSOBA_ID RESTART WITH 1000;


-- BO_ADRES

CREATE TABLE BO_ADRES
( 
   ID_ADRESU INTEGER NOT NULL,
   ID_OSOBY INTEGER NOT NULL,
   TYP_ADRESU CHAR(1), 
   MIASTO VARCHAR(60) COLLATE PXW_PLK,
   ULICA VARCHAR(65) COLLATE PXW_PLK,
   DOM VARCHAR(15),
   LOKAL VARCHAR(10),
   TYP_ULICY VARCHAR(10) COLLATE PXW_PLK,
   KOD VARCHAR(6),
   POCZTA VARCHAR(60) COLLATE PXW_PLK,
   GMINA VARCHAR(40) COLLATE PXW_PLK,
   POWIAT VARCHAR(40) COLLATE PXW_PLK,
   WOJEWODZTWO VARCHAR(40) COLLATE PXW_PLK,
   KRAJ VARCHAR(60) COLLATE PXW_PLK,
   REJ_DATA TIMESTAMP NOT NULL,
   REJ_OPER INTEGER NOT NULL,
   MOD_DATA TIMESTAMP,
   MOD_OPER INTEGER,
      CONSTRAINT BO_PK_ADRES PRIMARY KEY (ID_ADRESU)
);

ALTER TABLE BO_ADRES ADD CONSTRAINT BO_CST_ADR_MIASTO CHECK( MIASTO IS NOT NULL AND MIASTO <> '' );
ALTER TABLE BO_ADRES ADD CONSTRAINT BO_CST_ADR_TYP_ADRESU CHECK( TYP_ADRESU IS NULL OR TYP_ADRESU IN ('Z', 'M', 'S', 'I') );

ALTER TABLE BO_ADRES ADD CONSTRAINT BO_REL_MN2ADR FOREIGN KEY (ID_OSOBY)
REFERENCES BO_MAIN (ID_OSOBY)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE BO_ADRES ADD CONSTRAINT BO_REL_OPR2ADR_R FOREIGN KEY (REJ_OPER)
REFERENCES OP_OPER (ID_OPER)
ON UPDATE CASCADE;

ALTER TABLE BO_ADRES ADD CONSTRAINT BO_REL_OPR2ADR_M FOREIGN KEY (MOD_OPER)
REFERENCES OP_OPER (ID_OPER)
ON UPDATE CASCADE;

CREATE INDEX BO_IDX_ADR_MIASTO ON BO_ADRES COMPUTED BY (UPPER(MIASTO));
CREATE INDEX BO_IDX_ADR_ULICA ON BO_ADRES COMPUTED BY (UPPER(ULICA));

CREATE SEQUENCE BO_SEQ_ADRES_ID;
ALTER SEQUENCE BO_SEQ_ADRES_ID RESTART WITH 1000;


-- BO_FIZ

CREATE TABLE BO_FIZ
( 
   ID_OSOBY INTEGER NOT NULL,
   IMIE VARCHAR(30) COLLATE PXW_PLK,
   IMIE_DRUGIE VARCHAR(30) COLLATE PXW_PLK,
   NAZWISKO VARCHAR(50) COLLATE PXW_PLK,
   IMIE_OJCA VARCHAR(30) COLLATE PXW_PLK,
   IMIE_MATKI VARCHAR(30) COLLATE PXW_PLK,
   PESEL VARCHAR(11),
   TYP_DOK_TOZ CHAR(1),
   NR_DOK_TOZ VARCHAR(10),
   DATA_UR TIMESTAMP,
   MIEJSCE_UR VARCHAR(65) COLLATE PXW_PLK,
      CONSTRAINT BO_PK_FIZ PRIMARY KEY (ID_OSOBY)
);

ALTER TABLE BO_FIZ ADD CONSTRAINT BO_CST_FIZ_IMIE CHECK( IMIE IS NOT NULL AND IMIE <> '' );
ALTER TABLE BO_FIZ ADD CONSTRAINT BO_CST_FIZ_NAZWISKO CHECK( NAZWISKO IS NOT NULL AND NAZWISKO <> '' );
ALTER TABLE BO_FIZ ADD CONSTRAINT BO_CST_FIZ_TYP_DOK_TOZ CHECK( TYP_DOK_TOZ IS NULL OR TYP_DOK_TOZ IN ('D', 'J', 'P') );

ALTER TABLE BO_FIZ ADD CONSTRAINT BO_REL_MN2FIZ FOREIGN KEY (ID_OSOBY)
REFERENCES BO_MAIN (ID_OSOBY)
ON UPDATE CASCADE
ON DELETE CASCADE;

CREATE INDEX BO_IDX_FIZ_IMIE ON BO_FIZ COMPUTED BY (UPPER(IMIE));
CREATE INDEX BO_IDX_FIZ_NAZWISKO ON BO_FIZ COMPUTED BY (UPPER(NAZWISKO));


-- BO_PRAWNE

CREATE TABLE BO_PRAWNE
( 
   ID_OSOBY INTEGER NOT NULL,
   NAZWA_SKR VARCHAR(50) COLLATE PXW_PLK,
   NAZWA_PLN VARCHAR(180) COLLATE PXW_PLK,
   WWW VARCHAR(60),
   NUMER_KRS VARCHAR(10),
      CONSTRAINT BO_PK_PRAWNE PRIMARY KEY (ID_OSOBY)
);

ALTER TABLE BO_PRAWNE ADD CONSTRAINT BO_CST_PRW_NAZWA_SKR CHECK( NAZWA_SKR IS NOT NULL AND NAZWA_SKR <> '' );
ALTER TABLE BO_PRAWNE ADD CONSTRAINT BO_CST_PRW_NAZWA_PLN CHECK( NAZWA_PLN IS NOT NULL AND NAZWA_PLN <> '' );

ALTER TABLE BO_PRAWNE ADD CONSTRAINT BO_REL_MN2PRW FOREIGN KEY (ID_OSOBY)
REFERENCES BO_MAIN (ID_OSOBY)
ON UPDATE CASCADE
ON DELETE CASCADE;

CREATE INDEX BO_IDX_PRW_NAZWA_SKR ON BO_PRAWNE COMPUTED BY (UPPER(NAZWA_SKR));
CREATE INDEX BO_IDX_PRW_NAZWA_PLN ON BO_PRAWNE COMPUTED BY (UPPER(NAZWA_PLN));


-- PD_KONTA

CREATE TABLE PD_KONTA
(
   ID_KONTA INTEGER NOT NULL,
   NUMER_KW VARCHAR(15),
   NIER_ULICA VARCHAR(65) COLLATE PXW_PLK,
   NIER_DOM VARCHAR(20),
   NIER_LOKAL VARCHAR(15),
   TERMIN_PL TIMESTAMP,
   WPLATA_KWT NUMERIC(15,2),
   WPLATA_DT TIMESTAMP,
      CONSTRAINT PD_PK_KONTA PRIMARY KEY (ID_KONTA)
);

ALTER TABLE PD_KONTA ADD CONSTRAINT PD_CST_KNT_NUMER_KW CHECK( NUMER_KW IS NOT NULL );
ALTER TABLE PD_KONTA ADD CONSTRAINT PD_CST_KNT_NIER_ULICA CHECK( NIER_ULICA IS NOT NULL );
ALTER TABLE PD_KONTA ADD CONSTRAINT PD_CST_KNT_TERMIN_PL CHECK( TERMIN_PL IS NOT NULL );
ALTER TABLE PD_KONTA ADD CONSTRAINT PD_CST_KNT_WPLATA_KWT CHECK( WPLATA_KWT IS NULL OR WPLATA_KWT >= 0.0 );

CREATE INDEX PD_IDX_KNT_NUMER_KW ON PD_KONTA COMPUTED BY (UPPER(NUMER_KW));
CREATE INDEX PD_IDX_KNT_NIER_ULICA ON PD_KONTA COMPUTED BY (UPPER(NIER_ULICA));

CREATE SEQUENCE PD_SEQ_KONTO_ID;
ALTER SEQUENCE PD_SEQ_KONTO_ID RESTART WITH 1000;


-- PD_PODATNICY

CREATE TABLE PD_PODATNICY
(
   ID_KONTA INTEGER NOT NULL,
   ID_OSOBY INTEGER NOT NULL,
   ID_ADRESU INTEGER NOT NULL,
   ID_ADRESU_K INTEGER,
   UDZIAL_L INTEGER DEFAULT 1,
   UDZIAL_M INTEGER DEFAULT 1,
   STATUS CHAR(1) DEFAULT 'W',
      CONSTRAINT PD_PK_PODATNICY PRIMARY KEY (ID_KONTA, ID_OSOBY)
);

ALTER TABLE PD_PODATNICY ADD CONSTRAINT PD_CST_PDT_UDZIAL CHECK( UDZIAL_M IS NOT NULL AND UDZIAL_L IS NOT NULL AND UDZIAL_M > 0 AND UDZIAL_L <= UDZIAL_M );
ALTER TABLE PD_PODATNICY ADD CONSTRAINT PD_CST_PDT_STATUS CHECK( STATUS IS NOT NULL AND STATUS IN ('W', 'D', 'P', 'S', 'I') );

ALTER TABLE PD_PODATNICY ADD CONSTRAINT PD_REL_MN2PDT FOREIGN KEY (ID_OSOBY)
REFERENCES BO_MAIN (ID_OSOBY)
ON UPDATE CASCADE;

ALTER TABLE PD_PODATNICY ADD CONSTRAINT PD_REL_ADR2PDT FOREIGN KEY (ID_ADRESU)
REFERENCES BO_ADRES (ID_ADRESU)
ON UPDATE CASCADE;

ALTER TABLE PD_PODATNICY ADD CONSTRAINT PD_REL_ADR2PDTK FOREIGN KEY (ID_ADRESU_K)
REFERENCES BO_ADRES (ID_ADRESU)
ON UPDATE CASCADE;


-- PD_RODZAJE_SKL

CREATE TABLE PD_RODZAJE_SKL
(
   ID_RODZAJU_SKL INTEGER NOT NULL,
   NAZWA VARCHAR(250),
   PROC_ULGI NUMERIC(5,2),
      CONSTRAINT PD_PD_RODZAJE_SKL PRIMARY KEY (ID_RODZAJU_SKL)
);

ALTER TABLE PD_RODZAJE_SKL ADD CONSTRAINT PD_CST_SRS_NAZWA CHECK( NAZWA IS NOT NULL AND NAZWA <> '' );
ALTER TABLE PD_RODZAJE_SKL ADD CONSTRAINT PD_CST_SRS_PROC_ULGI CHECK( PROC_ULGI IS NULL OR (PROC_ULGI >= 0.0 AND PROC_ULGI <= 100.0) );

CREATE SEQUENCE PD_SEQ_RODZAJ_SKL_ID;


-- PD_SKLADNIKI

CREATE TABLE PD_SKLADNIKI
(
   ID_KONTA INTEGER NOT NULL,
   ID_SKLADNIKA INTEGER NOT NULL,
   ID_RODZAJU_SKL INTEGER,
   POWIERZCHNIA NUMERIC(15,2),
   UDZIAL NUMERIC(10,8) DEFAULT 1.0,
   STAWKA NUMERIC(15,4),
   PROC_ULGI NUMERIC(5,2),
      CONSTRAINT PD_PK_SKLADNIKI PRIMARY KEY (ID_KONTA, ID_SKLADNIKA)
);

ALTER TABLE PD_SKLADNIKI ADD CONSTRAINT PD_CST_SKL_POWIERZCHNIA CHECK( POWIERZCHNIA IS NOT NULL AND POWIERZCHNIA >= 0.0 );
ALTER TABLE PD_SKLADNIKI ADD CONSTRAINT PD_CST_SKL_UDZIAL CHECK( UDZIAL IS NOT NULL AND UDZIAL >= 0.0 AND UDZIAL <= 1.0 );
ALTER TABLE PD_SKLADNIKI ADD CONSTRAINT PD_CST_SKL_STAWKA CHECK( STAWKA IS NOT NULL AND STAWKA >= 0.0 );
ALTER TABLE PD_SKLADNIKI ADD CONSTRAINT PD_CST_SKL_PROC_ULGI CHECK( PROC_ULGI IS NULL OR (PROC_ULGI >= 0.0 AND PROC_ULGI <= 100.0) );

ALTER TABLE PD_SKLADNIKI ADD CONSTRAINT PD_REL_KNT2SKL FOREIGN KEY (ID_KONTA)
REFERENCES PD_KONTA (ID_KONTA)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE PD_SKLADNIKI ADD CONSTRAINT PD_REL_SRS2SKL FOREIGN KEY (ID_RODZAJU_SKL)
REFERENCES PD_RODZAJE_SKL (ID_RODZAJU_SKL)
ON UPDATE CASCADE;

CREATE SEQUENCE PD_SEQ_SKLADNIK_ID;



SET TERM ^ ;


CREATE OR ALTER PROCEDURE OP_SP_OPER_GEN_ID 
RETURNS (ID_OPER INTEGER) 
AS 
BEGIN

   ID_OPER = NEXT VALUE FOR OP_SEQ_OPER_ID;
   
END ^


CREATE OR ALTER PROCEDURE BO_SP_MAIN_GEN_ID 
RETURNS (ID_OSOBY INTEGER) 
AS 
BEGIN

   ID_OSOBY = NEXT VALUE FOR BO_SEQ_OSOBA_ID;
   
END ^


CREATE OR ALTER PROCEDURE BO_SP_ADRES_GEN_ID 
RETURNS (ID_ADRESU INTEGER) 
AS 
BEGIN

   ID_ADRESU = NEXT VALUE FOR BO_SEQ_ADRES_ID;
   
END ^


CREATE OR ALTER PROCEDURE PD_SP_KONTO_GEN_ID 
RETURNS (ID_KONTA INTEGER) 
AS 
BEGIN

   ID_KONTA = NEXT VALUE FOR PD_SEQ_KONTO_ID;
   
END ^


CREATE OR ALTER PROCEDURE PD_SP_RODZAJ_SKL_GEN_ID 
RETURNS (ID_RODZAJU_SKL INTEGER) 
AS 
BEGIN

   ID_RODZAJU_SKL = NEXT VALUE FOR PD_SEQ_RODZAJ_SKL_ID;
   
END ^


CREATE OR ALTER PROCEDURE PD_SP_SKLADNIK_GEN_ID 
RETURNS (ID_SKLADNIKA INTEGER) 
AS 
BEGIN

   ID_SKLADNIKA = NEXT VALUE FOR PD_SEQ_SKLADNIK_ID;
   
END ^


CREATE OR ALTER TRIGGER OP_TRG_OPER_INS_BEF FOR OP_OPER
ACTIVE BEFORE INSERT AS
BEGIN

   IF (NEW.ID_OPER IS NULL) THEN
      NEW.ID_OPER = NEXT VALUE FOR OP_SEQ_OPER_ID;
      
END ^


CREATE OR ALTER TRIGGER BO_TRG_MAIN_INS_BEF FOR BO_MAIN
ACTIVE BEFORE INSERT AS
BEGIN

   IF (NEW.ID_OSOBY IS NULL) THEN
      NEW.ID_OSOBY = NEXT VALUE FOR BO_SEQ_OSOBA_ID;
      
END ^


CREATE OR ALTER TRIGGER BO_TRG_ADRES_INS_BEF FOR BO_ADRES
ACTIVE BEFORE INSERT AS
BEGIN

   IF (NEW.ID_ADRESU IS NULL) THEN
      NEW.ID_ADRESU = NEXT VALUE FOR BO_SEQ_ADRES_ID;
      
END ^


CREATE OR ALTER TRIGGER PD_TRG_KONTO_INS_BEF FOR PD_KONTA
ACTIVE BEFORE INSERT AS
BEGIN

   IF (NEW.ID_KONTA IS NULL) THEN
      NEW.ID_KONTA = NEXT VALUE FOR PD_SEQ_KONTO_ID;
      
END ^


CREATE OR ALTER TRIGGER PD_TRG_RODZAJE_SKL_INS_BEF FOR PD_RODZAJE_SKL
ACTIVE BEFORE INSERT AS
BEGIN

   IF (NEW.ID_RODZAJU_SKL IS NULL) THEN
      NEW.ID_RODZAJU_SKL = NEXT VALUE FOR PD_SEQ_RODZAJ_SKL_ID;
      
END ^


CREATE OR ALTER TRIGGER PD_TRG_SKLADNIKI_INS_BEF FOR PD_SKLADNIKI
ACTIVE BEFORE INSERT AS
BEGIN

   IF (NEW.ID_SKLADNIKA IS NULL) THEN
      NEW.ID_SKLADNIKA = NEXT VALUE FOR PD_SEQ_SKLADNIK_ID;
      
END ^


SET TERM ; ^
