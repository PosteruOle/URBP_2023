--	COUNT

--COUNT(*)
--COUNT(<izraz>)
--COUNT(DISTINCT <izraz>)

--SELECT * FROM da.priznatIspit;

--SELECT COUNT(*)
--FROM da.priznatIspit;

--SELECT COUNT(*)
--FROM da.priznatIspit
--WHERE ocena IS NOT  NULL;

--SELECT COUNT(ocena)
--FROM da.priznatIspit;

--SELECT COUNT(DISTINCT ocena)
--FROM da.priznatIspit;


--	MIN, MAX i AVG

--SELECT MIN(ocena),MAX(ocena)
--FROM da.priznatIspit;

--SELECT SUM(ocena)
--FROM da.priznatIspit;

--SELECT SUM(DISTINCT ocena)
--FROM da.priznatIspit;

--SELECT AVG(DISTINCT ocena)
--FROM da.priznatIspit;

------------------------------------------------------------------------------


-- 1. Izdvojiti  ukupan  broj  studenata,
--     leksikografski  gledano  najmanje  ime  i
--     najveci broj indeksa studenta iz tabele dosije.

SELECT COUNT(*) AS "Broj studenata",
	MIN(ime) AS "Najmanje ime",
	MAX(indeks) AS NaJvEcIiNdeks
FROM da.dosije;

-- 2. Odrediti ukupan broj studenata,
--     broj studenata kojima je poznat datum diplomiranja i
--     broj razlicitih vrednosti za mesto rodenja.

SELECT COUNT(*), COUNT(datDiplomiranja), COUNT(DISTINCT mestoRodjenja)
FROM da.dosije;

-- 3. Za  studente  koji  su  nesto  polozili,
--     izdvojiti  broj  indeksa  i  ukupan  broj skupljenih bodova.

--Prvo probati:
SELECT indeks, espb
FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
WHERE ocena>5 AND status='o'
ORDER BY 1;

--Resenje:
SELECT indeks, SUM(espb) AS "Ukupno espb"
FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
WHERE ocena>5 AND status='o'
GROUP BY indeks
ORDER BY 1;


-- 4. Za studenta koji je skupio bar 20 bodova prikazati
--     ukupan broj skupljenih bodova.
--     Rezultat urediti rastuce po ukupnom broju skupljenih bodova.

--Prvo probaj
SELECT indeks,SUM(espb) AS ukupno
FROM  da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
WHERE ocena>5 AND status='o' AND SUM(espb)>=20
GROUP BY indeks;

--Resenje:
SELECT indeks, SUM(espb) AS ukupno
FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id
WHERE ocena>5 AND status='o'
GROUP BY indeks
HAVING sum(espb)>=20
ORDER BY 2;

-- 5.  Izracunati prosek studentima koji su polozili neki ispit.
--      Rezultat urediti opadajuce po proseku.

SELECT indeks, AVG(ocena+0.0)
FROM da.ispit
WHERE ocena>5 AND status='o'
GROUP BY indeks
ORDER BY 2 DESC;

SELECT indeks, DECIMAL(AVG(ocena+0.0),5,2)
FROM da.ispit 
WHERE ocena>5 AND status='o'
GROUP BY indeks
ORDER BY 2 DESC;

-- 6. Za svaki od ispitnih rokova i za svaki polagan predmet u tom roku
--     odrediti broj uspesnih polaganja.
--     Uzeti u obzir samo rokove i predmete takve da je u izdvojenom roku
--     bilo polozenih ispita iz izdvojenog predmeta.

--Prvo probati:
SELECT skGodina,oznakaRoka, idPredmeta
FROM da.ispit i
WHERE ocena>5 AND status='o'
ORDER BY 1,2,3;

--Resenje:
SELECT skGodina, oznakaRoka, idPredmeta, COUNT(*)
FROM da.ispit
WHERE ocena>5 AND status='o'
GROUP BY skGodina, oznakaRoka, idPredmeta
ORDER BY 1, 2, 3;

-- 7.  Izdvojiti brojeve indeksa studenata koji su polozili bar 3 ispita i
--      identifikatore predmeta koje su polozila bar tri studenta.
--	Sve to uradi u jednom upitu i
--      rezultat urediti u opadajucem poretku po broju polozenih ispita,
--      odnosno broju studenata.

