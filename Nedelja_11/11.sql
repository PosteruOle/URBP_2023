Relaciona algebra
	unija
	presek
	razlika
	proizvod

	projekcija
	restrikcija 
	prirodno spajanje


-- 1. Izdvojiti naziv i broj espb bodova za sve predmete
--     koji se predaju na fakultetu (PROJEKCIJA).

--Pr
--predmet[idPredmeta, sifra, naziv, espb]
--(4,'M202','Algebra 1',5)
--(5,'M203','Algebra 2',5)

--('Algebra 1',5)
--('Algebra 2',5)


predmet[naziv,espb]


-- 2. Izdvojiti sve detalje o studentima rodenim u Beogradu (Savski Venac)
--     (RESTRIKCIJA).
--Resenje:

dosije
WHERE mestoRodjenja='Beograd (Savski Venac)'


-- 3. Prikazati detalje svih parova student ispit takvih da je student
--     polagao taj ispit (SLOBODNO SPAJANJE).
--Resenje:

dosije TIMES ispit
WHERE dosije.indeks=ispit.indeks

-- 3. Prikazati detalje svih parova student ispit
--     takvih da je student polagao taj ispit.
--     Bez izdvajanja dva atributa sa vrednostima istog indeksa
--     (PRIRODNO SPAJANJE)
--Resenje:

dosije JOIN ispit

-- 4. Izdvojiti oznake predmeta koji nose 3 ili 6 espb bodova (UNIJA).
--Resenje:

(predmet WHERE espb=3)[oznaka]
UNION
(predmet WHERE espb=6)[oznaka]

--(predmet WHERE espb=3 OR espb=6)[oznaka]


-- 5. Izdvojiti indekse studenata koji su ispite polagali(polozili) sa ocenama
--     8 i 9 (INTERSECT).
--Resenje:

(ispit WHERE ocena=8 AND status='o')[indeks]
INTERSECT
(ispit WHERE ocena=9 AND status='o')[indeks]


-- 6. Izdvojiti indekse studenata koji su sve ispite koje su polozili
--     polozili sa ocenom 10 (MINUS).
--Resenje:

(ispit WHERE ocena=10 AND status='o')[indeks]
MINUS
(ispit WHERE ocena>5 AND ocena<10 AND status='o')[indeks]


-- 7. Napraviti spisak parova brojeva indeksa studenata
--     takvih da su oba rodjena u istom gradu.  (ALIJASI)

--ne mozemo
--dosije TIMES dosije
--WHERE dosije.mestoRodjenja=dosije.mestoRodjenja

--Resenje:

DEFINE ALIAS d1 FOR dosije
DEFINE ALIAS d2 FOR dosije
(d1 TIMES d2
WHERE d1.mestoRodjenja=d2.mestoRodjenja 
	AND d1.indeks<d2.indeks) [d1.indeks, d2.indeks]

-- 8. Prikazati ime i prezime studenta koji je
--     polagao predmet ciji identifikator je 2001. 

--(ispit WHERE idPredmeta=2001)[indeks]

--Resenje:

((ispit WHERE idPredmeta=2001)[indeks]
JOIN
dosije[indeks, ime, prezime])[ime, prezime]


-- 9. Prikazati ime i prezime studenta koji je polozio
--     najmanje 1 predmet koji nosi 6 espb bodova.
--     Napomena: predmet sadrzi idPredmeta kao atribut (ne zove se id)
--Resenje:

((ispit WHERE ocena>5 AND status='o')[indeks, idPredmeta]
JOIN
(predmet WHERE espb=6)[idPredmeta])[indeks]


(((ispit WHERE ocena>5 AND status='o')[indeks, idPredmeta]
JOIN
(predmet WHERE espb=6)[idPredmeta])[indeks]
JOIN
dosije[indeks, ime, preizme])[ime, preizme]

-- 10. Izdvojiti brojeve indeksa studenata koji su polagali sve predmete.(deljenje)
--Resenje:

ispit[indeks, idPredmeta]
DIVIDEBY
predmet[idPredmeta]

--  11. Prikazati brojeve indeksa studenta koji su polozili bar one razlicite predmete koje je polagao 
--        student sa brojem indeksa 20130023.

--Predmeti koje je polagao student sa brojem 20130023
-- (ispit WHERE indeks=20130023)[idPredmeta]

--Resenje:

(ispit WHERE ocena>5 AND status='o')[indeks, idPredmeta]
DIVIDEBY
(ispit WHERE indeks=20130023)[idPredmeta]

-- 12. Izdvojiti nazive svih predmeta koje su polozili svi studenti koji su upisali fakultet 2013. godine.

--Studenti upisani pre 2013.
--(dosije WHERE indeks>20130000 AND indeks<20140000)[indeks]

-- prvo idPredmeta

(ispit WHERE ocena>5 AND status='o')[idPredmeta, indeks]
DIVIDEBY
(dosije WHERE indeks>20130000 AND indeks<20140000)[indeks]

-- naziv jos nadjemo:
--Resenje:

