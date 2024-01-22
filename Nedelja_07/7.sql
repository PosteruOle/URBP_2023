-- Naredbe za menjanje podataka

--INSERT INTO <naziv tabele> [(<lista naziva kolona>)]
--<upit>


-- 1. Dodati ispitni rok Oktobar 2 2015.

describe table da.ispitnirok;
select * from da.ispitniRok order by 1 desc,2;

INSERT INTO da.ispitniRok
VALUES (2015, 'okt2', 'Oktobar 2 2015', '01.10.2016', '07.10.2016');

---------------------------------------------------------------------
--Probamo
INSERT INTO da.ispitniRok
VALUES ( 'okt2', 'Oktobar 2 2015', '01.10.2016', '07.10.2016',2015);

INSERT INTO da.ispitniRok (oznakaRoka,naziv,datPocetka,datKraja,skGodina)
VALUES ( 'okt2', 'Oktobar 2 2016', '01.10.2017', '07.10.2017',2016),
	   ( 'okt2', 'Oktobar 2 2017', '01.10.2018', '07.10.2018',2017);
---------------------------------------------------------------------

SELECT * FROM da.ispitniRok WHERE oznakaroka='okt2';


-- 2. Dodati studenta Ivana Markovica sa brojem indeksa
--     20140055 rodenog u Beogradu, ciji su datumi diplomiranja i pol nepoznati (stud program Matematika, id=101, 06.06.2014. npr upisao).
--     Zatim dodati:
--     polaganje predmeta Analiza 2 (id-2357, stud program Matematika) sa ocenom 8 u oktobru 2 2015.
--     neuspesno polaganje predmeta Analiza 3, u istom roku.

DESCRIBE TABLE da.dosije;

INSERT INTO da.dosije (indeks, idPrograma, ime, prezime, pol, mestoRodjenja, idStatusa, datUpisa, datDiplomiranja)
VALUES(20140055, _?_ ,'Ivan','Markovic', NULL, 'Beograd', _?_ ,'06.06.2014',NULL);


-- Dodacemo da je na budzetu
SELECT *
FROM da.studentskiStatus;

SELECT id, oznaka, naziv, idNivoa
FROM da.studijskiProgram;
-- matematika 101


--Probajte sa 880 umesto 101
INSERT INTO da.dosije (indeks, idPrograma, ime, prezime, pol, mestoRodjenja, idStatusa, datUpisa, datDiplomiranja)
VALUES (20140055, 101, 'Ivan', 'Markovic', NULL, 'Beograd', 1, '06.06.2014', NULL);

SELECT * FROM da.dosije
WHERE indeks=20140055;

-- Drugi nacin
INSERT INTO da.dosije (idPrograma, ime, prezime, mestoRodjenja, idStatusa ,datUpisa, indeks)
VALUES (101, 'Ivan', 'Markovic', 'Beograd', 1, '06.06.2014', 20140055);

SELECT *
FROM da.dosije
WHERE indeks=20140055;
---------------------

-- Dodajemo A2 (id 2357) u oktobru 2 2015 sa ocenom 8.

DESCRIBE TABLE da.ispit;

--probamo
INSERT INTO da.ispit (skGodina, oznakaRoka, indeks, idPredmeta, status, datPolaganja, poeni, ocena)
VALUES (2015, 'okt2', 20140055, 2357, 'o', NULL, 74, 8);


-- Da li je 20140055 upisao kurs 2357?
SELECT *
FROM da.upisanKurs
WHERE indeks=20140055;

DESCRIBE TABLE da.upisanKurs;

INSERT INTO da.upisanKurs (indeks, idPredmeta, skGodina, semestar)
VALUES(20140055, 2357, 2015 ,_?_);


SELECT *
FROM da.kurs
WHERE idPredmeta=2357;

INSERT INTO da.upisanKurs (indeks, idPredmeta, skGodina, semestar)
VALUES(20140055, 2357, 2015, 1); 

SELECT *
FROM da.upisanKurs
WHERE indeks=20140055;

