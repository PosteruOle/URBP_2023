-- Indeksi

-- 1. Kreirati  indeks  tabele  dosije  po  imenu  i  prezimenu
--     u  opadajucem  redosledu. Zatim ga obrisati.

CREATE INDEX dosije_ime_prezime ON da.dosije
(ime DESC, prezime DESC);

DROP INDEX dosije_ime_prezime;


--Probajmo
CREATE UNIQUE INDEX dosije_ime_prezime ON da.dosije
(ime DESC, prezime DESC);

CREATE UNIQUE INDEX dosije_ime_prezime ON da.dosije
(indeks ASC, ime DESC, prezime DESC);

DROP INDEX dosije_ime_prezime;


CREATE INDEX neki ON da.dosije
(ime DESC);

CREATE INDEX neki ON da.predmet
(naziv DESC);

DROP INDEX neki;

-- Indeks bez imena

CREATE INDEX ON da.predmet
(naziv DESC);


-----------------------------------------------------

-- Pogledi

-- 1. Kreirati pogled kojim se izdvajaju svi ispitni rokovi
--     pocev od 2019. godine.
--     Zatim ilustrovati naredbe za rad sa pogledom.


SELECT skGodina, oznakaRoka, naziv, datPocetka, datKraja
FROM da.ispitniRok
WHERE skGodina>=2019;


CREATE VIEW da.ispiti2019 AS
SELECT skGodina, oznakaRoka, naziv, datPocetka, datKraja
FROM da.ispitniRok
WHERE skGodina>=2019;

--Dodajemo u tabelu
INSERT INTO da.ispitniRok
VALUES(2019, 'medj1', 'Test', '10.08.2020', '14.08.2020');

--SELECT *
--FROM da.ispitniRok;

--SELECT *
--FROM da.ispiti2019;


--Dodajemo u pogled
INSERT INTO da.ispiti2019
VALUES(2019, 'medj2', 'Test2', '15.08.2020', '19.08.2020');

--SELECT *
--FROM da.ispiti2019;

--SELECT *
--FROM da.ispitniRok;


UPDATE da.ispiti2019
SET naziv='T2n'
WHERE skGodina=2019 AND oznakaRoka='medj2';

--SELECT *
--FROM da.ispiti2019;

--SELECT *
--FROM da.ispitniRok;

UPDATE da.ispiti2019
SET skGodina=2018
WHERE skGodina=2019 AND oznakaRoka='medj2';

--SELECT *
--FROM da.ispiti2019;

--SELECT *
--FROM da.ispitniRok;

DROP VIEW da.ispiti2019;

--SELECT *
--FROM da.ispitniRok;

DELETE FROM da.ispitniRok
WHERE oznakaRoka LIKE 'medj%';

-- 2.  Kreirati pogled sa svim prijavljenim ispitima Luke Blagica.

SELECT i.*
FROM da.ispit i JOIN da.dosije d ON i.indeks=d.indeks
WHERE d.ime='Luka' AND d.prezime='Blagic';


CREATE VIEW da.lb AS 
SELECT i.*
FROM da.ispit i JOIN da.dosije d ON i.indeks=d.indeks
WHERE d.ime='Luka' AND d.prezime='Blagic';

INSERT INTO da.lb
VALUES (2016,'sep2',20150174,2022,'x',NULL,NULL,NULL);

CREATE VIEW da.lbn AS 
SELECT *
FROM da.ispit i
WHERE EXISTS(SELECT *
			FROM da.dosije d
			WHERE d.indeks=i.indeks AND
			      	    d.ime='Luka' AND d.prezime='Blagic');


INSERT INTO da.lbn
VALUES (2016,'sep2',20150174,2022,'x',NULL,NULL,NULL);


DROP VIEW da.lb;
DROP VIEW da.lbn;



-- 3. Kreirati pogled kojim se izdvajaju sva polaganja studenata
--     koji se zovu Marko  ili  Maja,  i
--     koji  su  u  junskom  ispitnom  roku  2018.   godine
--     	    polozili barem jedan predmet.


SELECT *
FROM da.ispit i
WHERE EXISTS(SELECT *
			FROM da.dosije 
			WHERE indeks=i.indeks AND
			            ime IN ('Marko', 'Maja')) AND
             EXISTS(SELECT *
		         FROM da.ispit 
			 WHERE indeks=i.indeks AND
			             skGodina=2018 AND
				     oznakaRoka='jun1' AND
				     ocena>5 AND status='o');


CREATE VIEW da.ispitiMM AS
SELECT *
FROM da.ispit i
WHERE EXISTS(SELECT *
			FROM da.dosije 
			WHERE indeks=i.indeks AND
			            ime IN ('Marko', 'Maja')) AND
             EXISTS(SELECT *
		         FROM da.ispit 
			 WHERE indeks=i.indeks AND
			             skGodina=2018 AND
				     oznakaRoka='jun1' AND
				     ocena>5 AND status='o')
