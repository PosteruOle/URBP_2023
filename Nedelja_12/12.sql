Relacioni racun

RANGE OF <ime-promenljive> IS <ime- relacije>

--Izraz rel racuna ntorki
{(t1, t2,..., tk) : f }
  ciljna lista      kvalifikacioni izraz

t1,t2,...,tk WHERE f

t[i] -> t.kolona

X1.A1, X2.A2, . . . , Xk.Ak WHERE f


-- 1. Izdvojiti naziv i broj espb bodova za sve predmete koji se predaju na fakultetu (Projekcija).
--Resenje:

RANGE OF px IS predmet
px.naziv, px.espb

-- 2. Izdvojiti sve detalje o studentima rodenim u Beogradu (Savski Venac)  (Restrikcija).
--Resenje:

RANGE OF dx IS dosije
dx.indeks, dx.idPrograma, dx.ime, dx.prezime, dx.pol, dx.mestoRodjenja, dx.idStatusa, dx.datUpisa, dx.datDiplomiranja
WHERE dx.mestoRodjenja='Beograd (Savski Venac)'


-- 3. Prikazati detalje svih parova student ispit takvih da je student polagao taj ispit (Spajanje).
--Resenje:

RANGE OF dx IS dosije
RANGE OF ix is ispit
dx.indeks, dx.idPrograma, dx.ime, dx.prezime, dx.pol, dx.mestoRodjenja, dx.idStatusa, dx.datUpisa, dx.datDiplomiranja, ix.indeks, ix.idPredmeta, ix.skGodina, ix.oznakaRoka, ix.semestar, ix.status, ix.datPolaganja, ix.poeni, ix.ocena
WHERE ix.indeks=dx.indeks

-- 4. Izdvojiti oznake predmeta koji nose 3 ili 6 espb bodova.
--Resenje:

RANGE OF px IS predmet
px.oznaka
WHERE px.espb=3 OR px.espb=6

-- 5. Prikazati ime i prezime studenta koji je polagao predmet ciji identifikator je 2001.
--Resenje:

RANGE OF dx IS dosije
RANGE OF ix IS ispit
dx.ime, dx.prezime
WHERE EXISTS ix(ix.indeks=dx.indeks AND ix.idPredmeta=2001)


-- 6. Izdvojiti brojeve indeksa studenata koji su polagali sve predmete.
--Resenje:

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
dx.indeks
WHERE FORALL px(EXISTS ix(ix.indeks=dx.indeks AND ix.idPredmeta=px.idPredmeta))


--Vx(p) <-> !Ex(!p)

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
dx.indeks
WHERE NOT EXISTS px(NOT EXISTS ix(ix.indeks=dx.indeks AND ix.idPredmeta=px.idPredmeta))

-- 7. Prikazati ime i prezime studenta koji je polozio najmanje 1 predmet koji nosi 6 bodova.
--Resenje 1:

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
dx.ime, dx.prezime
WHERE EXISTS ix(ix.indeks=dx.indeks AND ix.ocena>5 AND ix.status='o' AND EXISTS px(px.idPredmeta=ix.idPredmeta AND px.espb=6))

--Resenje 2:
RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
dx.ime, dx.prezime
WHERE EXISTS px(px.espb=6 AND EXISTS ix(ix.indeks=dx.indeks AND ix.ocena>5 AND ix.status='o' AND ix.idPredmeta=px.idPredmeta))


-- 8. Prikazati brojeve indeksa studenta koji su polozili bar one razlicite predmete koje je polagao student sa brojem indeksa 20130023.

--RANGE OF dx IS dosije
--RANGE OF ix IS ispit
--RANGE OF iy IS ispit
--dx.indeks
--WHERE FORALL ix(IF ix.indeks=20130023
--			      THEN EXISTS iy(iy.indeks=dx.indeks AND iy.idPredmeta=ix.idPredmeta AND iy.ocena>5 AND iy.status='o'))

-- p=>q 	<->	 !p || q

--Resenje 1:

RANGE OF dx IS dosije
RANGE OF ix IS ispit
RANGE OF iy IS ispit
dx.indeks
WHERE FORALL ix(ix.indeks<>20130023
			      OR EXISTS iy(iy.indeks=dx.indeks AND iy.idPredmeta=ix.idPredmeta AND iy.ocena>5 AND iy.status='o'))

--Vx(p) <-> !Ex(!p)
--!(p || q) <-> (!p & !q)

--Resenje 2:

RANGE OF dx IS dosije
RANGE OF ix IS ispit
RANGE OF iy IS ispit
dx.indeks
WHERE NOT EXISTS ix(ix.indeks=20130023
			            AND NOT EXISTS iy(iy.indeks=dx.indeks AND iy.idPredmeta=ix.idPredmeta AND iy.ocena>5 AND iy.status='o'))

-- 9. Izdvojiti nazive svih predmeta koje su polozili svi studenti koji su upisali fakultet 2013. godine.

--RANGE OF dx IS dosije
--RANGE OF px IS predmet
--RANGE OF ix IS ispit
--px.naziv
--WHERE FORALL dx(IF dx.indeks>20130000 AND dx.indeks<20140000
--      	     	   	       THEN EXISTS ix(ix.indeks=dx.indeks AND ix.idPredmeta=px.idPredmeta AND ix.ocena>5 AND ix.status='o'))

-- p=>q 	<->	 !p || q

--Resenje:

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
px.naziv
WHERE FORALL dx(dx.indeks<20130000 OR dx.indeks>20140000
      	     	   	       OR EXISTS ix(ix.indeks=dx.indeks AND ix.idPredmeta=px.idPredmeta AND ix.ocena>5 AND ix.status='o'))

