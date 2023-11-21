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
