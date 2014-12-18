Commerzbank_PDF2CSV
===================

Hiermit kann man Kreditkartenabrechnungen der Commerzbank in CSV-Dateien umwandeln.
Die CSV-Datei kann man dann in einer Tabellen-Calkulation aufbereiten,
um zum Beispiel die Steuererklärung einfacher erledigen zu können.

Allerdings kann man hiermit auch eine QIF-Datei, für den Import in andere
Kontoverwaltungs-Programme (z.B. GnuCache), erzeugen.

Es kann auch eine spezielle CSV-Datei für den Import in MoneyPlex (Importfilter: "CSV-Import Geldtipps Homebanking") generiert werden.

--------------------------------------------------------------------------------

Um diese Skripte nutzen zu können, reicht es nicht das Paket "ghostscript" zu installieren, hierfür müssen auch die Pakete "pstotext" und "poppler-utils" noch installiert werden!

--------------------------------------------------------------------------------

Schritt-für-Schritt-Abfolge, wie die CSV-Datei erstellt wird:
-------------------------------------------------------------
    
    > wget https://github.com/FlatheadV8/Commerzbank_PDF2CSV/archive/v1.2.2.tar.gz
    
    > tar xzf v1.2.2.tar.gz
    
    > chmod 0755 Commerzbank_PDF2CSV-1.2.2/*.sh
    
    > find Commerzbank_PDF2CSV-1.2.2/
    Commerzbank_PDF2CSV-1.2.2/
    Commerzbank_PDF2CSV-1.2.2/commerzbank-pdf2csv.sh
    Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2qif.sh
    Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2moneyplex.sh
    Commerzbank_PDF2CSV-1.2.2/README.md
    
    > cp ../????/Commerzbank/Kreditkartenabrechnung-2014-04-09.pdf .
    
    > ls -lha Kreditkartenabrechnung-2014-04-09.pdf
    -rw-r--r-- 1 ich ich 142K Dez 12 13:51 Kreditkartenabrechnung-2014-04-09.pdf
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-pdf2csv.sh Kreditkartenabrechnung-2014-04-09.pdf
    
    das kann jetzt ein paar Minuten dauern ...
    
    -rw-r--r-- 1 ich ich 5,5K Dez 13 23:31 Kreditkartenabrechnung-2014-04-09.csv
    
    libreoffice --calc Kreditkartenabrechnung-2014-04-09.csv


wie aus der CSV-Datei die QIF-Datei gemacht wird:
-------------------------------------------------
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2qif.sh Kreditkartenabrechnung-2014-04-09.csv
    -rw-r--r-- 1 ich ich 6,7K Dez 13 23:32 Kreditkartenabrechnung-2014-04-09.qif

oder (auf der Originalabrechnung stehen immer nur Tag+Monat aber kein Jahr, so wird das geändert)
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2qif.sh -j 2014 Kreditkartenabrechnung-2014-04-09.csv
    -rw-r--r-- 1 ich ich 6,7K Dez 13 23:33 Kreditkartenabrechnung-2014-04-09.qif

oder (die Zusatz "DB" für die Bahnkart-Abrechnungen können auch beliebig umbenannt werden, z.B. in "Fahrtkosten")
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2qif.sh -k DB/Fahrtkosten Kreditkartenabrechnung-2014-04-09.csv
    -rw-r--r-- 1 ich ich 7,4K Dez 13 23:33 Kreditkartenabrechnung-2014-04-09.qif

oder (die Kombination beider Parameter ist auch möglich)
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2qif.sh -j 2014 -k DB/Fahrtkosten Kreditkartenabrechnung-2014-04-09.csv
    -rw-r--r-- 1 ich ich 7,4K Dez 13 23:34 Kreditkartenabrechnung-2014-04-09.qif


wie aus der CSV-Datei die TXT-Datei gemacht wird:
-------------------------------------------------
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2moneyplex.sh Kreditkartenabrechnung-2014-04-09.csv
    -rw-r--r-- 1 ich ich 5,7K Dez 13 23:34 Kreditkartenabrechnung-2014-04-09_moneyplex.csv

oder (auf der Originalabrechnung stehen immer nur Tag+Monat aber kein Jahr, so wird das geändert)
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2moneyplex.sh -j 2014 Kreditkartenabrechnung-2014-04-09.csv
    -rw-r--r-- 1 ich ich 6,7K Dez 13 23:35 Kreditkartenabrechnung-2014-04-09_moneyplex.csv

oder (die Zusatz "DB" für die Bahnkart-Abrechnungen können auch beliebig umbenannt werden, z.B. in "Fahrtkosten")
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2moneyplex.sh -k DB/Fahrtkosten Kreditkartenabrechnung-2014-04-09.csv
    -rw-r--r-- 1 ich ich 6,4K Dez 13 23:35 Kreditkartenabrechnung-2014-04-09_moneyplex.csv

oder (die Kombination beider Parameter ist auch möglich)
    
    > Commerzbank_PDF2CSV-1.2.2/commerzbank-csv2moneyplex.sh -j 2014 -k DB/Fahrtkosten Kreditkartenabrechnung-2014-04-09.csv
    -rw-r--r-- 1 ich ich 7,4K Dez 13 23:36 Kreditkartenabrechnung-2014-04-09_moneyplex.csv


--------------------------------------------------------------------------------

Die Umwandlung dieser PDF-Dateien ist besonders schwierig, weil die Kreditkartenabrechnung der Commerzbank wie Tabellen aussehen, leider vom internen Kode her aber keine sind.
Die Informationen im Dokument werden alle völlig frei auf der Seite positioniert, wie zum Beispiel Statistische Werte in einem Diagramm.
Das ganze wird noch dadurch erschwert, dass die Angaben, die offensichtlich in der selben Zeile stehen, aber in der Höhe leicht versetzt sein können.
Wenn zum Beispiel das Umsatzdatum (ganz links) 626 Bildpunkte vom oberen Rand entfernt steht, kann es sein, dass der Betrag (ganz rechts) 629 Bildpunkte vom oberen Rand entfernt steht. Somit kommt es schon einer Raterei nahe, wenn man hier feststellen will, was alles in ein und die selbe Zeile gehört.

Ein weiteres Problem ist, das in der PDF-Datei die Zeilen und Spalten frei positioniert stehen, aus diesem Grund ist es auch erlaubt, dass die Zeilen und Spalten im Kode in einer beliebigen Reihenfolge vorliegen können und es auch tun.

Weiter gibt es mit dieserm PDF-Format noch eine Koriose Eigenart, die mir einiges Kopfzerbrechen bereitet hat.

Gewöhnlich habe ich PDF-Dateien immer auf die folgende Weise in Text-Dateien umgewandelt:

    pdf2ps Datei.pdf Datei.ps
    ps2ascii Datei.ps Datei.txt

Das funktioniert zum Beispiel bei Kontoauszügen der der Postbank prima, hier aber endet alles in einem unleserliche Zeichensalat:

    Kreditkarten-Service der Commerzbank AG,Postfach 110347, 60038 Frankfurt
    ...
    \Gamma \Delta  \Theta \Lambda \Upsilon ! \Gamma \Lambda  \Theta \Lambda o/*`'ffiffl`'"""AEo/\Psi fiaeo/\Phi !i\Sigma `AE\Upsilon ` \Delta ,O/\Theta
    \Gamma \Delta  \Theta \Lambda \Upsilon ! \Gamma \Lambda  \Theta \Lambda o/*`'ffiffl`'"""AEo/\Psi fiaeo/\Phi !i\Sigma `AE\Upsilon ` fl,_\Theta
    \Gamma \Delta  \Theta \Lambda \Upsilon ! \Gamma \Lambda  \Theta \Lambda i'ff`\Omega '`ff\Upsilon ! !\Pi ffl' \Pi ae'\Omega  _#oeoe`^ \Gamma \Theta ,**
    ...
    50 Euro Startguthaben und ein komfortabler Konto-Umzugsservice- das kostenlose Girokonto* der Commerzbank zahlt sich aus!Unser Angebot: Sie zahlen dauerhaft keine Kontogebu"hren und wir erledigen den gesamten Schriftverkehr fu"r Sie - kostenlos und schnell.
    ...
    Zahlungsempfa"nger:            Commerzbank AGBankverbindung:
    Commerzbank AGVerwendungszweck:
    So fu"llen Sie den U"berweisungstra"ger aus:
    IBAN:BIC:
    ...

Wo "\Gamma \Delta  \Theta \Lambda \Upsilon ..." steht, dort gehören die Kontodaten hin...

Am 26. Juli 2007 hat sich darüber bereits jemand bei GhostScript beschwert (siehe http://bugs.ghostscript.com/show_bug.cgi?id=689107#c13), leider ohne Erfolg:

Der Bug-Report wurde trotzdem mit der folgenden Bemerkung geschlossen:

    ...
    The \Delta, \Lambda, etc. strings mentioned in comment #13 continue in the 
    output, but these are non-ascii characters and it's not clear what Ghostscript 
    should be doing for these cases.
    ...

Komisch nur, dass diese Zeichen, bei der Umwandlung ins HTML-Format ordentlich übersetzt werden können, aber ins TXT-Format nicht...


Beim wahllosen rumprobieren, habe ich rein zufällig, herausgefunden, dass die Buchungseinträge beim übersetzen in das HTML- und XML-Format lesbar bleiben.  ;-)

Leider habe ich bis jetzt aber immer noch kein geeignetes Werkzeug gefunden, welches die Positionsangaben beim umwandeln aus dem HTML- bzw. XML-Format ins TXT-Format beibehält.

Deshalb muss ich diesen Part selber schreiben bzw. programmieren.


Zielsetzung, Voraussetzungen und Einschränkungen von diesem Skript
------------------------------------------------------------------
Da ich kein Konto bei der Commerzbank habe, muss ich die Funktionsweise dieses Skriptes auf Basis einer mir zur Verfühgung gestellten, dreiseitigen, Kreditkartenabrechnung der Commerzbank vom Sep. 2014 erarbeiten.

Dieses Skript hat zum Ziel, nur die Buchungsdaten aus dem PDF ins CSV-Format zu überführen.
Mangels markanter Zeichenfolden im extrahierten XML-Kode, werden die für mich offensichtlichen Stil-Elemente der Formatierung für die Selektive Auswahl von Kontodaten verwendet.
Diese sehen zur Zeit für mich wie Folgt aus:
- Alle Zeichenfolgen, die oberhalb von "H = Guthaben" stehen, sind keine Kontodaten.
- Kontodaten sind nie fett gedruckt.
- Unter den Kontodaten stehn weitere fett gedruckte Zeichenfolgen, unter denen wiederum keine Kontodaten mehr folgen.

Wenn sich eines dieser Elemente ändert, dann funktioniert das Skript nicht mehr!!!

Die größter Gefahr sehe ich in der Möglichkeit, dass im Bereich der Kontodaten etwas durch fettdruck hervorgehoben wird. In dem Fall würde ab dieser Hervorhebung die CSV-Datei enden und alle Kontodaten unterhalb der ersten Hervorhebung nicht in der CSV-Datei erscheinen.

Sollte soetwas vorkommen, dann teilen Sie es mir bitte mit. In dem Fall würde ich lieber Werbung mit in die CSV-Datei übernehmen als Kontodaten auszulassen.
