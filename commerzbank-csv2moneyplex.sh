#!/bin/bash


#
# CSV -> MoneyPlex-CSV
#


#------------------------------------------------------------------------------#
### Eingabeüberprüfung
if [ -z "${1}" ] ; then
	echo "${0} Kreditkartenabrechnung_der_Commerzbank.csv"
	exit 1
fi


#==============================================================================#
### CSV für MoneyPlex umsortieren

#------------------------------------------------------------------------------#
### Kategorie-Schalter: DB -> Fahrtkosten

while [ "${#}" -ne "0" ]; do
        case "${1}" in
                -k)
                        KATEGORIE_PARAMETER="${2}"
                        shift
                        shift
                        ;;
                -h)
                        echo "
                        HILFE:
                        ${0} -k [Kategorie_alt/Kategorie_neu]
                        ${0} -k DB/Fahrtkosten
                        "
                        exit 1
                        ;;
                *)
                        CSVDATEI="${1}"
                        shift
                        ;;
        esac
done

KATEGORIE_ALT="$(echo "${KATEGORIE_PARAMETER}" | awk -F'/' '{print $1}')"
KATEGORIE_NEU="$(echo "${KATEGORIE_PARAMETER}" | awk -F'/' '{print $2}')"
NEUERNAME="$(echo "${CSVDATEI}" | sed 's/[( )][( )]*/_/g' | rev | sed 's/.*[.]//' | rev)"

### nur für Tests
#echo "
#CSVDATEI='${CSVDATEI}'
#KATEGORIE_PARAMETER='${KATEGORIE_PARAMETER}'
#KATEGORIE_ALT='${KATEGORIE_ALT}'
#KATEGORIE_NEU='${KATEGORIE_NEU}'
#"
#------------------------------------------------------------------------------#


### MoneyPlex - Import-Format (Fehlerhaft)
#(echo '"Saldo";"SdoWaehr";"AgBlz";"AgKto";"AgName1";"Storno";"OrigBtg";"Betrag";"BtgWaehr";"OCMTBetr";"OCMTWaehr";"Textschl";"VWZ1";"VWZ2";"VWZ3";"VWZ4";"VWZ5";"VWZ6";"VWZ7";"VWZ8";"VWZ9";"VWZ10";"VWZ11";"VWZ12";"VWZ13";"VWZ14";"BuchDatum";"WertDatum";"Primanota";"Kategorie";"Unterkat";"Kostenst"';
#cat "${CSVDATEI}" | grep -Ev '^Bahnkart;' | grep -Ev '^$' | while read ZEILE
#do
#	if [ -n "${KATEGORIE_PARAMETER}" ] ; then
#		echo "${ZEILE}" | sed "s/^${KATEGORIE_ALT};/${KATEGORIE_NEU};/" | tee -a /tmp/test.csv
#	else
#		echo "${ZEILE}"
#	fi
#done | awk -F';' '{ print ";;;;"$3";;"$9";"$9";EUR;"$5";"$6";"$7";"$4";;;;;;;;;;;;;;"$8";"$2";;"$1";;"$10";" }') > ${NEUERNAME}_moneyplex.csv


### VR-NetWorld - Export-Format (http://wiki.matrica.com/index.php/Daten%C3%BCbernahme)
(echo 'Datum;Valuta;Zahlungspflichtiger/-empfänger;ZP/ZEKonto/IBAN;ZP/ZEBankleitzahl/BIC;Verwendungszweck;Kategorie;Betrag;Währung';
cat "${CSVDATEI}" | grep -Ev '^Bahnkart;' | grep -Ev '^$' | while read ZEILE
do
	if [ -n "${KATEGORIE_PARAMETER}" ] ; then
		echo "${ZEILE}" | sed "s/^${KATEGORIE_ALT};/${KATEGORIE_NEU};/" | tee -a /tmp/test.csv
	else
		echo "${ZEILE}"
	fi
done | awk -F';' '{ print $2";"$8";"$3,$4";;;"$5,$6,$7";"$1";"$9";EUR" }') > ${NEUERNAME}_moneyplex.csv

