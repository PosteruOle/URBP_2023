--Januar 1 2022/2023
--1. Napisati upit u SQL-u kojim se za studente osnovni akademskih studija, studijskog programa matematika, 
--koji su u poslednje 4 godine položili predmet od barem 6 espb sa ocenom 9 ili 10 izdvajaju: ime, prezime 
--i poslednje dve cifre godine rođenja u obliku ime_prezime_BB (računati da su studenti sa 19 godina upisali 
--Matematički fakultet), prvo slovo naziva studijskog programa spojeno sa brojem koji predstavlja odgovarajući 
--nivo studija, mesto rodjenja tih studenata (u slučaju studenata rođenih u Valjevu prikazati NULL vrednost) i datum 
--diplomiranja tih studenata ili najkasniji mogući datum diplomiranja (koji dobijamo kada na datum upisa studenta dodamo 
--dvostruku dužinu trajanja odgovarajućih studija) ukoliko student nije diplomirao. Rezultat upita urediti opadajuće po indeksu. 

--Resenje:
SELECT d.ime || ‘_’ || d.prezime || ‘_’ || CHAR((indeks/10000-19)%100), ‘M1’, NULLIF(mestoRodjenja, ‘Valjevo’), COALESCE(datDiplomiranja, datUpisa + 8 YEARS)
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
WHERE nk.naziv='Osnovne akademske studije' AND sp.naziv='Matematika' 
    AND EXISTS(SELECT * 
               FROM da.ispit i JOIN da.predmet p ON i.idPredmeta=p.id 
               WHERE i.indeks=d.indeks AND p.espb>=6 AND i.ocena IN (9,10) AND datPolaganja<datUpisa+4 YEARS)            	 
ORDER BY indeks DESC;

--Januar 2 2022/2023
--1. Izdvojiti informacije o uspesnim polaganjima studenata osnovnih akademskih studija matematike 
--kod kojih je naziv predmeta duzi od naziva ispitnog roka u kome je taj predmet polozen (ne racunajuci 
--eventualne beline na pocetku odnosno kraju bilo naziva roka, bilo naziva predmeta). 

--Informacije izdvojiti samo za studente sa statusom 'Na razmeni', 'Stare studije', 'Neupusan' ili koji imaju priznatih bar 5 ispita.

--Izdvojiti i indeks, ime i prezime studenta u formatu 'Ime razmak prezime' (kolonu nazvati potpis), naziv njegovog statusa, 
--nazive predmeta odnosno ispitnog roka, kao i dobijenu ocenu.

--Upit urediti po punom potpisu opadajuce, zatim po oceni rastuce.

--Resenje:
SELECT d.indeks, d.ime || ' ' || d.prezime AS "Potpis", ss.naziv, p.naziv, ir.naziv, i.ocena
FROM da.dosije d JOIN da.studijskiProgram sp ON d.idPrograma=sp.id
			     JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
			     JOIN da.ispit i ON d.indeks=i.indeks
			     JOIN da.ispitniRok ir ON i.skGodina=ir.skGodina AND i.oznakaRoka=ir.oznakaRoka
			     JOIN da.predmet p ON i.idPredmeta=p.id
			     JOIN da.studentskiStatus ss ON d.idStatusa=ss.id
WHERE sp.naziv='Matematika' AND nk.naziv='Osnovne akademske studije' AND i.ocena>5 AND i.status='o'
            AND LENGTH(TRIM(p.naziv))>=LENGTH(TRIM(ir.naziv))
            AND (ss.naziv IN ('Na razmeni', 'Stare studije', 'Neupisan')
            OR (SELECT COUNT(*) FROM da.priznatIspit WHERE indeks=d.indeks)>5)
ORDER BY 2 DESC, 6 ASC;

