--Prosli cas
-- 0. Za svaki predmet prikazati brojeve indeksa,  id predmeta,  ocena, datum kada je neki student polozio taj predmet.
-- U rezultatu treba da se nadu i predmeti koje niko nije polozio.

SELECT  indeks, idPredmeta, ocena, datPolaganja, naziv
FROM da.ispit i RIGHT OUTER JOIN da.predmet p ON i.idPredmeta=p.id AND ocena>5 AND status='o';

SELECT  indeks, idPredmeta, ocena, datPolaganja, naziv
FROM da.ispit i RIGHT OUTER JOIN da.predmet p ON i.idPredmeta=p.id 
WHERE ocena>5 AND status='o';

SELECT indeks, idPredmeta, ocena, datPolaganja, naziv
FROM da.ispit i RIGHT OUTER JOIN da.predmet p ON i.idPredmeta=p.id AND ocena>5 AND status='o'
WHERE idPredmeta IS NOT NULL ;

------------------------------------------------------------------

--	<exp> <operator> ANY (<exp>)
-- 1. Izdvojiti informacije o svim predmetima osim o onima koji nose najvise bodova.
SELECT *
FROM da.predmet
WHERE espb < ANY(SELECT espb FROM da.predmet);

SELECT *
FROM da.predmet
WHERE espb < SOME(SELECT espb FROM da.predmet);


--	<exp> <operator> ALL (<exp>)
-- 2. Izdvojiti infomracije o studentima koji su se prvi upisali na fakultet.

SELECT indeks, ime, prezime, datUpisa
FROM da.dosije
WHERE datUpisa <= ALL(SELECT datUpisa FROM da.dosije);


-- 3. Izdvojiti infomracije o studentima koji su se prvi diplomirali na fakultetu.

SELECT indeks, ime, prezime, datDiplomiranja
FROM da.dosije
WHERE datDiplomiranja <= ALL(SELECT datDiplomiranja FROM da.dosije);

--Resenje:

SELECT indeks, ime, prezime, datDiplomiranja
FROM da.dosije
WHERE datDiplomiranja <= ALL(SELECT datDiplomiranja FROM da.dosije WHERE datDiplomiranja IS NOT NULL);

-- 4.  Izdvojiti imena i prezimena studenata koji su polozili predmet ciji je identifikator 1578.

--1)nacin
SELECT ime, prezime
FROM da.dosije d JOIN da.ispit i ON d.indeks=i.indeks
WHERE idPredmeta=1578 AND ocena>5 AND status='o';


--2)nacin
--	<exp> IN (<exp>)		[   <-> <exp> = ANY (<exp>)  ]

SELECT ime, prezime
FROM da.dosije
WHERE indeks IN (SELECT indeks
		         FROM da.ispit
	             WHERE idPredmeta=1578 AND ocena>5 AND status='o');


SELECT ime, prezime
FROM da.dosije d
WHERE 1578 IN (SELECT idPredmeta
		       FROM da.ispit i
		       WHERE i.indeks=d.indeks AND ocena>5 AND status='o');


--3)nacin
-- Tabelarni podupiti
--	EXISTS (<tab>)


SELECT ime, prezime
FROM da.dosije d
WHERE EXISTS(SELECT *
	       FROM da.ispit
	       WHERE indeks=d.indeks AND idPredmeta=1578 AND ocena>5 AND status='o');

-- 5.  Izdvojiti indekse, imena i prezimena studenata koji nisu polagali predmet ciji je identifikator 1578.

SELECT indeks, ime, prezime
FROM da.dosije d
WHERE NOT EXISTS(SELECT *
		         FROM da.ispit i
		         WHERE indeks=d.indeks AND idPredmeta=1578);

SELECT indeks,ime,prezime
FROM da.dosije d
WHERE d.indeks NOT IN(SELECT indeks	FROM da.ispit WHERE idPredmeta=1578);

-- 6. Izdvojiti  brojeve  indeksa,  imena  i  prezimena  studenta  koji  su  polagali predmet koji nosi 5 bodova.

SELECT DISTINCT  d.indeks, ime, prezime
FROM da.dosije d JOIN da.ispit i ON d.indeks=i.indeks
   	       	     JOIN da.predmet p ON i.idPredmeta=p.id
WHERE p.espb=5;


SELECT indeks, ime, prezime
FROM da.dosije d
WHERE EXISTS(SELECT * FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id WHERE indeks=d.indeks AND p.espb=5);

