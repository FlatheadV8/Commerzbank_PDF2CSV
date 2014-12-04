Commerzbank_PDF2CSV
===================

Mit diesem Skript kann man Kreditkartenabrechnung der Commerzbank in eine CSV-Datei umwandeln.

Die Umwandlung dieser PDF-Dateien ist besonders schwierig, weil die Kreditkartenabrechnung der Commerzbank wie Tabellen aussehen, leider vom internen Kode her aber nicht sind.
Die Informationen im Dokument werden alle völlig frei auf der Seite positioniert, wie zum Beispiel Statistische Werte in einem Diagramm. Erschwerend kommt hier noch hinzu, dass die Angaben, die offensichtlich in der selben Zeile stehen, aber in der Höhe leicht versetzt sein können. Wenn zum Beispiel das Umsatzdatum (ganz links) 626 Bildpunkte vom oberen Rand entfernt steht, kann es sein, dass der Betrag (ganz rechts) 629 Bildpunkte vom oberen Rand entfernt steht. Somit kommt es schon einer Raterei nahe, wenn man hier feststellen will, was alles in eine Zeile gehört.

Weiter gibt es mit dieserm PDF-Format noch eine Koriose Eigenart, die mir einiges Kopfzerbrechen bereitet hat.

Gewöhnlich habe ich PDF-Dateien immer auf die folgende Weise in Text-Dateien umgewandelt:

    pdf2ps Datei.pdf Datei.ps
    ps2ascii Datei.ps Datei.txt

Das funktioniert zum Beispiel bei Kontoaszügen der der Postbank prima, hier endet alles in unleserliche Zeichen wie diese hier:

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

Am 26. Juli 2007 hat sich darüber bereits jemand bei GhostScript beschwert (siehe http://bugs.ghostscript.com/show_bug.cgi?id=689107#c13), leider ohne Erfolg:

Der Bug-Report wurde trotzdem mit der folgenden Bemerkung geschlossen:

    ...
    The \Delta, \Lambda, etc. strings mentioned in comment #13 continue in the 
    output, but these are non-ascii characters and it's not clear what Ghostscript 
    should be doing for these cases.
    ...
Komisch nur, dass diese Zeichen, bei der Umwandlung ins HTML-Format ordentlich übersetzt werden können, aber ins TXT-Format nicht...

Beim wahllosen rumprobieren habe ich rein zufällig herausgefunden, dass die Buchungseinträge beim übersetzen in das HTML- und XML-Format lesbar bleiben.  ;-)

Leider habe ich bis jetzt immer noch kein geeignetes Werkzeug gefunden, welches die Positionsangaben beim umwandeln aus dem HTML- bzw. XML-Format ind TXT-Format beibehält.
Deshalb muss ich diesen Part selber schreiben.


Stand 2014-12-04 (Version 0.1.0)
--------------------------------
Bis jetzt kann das Skript nur Angaben in ein und der selben Zeile angeben, bei denen der Abstand vom oberen Rand exakt die gleiche Anzahl von Bildpunkten beträgt.
Somit werden zur Zeit noch die Daten aus dem oben genannten Beispiel in zwei untereinander stehenden separaten Zeilen in der CSV-Datei dargestellt.

Auch kann das Skript noch keine Spalten eindeutig erkennen.
Zur Zeit werden die Angaben in einer Zeile in der richtigen Reihenfolge hintereinander in der selben Zeile angegeben, müssen aber nicht in der richtigen Spalte stehen, da zur Zeit noch nur belegte Spalten als Spalten erkannt werden.