((
 (ispit WHERE ocena>5 AND status='o')[idPredmeta, indeks]
 DIVIDEBY
 (dosije WHERE indeks>20130000 AND indeks<20140000)[indeks]
) JOIN predmet[idPredmeta, naziv])[naziv]

-- 13. Izdvojiti ime i prezime za svakog od studenata koji nisu polagali predmet ciji identifikator je 1021.

--nadjimo prvo studente koji su polagali predmet 1021
(ispit WHERE idPredmeta=1021)[indeks]

-- prvo indeks:
dosije[indeks]
MINUS
(ispit WHERE idPredmeta=1021)[indeks]

-- ime i prezime:
--Resenje:

((
	dosije[indeks]
	MINUS
	(ispit WHERE idPredmeta=1021)[indeks]
) JOIN dosije[indeks, ime, prezime])[ime, prezime]

-- 14. Prikazati sifre svih predmeta koji nose 6 bodova ili ih je neko polozio u roku Januar 2015.

-- prvo id
(predmet WHERE espb=6)[idPredmeta]
UNION
(ispit WHERE ocena>5 AND status='o' AND skGodina=2015 AND oznakaRoka='jan')[idPredmeta]

-- sifra:
((
	(predmet WHERE espb=6)[idPredmeta]
	UNION
	(ispit WHERE ocena>5 AND status='o' AND skGodina=2015 AND oznakaRoka='jan')[idPredmeta]
) JOIN predmet[idPredmeta, sifra])[sifra]

-- 15. Prikazati imena i prezimena studenata koji imaju polozen neki ispit sa ocenom 6, i neki drugi polozen sa ocenom 10. 

--prvo indeksi:
(ispit WHERE ocena=6 AND status='o')[indeks]
INTERSECT
(ispit WHERE ocena=10 AND status='o')[indeks]

-- ime i prezime:
((
	(ispit WHERE ocena=6 AND status='o')[indeks]
	INTERSECT
	(ispit WHERE ocena=10 AND status='o')[indeks]
) JOIN dosije[indeks, ime, preizme])[ime, prezime]

-- 16. Izdvojiti nazive svih ispitnih rokova u kojima je polagan predmet "Programiranje 1".

-- prvo skGodina i oznakaRoka
ispit[idPredmeta, skGodina, oznakaRoka]
JOIN
(predmet WHERE naziv='Programiranje 1')[idPredmeta]

-- naziv roka:
((
	ispit[idPredmeta, skGodina, oznakaRoka]
	JOIN
	(predmet WHERE naziv='Programiranje 1')[idPredmeta]
) JOIN ispitniRok[skGodina, oznakaRoka, naziv])[naziv]

-- 17.  Izlistati spisak identifikatora predmeta koji nose manje bodova od predmeta ciji identifikator je 2004.

(predmet
WHERE espb<(predmet WHERE idPredmeta=2004)[espb])[idPredmeta]

-------------------------------------------------------------------
-- Vezbanje:
-- 1. Prikazati nazive svih predmeta koje je polozio student Nikola Vukovic.
--Resenje:

(((dosije WHERE ime='Nikola' AND prezime='Vukovic')[indeks]
JOIN 
(ispit WHERE ocena>5 AND status='o')[indeks, idPredmeta])[idPredmeta]
JOIN predmet[idPredmeta, naziv])[naziv]

-- 2. Izdvojiti nazive svih predmeta koji su studenti rodeni u Beogradu polozili u Februaru 2015.
--Resenje:

((ispit WHERE ocena>5 AND stauts='o')[indeks, idPredmeta, skGodina, oznakRoka]
JOIN 
(ispitniRok WHERE naziv='Februar 2015')[skGodina, oznakaRoka]
JOIN
(dosije WHERE mestoRodjenja='Beograd')[indeks]
JOIN 
predmet[idPredmeta, naziv]
)[naziv]

-- 3. Prikazati imena i prezimena svih studenata koji su polozili najmanje
--    jedan ispit koji je polozio student sa indeksom 20140025.
--Resenje:

((ispit WHERE ocena>5 AND stauts='o')[indeks, idPredmeta]
JOIN 
(ispit WHERE indeks = 20140025 and ocena>5 AND status='o')[idPredmeta]
JOIN 
dosije[indeks, ime, preizme])[ime, prezime]

-- 4. Prikazati oznake i godine ispitnih rokova u kojima nijedan student iz
--    Kraljeva nije polozio nijedan predmet koji nosi 4 boda.
--Resenje:

ispitniRok[skGodina, oznakaRoka]
MINUS
(
    (dosije WHERE mestoRodjenja='Kraljevo')[indeks]
    JOIN
    (ispit WHERE ocena>5 AND status='o')[indeks, idPredmeta, skGodina, oznakRoka]
    JOIN
    (predmet WHERE espb=4)[idPredmeta]
)[skGodina, oznakaRoka]

-------------------------------------------------------------------------
--    http://www.matf.bg.ac.rs/p/files/1607987415-24-rbpVezbe102020.html 
--    [instructions at the bottom of the page]