INSERT INTO da.ispit (skGodina, oznakaRoka, indeks, idPredmeta, status, datPolaganja, poeni, ocena)
VALUES (2015, 'okt2', 20140055, 2357, 'o', NULL, 74, 8);

SELECT * 
FROM da.ispit
WHERE indeks=20140055;

---------------------

-- Dodajemo A3, neuspesno polaganje (nemamo id).

INSERT INTO da.ispit (skGodina, oznakaRoka, indeks, idPredmeta, status, datPolaganja, poeni, ocena)
VALUES (2015, 'okt2', 20140055, _?_ , 'o', NULL, 15, 5);

SELECT *
FROM da.upisanKurs
WHERE indeks=20140055;

SELECT 20140055, idPredmeta, 2015, semestar	
FROM da.predmet p JOIN da.kurs k ON k.idPredmeta=p.id
WHERE p.naziv='Analiza 3';

SELECT DISTINCT 20140055, idPredmeta, 2015, semestar	
FROM da.kurs k JOIN da.predmet p ON k.idPredmeta=p.id
WHERE p.naziv='Analiza 3';

INSERT INTO da.upisanKurs (indeks, idPredmeta, skGodina, semestar)
SELECT DISTINCT 20140055, idPredmeta, 2015, semestar
FROM da.kurs k JOIN da.predmet p ON k.idPredmeta=p.id
WHERE p.naziv='Analiza 3';

SELECT *
FROM da.upisanKurs
WHERE indeks=20140055;

SELECT id
FROM da.predmet
WHERE naziv='Analiza 3';

INSERT INTO da.ispit (skGodina, oznakaRoka, indeks, idPredmeta, status, poeni, ocena)
SELECT 2015, 'okt2', 20140055, id, 'o', 15, 5
FROM da.predmet
WHERE naziv='Analiza 3';

SELECT *
FROM da.ispit
WHERE indeks=20140055;

-- 3. Dodati studenta sa brojem indeksa 20140066 i imenom Milan koji je posvemu
--     osim po broju indeksa i imenu isti kao student sa brojem indeksa
--     20150174 (brat blizanac Luke Blagica).

DESCRIBE TABLE da.dosije;

SELECT indeks, idPrograma, ime , prezime, pol, mestoRodjenja, idStatusa, datUpisa, datDiplomiranja
FROM da.dosije
WHERE indeks=20150174;

SELECT 20140066, idPrograma, 'Milan', prezime, pol, mestoRodjenja, idStatusa, datUpisa, datDiplomiranja
FROM da.dosije
WHERE indeks=20150174;

INSERT INTO da.dosije
SELECT 20140066, idPrograma, 'Milan', prezime, pol, mestoRodjenja, idStatusa, datUpisa, datDiplomiranja
FROM da.dosije
WHERE indeks=20150174;

SELECT *
FROM da.dosije
WHERE indeks/10000=2014;

---------------------------------------------------------------------

-- DELETE:
-- DELETE FROM naziv_tabele
-- [WHERE uslov]

-- 1. Obrisati studenta sa brojem indeksa 20140055.

DELETE FROM da.dosije
WHERE indeks=20140055;

-- Potrebno je obezbediti konzistentnost baze
DELETE FROM da.dosije
WHERE indeks=20140066;
-- Prolazi jer nemamo zavisne ntorke u drugim tabelama

-- 2. Obrisati sve ispite studenata polozene sa ocenom 6.

SELECT COUNT(*)
FROM da.ispit;

DELETE FROM da.ispit
WHERE ocena=6 AND status='o';

SELECT COUNT(*)
FROM da.ispit;

-- 3. Obrisati sva polaganja studenata.

SELECT COUNT(*)
FROM da.ispit;

DELETE FROM da.ispit;

SELECT COUNT(*)
FROM da.ispit;

-- 4. Obrisati sva polaganja predmeta Analiza 3.

SELECT COUNT(*)
FROM da.ispit;

DELETE FROM da.ispit
WHERE idPredmeta IN (SELECT id
				     FROM da.predmet
				     WHERE naziv='Analiza 3');

SELECT COUNT(*)
FROM da.ispit;

