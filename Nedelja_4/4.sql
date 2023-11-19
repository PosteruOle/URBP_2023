-- Skupovne operacije

--UNION:1,1,1,2 
--      1,1,2,3		-->1,2,3

--UNION ALL:1,1,1,2 
--          1,1,2,3		-->1,1,2,3,1,1,1,2

--INTERSECT:1,1,1,2 
--          1,1,2,3		-->1,2

--INTERSECT ALL:1,1,1,2 
--              1,1,2,3		-->1,1,2

--EXCEPT:   1,1,1,2 
--          1,1,2,3		-->

--EXCEPT ALL:   1,1,1,2 
--              1,1,2,3		-->1

--SELECT naziv
--FROM da.studentskiStatus;

--SELECT naziv
--FROM da.studijskiProgram;

--SELECT naziv
--FROM da.studijskiProgram
--UNION
--SELECT naziv
--FROM da.studentskiStatus;

--SELECT naziv
--FROM da.studentskiStatus
--UNION
--SELECT indeks
--FROM da.ispit;

-- 1.  Izdvojiti  identifikatore  predmeta  koji
--      ili  nose  vise  od  6  bodova
--	ili  ih  je polagao student ciji broj indeksa je 20150174.


SELECT DISTINCT id
FROM da.predmet p LEFT OUTER JOIN da.ispit i ON i.idPredmeta=p.id
WHERE p.espb>=6 OR i.indeks=20150174;

SELECT id
FROM da.predmet p
WHERE espb>=6 OR EXISTS(SELECT * FROM da.ispit WHERE indeks=20150174 AND idPredmeta=p.id);

SELECT id
FROM da.predmet
WHERE espb>=6
UNION 
SELECT idPredmeta
FROM da.ispit
WHERE indeks=20150174;

------------------------------------------
--Dodatno-uporediti naredne rezultate

SELECT id
FROM da.predmet
WHERE espb>=6
UNION ALL
SELECT idPredmeta
FROM da.ispit
WHERE indeks=20150174;

SELECT DISTINCT id
FROM da.predmet
WHERE espb>=6
UNION ALL
SELECT DISTINCT idPredmeta
FROM da.ispit
WHERE indeks=20150174;

SELECT id
FROM da.predmet p
WHERE espb>=6
AND EXISTS(SELECT * FROM da.ispit WHERE indeks=20150174 AND p.id=idPredmeta);
------------------------------------------

-- 2.  Izdvojiti  identifikatore  predmeta  koji  su  polagani i  u  sep2 2019  i  u sep3 2019;

SELECT id
FROM da.predmet p
WHERE EXISTS(SELECT *
		     FROM da.ispit i
		     WHERE idPredmeta=p.id AND skGodina=2019 AND oznakaRoka='sep2') AND EXISTS(SELECT * FROM da.ispit i WHERE idPredmeta=p.id AND skGodina=2019 AND oznakaRoka='sep3');

SELECT idPredmeta
FROM da.ispit i
WHERE skGodina=2019 AND oznakaRoka='sep2'
INTERSECT
SELECT idPredmeta
FROM da.ispit i
WHERE skGodina=2019 AND oznakaRoka='sep3';

-----------------------------------
--Pogledati rezultat i sa INTERSECT ALL

SELECT idPredmeta
FROM da.ispit i
WHERE skGodina=2019 AND oznakaRoka='sep2'
INTERSECT ALL
SELECT idPredmeta
FROM da.ispit i
WHERE skGodina=2019 AND oznakaRoka='sep3';
-----------------------------------

-- 3. Izdvojiti  sve  identifikatore  za  predmete  koje
--     je polozio  student  sa  brojem indeksa 20150174,
--     a nije polozio student sa indeksom 20150036.

SELECT DISTINCT idPredmeta
FROM da.ispit i
WHERE indeks=20150174 AND ocena>5 AND status='o'
    AND NOT EXISTS(SELECT * FROM da.ispit WHERE idPredmeta=i.idPredmeta AND indeks=20150036 AND ocena>5 AND status='o');

SELECT idPredmeta
FROM da.ispit i
WHERE indeks=20150174 AND ocena>5 AND status='o'
EXCEPT
SELECT idPredmeta
FROM da.ispit i
WHERE indeks=20150036 AND ocena>5 AND status='o';

-- Skalarne funkcije

-- 1. Ako je predmetima potrebno uvecati broj bodova za 35%:
--     * prikazati koliko ce svaki predmet imati bodova nakon uvecanja. Uvecani broj bodova prikazati sa jednom decimalnom cifrom.

SELECT naziv, espb, DECIMAL(espb*1.35, 10, 1) AS uvecanje
FROM da.predmet;

--     * prikazati koliko ce bodova imati predmeti koji nakon uvecanja imaju vise od 8 bodova;
--        Uvecani broj bodova zaokruziti na vecu celobrojnu vrednost.

SELECT naziv, espb, CEIL(espb*1.35) AS uvecanje
FROM da.predmet
WHERE espb*1.35>=8;

---------
--Pokusaj i vidi u cemu je greska
SELECT naziv,espb, CEIL(espb*1.35) AS uvecanje
FROM da.predmet
WHERE uvecanje>=8;
---------


