-- Slozen upit

--WITH <ime> [AS] ( <upit> )
--  [, <ime> [AS] ( <upit> )]*
--<upit>

-- 1. Predmeti  se  kategorisu  kao
-- laki: ukoliko  nose  manje  od  6  bodova,
-- teski: ukoliko nose vise od 8 bodova,
-- inace su srednje teski.
-- Prebrojati koliko predmeta pripada kojoj kategoriji.S
-- Izdvojiti kategoriju i broj predmeta iz te kategorije.


SELECT id,
	CASE
		WHEN espb<6 THEN 'lak'
		WHEN espb BETWEEN 6 AND 8 THEN 'srednje tezak'
		ELSE 'tezak'
	END AS tezina
FROM da.predmet p;

WITH klasifikacija AS (
SELECT  CASE
		    WHEN espb < 6 THEN 'lak'
		    WHEN espb BETWEEN 6 AND 8 THEN 'srednje tezak'
		    ELSE 'tezak'
	    END AS tezina
FROM da.predmet p
)
SELECT tezina, COUNT(*)
FROM klasifikacija
GROUP BY tezina;



-- 2. Izracunati koliko studenata je polozilo vise od 20 bodova.

SELECT indeks, SUM(espb) polozeno_poena
FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
WHERE ocena>5 AND status='o'
GROUP BY indeks;


WITH polozeno AS(
    SELECT indeks, SUM(espb) polozeno_poena
    FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
    WHERE ocena>5 AND status='o'
    GROUP BY indeks
)
SELECT COUNT(*) AS "Polozili vise od 20 espb"
FROM polozeno
WHERE polozeno_poena > 20;

WITH polozeno AS(
	SELECT indeks,SUM(espb) as pol
	FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
	WHERE ocena>5 AND status='o'
	GROUP BY indeks
	HAVING SUM(espb)>20
)
SELECT COUNT(*)
FROM polozeno;

-- 3.  Naci broj ispitnih  rokova u  kojima su  studenti
--      polozili bar  2  razlicita predmeta.

SELECT skGodina, oznakaRoka, COUNT(DISTINCT idPredmeta) AS razl_predmeta
FROM da.ispit i
WHERE ocena>5 AND status='o'
GROUP BY skGodina, oznakaRoka;

WITH rokovi AS (
     SELECT skGodina, oznakaRoka, COUNT(DISTINCT idPredmeta) AS razl_predmeta
     FROM da.ispit i
     WHERE ocena>5 AND status='o'
     GROUP BY skGodina, oznakaRoka)
SELECT COUNT(*) AS "Polozeno bar 2 predmeta u roku"
FROM rokovi
WHERE razl_predmeta>=2;

-- 4. Za svaki predmet izdvojiti identifikator i
--     broj razlicitih studenata koji su ga polagali.
--     Uz identifikatore predmeta koje niko nije polagao izdvojiti 0.

SELECT id, COUNT(DISTINCT indeks) AS brstud
FROM da.ispit i RIGHT OUTER JOIN da.predmet p ON i.idPredmeta=p.id
GROUP BY id
ORDER BY 2;

SELECT idPredmeta, COUNT(DISTINCT indeks)
FROM da.ispit i
GROUP BY idPredmeta
UNION
SELECT id, 0
FROM da.predmet p
WHERE id NOT IN (SELECT idPredmeta FROM da.ispit i)
ORDER BY 2;

WITH polagani AS (
    SELECT idPredmeta, COUNT(DISTINCT indeks) AS nstud
    FROM da.ispit
    GROUP BY idPredmeta
)
SELECT p.id, COALESCE(nstud, 0) AS br_studenata
FROM polagani RIGHT OUTER JOIN da.predmet p ON p.id=polagani.idPredmeta
ORDER BY 2;

-- 5. Za svakog studenta izdvojiti ime i prezime i
--     broj razlicitih ispita koje je pao (ako ne postoji nijedan izdvojiti 0).

SELECT ime,prezime, COUNT(DISTINCT idPredmeta) AS br_padova
FROM da.ispit i RIGHT OUTER JOIN da.dosije d ON i.indeks=d.indeks AND ocena=5 AND status='o'
GROUP BY d.indeks, ime, prezime;

SELECT ime, prezime, COUNT(DISTINCT idPredmeta) AS br_padova
FROM da.ispit i JOIN da.dosije d ON i.indeks=d.indeks
WHERE ocena=5 AND status='o'
GROUP BY d.indeks, ime, prezime
UNION ALL
SELECT ime, prezime, 0
FROM da.dosije d
WHERE NOT EXISTS(SELECT * FROM da.ispit i WHERE indeks=d.indeks AND ocena=5 AND status='o');

