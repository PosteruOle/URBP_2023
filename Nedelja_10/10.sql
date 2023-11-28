-- MERGE naredba

--MERGE INTO <ime tabele>
--USING <upit> ON <uslov povezivanja>
--{ WHEN [NOT] MATCHED [AND <uslov>] THEN <izraz> }+
--[ELSE IGNORE]

--<izraz> moze biti:
--UPDATE ... SET <pojedinacne dodele ili grupna dodela>
--DELETE ...
--INSERT [(<lista kolona>)] VALUES <izraz>

-- 1. Napisati SQL naredbe kojima se:
--  a) kreira tabela predmetStudent u kojoj se cuvaju informacije o broju
--     studenata koji su uspesno polozili ispit iz tog predmeta.
--     Tabela sadrzi kolone idPredmeta i brStudenata.
--     Kolona idPredmeta je i primarni kljuc. Definisati i strani kljuc na tabelu predmet.

CREATE TABLE da.predmetStudent (
    idPredmeta INTEGER NOT NULL PRIMARY KEY,
    brStudenata SMALLINT,
    FOREIGN KEY fkPredmet (idPredmeta) REFERENCES da.predmet
);


--  b) Popunjava tabela predmetStudent sa obaveznim predmetima sa osnovnih
--     akadamskih studija informatike.
--     Prilikom popunjavanja, vrednost u koloni brStudenata postaviti na 5.

SELECT pp.idPredmeta, 5
FROM da.predmetPrograma pp JOIN da.studijskiProgram sp ON pp.idPrograma=sp.id
    		               JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
WHERE sp.naziv='Informatika' AND nk.naziv='Osnovne akademske studije' AND pp.vrsta='obavezan';

			    
INSERT INTO da.predmetStudent
SELECT pp.idPredmeta, 5
FROM da.predmetPrograma pp JOIN da.studijskiProgram sp ON pp.idPrograma=sp.id
   		                   JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
WHERE sp.naziv='Informatika' AND nk.naziv='Osnovne akademske studije' AND pp.vrsta='obavezan';

SELECT *
FROM da.predmetStudent;

--  c) Dopunjava sadrzaj tabele predmetStudent sa validnim podacima za
--     sve predmete iz tabele predmet, tako sto se azuriraju podaci za vec
--     postojece predmete u tabeli predmetStudent, i dodavanjem novih
--     redova za ostale predmete.

SELECT p.id, COUNT(i.indeks) br
FROM da.predmet p LEFT OUTER JOIN da.ispit i ON p.id=i.idPredmeta AND i.ocena>5 AND i.status='o'
GROUP  BY p.id;


MERGE INTO da.predmetStudent ps
USING(
	SELECT p.id, COUNT(i.indeks) br
	FROM da.predmet p LEFT OUTER JOIN da.ispit i ON p.id=i.idPredmeta AND i.ocena>5 AND i.status='o'
	GROUP BY p.id
) AS pom
ON ps.idPredmeta=pom.id
WHEN MATCHED THEN
		UPDATE SET ps.brStudenata=pom.br
WHEN NOT MATCHED THEN 
		INSERT VALUES (pom.id, pom.br);

SELECT *
FROM da.predmetStudent;

--  d) Brise tabela predmetStudent.

DROP TABLE da.predmetStudent;

-- 2. Napisati SQL naredbe kojima se:
--     a) Kreira tabela studentPodaci u kojoj se cuvaju sledece informacije:
--        indeks, broj polozenih predmeta, prosek i datum upisa studenta.
--	  Kolona indeks je i primarni kljuc.
--	  Definisati i strani kljuc na tabelu dosije.

CREATE TABLE da.studentPodaci (
    indeks INTEGER NOT NULL PRIMARY KEY,
    brojPolozenih SMALLINT,
    prosek FLOAT,
    datumUpisa DATE,
    FOREIGN KEY (indeks) REFERENCES da.dosije
);

--     b) U kreiranu tabelu unose informacije
--        za studente ciji prosek ocena je veci od 8, pri cemu se ne navodi datum upisa i
--	  za studente koji imaju status diplomirao postavlja se broj polozenih predmeta na 40, prosek na 10.00 i datum upisa ostaje nepoznat.


