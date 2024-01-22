-- 1. Izdvojiti indekse, imena i prezimena studenata ciji datum diplomiranja nije poznat.
SELECT indeks, ime, prezime
FROM da.dosije
WHERE datDiplomiranja IS NULL;

-- 2. Izdvojiti imena i prezimena studenata koji nisu rodjeni u Kraljevu.
SELECT ime, prezime
FROM da.dosije
WHERE mestoRodjenja<>'Kraljevo';

-- 3. Definisati  konstatnu  tabelu  koja  ima  1  kolonu  i  3  reda  sa  prva  tri  celabroja.
-- [1]
-- [2]
-- [3]
VALUES (1), (2), (3);
VALUES (1, 2, 3);

-- 4. Definisati konstatnu tabelu koja ima 2 reda sa 3 kolone popunjenu sa prvih 6 celih brojeva.
-- [1, 2, 3]
-- [4, 5, 6]
VALUES (1, 2, 3), (4, 5, 6);

-- 5. Definisati konstatnu tabelu koja sadrzi korisnicko ime trenutno ulogovanog korisnika.
VALUES USER;

-- 6. -||- trenutno vreme, datum
VALUES CURRENT TIME;
VALUES CURRENT DATE;
VALUES CURRENT TIMESTAMP;

-- Spajanje tabela
-- 7. Izdvojiti ime, prezime studenta i identifikator predmeta koji je taj student polagao.
-- Za pocetak hocu indeks, id_predmeta za sva polaganja.
-- SELECT indeks, idPredmeta
-- FROM da.ispit;
-- Decart(A, B) = A x B = {(a, b) | a in A, b in B}
-- |AxB| = |A|*|B|

SELECT DISTINCT ime, prezime, idPredmeta
FROM da.dosije, da.ispit
WHERE da.dosije.indeks=da.ispit.indeks;

-- SELECT DISTINCT ime, prezime, idPredmeta
-- FROM da.dosije d, da.ispit i
-- WHERE d.indeks=i.indeks;

SELECT DISTINCT ime, prezime, idPredmeta
FROM da.dosije AS d, da.ispit AS i
WHERE d.indeks=i.indeks;

SELECT DISTINCT ime, prezime, idPredmeta
.FROM da.dosije d JOIN da.ispit i ON d.indeks=i.indeks;

-- 8.  Prikazati broj indeksa, ime i prezime studenta i nazive svih predmeta
-- koje je taj student polozio.

-- Banalizovano: indeks, idPredmeta za sva uspesna polaganja
SELECT indeks, idPredmeta
FROM da.ispit
WHERE ocena>5 AND status='o';

-- Hocu indeks i naziv predmeta
SELECT indeks, TRIM(naziv)
FROM da.ispit i, da.predmet p
WHERE ocena>5 AND status='o' AND i.idPredmeta=p.id;

-- Hocu ime, prezime, naziv predmeta
SELECT d.indeks, ime, prezime, naziv
FROM da.ispit i, da.predmet p, da.dosije d
WHERE ocena>5 AND status='o' AND i.idPredmeta=p.id AND d.indeks=i.indeks;

SELECT d.indeks, d.ime, d.prezime, p.naziv
FROM da.ispit i JOIN da.dosije d ON d.indeks=i.indeks
     	                 JOIN da.predmet p ON i.idPredmeta=p.id
WHERE i.ocena>5 AND i.status='o';

--9. Prikazati  sve  parove  brojeva  indeksa  studenata  koji  su  rodeni  u  istom gradu.
SELECT d1.indeks, d2.indeks, d1.mestoRodjenja, d2.mestoRodjenja
FROM da.dosije d1, da.dosije d2
WHERE d1.mestoRodjenja=d2.mestoRodjenja AND d1.indeks<d2.indeks;

-- 10.  Izdvojiti parove naziva razlicitih ispitnih rokova u kojima je
--        isti studentpolagao isti predmet.
SELECT DISTINCT ir1.naziv, ir2.naziv
FROM (da.ispitniRok ir1 JOIN da.ispit i1 ON ir1.skGodina=i1.skGodina AND ir1.oznakaRoka=i1.oznakaRoka)
--          JOIN
	  (da.ispitniRok ir2 JOIN da.ispit i2 ON ir2.skGodina=i2.skGodina AND ir2.oznakaRoka=i2.oznakaRoka)
	  ON i1.indeks=i2.indeks AND i1.idPredmeta=i2.idPredmeta AND (i1.oznakaRoka<>i2.oznakaRoka OR i1.skGodina<>i2.skGodina);

-- ispit:
-- milan cug urbp sept1 2020
-- milan cug urbp jan 2020
-- pera peric P1 sept1 2020
-- pera peric P1 jan 2020

-- 11.  Za  svaki  predmet  izdvojiti  naziv predmeta i naziv roka  u  kojima  je  taj predmet polagan.
SELECT p.naziv, i.skGodina, i.oznakaRoka
FROM da.predmet p LEFT OUTER JOIN da.ispit i ON p.id=i.idPredmeta;

SELECT p.naziv, i.skGodina, i.oznakaRoka
FROM da.ispit i RIGHT OUTER JOIN da.predmet p ON p.id=i.idPredmeta;

-- FULL OUTER JOIN

-- 12. Za svaki predmet prikazati brojeve indeksa,  id predmeta,  ocena,  datumkada je neki student polozio taj predmet.  U rezultatu treba da se nadu ipredmeti koje niko nije polagao.
SELECT indeks, idPredmeta, ocena, datPolaganja, TRIM(naziv)
FROM da.ispit i RIGHT OUTER JOIN da.predmet p ON i.idPredmeta=p.id AND ocena>5 AND status='o'
ORDER BY indeks;

-- Uslov restrikcije 'ubija' spoljasnje spajanje
-- (NULL, NULL, NULL, NULL, URBP)