-- 5. Obrisati sve studente koji nisu polagali nijedan ispit.
SELECT COUNT(*)
FROM da.dosije;

DELETE FROM da.dosije
WHERE indeks NOT IN (SELECT indeks FROM da.ispit);

-----------------------------------------------------------------------

UPDATE <naziv tabele>
SET { <pojedinacne dodele> | <grupna dodela> }
WHERE <uslov>

--pojedinacne : <ime kolone> = <izraz> [, <ime kolone> = <izraz>]*
--grupna: ( <lista kolona> ) = <upit>


-- 1. Promeniti broj bodova predmetu Uvod u filozofiju 20.

SELECT *
FROM da.predmet
WHERE naziv='Uvod u filozofiju';

UPDATE da.predmet
SET espb=20
WHERE naziv='Uvod u filozofiju';

SELECT *
FROM da.predmet
WHERE naziv='Uvod u filozofiju';

-- 2. Studentu Luki Blagicu promeniti:
--     mesto rodenja na nepoznato, a
--     godinu upisa na 1991.
SELECT *
FROM da.dosije
WHERE ime='Luka' AND prezime='Blagic';

UPDATE da.dosije
SET mestoRodjenja=NULL, datUpisa=datUpisa + (1991 - YEAR(datUpisa)) YEARS
WHERE ime='Luka' AND prezime='Blagic';

SELECT *
FROM da.dosije
WHERE ime='Luka' AND prezime='Blagic';

-- 3. Povecati broj bodova svim predmetima za +5, a onda vratiti na stare vrednosti.

UPDATE da.predmet
SET espb = espb + 5;

SELECT id, espb, naziv
FROM da.predmet;

UPDATE da.predmet
SET espb = espb - 5;

SELECT id, espb, naziv
FROM da.predmet;

-----------------------------
-- Ako probamo da dupliramo
UPDATE da.predmet
SET espb = 2*espb;

SELECT MIN(espb),MAX(espb)
FROM da.predmet;
-----------------------------

-- 4. Promeniti sve padove iz predmeta Programiranje 1 na polaganja sa ocenom 6.

UPDATE da.ispit
SET poeni = NULL AND ocena = 6 AND status = 'o'
WHERE ocena = 5 AND status = 'o' AND idPredmeta IN (SELECT id
						    FROM da.predmet
						    WHERE naziv='Programiranje 1');

-- 5. Za sva polaganja ispita u roku Oktobar2 2015 promeniti
--     datum polaganja ispita na datum poslednjeg polaganog ispita, a
--     ocenu na 10;

SELECT *
FROM da.ispit i
WHERE skGodina=2015 AND oznakaRoka='okt2';

UPDATE da.ispit
SET (datPolaganja, ocena) = (SELECT MAX(datPolaganja), 10 FROM da.ispit)
WHERE skGodina=2015 AND oznakaRoka='okt2';

SELECT *
FROM da.ispit i
WHERE skGodina=2015 AND oznakaRoka='okt2';

----------------------------------------------
--Radicemo na pocetku sledeceg casa:

-- 6. Promeniti broj indeksa studenta sa brojem indeksa 20140055 u 20140056.

--Probamo
UPDATE da.dosije
SET indeks=20140056
WHERE indeks=20140055;

--Probamo
UPDATE da.upisanKurs
SET indeks=20140056
WHERE indeks=20140055;


INSERT INTO da.dosije
SELECT 20140056, idPrograma, ime, prezime, pol, mestoRodjenja, idStatusa, datUpisa, datDiplomiranja
FROM da.dosije
WHERE indeks=20140055;

INSERT INTO da.upisanKurs
SELECT 20140056, skGodina, semestar, idPredmeta
FROM da.upisanKurs
WHERE indeks=20140055;

SELECT *
FROM da.upisanKurs
WHERE indeks/10000=2014;

UPDATE da.ispit
SET indeks=20140056
WHERE indeks=20140055;

DELETE FROM da.upisanKurs
WHERE indeks=20140055;

DELETE FROM da.dosije
WHERE indeks=20140055;