WITH diplomirani AS (
	SELECT indeks
	FROM da.dosije d JOIN da.studentskiStatus ss ON d.idStatusa=ss.id
	WHERE ss.naziv='Diplomirao'
)
SELECT indeks,40,10.00,NULL
FROM diplomirani
UNION
SELECT indeks, COUNT(idPredmeta), AVG(ocena+0.0),NULL
FROM da.ispit
WHERE ocena>5 AND status='o' AND indeks NOT IN (SELECT indeks FROM diplomirani)
GROUP BY indeks
HAVING AVG(ocena+0.0)>= 8;


INSERT INTO da.studentPodaci
WITH diplomirani AS (
	SELECT indeks
	FROM da.dosije d JOIN da.studentskiStatus ss ON d.idStatusa=ss.id
	WHERE ss.naziv='Diplomirao'
)
SELECT indeks,40,10.00,NULL
FROM diplomirani
UNION
SELECT indeks, COUNT(idPredmeta), AVG(ocena+0.0),NULL
FROM da.ispit
WHERE ocena>5 AND status='o' AND indeks NOT IN (SELECT indeks FROM diplomirani)
GROUP BY indeks
HAVING AVG(ocena+0.0)>=8;


--     c) Dopunjava sadrzaj tabele studentPodaci sa validnim podacima za sve studente iz tabele dosije, tako sto se:
--    - Azurira datum upisa studentima koji su vec u tabeli i imaju
--	     status diplomiranog studenta,
--	  - Studentima koji su vec u tabeli i na budzetu su, azuriraju se
--	     podaci o broju polozenih predmeta i proseku.
--	  - Studentima koji su vec u tabeli, a imaju status ispisan, brisu se
--	     iz tabele predmet student
--	  - Studenti koji se ne nalaze u tabeli predmet student i kojima status nije ispisan, uneti indeks,
--	     validan broj polozenih predmeta i prosek.
--	  - Za sve ostale ne raditi nista.
--  Aktuelni status je poslednji status studenta u tabeli status.


SELECT d.indeks, datUpisa, 
	COUNT(CASE
			WHEN ocena>5 AND status='o' THEN idPredmeta
			ELSE NULL
		  END) brp,
	AVG(CASE
			WHEN ocena>5 AND status='o' THEN ocena+0.0
			ELSE NULL
		END) prosek,
	ss.naziv
FROM da.dosije d LEFT OUTER JOIN da.ispit i ON d.indeks=i.indeks
	             LEFT OUTER JOIN da.studentskiStatus ss ON d.idStatusa=ss.id
GROUP BY d.indeks,datUpisa,ss.naziv;
 

MERGE INTO da.studentPodaci sp
USING(
SELECT d.indeks, datUpisa, 
	COUNT(
		CASE
			WHEN ocena>5 AND status='o' THEN idPredmeta
			ELSE NULL
		END) brp,
	AVG(
		CASE
			WHEN ocena>5 AND status='o' THEN ocena+0.0
			ELSE NULL
		END) prosek,
    ss.naziv
FROM da.dosije d LEFT OUTER JOIN da.ispit i ON d.indeks=i.indeks
	LEFT OUTER JOIN da.studentskiStatus ss ON d.idStatusa=ss.id
GROUP BY d.indeks,datUpisa,ss.naziv
) AS pom ON pom.indeks=sp.indeks
WHEN MATCHED AND pom.naziv='Diplomirao' THEN
	UPDATE	SET sp.datumUpisa=pom.datUpisa
WHEN MATCHED AND pom.naziv='Budzet' THEN
	UPDATE	SET (sp.brojPolozenih,sp.prosek)=(pom.brp,pom.prosek)
WHEN MATCHED AND pom.naziv='Ispisan' THEN
	DELETE
WHEN NOT MATCHED AND pom.naziv<>'Ispisan' THEN
	INSERT (indeks,brojPolozenih,prosek)
	VALUES(pom.indeks,pom.brp,pom.prosek)