-------------------------------------------------------------------
--Probati i sa UNION, zasto sad imamo problem a u 4.zadatku ne? 
SELECT ime, prezime, COUNT(DISTINCT idPredmeta) AS br_padova
FROM da.ispit i JOIN da.dosije d ON i.indeks=d.indeks
WHERE ocena=5 AND status='o'
GROUP BY d.indeks, ime, prezime
UNION 
SELECT ime, prezime, 0
FROM da.dosije d
WHERE NOT EXISTS(SELECT * FROM da.ispit i WHERE indeks=d.indeks AND ocena=5 AND status='o');

-------------------------------------------------------------------

WITH padovi AS (
    SELECT d.indeks, ime, prezime, COUNT(DISTINCT idPredmeta) AS br_padova
    FROM da.ispit i JOIN da.dosije d ON i.indeks=d.indeks
    WHERE ocena=5 AND status='o'
    GROUP BY d.indeks, ime, prezime
)
SELECT d.ime, d.prezime, COALESCE(br_padova, 0)
FROM da.dosije d LEFT OUTER JOIN padovi pad ON d.indeks=pad.indeks
ORDER BY 3;

-- 6. Izdvojiti broj studenata koji su polozili neke predmete u bar 2 razlicita roka.

SELECT DISTINCT indeks, skGodina, oznakaRoka
FROM da.ispit i
WHERE ocena>5 AND status='o'
ORDER BY 1,2,3;

WITH polaganja AS (
     SELECT DISTINCT indeks, skGodina, oznakaRoka
     FROM da.ispit i
     WHERE ocena>5 AND status='o'
     ORDER BY 1,2,3
)
SELECT indeks, COUNT(*) br_pol
FROM polaganja
GROUP BY indeks
HAVING COUNT(*)>=2;

WITH polaganja AS (
    SELECT DISTINCT indeks, skGodina, oznakaRoka
    FROM da.ispit i
    WHERE ocena>5 AND status='o'
    ORDER BY 1,2,3
), polaganja_vise2 AS (
    SELECT indeks, COUNT(*) br_pol
    FROM polaganja
    GROUP BY indeks
    HAVING COUNT(*) >= 2
)
SELECT COUNT(*) AS "Polozili nesto u vise ili jednako 2 roka"
FROM polaganja_vise2;


WITH polaganja_vise2 AS (
    SELECT indeks, COUNT(DISTINCT CHAR(skGodina) || oznakaRoka) n
    FROM da.ispit i
    WHERE ocena>5 AND status='o'
    GROUP BY indeks
    HAVING COUNT(DISTINCT CONCAT(CHAR(skGodina), oznakaRoka))>=2
)
SELECT COUNT(*) AS "Polozili nesto u vise ili jednako 2 roka."
FROM polaganja_vise2;

-----------------------------------------------------------------------------
-- Vezbanje SQL

-- 1.  Izdvojiti indekse studenata koji su rodeni u istom gradu kao
--      oni studenti koji su upisani na Matematicki fakultet pre 2016.godine.

SELECT indeks
FROM da.dosije
WHERE mestoRodjenja IN (SELECT mestoRodjenja
					   FROM da.dosije d1
					   WHERE YEAR(d1.datUpisa)<2016);

WITH pom AS (
SELECT indeks, datUpisa, mestoRodjenja
FROM da.dosije
WHERE YEAR(datUpisa)<2016
)
SELECT indeks
FROM da.dosije d
WHERE mestoRodjenja IN (SELECT mestoRodjenja FROM pom);

-- 2.  Napisati upit u SQL-u kojim se izdvajaju nazivi ispitnih rokova u
--      * kojima nijedan student nije pao na ispitu iz predmeta koji nosi 8 bodova ili
--      * za taj rok postoji neki drugi rok odrzan u istoj godini u kome je
--	   barem jedan student pao neki predmet od 8 bodova.
-- 	Rezultat urediti opadajuce prema nazivu roka.

SELECT naziv
FROM da.ispitnIRok ir
WHERE NOT EXISTS(SELECT *
			     FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
			     WHERE ocena=5 AND status='o' AND
				     skGodina=ir.skGodina AND oznakaRoka=ir.oznakaRoka AND espb=8)
             OR EXISTS(SELECT *
			           FROM da.ispit 
			           WHERE ocena=5 AND status='o' AND skGodina=ir.skGodina 
                                     AND oznakaRoka<>ir.oznakaRoka AND idPredmeta IN (SELECT id FROM da.predmet WHERE espb=8))
ORDER BY naziv DESC;

-- 3.  Izdvojiti sva imena studentkinja zajedno sa brojem njihovih pojavljivanja.
--      Rezultat urediti opadajuce po broju pojavljivanja.

SELECT ime, COUNT(*) AS brojPojavljivanja
FROM da.dosije
WHERE pol='z'
GROUP BY ime
ORDER BY 2 DESC;