SELECT indeks, ime, prezime
FROM da.dosije d
WHERE EXISTS(SELECT *
	         FROM da.ispit i
	         WHERE indeks=d.indeks AND EXISTS(SELECT * FROM da.predmet p WHERE id=i.idPredmeta AND espb=5));

-- 7. Prikazati brojeve indeksa, imena i prezimena studenata koji su polozili sve predmete.

--(Ax)p(x) <-> !(Ex)!p(x)

SELECT indeks, ime, prezime
FROM da.dosije d
WHERE NOT EXISTS(SELECT *
 		         FROM da.predmet p
		         WHERE NOT EXISTS(SELECT * FROM da.ispit i WHERE indeks=d.indeks AND idPredmeta=p.id AND ocena>5 AND status='o'));

-- 8. Prikazati brojeve indeksa studenata koji su polozili bar one predmete koje i student sa brojem indeksa 20150174.

SELECT idPredmeta
FROM da.ispit
WHERE indeks=20150174 AND ocena>5 AND status='o';


--(Ax)(p(x)->q(x))
--	<-> !(Ex)!(p(x)->q(x))
--	<-> !(Ex)!(!p(x) V q(x))
--	<-> !(Ex) (p(x) & !q(x))
--
--20150174 polozio predmet x -> nas_student polozio predmet x
 
SELECT indeks, ime, prezime
FROM da.dosije d
WHERE NOT EXISTS(SELECT *
		         FROM da.ispit i
		         WHERE indeks=20150174 AND ocena>5 AND status='o' AND NOT EXISTS(SELECT *
						                                                         FROM da.ispit i1
						                                                         WHERE indeks=d.indeks AND idPredmeta=i.idPredmeta AND ocena>5 AND status='o'));

-- 9.  Za  svaki  ispit  izdvojiti  indeks, idpredmeta i dobijenu  ocenu.
-- Vrednost ocene ispisati i slovima.
-- Ako je predmet nepolozen umesto ocene ispisati nepolozen.

SELECT indeks ind,idPredmeta,ocena,5 AS pet
FROM da.ispit AS i
LIMIT 2;

--Resenje:
SELECT indeks, idPredmeta, ocena,
            CASE ocena
	     	    WHEN 6 THEN 'sest'
		        WHEN 7 THEN 'sedam'
		        WHEN 8 THEN 'osam'
		        WHEN 9 THEN 'devet'
		        WHEN 10 THEN 'deset'
		        ELSE 'nepolozen'
	        END AS ocena
FROM da.ispit;

SELECT indeks, idPredmeta, ocena,
            CASE 
	            WHEN ocena=6 THEN 'sest'
		        WHEN ocena=7 THEN 'sedam'
		        WHEN ocena=8 THEN 'osam'
		        WHEN ocena=9 THEN 'devet'
		        WHEN ocena=10 THEN 'deset'
		        ELSE 'nepolozen'
	        END AS ocena
FROM da.ispit;

-- 10. Klasifikovati predmete prema broju bodova na sledeci nacin:
-- ispisati: 	* 'lak' ako predmet nosi manje od 6 bodova
-- 	  	* 'srednje tezak' ako nosi 6 ili 7 bodova
--		* 'tezak' ako nosi bar 8 bodova

SELECT naziv, espb,
            CASE 
	     	    WHEN espb < 6 THEN 'lak'
		        WHEN espb IN (6, 7) THEN 'srednje tezak'
		        ELSE 'tezak'
	        END AS klasifikacija
FROM da.predmet;

-- 11. Za  svakog  studenta  iz  tabele dosije izdvojiti  indeks,  ime,  prezime  studenta
-- praceno jednom od mogucih informacija o statusu studenta:
-- 	 	 * 'brucos' ako nije polagao nijedan predmet
-- 		 * 'nijedan polozen' ako nema polozen ispit
-- 		 * 'student' inace

SELECT d.indeks, d.ime, d.prezime,
       	    CASE
			    WHEN NOT EXISTS(SELECT * FROM da.ispit i WHERE i.indeks=d.indeks) THEN 'brucos'
			    WHEN NOT EXISTS(SELECT * FROM da.ispit i WHERE i.indeks=d.indeks AND i.ocena>5 AND i.status='o') THEN 'nijedan polozen'
			    ELSE 'student'
	    	END AS klasifikacija
FROM da.dosije d;

-- 12. Da li uslovi u case-u moraju biti disjunktni?

SELECT indeks, ocena, CASE
			   WHEN ocena>=8 THEN '>=8'
			   WHEN ocena>=7 THEN '>=7'
			   ELSE 'trece'
			END AS klase
FROM da.ispit i
WHERE ocena>5;