WITH CHECK OPTION;

		     
INSERT INTO da.ispitiMM
VALUES(2020, 'jan1', 20150174, 2016, 'o', current date, 67, 7);


INSERT INTO da.ispitiMM
VALUES(2018, 'jan2', 20181104, 2127, 'o', current date, 67, 7);


--select count(*) from da.ispit;

DELETE FROM da.ispitiMM
WHERE indeks=20181104 AND skGodina=2018 AND oznakaRoka='jan2';

--select count(*) from da.ispit;

DROP VIEW da.ispitiMM;


-------
--Drugi nacin :

SELECT DISTINCT i.*
FROM da.dosije d JOIN da.ispit i ON d.indeks=i.indeks
     	       	      	   JOIN da.ispit i1 ON d.indeks=i1.indeks
WHERE d.ime IN ('Marko', 'Maja') AND
      	    i1.skGodina=2018 AND i1.oznakaRoka='jun1' AND
	    i1.ocena>5 AND i1.status='o';

-----------------------------------------------------------------------

-- Vezba
-- 3. Za studente Osnovnih akademskih studija Matematike
--     koji su upisani 2018.  godine, pronaci
--     koji su obavezni predmeti ostali do zavrsetka studiranja.
--     Izdvojiti indeks, ime i prezime studenta
--     i naziv nepolozenog obaveznog predmeta.
--     Smatrati  da  se  student  upisao  2018.   godine  ako  su
--     mu  najvise  4  cifreindeksa bas 2018.


--Izdvojimo prvo studente koji su upisani 2018 na matematiku OAS:
SELECT d.indeks, d.ime, d.prezime
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
    	       	             JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
WHERE d.indeks/10000=2018 AND sp.naziv='Matematika' AND nk.naziv='Osnovne akademske studije';

SELECT d.indeks, d.ime, d.prezime, pp.idPredmeta
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
    	       	 JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
WHERE d.indeks/10000=2018 AND sp.naziv='Matematika' AND nk.naziv='Osnovne akademske studije' AND pp.vrsta='obavezan'
ORDER BY 1;	

SELECT d.indeks, d.ime, d.prezime, pp.idPredmeta
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
    	         JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
WHERE d.indeks/10000=2018 AND
     	 sp.naziv='Matematika' AND
	     nk.naziv='Osnovne akademske studije' AND
	     pp.vrsta='obavezan' AND
	     NOT EXISTS(SELECT *
				    FROM da.ispit
				    WHERE indeks=d.indeks AND idPredmeta=pp.idPredmeta AND ocena>5 AND status='o');

--Izdvajamo nazive a ne id
SELECT d.indeks, d.ime, d.prezime, p.naziv
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
    	       	 JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
			     JOIN da.predmet p ON pp.idPredmeta=p.id
WHERE d.indeks/10000=2018 AND
     	 sp.naziv='Matematika' AND
	     nk.naziv='Osnovne akademske studije' AND
	     pp.vrsta='obavezan' AND
	     NOT EXISTS(SELECT *
				    FROM da.ispit
				    WHERE indeks=d.indeks AND idPredmeta=pp.idPredmeta AND ocena>5 AND status='o');

-------
--Dodatak zarad provere kardinalnosti:
SELECT pp.idPredmeta
FROM da.studijskiProgram sp JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			                JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
WHERE sp.naziv='Matematika' AND nk.naziv='Osnovne akademske studije' AND
	     pp.vrsta='obavezan'
ORDER BY 1;
--------

-- 4. Za studente Osnovnih akademskih studija Matematike
--     upisane 2018.  godine izdvojiti:
--     za  koje  obavezne  predmete  nisu  polozili  uslovne  predmete.
--     Izdvojiti indeks, ime i prezime studenta, naziv obaveznog predmeta
--     i naziv uslovnog predmeta.
--     Smatrati da se student upisao 2018.  godine ako je godina datuma upisa 2018.

SELECT d.indeks, d.ime, d.prezime, pp.idPredmeta, up.idPredmeta, up.idUslovnogPredmeta
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
    	       	 JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
			     JOIN da.uslovniPredmet up ON pp.idPrograma=up.idPrograma AND pp.idPredmeta=up.idPredmeta
WHERE YEAR(d.datUpisa)=2018 AND
     	sp.naziv='Matematika' AND
	    nk.naziv='Osnovne akademske studije' AND
	    pp.vrsta='obavezan';

SELECT d.indeks, d.ime, d.prezime, pp.idPredmeta, up.idPredmeta, up.idUslovnogPredmeta
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
    	       	 JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
			     JOIN da.uslovniPredmet up ON pp.idPrograma=up.idPrograma AND pp.idPredmeta=up.idPredmeta
WHERE YEAR(d.datUpisa)=2018 AND
     	sp.naziv='Matematika' AND
	    nk.naziv='Osnovne akademske studije' AND
	    pp.vrsta='obavezan' AND NOT EXISTS(SELECT *
				                           FROM da.ispit
				                           WHERE indeks=d.indeks AND idPredmeta=up.idUslovnogPredmeta AND ocena>5 AND status='o');