ELSE IGNORE;    


SELECT *
FROM da.studentPodaci;

DROP TABLE da.studentPodaci;

-----------------------------------------------
-- Vezba

-- 1. Napisati upit na SQL-u koji za skolsku godinu i studijski program osnovnih studija
--     izracunava koliki je procenat studenata koji su te godine upisali fakultet,
--     upisan upravo na taj studijski program, kao i koja je prosecna ocena studenata tog
--     studijskog programa na ispitima u toku te skolske godine.
--     Izdvojiti oznaku i naziv studijskog programa,
--     skolsku godinu,
--     ukupan broj upisanih studenata na fakultet te godine i
--     prosecnu ocenu studijskog programa u toj generaciji na kursevima slusanim te skolsk godine.
--     Izvestaj urediti po godini i prosecnoj oceni.

--Izlistajmo prvo studijske programe osnovnih akademskih studija
SELECT sp.id, sp.oznaka, sp.naziv
FROM da.studijskiProgram sp JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
WHERE nk.naziv='Osnovne akademske studije';

--Izdvojimo za svaku godinu broj upisanih studenata
SELECT skGodina,COUNT(indeks) brStudenata
FROM da.upisGodine
WHERE skGodina=indeks/10000
GROUP BY skGodina;

SELECT d.indeks/10000 godina, COUNT(*)
FROM da.dosije d
GROUP BY d.indeks/10000;

SELECT sp.id idPrograma,sp.idNivoa, d.indeks/10000 godina, COUNT(*) brojStudenata
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
GROUP BY sp.id, sp.idNivoa, d.indeks/10000;

SELECT i.skGodina, d.idPrograma, AVG(i.ocena+0.0) prosek
FROM da.ispit i JOIN da.dosije d ON d.indeks=i.indeks
WHERE ocena>5 AND status='o'
GROUP BY d.idPrograma, i.skGodina;

WITH studijskiProgrami AS(
	SELECT sp.id idPrograma,sp.idNivoa, d.indeks/10000 godina, COUNT(*) brojStudenata
	FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
	GROUP BY sp.id, sp.idNivoa, d.indeks/10000	
), upisaniPoGodini AS(
	SELECT skGodina,COUNT(indeks) brStudenata
	FROM da.upisGodine
	WHERE skGodina=indeks/10000
	GROUP BY skGodina
), prosekPoProgramu AS (
	SELECT i.skGodina, d.idPrograma, AVG(i.ocena+0.0) prosek
	FROM da.ispit i JOIN da.dosije d ON d.indeks=i.indeks
	WHERE ocena>5 AND status='o'
	GROUP BY d.idPrograma, i.skGodina
)
SELECT sp.id, sp.oznaka, sp.naziv,spi.godina, 100.0*spi.brojStudenata/upg.brStudenata procenat,	ppp.prosek
FROM da.studijskiProgram sp JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
	                        JOIN studijskiProgrami spi ON sp.id=spi.idPrograma AND sp.idNivoa=spi.idNivoa
	                        JOIN upisaniPoGodini upg ON upg.skGodina=spi.godina
	                        JOIN prosekPoProgramu ppp ON ppp.idPrograma=sp.id AND ppp.skGodina=spi.godina
WHERE nk.naziv='Osnovne akademske studije'
ORDER BY spi.godina, prosek DESC;

-- 2. Za sve studente cije ime pocinje sa "Mil" izdvojiti spisak do sada polozenih predmeta.
--      Izdvojiti: broj indeksa, ime, prezime, oznaku studijskog programa, naziv predmeta, broj espb bodova predmeta, skolsku godinu, semestar i ocenu.
--	Izvestaj ureditiprema broju indeksa, skolskoj godini, semestru i sifri predmeta.

SELECT d.indeks, d.ime, d.prezime
FROM da.dosije d 
WHERE d.ime LIKE 'Mil%';

SELECT d.indeks, d.ime, d.prezime, sp.oznaka
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
WHERE d.ime LIKE 'Mil%';

