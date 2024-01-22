-- Kreiranje i promena strukture tabele

-- 1. Napraviti tabelu polozeni_predmeti u kojoj ce se
--     nalaziti podaci o polozenim predmetima studenata.
--     Tabela ima iste kolone kao i tabela ispit.
--     Dodati ogranicenje da ocena mora biti
--     iz intervala [6,10] i da strani kljuc na tabelu dosije
--     dozvoli kaskadno brisanje.

CREATE TABLE da.polozeni_predmeti (
    skGodina SMALLINT NOT NULL,
    oznakaRoka VARCHAR(20) NOT NULL,
    indeks INTEGER NOT NULL,
    idPredmeta INTEGER NOT NULL,
    status CHAR(1) NOT NULL,
    datPolaganja DATE,
    poeni SMALLINT,
    ocena SMALLINT,
    PRIMARY KEY (skGodina, oznakaRoka, indeks, idPredmeta),
    FOREIGN KEY fkDosije(indeks) REFERENCES da.dosije ON DELETE CASCADE,
    FOREIGN KEY fkIspitniRok(skGodina, oznakaRoka) REFERENCES da.ispitniRok,
    FOREIGN KEY fkUpisanKurs(indeks, skGodina, idPredmeta) REFERENCES da.upisanKurs,
    CONSTRAINT vrednost_ocene CHECK (ocena BETWEEN 6 AND 10)
);


CREATE TABLE da.polozeni_predmeti1 LIKE da.ispit;
ALTER TABLE da.polozeni_predmeti1
    ADD PRIMARY KEY (skGodina, oznakaRoka, indeks, idPredmeta)
    ADD FOREIGN KEY fkDosije(indeks) REFERENCES da.dosije ON DELETE CASCADE
    ADD FOREIGN KEY fkIspitniRok(skGodina, oznakaRoka) REFERENCES da.ispitniRok
    ADD FOREIGN KEY fkUpisanKurs(skGodina, indeks, idPredmeta) REFERENCES da.upisanKurs
    ADD CONSTRAINT vrednost_ocene CHECK (ocena BETWEEN 6 AND 10);

-- Alternativa za LIKE:
CREATE TABLE da.polozeni_predmeti2 AS
(SELECT * FROM da.ispit)
DEFINITION ONLY; 	--(probajte with data)

INSERT INTO da.polozeni_predmeti
SELECT *
FROM da.ispit
WHERE ocena>5 AND status='o';

INSERT INTO da.polozeni_predmeti1
SELECT *
FROM da.ispit
WHERE ocena>5 AND status='o';
--(pogledati fkUpisanKurs)

SELECT *
FROM da.polozeni_predmeti;

--ALTER TABLE <ime tabele>
--{ ADD <element> | ALTER <element> | DROP <element> }*

-- 2. Iz tabele polozeni_predmeti ukloniti kolonu datPolaganja.

ALTER TABLE da.polozeni_predmeti
DROP datPolaganja;

-- 3. Postaviti uslov da se u tabeli polozeni_predmeti mogu nalaziti samo
--     podaci o ispitima na kojima je student dobio izmedu 51 i 100 bodova
--      i da je podrazumevana ocena 6.

ALTER TABLE da.polozeni_predmeti
    ADD CONSTRAINT bodovi_ispit CHECK (poeni BETWEEN 51 AND 100)
    ALTER COLUMN ocena SET DEFAULT 6;

-- 4. Ukloniti tabelu polozeni_predmeti.

DROP TABLE da.polozeni_predmeti;

-- 5. Napraviti tabelu student_ispiti koja od kolona ima:
--     * indeks - indeks studenta
--     * polozeni_ispiti - broj polozenih ispita
--     * prosek - prosek studenta
--    Definisati primarni kljuc i strani kljuc na tabelu dosije.

CREATE TABLE da.student_ispiti (
    indeks INTEGER NOT NULL PRIMARY KEY,
    polozeniIspiti SMALLINT,
    prosek DOUBLE,
    FOREIGN KEY fkDosije (indeks) REFERENCES da.dosije
);

-- 6. Tabeli student_ispiti dodati kolonu brojIspita koja predstavlja broj polaganih ispita.
--     Dodati i ogranicenje da broj polaganih ispita mora biti veci ili jednak
--     od broja polozenih ispita.

ALTER TABLE da.student_ispiti
    ADD brojIspita SMALLINT
    ADD CONSTRAINT ispiti CHECK (brojIspita >= polozeniIspiti);

-- 7. U tabelu student_ispiti uneti podatke za svakog studenta iz tabele dosije.
--     Ukoliko student nije polagao ili polozio nijedan predmet,
--     u odgovarajuce kolone uneti NULL vrednosti.

INSERT INTO da.student_ispiti
SELECT d.indeks,
	 NULLIF(SUM(CASE
		            WHEN ocena>5 AND status='o' THEN 1
		            ELSE 0
		        END), 0) AS polozeniIspiti,
            AVG(CASE
			        WHEN ocena>5 AND status='o' THEN ocena+0.0
			        ELSE NULL
		        END) AS prosek,
            NULLIF(COUNT(i.indeks), 0) brojIspita
FROM da.dosije d LEFT OUTER JOIN da.ispit i ON d.indeks=i.indeks
GROUP BY d.indeks;

DROP TABLE da.student_ispiti;

------------------------------------------------------------------------------------------
-- VEZBANJE SQL

-- 1.  Za svakog studenta izdvojiti:
--      * njegovo ime,
--	* naziv predmeta iz kog je polozio svoj poslednji ispit
--	* datum tog polaganja.

