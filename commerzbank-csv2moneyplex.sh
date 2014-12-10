#!/bin/bash


#
# CSV -> MoneyPlex-CSV
#


#------------------------------------------------------------------------------#
### Eingabeüberprüfung
if [ -z "${1}" ] ; then
	echo "${0} Kreditkartenabrechnung_der_Commerzbank.csv"
	exit 1
else
	CSVDATEI="${1}"
	NEUERNAME="$(echo "${1}" | sed 's/[( )][( )]*/_/g' | rev | sed 's/.*[.]//' | rev)"
fi


#==============================================================================#
### CSV für MoneyPlex umsortieren

# echo '"Saldo";"SdoWaehr";"AgBlz";"AgKto";"AgName1";"Storno";"OrigBtg";"Betrag";"BtgWaehr";"OCMTBetr";"OCMTWaehr";"Textschl";"VWZ1";"VWZ2";"VWZ3";"VWZ4";"VWZ5";"VWZ6";"VWZ7";"VWZ8";"VWZ9";"VWZ10";"VWZ11";"VWZ12";"VWZ13";"VWZ14";"BuchDatum";"WertDatum";"Primanota";"Kategorie";"Unterkat";"Kostenst"';
cat "${CSVDATEI}" | grep -Ev '^Bahnkart;' | grep -Ev '^$' | awk -F';' '{ print ";;;;"$3";;"$9";"$9";;"$5";"$6";"$7";"$4";;;;;;;;;;;;;;"$8";"$2";;"$1";;"$10";" }' > ${NEUERNAME}_moneyplex.txt

ls -lh ${NEUERNAME}_moneyplex.txt

#==============================================================================#

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