SELECT d.indeks, d.ime, d.prezime, sp.oznaka, i.idPredmeta,i.skGodina,i.ocena
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
	             LEFT OUTER JOIN da.ispit i ON d.indeks=i.indeks AND ocena>5 AND status='o'
WHERE d.ime LIKE 'Mil%';

SELECT d.indeks, d.ime,d.prezime, sp.oznaka,p.naziv, p.espb, i.skGodina, i.ocena,uk.semestar
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
                 LEFT OUTER JOIN
                      (da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id 
                      		      JOIN da.upisanKurs uk ON i.indeks=uk.indeks AND i.idPredmeta=uk.idPredmeta AND i.skGodina=uk.skGodina)
	             ON d.indeks=i.indeks AND ocena>5 AND status='o'
WHERE d.ime LIKE 'Mil%';

---------------------------------------------
--Domaci (resenja kolege Milana)
-- 3. Izdvojiti podatke o uspesnosti polaganja na studijskom programu Informatika Master akademskih studija  u skolskoj godini 2017/2018.
--     Izdvojiti  oznaku i naziv predmeta, naziv ispitnog roka, broj prijavljivanih studenta, broj studenata koji su ga polozili kao i prosecnu ocenu.
--     Izvestaj urediti prema prosecnoj oceni opadajuce, null na kraju.

SELECT COUNT(*)
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
     	       	 JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.ispit i ON d.indeks=i.indeks
     	       	 JOIN da.predmet p ON i.idPredmeta=p.id
WHERE sp.naziv='Informatika' AND nk.naziv='Master akademske studije';			     

SELECT p.oznaka, SUBSTR(p.naziv, 1, 50)pnaziv, SUBSTR(ir.naziv, 1, 30) irnaziv, COUNT(i.indeks) "Broj prijavljenih"
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
     	       	      	     JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.ispit i ON d.indeks=i.indeks
     	       	      	     JOIN da.predmet p ON i.idPredmeta=p.id
			     JOIN da.ispitniRok ir ON i.skGodina=ir.skGodina AND i.oznakaRoka=ir.oznakaRoka
WHERE sp.naziv='Informatika' AND nk.naziv='Master akademske studije'
GROUP BY p.id, p.oznaka, p.naziv, ir.naziv;

SELECT p.oznaka, SUBSTR(p.naziv, 1, 50)pnaziv, SUBSTR(ir.naziv, 1, 30) irnaziv, COUNT(*) prijavilo,
    SUM(CASE
			WHEN ocena>5 AND status='o' THEN 1
			ELSE 0
		END) AS polozilo,
    AVG(CASE
		    WHEN ocena>5 AND status='o' THEN 0.0+ocena
			ELSE NULL
		END) AS prosecnaOcena
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
     	       	 JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.ispit i ON d.indeks=i.indeks
     	       	 JOIN da.predmet p ON i.idPredmeta=p.id
			     JOIN da.ispitniRok ir ON i.skGodina=ir.skGodina AND i.oznakaRoka=ir.oznakaRoka
WHERE sp.naziv='Informatika' AND nk.naziv='Master akademske studije'
GROUP BY p.id, p.oznaka, p.naziv, ir.naziv
ORDER BY prosecnaOcena DESC NULLS LAST;

-- 4. Za studijske programe na osnovnim studijama izdvojiti podatke o obaveznim predmetima koje su u skolskoj 2017/2018. godini neki studenti ponovljeno upisali.
--     Izdvojiti oznaku i naziv studijskog programa,
--     naziv predmeta,
--     ukupan broj studenta upisanih na kurs iz tog predmeta u skolskoj 2017/2018. godini,
--     broj studenta kojima to nije prvi put da su upisali kurs iz tog predmeta,
--     procenat studenata koji su ponovo upisali kurs.
--     Izvestaj urediti prema procentu studenata koji su ponovili upis u opadajucem poretku.

SELECT sp.oznaka, sp.naziv, pp.idPredmeta
FROM da.studijskiProgram sp JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
     			    	 	JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
WHERE nk.naziv='Osnovne akademske studije' AND pp.vrsta='obavezan';