-- Januar 2 2023/2024
--1. Za potrebe selekcije studenata koji bi u narednoj školskoj godini bili angažovani kao saradnici u nastavi na Matematičkom fakultetu
--potrebno je napisati SQL upit kojim  bi se izdvojilo 10 najboljih kandidata. Potrebno je izdvojiti studente osnovnih akademskih studija 
--studijskih programa matematika ili informatika koji još uvek nisu diplomirali, čiji je prosek veći ili jednak od 8.5 i koji su osvojili 
--barem 180 ESPB. Kao prvu kolonu potrebno je izdvojiti ime i prezime studenta u formatu ime RAZMAK prezime i tu kolonu je potrebno 
--nazvati “KANDIDAT”. Kao drugu kolonu potrebno je izdvojiti potencijalni nastavnički mejl kandidata u formatu ime.prezime@poincare.matf.bg.ac.rs 
--i tu kolonu je potrebno nazvati “NASTAVNICKI_MEJL”. U preostale tri kolone bi trebalo da se nalazi prosek kandidata zaokružen na dve decimale, 
--ukupan broj osvojenih ESPB i broj godina studiranja (razlika trenutne godine i godine upisa). Upit je potrebno urediti po prosečnoj oceni opadajuće,
--zatim po broju osvojenih ESPB opadajuće i na kraju prema broju godina studiranja rastuće. Na kraju, kao što je već rečeno, potrebno je 
--izdvojiti samo prvih 10 rezultata upita.

--Rešenje:
SELECT TRIM(ime || ' ' || prezime) as "KANDIDAT", ime || '.' || prezime || '@poincare.matf.bg.ac.rs' AS "NASTAVNICKI_MEJL", 
       SUM(CASE
       		   WHEN i.ocena>5 AND status='o' THEN p.espb
       		   ELSE 0 
           END) "UKUPNO_ESPB", DECIMAL(AVG(CASE 
                                   	           WHEN ocena>5 AND status='o' THEN ocena+0.0
                                   	           ELSE NULL
                                           END), 5, 2) as "PROSEK", YEAR(CURRENT_DATE)-YEAR(d.datUpisa) 
FROM da.dosije d JOIN da.ispit i ON d.indeks=i.indeks JOIN da.predmet p ON i.idPredmeta=p.id
                 JOIN da.studijskiprogram sp ON d.idPrograma=sp.id JOIN da.nivoKvalifikacije nk ON sp.idNivoa=nk.id
WHERE nk.naziv='Osnovne akademske studije' AND sp.naziv IN ('Matematika', 'Informatika') AND (d.datDiplomiranja IS NULL)
GROUP BY d.indeks, TRIM(ime || ' ' || prezime), ime || '.' || prezime || '@poincare.matf.bg.ac.rs', YEAR(CURRENT_DATE)-YEAR(d.datUpisa)
HAVING  SUM(CASE
       		    WHEN i.ocena>5 AND status='o' THEN p.espb
       		    ELSE 0 
            END) BETWEEN 180 AND 240 AND AVG(CASE 
                                   	             WHEN ocena>5 AND status='o' THEN ocena+0.0
                                   	             ELSE NULL
                                             END) >=8.5
ORDER BY 4 DESC, 3 DESC, 5 ASC
LIMIT 10;

-- Januar 2 2023/2024
--4. Napisati upit u relacionoj algebri i relacionom računu  kojim se izdvajaju školske godine i oznake ispitnih rokova 
--u kojima ni jedan student iz Beograda nije položio predmet od barem 5 ESPB sa ocenom 10.

--Rešenje:

--Relacioni račun:

RANGE OF irx IS ispitnirok
RANGE OF ix IS ispit
RANGE OF dx IS dosije
RANGE OF px IS predmet

irx.skGodina, irx.oznakaRoka
WHERE NOT EXISTS ix(
      ix.oznakaRoka=irx.oznakaRoka AND ix.skGodina=irx.skGodina AND ix.ocena=10 AND    
      ix.status=’o’ AND EXISTS dx(ix.indeks=dx.indeks AND     dx..mestoRodjenja=’Beograd%’) 
      AND EXISTS px(ix.idPredmeta=px.idPredmeta AND px.espb>=5)
)

--Relaciona algebra:

ispitnirok[skGodina, oznakaRoka]
MINUS 
((dosije WHERE mestorodjenja=’Beograd’)[indeks]
JOIN
(ispit WHERE ocena=10 AND status=’o’)[indeks, idPredmeta, skGodina, oznakaRoka]
 JOIN 
(predmet WHERE espb>=5)[idPredmeta])[skGodina, oznakaRoka]