SELECT i.indeks, i.idPredmeta
FROM da.ispit i
WHERE ocena>5 AND status='o' AND datPolaganja = (SELECT MAX(datPolaganja)
					                             FROM da.ispit
					                             WHERE indeks=i.indeks AND ocena>5 AND status='o');

SELECT d.ime, p.naziv, i.datPolaganja
FROM da.ispit i JOIN da.dosije d ON i.indeks=d.indeks
     	      	JOIN da.predmet p ON i.idPredmeta=p.id
WHERE ocena>5 AND status='o' 
              AND datPolaganja = (SELECT MAX(datPolaganja)
					              FROM da.ispit
					              WHERE indeks=i.indeks AND ocena>5 AND status='o');

-- 5. Napisati upit kojim se za smer pod nazivom Matematika sa osnovnih studija  izdvajaju
-- nazivi  svih  obaveznih  predmeta  i  broj  uslovnih  predmeta za svaki od obveznih predmeta.
-- Ukoliko neki predmet nema uslovne predmete, izdvojiti 0.
-- Izdvojene podatke urediti prema nazivu obaveznog predmeta u rastucem poretku.

SELECT sp.id, sp.oznaka, sp.naziv, nk.naziv
FROM da.studijskiProgram sp JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id;

--Resenje: 
SELECT p.naziv, COUNT(up.idUslovnogPredmeta) brojUslovnih
FROM da.studijskiProgram sp JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
     			    	 	JOIN da.predmetPrograma pp ON sp.id=pp.idPrograma
					        JOIN da.predmet p ON pp.idPredmeta=p.id
					        JOIN da.uslovniPredmet up ON pp.idPrograma=up.idPrograma AND pp.idPredmeta=up.idPredmeta
WHERE sp.naziv='Matematika' AND nk.naziv='Osnovne akademske studije' AND pp.vrsta='obavezan'
GROUP BY p.id, p.naziv
ORDER BY p.naziv ASC;

-- 6.Izdvojiti indekse i ukupan broj promena statusa
-- tokom dosadasnjeg skolovanja studenata
-- koji su bar 3 puta promenili status.


SELECT indeks, skGodina, datUpisa, idStatusa
FROM da.upisGodine
ORDER BY 1;

SELECT indeks, skGodina, datUpisa, idStatusa
FROM da.upisGodine
WHERE indeks=20152027;

SELECT ug1.indeks, ug1.skGodina,ug1.idStatusa, ug2.indeks, ug2.skGodina,ug2.idStatusa
FROM da.upisGodine ug1 JOIN da.upisGodine ug2 ON ug1.indeks=ug2.indeks AND ug1.datUpisa<ug2.datUpisa AND ug1.idStatusa<>ug2.idStatusa
AND NOT EXISTS(SELECT * 
	           FROM da.upisGodine
               WHERE indeks=20152027 AND ug1.datUpisa<datUpisa AND datUpisa<ug2.datUpisa)
WHERE ug1.indeks=20152027;

-- Resenje:

SELECT ug1.indeks, COUNT(*) brPromena
FROM da.upisGodine ug1 JOIN da.upisGodine ug2 ON ug1.indeks=ug2.indeks AND ug1.datUpisa<ug2.datUpisa AND ug1.idStatusa<>ug2.idStatusa
WHERE NOT EXISTS(SELECT *
				 FROM da.upisGodine
				 WHERE indeks=ug1.indeks AND ug1.datUpisa<datUpisa AND datUpisa<ug2.datUpisa)
GROUP BY ug1.indeks
HAVING COUNT(*)>=3
ORDER BY 2;

-- 2. Izdvojiti podatke o studentima (broj indeksa, ime, prezime)
--     koji su barem jednom dobili prelaznu ocenu na ispitu
--     iz predmeta sa sifrom R270 (RBP)

SELECT d.indeks, d.ime, d.prezime
FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
     	      	JOIN da.dosije d ON i.indeks=d.indeks
WHERE ocena>5 AND status='o' AND p.oznaka='R270';

-- 3. Izdvojiti  brojeve  indeksa  studenata  koji
--     * imaju  prosek  veci  od  9.8
--     * ili su ponistili neki polozen ispit u roku Januar1 2016.

SELECT i.indeks
FROM da.ispit i
WHERE ocena>5 AND status='o'
GROUP BY i.indeks
HAVING AVG(1.0*ocena)>9.8
UNION 
SELECT indeks
FROM da.ispit i
WHERE skGodina=2016 AND oznakaRoka='jan1' AND ocena>5 AND status='x';

-- 4. Izdvojiti podatke o studentima
--     (broj indeksa, ime i prezime, skolska godina, semestar) koji:
--     * nisu  polozili  upisan  kurs  iz  predmeta  sa sifrom  P101
--        u godini kada su ga upisali.
--     Pri tome nije vazno da li su studenti kasnije ponovo upisali kurs
--     i polozili ispit ili ne.

DESCRIBE TABLE da.upisanKurs;

SELECT d.indeks, d.ime, d.prezime, uk.skGodina, uk.semestar
FROM da.dosije d JOIN da.upisanKurs uk ON d.indeks=uk.indeks
     	       	 JOIN da.predmet p ON uk.idPredmeta=p.id
WHERE p.oznaka='P101' AND NOT EXISTS(SELECT *
			  	                     FROM da.ispit i
				                     WHERE indeks=d.indeks AND skGodina=uk.skGodina  AND idPredmeta=i.idPredmeta AND ocena>5 AND status='o');