WITH upisani17 AS (
     SELECT sp.id idPrograma, sp.idNivoa, uk.idPredmeta, d.indeks
     FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
     	  	          JOIN da.upisanKurs uk ON d.indeks=uk.indeks
     WHERE uk.skGodina=2017
), upisani17Zbirno AS(
     SELECT u.idPrograma, u.idNivoa, u.idPredmeta, COUNT(indeks) broj
     FROM upisani17 u
     GROUP BY u.idPrograma, u.idNivoa, u.idPredmeta
), ponovili17 AS (
      SELECT u.idPrograma, u.idNivoa, u.idPredmeta, COUNT(u.indeks) broj
      FROM upisani17 u
      WHERE EXISTS(SELECT *
			       FROM da.upisanKurs uk
			       WHERE uk.indeks=u.indeks AND uk.idPredmeta=u.idPredmeta AND uk.skGodina<2017)
      GROUP BY u.idPrograma, u.idNivoa, u.idPredmeta
)
SELECT sp.oznaka, sp.naziv, pp.idPredmeta, SUBSTR(p.naziv, 1, 50), u17z.broj "Upisani1718", p17.broj "Ponovili1718", DECIMAL(100.0*p17.broj/u17z.broj, 6, 2) "Procenat"
FROM da.studijskiProgram sp JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
     			    	 	JOIN da.predmetPrograma pp ON pp.idPrograma=sp.id
					        JOIN ponovili17 p17 ON p17.idPrograma=sp.id AND p17.idNivoa=nk.id AND p17.idPredmeta=pp.idPredmeta
					        JOIN upisani17Zbirno u17z ON u17z.idPrograma=sp.id AND u17z.idNivoa=nk.id AND u17z.idPredmeta=pp.idPredmeta
					        JOIN da.predmet p ON pp.idPredmeta=p.id
WHERE nk.naziv='Osnovne akademske studije' AND pp.vrsta='obavezan';

-- 5.Neka je data tabela prviIspit koja sadrzi podatke o prvim polozenim ispitima za sve studente.
-- Napisati naredbu SQL-a kojom se:       
-- a)  studentima  koji  imaju  neki  polozen  ispit  unose  ispravni  podaci  u tabelu prviIspit
-- b)  iz tabele prviIspit brisu podaci za studente osnovnih studija
-- c)  za sve studente doktorskih studija umesto prvog upisuje datum poslednjeg polozenog ispita
-- d)  objedinjuje posao iz b) i c).

CREATE TABLE da.prviIspit (
    indeks INTEGER NOT NULL PRIMARY KEY,
    datum DATE
);

INSERT INTO da.prviIspit
SELECT indeks, MIN(datPolaganja)
FROM da.ispit
WHERE ocena>5 AND status='o'
GROUP BY indeks;

SELECT COUNT(*)
FROM da.prviIspit;

DELETE FROM da.prviIspit
WHERE indeks IN (SELECT indeks
      	     	 FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
			      	   	       	  JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     WHERE nk.naziv='Osnovne akademske studije');

SELECT COUNT(*)
FROM da.prviIspit;


UPDATE da.prviIspit pi
SET datum = (SELECT MAX(datPolaganja)
    	     FROM da.ispit
		     WHERE indeks=pi.indeks AND ocena>5 AND status='o')		       
WHERE indeks IN (SELECT indeks
      	     	 FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
			      	   	       	  JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     WHERE nk.naziv='Doktorske akademske studije');


MERGE INTO da.prviIspit pi
USING(
    SELECT d.indeks, nk.naziv, MAX(i.datPolaganja) maxDatum
    FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
      	   	       	 JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
      				 JOIN da.ispit i ON d.indeks=i.indeks
    WHERE ocena>5 AND status='o'
    GROUP BY d.indeks, nk.naziv
) AS pom ON pi.indeks=pom.indeks
WHEN MATCHED AND pom.naziv='Osnovne akademske studije' THEN DELETE
WHEN MATCHED AND pom.naziv='Doktorkse akademnske studije' THEN UPDATE SET pi.datum=pom.maxDatum
ELSE IGNORE;

DROP TABLE da.prviIspit;