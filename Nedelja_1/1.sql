--	SELECT <lista imena kolona>
--	FROM <tabela>
--	WHERE <uslov>


-- 1. Izdvojiti sve informacije o postojecim studenitma.
db2 "select indeks, idprograma, ime, prezime, pol, mestorodjenja, idstatusa, datupisa, datdiplomiranja from da.dosije"
db2 "select * from da.dosije"

-- 2. Izdvojiti brojeve indeksa studenata koji su polagali neki ispit
--2020 jan1 |20170004| 1594 s ..
--2019 jun1 |20170004| 1595 o ..
--2020 sep2 |20180014| 1600 o ..

db2 "select indeks from da.ispit"

-- 3. Izdvojiti razlicite brojeve indeksa studenata koji su polagali neki ispit.
db2 "select distinct indeks from da.ispit"

-- 4. Izdvojiti listu parova oznaka roka, ocena za sva polaganja bez ponavljanja.
db2 "select distinct OznakaRoka, Ocena from da.ispit"

-- 5.  Izdvojiti brojeve indeksa i prezimena studenata koji se zovu 'Nikola' ili su rodeni u Beogradu
db2 "select indeks, prezime from da.dosije where ime='Nikola' or mestorodjenja='Beograd'"

-- 6. Izdvojiti id-jeve predmeta koji nose bar 6 bodova.
db2 "select id from da.predmet where espb>=6"

-- 7. Izdvojiti sva uspesna polaganja ispita u Septembru 4 2019. godine.
db2 "select * from da.ispit where ocena>5 and oznakaroka='sep4' and skgodina=2019"

-- 8. Izdvojiti za svako uspesno polaganje indeks, ocenu i ocenu sracunatu preko 
-- bodova sa ispita, kao prvi veci ceo broj od celobrojnog deljenja broja bodova sa 10.

-- 91-->10
-- 90-->9

db2 "select indeks, ocena, (poeni-1)/10+1 from da.ispit where ocena>5"

SELECT indeks,ocena,(poeni-1)/10+1
FROM da.ispit
WHERE ocena>5;

-- 9. Izdvojiti brojeve indeksa i datum upisa studenata sa indeksom vecim od 20140000, uredene opadajuce prema datumu upisa.
db2 "select indeks, datUpisa from da.dosije where indeks>20140000 order by datUpisa desc"
db2 "select indeks, datUpisa from da.dosije where indeks>20140000 order by 2 desc"

-- 10. Izdvojiti sva polaganja ispita sa ocenom 8, uredena prema datumu ispita opadajuce, a zatim prema broju indeksa rastuce
db2 "select indeks, ocena from da.ispit where ocena=8 and status='o' order by datpolaganja desc, indeks asc"

-- 11. Izdvojiti nazive predmeta koji nose izmedu 4 i 6 bodova, ukljucujuci obe granice.
db2 "select naziv from da.predmet where espb>=4 and espb<=6"
db2 "select naziv from da.predmet where espb between 4 and 6" 

-- 12. Izdvojiti nazive predmeta koji ne nose izmedu 4 i 6 bodova.
db2 "select naziv from da.predmet where espb<4 or espb>6"
db2 "select naziv from da.predmet where espb not between 4 and 6"

-- 13. Izdvojiti identifikatore predmeta za koje postoji polaganje na kom je neki student dobio neparnu ocenu.
db2 "select idpredmeta from da.ispit where ocena in (5,7,9)" 

-- 14. Izdvojiti indekse studenata koji nisu dobili parnu ocenu na nekom ispitu.
-- ocena not in, not (ocena in)

-- 15. Izdvojiti nazive predmeta koji u svom imenu imaju slovo 'a'.
db2 "select naziv from da.predmet where naziv like '%a%'"

-- 16. Izdvojiti nazive predmeta ciji se naziv zavrsava slovom 'a'.
db2 "select naziv from da.predmet where naziv like '%a'"

-- 17. Izdvojiti imena i prezimena studenata cije je ime duze od 5 karaktera, a pocinje slovom 'M'.
db2 "select ime, prezime from da.dosije where ime like 'M_____%'"

-- 18. Izdvojiti razlicite nazive predmeta koji u svom nazivu imaju kao drugo slovo '%', a pretposlednje '\'.
db2 "select naziv from da.predmet where naziv like '_\%%\\_'"
db2 "select naziv from da.predmet where naziv like '_&%%\_' escape '&' "

--19.Izdvojiti indekse, imena i prezimena studenata ciji datum diplomiranja nije poznat.
db2 "select indeks,ime,prezime from da.dosije where datDiplomiranja is null"

--20.Izdvojiti imena i prezimena studenata koji nisu rodjeni u Kraljevu.
db2 "select ime,prezime from da.dosije where mestoRodjenja<>'Kraljevo'"