SELECT d.indeks, d.ime, d.prezime, p1.naziv, p2.naziv
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
    	       	 JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
			     JOIN da.uslovniPredmet up ON pp.idPrograma=up.idPrograma AND pp.idPredmeta=up.idPredmeta
			     JOIN da.predmet p1 ON p1.id=up.idPredmeta
			     JOIN da.predmet p2 ON p2.id=up.idUslovnogPredmeta
WHERE YEAR(d.datUpisa)=2018 AND
     	sp.naziv='Matematika' AND
	    nk.naziv='Osnovne akademske studije' AND
	    pp.vrsta='obavezan' AND
	    NOT EXISTS(SELECT *
				   FROM da.ispit
				   WHERE indeks=d.indeks AND idPredmeta=up.idUslovnogPredmeta AND ocena>5 AND status='o');

-- 6. Za sve studente cije ime pocinje na slovo P i upisani su izmedu februara i  jula,
--     izdvojiti:
--     podatke  o  polozenim  ispitima.
--     Izdvojiti  indeks,  ime  i prezime studenta, naziv predmeta, dobijenu ocenu
--     i kategoriju polozenog predmeta.  Polozen predmet spada u kategoriju:
--     * obavezan, ako je obavezan predmet na smeru koji student studira;
--     * izborni, ako nije obavezan predmet na smeru koji student studira;
--     * NULL, ako nije polozio nijedan predmet;

SELECT d.indeks, d.ime, d.prezime
FROM da.dosije d
WHERE SUBSTR(d.ime, 1, 1)='P' AND MONTH(d.datUpisa) BETWEEN 2 AND 7;

SELECT d.indeks, d.ime, d.prezime, p.naziv,
        CASE
		    WHEN EXISTS(SELECT *
				       FROM da.predmetPrograma 
				       WHERE idPrograma=d.idPrograma AND idPredmeta=p.id ANDvrsta='obavezan') THEN 'obavezan'
		    WHEN p.id IS NULL THEN NULL
		    ELSE 'izborni'
	    END AS "kategorija"				       
FROM da.dosije d LEFT JOIN da.ispit i ON d.indeks=i.indeks AND ocena>5 AND status='o'
    	       	 LEFT JOIN da.predmet p ON i.idPredmeta=p.id
WHERE SUBSTR(d.ime, 1, 1)='P' AND MONTH(d.datUpisa) BETWEEN 2 AND 7
ORDER BY 4;

-----------------------------------------------------------
--Domaci:

-- 2. Odrediti prolaznost po predmetima.
--     Izdvojiti naziv predmeta i procenat studenata koji je polozio taj predmet
--     u odnosu na broj studenata koji suga polagali.
--     Procenat zaokruziti na dve decimale.
--     Dodati i NULL za one koje niko nije polagao.

SELECT id, naziv,
	        DECIMAL(AVG(CASE
			                WHEN ocena>5 AND status='o' THEN 100.0
			                ELSE 0.0
		                END), 6, 2) AS "prolaznost"
FROM da.predmet p JOIN da.ispit i ON p.id=i.idPredmeta
GROUP BY p.id, p.naziv
UNION
SELECT id, naziv, NULL
FROM da.predmet p
WHERE id NOT IN (SELECT idPredmeta FROM da.ispit);

-- Provera kardinalnosti:
SELECT COUNT(DISTINCT idPredmeta) FROM da.ispit;
SELECT COUNT(id) FROM da.predmet p WHERE id NOT IN (SELECT idPredmeta FROM da.ispit);
SELECT COUNT(id) FROM da.predmet;

-- 1. Za svaki studijski program pronaci studenta koji ima najvise polozenih bodova.
--     Izdvojiti identifikator i naziv studijskog programa, indeks, ime i prezime studenta
--     i broj polozenih bodova.
--     Ime i prezime prikazati u jednoj koloni i kao nisku odprvih 40 karaktera konkatenacije.
--     Od naziva studijskog programa i nivoa kvalifikacije prikazati samo prvih 30 karaktera. 

WITH studPolozeno AS (
SELECT d.indeks, d.ime, d.prezime, d.idPrograma, SUM(p.espb) ukupno
FROM da.dosije d JOIN da.ispit i ON d.indeks=i.indeks
     	       	 JOIN da.predmet p ON p.id=i.idPredmeta
WHERE ocena>5 AND status='o'
GROUP BY d.indeks, d.ime, d.prezime, d.idPrograma
)
SELECT SUBSTR(sp.naziv, 1, 30), SUBSTR(nk.naziv, 1, 30), pol.indeks, SUBSTR(pol.ime||' '||pol.prezime, 1, 40), pol.ukupno
FROM (da.studijskiProgram sp JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id)
        LEFT OUTER JOIN studPolozeno pol ON sp.id=pol.idPrograma
WHERE pol.ukupno=(SELECT MAX(ukupno)
				  FROM studPolozeno
				  WHERE idPrograma=sp.id) or pol.indeks IS NULL
ORDER BY 1, 2;	