SELECT indeks, COUNT(idPredmeta)
FROM da.ispit 
WHERE ocena>5 AND status='o'
GROUP BY indeks
HAVING COUNT(idPredmeta)>=3
ORDER BY 2 DESC;

SELECT idPredmeta,COUNT(indeks)
FROM da.ispit
WHERE ocena>5 AND status='o'
GROUP BY idPredmeta
HAVING COUNT(indeks)>=3
ORDER BY 2 DESC;

--Resenje:
SELECT indeks, COUNT(idPredmeta)
FROM da.ispit
WHERE ocena>5 AND status='o'
GROUP BY indeks
HAVING COUNT(idPredmeta)>=3
UNION
SELECT idPredmeta, COUNT(indeks)
FROM da.ispit i
WHERE ocena>5 AND status='o'
GROUP BY idPredmeta
HAVING COUNT(indeks)>=3
ORDER BY 2 DESC;

-- 8. Za  svaki  predmet  izdvojiti  broj  studenata  koji  su  ga  polagali.
--     Izdvojiti naziv predmeta i broj studenata.
--     Za predmete koje niko nije polagao izdvojiti 0.
--     Rezultat urediti prema broju studenata koji su polagali predmet u opadajucem poretku.

SELECT naziv, COUNT(indeks) AS "Broj studenata"
FROM da.predmet p LEFT OUTER JOIN  da.ispit i ON i.idPredmeta=p.id
GROUP BY id,naziv
ORDER BY 2 DESC;

--Probajte i samo grupisanje po nazivu

SELECT naziv, COUNT(id)
FROM da.predmet
GROUP BY naziv
HAVING COUNT(id)>1;

SELECT *
FROM da.predmet
WHERE naziv LIKE 'Zvezdana astr%';

-- 9. Za studenta koji je polagao neki ispit
--     izracunati iz koliko ispita je dobio ocenu 8 i iz koliko ispita je dobio ocenu 9.
--     Izdvojiti indeks studenta,
--                   broj ispita  iz  kojih  je  student  dobio  ocenu  8  i
--                   broj  ispita  iz  kojih  je  student dobio ocenu 9.

--Resenje 1:
SELECT indeks,
            SUM(CASE ocena
		       WHEN 8 THEN 1
		       ELSE 0
		    END) AS "Broj osmica",
	        SUM(CASE ocena
			    WHEN 9 THEN 1
			    ELSE 0
			END) AS "Broj devetki"
FROM da.ispit
GROUP BY indeks
ORDER BY 1;

--Resenje 2:
SELECT indeks, COUNT(
    CASE ocena
		WHEN 8 THEN 5
		ELSE NULL
	END) AS brOsmica, COUNT(
	CASE ocena
		WHEN 9 THEN 15
		ELSE NULL
	END) AS brDevetki
FROM da.ispit
GROUP BY indeks
ORDER BY 1;

-----------------------------------------------------------
--Vase resenje sa casa:

SELECT indeks, COUNT(NULLIF(ocena,9)) AS brOsmica, COUNT(NULLIF(ocena,8)) AS brDevetki
FROM da.ispit
WHERE ocena IN (8,9)
GROUP BY indeks
ORDER BY 2 DESC,3 DESC;

--Uporediti zasto manje rezultata dobijamo (Pogledati nacin sa casa ali ga sad uredite opadajuce po broju osmica i devetki)
--Sta se desava sa studentima koji nisu nikada dobili 8 ili 9 ali jesu npr 7
---------------------------------------------------------------


-- 10.  Izdvojiti informacije o studentima koji su prvi diplomirali na fakultetu.
--        Uzeti u razmatranje samo one studente za koje se zna datum diplomiranja.

--Resenje 1:
SELECT *
FROM da.dosije
WHERE datDiplomiranja <= ALL(SELECT datDiplomiranja FROM da.dosije WHERE datDiplomiranja IS NOT NULL);

--Resenje 2:
SELECT *
FROM da.dosije
WHERE datDiplomiranja = (SELECT MIN(datDiplomiranja) FROM da.dosije);