-- 2. Izdvojiti indeks,  ime,  prezime,  mesto rodenja,  broj slova u imenu i prezimenu
--     i  inicijale  za  svakog  studenata.
--     Ime  i  prezime  napisati  u  jednoj koloni,
--     a za studente rodene u Beogradu kao mesto rodenja ispisati Bg.


SELECT indeks,ime,prezime,mestoRodjenja,
	LENGTH(ime)+LENGTH(prezime) AS brojslova,
	SUBSTR(ime,1,1)||' '||SUBSTR(prezime,1,1) AS inicijali,
	ime||' '||prezime AS imeprezime,
	REPLACE(mestoRodjenja,'Beograd','Bg')
FROM da.dosije
LIMIT 5;

-- 3.  Ispisati trenutno vreme, trenutni datum i korisnika.

VALUES (current_time, current_date, user);

SELECT DISTINCT current_time, current_date, user
FROM da.dosije;

-- 4. Prikazati danasnji datum u svim formatima:  ISO, EUR, USA, LOCAL, JIS.

--Resenje:
VALUES CHAR(current_date), CHAR(current_date, ISO),	CHAR(current_date, USA),CHAR(current_date, LOCAL),CHAR(current_date, JIS);

-------------------
VALUES current_date, CHAR(current_date, JIS);
VALUES current_date, CHAR(current_date, EUR);
-------------------

-- 5. Izracunati koji je dan u nedelji (njegovo ime) bio 18.11.2018.

VALUES DAYNAME(DATE('11-18-2018'));
VALUES DAYNAME('11-18-2018');
VALUES DAYNAME('11/18/2018');
VALUES DAYNAME('2018-11-18');
VALUES DAYNAME('18.11.2018');


-- 6. Za danasnji datum izracunati:
--     * koji je dan u godini
--     * u kojoj je nedelji u godini
--     * dan u nedelji
--     * ime dana
--     * ime meseca

VALUES (current_date,
	    DAYOFYEAR(current_date),
	    WEEK(current_date),
	    DAY(current_date),
	    DAYNAME(current_date),
	    MONTHNAME(current_date));

-- 7. Izdvojiti sate, minute i sekunde iz trenutnog vremena.

VALUES (current_time, HOUR(current_time), MINUTE(current_time), SECOND(current_time));

-- 8. Izracunati koji ce datum biti za 12 godina, 5 meseci i 25 dana.

VALUES current_date, current_date + 12 YEARS + 5 MONTHS + 25 DAYS;

-- 9. Izdvojiti ispite koji su odrzani posle 1. aprila 2019. godine.

SELECT *
FROM da.ispit i
WHERE datPolaganja > DATE('01.04.2019');

-- 10.  Pronaci sve ispite odrzane u poslednje 4 godine.

--     	 |    4godine       |   
-- Pre4God___________________Sad____
--        X	Y
--		|    4godine       | 

SELECT *
FROM da.ispit i
WHERE datPolaganja + 4 YEARS > current_date;

SELECT *
FROM da.ispit i
WHERE datPolaganja BETWEEN current_date - 4 YEARS AND current_date;

-- 11. Za  sve  ispite  koji  su  odrzani  u  poslednjih  5  godina
--       izracunati  koliko  je godina,  meseci  i  dana  proslo  od  njihovog  odrzavanja.
--	  Izdvojiti  indeks studenta, naziv predmeta, ocenu, broj godina, broj meseci i broj dana.

--10000*brCelihGodina +100*brCelihMeseci+brCelihDana

SELECT i.indeks, p.naziv, i.ocena,
            current_date, i.datPolaganja, current_date-i.datPolaganja,
	        YEAR(current_date-i.datPolaganja) AS year,
	        MONTH(current_date-i.datPolaganja) AS month,
	        DAY(current_date-i.datPolaganja) AS day
FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
WHERE i.datPolaganja + 5 YEARS > current_date
LIMIT 10;

-- 12.  Za svakog studenta, koji je polagao bar jedan ispit,
--        izdvojiti indeks i broj dana od poslednjeg polaganja ispita.

SELECT indeks, DAYS(current_date)-DAYS(datPolaganja), DAYS_BETWEEN(current_date,datPolaganja)
FROM da.ispit i
WHERE datPolaganja IS NOT NULL AND
             datPolaganja >= ALL(SELECT datPolaganja
					       FROM da.ispit i1
					       WHERE i1.indeks=i.indeks AND i1.datPolaganja IS NOT NULL);


-- 13. Izdvojiti indeks, ime, prezime i datum diplomiranja za svakog studenta.
--     Ako je datum diplomiranja nepoznat,
--     umesto NULL vrednosti ispisati 'Nepoznat'.

SELECT indeks,ime,prezime, COALESCE(CHAR(datDiplomiranja),'Nepoznat')
FROM da.dosije;

-- 14.  Izdvojiti indeks, ime, prezime i mesto rodenja za svakog studenta.
--      Ako je mesto rodenja 'Kraljevo' prikazati NULL.

SELECT indeks,ime,prezime, NULLIF(mestoRodjenja,'Kraljevo') AS mesto
FROM da.dosije;