# Datum ; Valuta ; Zahlungspflichtiger/-empfänger ; ZP/ZE Konto/IBAN ; ZP/ZE Bankleitzahl/BIC ; Verwendungszweck ; Kategorie ; Betrag ; Währung
#
# 01 - Bahnkart		# Kategorie
# 02 - Umsatzdatum	# Datum
# 03 - Unternehmen	# Zahlungspflichtiger/-empfänger
# 04 - Ort		# Zahlungspflichtiger/-empfänger
# 05 - Ausgabe		# Verwendungszweck
# 06 - Währung		# Verwendungszweck
# 07 - Kurs		# Verwendungszweck
# 08 - Buchungsdatum	# Valuta
# 09 - Betrag in EUR	# Betrag
# 10 - Guthaben		# 

ls -lh ${NEUERNAME}_moneyplex.csv

exit
#==============================================================================#
#
# "Saldo";"SdoWaehr";"AgBlz";"AgKto";"AgName1";"Storno";"OrigBtg";"Betrag";"BtgWaehr";"OCMTBetr";"OCMTWaehr";"Textschl";"VWZ1";"VWZ2";"VWZ3";"VWZ4";"VWZ5";"VWZ6";"VWZ7";"VWZ8";"VWZ9";"VWZ10";"VWZ11";"VWZ12";"VWZ13";"VWZ14";"BuchDatum";"WertDatum";"Primanota";"Kategorie";"Unterkat";"Kostenst"
#
# 63,39;"EUR";"";"";"TESTAUFTRAGGEBER";0;-26,93;-26,93;"EUR";-26,93;"EUR";5;"";"TESTZWECK";"";"";"";"";"";"";"";"";"";"";"";"";17.3.2004;17.3.2004;"9044";"";"";""
#
#  Spaltennummer  | MoneyPlex     | CSV-Spalte    | CSV-Spaltenname       | Beispiel
# ----------------+---------------+---------------+-----------------------+----------
#         01      | "Saldo"       |               |                       | 63,39
#         02      | "SdoWaehr"    |               |                       | EUR
#         03      | "AgBlz"       |               |                       | 
#         04      | "AgKto"       |               |                       | 
#         05      | "AgName1"     |       03      |       Unternehmen     | TESTAUFTRAGGEBER
#         06      | "Storno"      |               |                       | 0
#         07      | "OrigBtg"     |       09      |       Betrag          | -26,93
#         08      | "Betrag"      |       09      |       Betrag          | -26,93
#         09      | "BtgWaehr"    |               |       EUR             | EUR
#         10      | "OCMTBetr"    |       05      |       Ausgabe         | -26,93
#         11      | "OCMTWaehr"   |       06      |       Währung         | EUR
#         12      | "Textschl"    |       07      |       Kurs            | 5
#         13      | "VWZ1"        |       04      |       Ort             | 
#         14      | "VWZ2"        |               |                       | TESTZWECK
#         15      | "VWZ3"        |               |                       | 
#         16      | "VWZ4"        |               |                       | 
#         17      | "VWZ5"        |               |                       | 
#         18      | "VWZ6"        |               |                       | 
#         19      | "VWZ7"        |               |                       | 
#         20      | "VWZ8"        |               |                       | 
#         21      | "VWZ9"        |               |                       | 
#         22      | "VWZ10"       |               |                       | 
#         23      | "VWZ11"       |               |                       | 
#         24      | "VWZ12"       |               |                       | 
#         25      | "VWZ13"       |               |                       | 
#         26      | "VWZ14"       |               |                       | 
#         27      | "BuchDatum"   |       08      |       Buchungsdatum   | 17.3.2004
#         28      | "WertDatum"   |       02      |       Umsatzdatum     | 17.3.2004
#         29      | "Primanota"   |               |                       | 9044
#         30      | "Kategorie"   |       01      |       Bahnkart        | 
#         31      | "Unterkat"    |               |                       | 
#         32      | "Kostenst"    |       10      |       Guthaben        | 
#
#
#
# Spalten auf der Kreditkartenabrechnung der Commerzbank:
#
# 01 - Bahnkart
# 02 - Umsatzdatum
# 03 - Unternehmen
# 04 - Ort
# 05 - Ausgabe
# 06 - Währung
# 07 - Kurs
# 08 - Buchungsdatum
# 09 - Betrag in EUR
# 10 - Guthaben