--Vx(p) <-> !Ex(!p)

--Resenje:

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
px.naziv
WHERE NOT EXISTS dx(dx.indeks>20130000 AND dx.indeks<20140000
      	     	   	       AND NOT EXISTS ix(ix.indeks=dx.indeks AND ix.idPredmeta=px.idPredmeta AND ix.ocena>5 AND ix.status='o'))

-- 10. Izdvojiti ime i prezime za svakog od studenata koji nisu polagali predmet ciji identifikator je 1021.
--Resenje:

RANGE OF dx IS dosije
RANGE OF ix IS ispit
dx.ime, dx.prezime
WHERE NOT EXISTS ix(ix.indeks=dx.indeks AND ix.idPredmeta=1021)


-- 11. Prikazati oznake svih predmeta koji nose 6 espb bodova ili ih je neko polozio u roku Januar 2015.
--Resenje:

RANGE OF px IS predmet
RANGE OF ix IS ispit
px.oznaka
WHERE px.espb=6 OR EXISTS ix(ix.idPredmeta=px.idPredmeta AND ix.skGodina=2015
				 AND ix.oznakaRoka='jan' AND ix.ocena>5 AND ix.status='o')

-- 12. Izdvojiti nazive svih ispitnih rokova u kojima je polagan predmet "Programiranje 1".
--Resenje:

RANGE OF px IS predmet
RANGE OF ix IS ispit
RANGE OF irx IS ispitniRok
irx.naziv
WHERE EXISTS ix(ix.skGodina=irx.skGodina AND ix.oznakaRoka=irx.oznakaRoka 
			AND EXISTS px(px.idPredmeta=ix.idPredmeta AND px.naziv='Programiranje 1'))

-- 13. Izlistati spisak identifikatora predmeta koji nose manje bodova od predmeta ciji identifikator je 2004.
--Resenje:

RANGE OF px IS predmet
RANGE OF py IS predmet
px.idPredmeta
WHERE EXISTS py(py.idPredmeta=2004 AND px.espb<py.espb)

-- 14. Prikazati imena i prezimena studenata koji imaju polozen neki ispit sa ocenom 6, i neki drugi polozen sa ocenom 10.
--Resenje:

RANGE OF dx IS dosije
RANGE OF ix IS ispit
dx.ime, dx.prezime
WHERE EXISTS ix(ix.indeks=dx.indeks AND ix.ocena=6 AND ix.status='o') AND
      	     EXISTS ix(ix.indeks=dx.indeks AND ix.ocena=10 AND ix.status='o') 

------------------
--Dodatni zadatak sa casa
RANGE OF dx IS dosije
RANGE OF ix IS ispit
RANGE OF iy IS ispit
dx.ime, dx.prezime
WHERE EXISTS ix(ix.indeks=dx.indeks AND ix.ocena=6 AND ix.status='o' 
      	     AND NOT EXISTS iy(iy.indeks=dx.indeks AND iy.ocena=6 AND iy.status='o' AND iy.idPredmeta<>ix.idPredmeta))
----------------------------------
--Vezba:

-- 15. Prikazati nazive svih predmeta koje je polozio student Nikola Vukovic.
--Resenje:

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
px.naziv
WHERE EXISTS ix(ix.idPredmeta=px.idPredmeta AND ix.ocena>5 AND ix.status='o' 
			AND EXISTS dx(dx.indeks=ix.indeks AND dx.ime='Nikola' AND dx.prezime='Vukovic' ))

-- 16. Napraviti spisak parova brojeva indeksa studenata takvih da su oba rodena u istom gradu.
--Resenje:

RANGE OF dx IS dosije
RANGE OF dy IS dosije
dx.indeks, dy.indeks
WHERE dx.mestoRodjenja=dy.mestoRodjenja AND dx.indeks<dy.indeks

-- 17. Izdvojiti nazive svih predmeta koji su studenti rodeni u Beogradu polozili u januaru 2015.
--Resenje:

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
RANGE OF irx IS isptiniRok
px.naziv
WHERE EXISTS ix(ix.idPredmeta=px.idPredmeta AND ix.ocena>5 AND ix.status='o' AND
      	     	EXISTS dx(dx.indeks=ix.indeks AND dx.mestoRodjenja='Beograd') AND
			    EXISTS irx(irx.skGodina=ir.skGodina AND irx.oznakaRoka=ix.oznakaRoka AND irx.naziv='Januar 2015'))

-- 18. Prikazati imena i prezimena svih studenata koji su polozili najmanje jedan ispit koji je polozio student sa indeksom 20140025.
--Resenje:

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
dx.ime, dx.prezime
WHERE EXISTS px(EXISTS ix(ix.indeks=20140025 AND ix.idPredmeta=px.idPredmeta AND ix.ocena>5 AND ix.status='o')
      	     	AND EXISTS ix(ix.indeks=dx.indeks AND ix.idPredmeta=px.idPredmeta AND ix.ocena>5 AND ix.status='o'))

-- 19. Prikazati oznake i godine ispitnih rokova u kojima nijedan student iz Kraljeva nije polozio nijedan predmet koji nosi 4 bodova.
--Resenje:

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
RANGE OF irx IS ispitniRok
irx.skGodina, irx.oznakaRoka
WHERE NOT EXISTS dx(dx.mestoRodjenja='Kraljevo' 
    AND EXISTS ix(ix.indeks=dx.indeks AND ix.skGodina=irx.skGodina AND ix.oznakaRoka=irx.oznakaRoka AND ix.ocena>5 AND ix.status='o' 
    AND EXISTS px(px.idPredmeta=ix.idPredmeta AND px.espb=4)))