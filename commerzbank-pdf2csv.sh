#!/bin/bash


#
# PDF -> XML -> CSV
#


#------------------------------------------------------------------------------#
### Eingabeüberprüfung
if [ -z "${1}" ] ; then
	echo "${0} Kreditkartenabrechnung_der_Commerzbank.pdf"
	exit 1
else
	PDFDATEI="${1}"
fi


#------------------------------------------------------------------------------#
### PDF -> XML
NEUERNAME="$(echo "${PDFDATEI}" | sed 's/[( )][( )]*/_/g' | rev | sed 's/.*[.]//' | rev)"
SEITEN="$(pdftohtml -c -i -xml -enc UTF-8 -noframes -nodrm -hidden "${PDFDATEI}" ${NEUERNAME}_alle_Seiten.xml | nl | awk '{print $1}' ; rm -f ${NEUERNAME}_alle_Seiten.xml)"
for i in ${SEITEN}
do
	#echo "pdftohtml -c -i -xml -enc UTF-8 -noframes -nodrm -hidden -f ${i} -l ${i} "${PDFDATEI}" ${NEUERNAME}_Seite_${i}.xml"
	pdftohtml -c -i -xml -enc UTF-8 -noframes -nodrm -hidden -f ${i} -l ${i} "${PDFDATEI}" ${NEUERNAME}_Seite_${i}.xml >/dev/null
	XMLDATEIEN="${XMLDATEIEN} ${NEUERNAME}_Seite_${i}.xml"
done


#------------------------------------------------------------------------------#
### XML -> CSV
for EINEXML in ${XMLDATEIEN}
do
	CSVNAME="$(echo "${EINEXML}" | rev | sed 's/.*[.]//' | rev)"
	#----------------------------------------------------------------------#
	### Zeilen- und Spalten-Angaben extrahieren
	### und Zeilen in die richtige Reihenfolge bringen

	NR_XMLDAT="$(cat ${EINEXML} | grep -E '^[<]text ' | while read ZEILE
	do
		SPALTE_01="$(echo "${ZEILE}" | awk -F'>' '{print $1}')"
		TOP="$(echo "${SPALTE_01}" | tr -s ' ' '\n' | grep -E '^top=' | tr -d '"' | awk -F'=' '{print $2}')"
		LEFT="$(echo "${SPALTE_01}" | tr -s ' ' '\n' | grep -E '^left=' | tr -d '"' | awk -F'=' '{print $2}')"
		WIDTH="$(echo "${SPALTE_01}" | tr -s ' ' '\n' | grep -E '^width=' | tr -d '"' | awk -F'=' '{print $2}')"
		HEIGHT="$(echo "${SPALTE_01}" | tr -s ' ' '\n' | grep -E '^height=' | tr -d '"' | awk -F'=' '{print $2}')"
		echo "${TOP} ${LEFT} ${WIDTH} ${HEIGHT} ${ZEILE}"
	done | sort -n)"

	#----------------------------------------------------------------------#
	### Spalten in die richtige Reihenfolge bringen
	#
	# Weil in der PDF- und demzurfolge auch in der XML-Datei die Zeilen und
	# Spalten frei positioniert stehen, ist es für den PDF- bzw. XML-Kode
	# auch legitim, die Zeilen und Spalten dort in einer beliebigen
	# Reihenfolge abzulegen... darum muss das hier sortiert werden.
	#

	ALLE_ZEILENNR="$(echo "${NR_XMLDAT}" | awk '{print $1}' | sort -n | uniq)"
	ZEILEN_SORTIERT="$(for ZEILEN_NR in ${ALLE_ZEILENNR}
	do
		echo "${NR_XMLDAT}" | egrep "^${ZEILEN_NR} " | while read Z_NR ZEILE
		do
			echo "${ZEILE}"
		done | sort -n | sed "s/.*/${ZEILEN_NR} &/"
	done)"

	#----------------------------------------------------------------------#
	### hier muss an Hand der Werte LEFT und WIDTH ermittelt werden
	### in welcher Spalte der Wert geschrieben werden muss

	#----------------------------------------------------------------------#
	### die Werbung (von oben und unten) entfernen

	XMLDATEN="$(echo "${ZEILEN_SORTIERT}" | sed '1,/[<]b[>]H = Guthaben[<][/]b[>]/d; /[>][<]b[>]/,//d')"
	ALLE_TOP="$(echo "${XMLDATEN}" | awk '{print $1}' | uniq)"

	#----------------------------------------------------------------------#
	### Daten aufarbeiten

	for ZEILEN_NR in ${ALLE_TOP}
	do
		SPALTE="0"
		echo "${XMLDATEN}" | egrep "^${ZEILEN_NR} " | while read ZEILEN_NR SPALTEN_NR SPLATEN_BREITE ZEILEN_HOEHE XML_ZEILE
		do
			SPALTE="$(echo "${SPALTE}" | awk '{print $1 + 1}')"
			SP_WERT="$(echo "${XML_ZEILE}" | sed 's/[<][/]text[>]$//; s/^[<]text .*[>]//;')"
			if [ "${SPALTE}" = "1" ] ; then
				ZAHLEN="$(echo -n "${SP_WERT};"|grep -E '[0-9][0-9]*[ \t][ \t]*[0-9][0-9]*')"
				if [ -n "${ZAHLEN}" ] ; then
					echo -n ";${SP_WERT};"
				else
					echo -n "${SP_WERT};"
				fi
			else
				echo -n "${SP_WERT};"
			fi
		done
		echo ""
	done
done > ${NEUERNAME}.csv

rm -f ${XMLDATEIEN}
ls -lha ${NEUERNAME}.csv
echo "
libreoffice --calc ${NEUERNAME}.csv"

#------------------------------------------------------------------------------#
exit

### MoneyPlex-Reihenfolge
echo '"Saldo";"SdoWaehr";"AgBlz";"AgKto";"AgName1";"Storno";"OrigBtg";"Betrag";"BtgWaehr";"OCMTBetr";"OCMTWaehr";"Textschl";"VWZ1";"VWZ2";"VWZ3";"VWZ4";"VWZ5";"VWZ6";"VWZ7";"VWZ8";"VWZ9";"VWZ10";"VWZ11";"VWZ12";"VWZ13";"VWZ14";"BuchDatum";"WertDatum";"Primanota";"Kategorie";"Unterkat";"Kostenst"'

### Beispiel
# "Saldo";"SdoWaehr";"AgBlz";"AgKto";"AgName1"         ;"Storno";"OrigBtg";"Betrag";"BtgWaehr";"OCMTBetr";"OCMTWaehr";"Textschl";"VWZ1";"VWZ2"     ;"VWZ3";"VWZ4";"VWZ5";"VWZ6";"VWZ7";"VWZ8";"VWZ9";"VWZ10";"VWZ11";"VWZ12";"VWZ13";"VWZ14";"BuchDatum";"WertDatum";"Primanota";"Kategorie";"Unterkat";"Kostenst"
# 63,39  ;"EUR"     ;""     ;""     ;"TESTAUFTRAGGEBER";0       ;-26,93   ;-26,93  ;"EUR"     ;-26,93    ;"EUR"      ;5         ;""    ;"TESTZWECK";""    ;""    ;""    ;""    ;""    ;""    ;""    ;""     ;""     ;""     ;""     ;""     ;17.3.2004  ;17.3.2004  ;"9044"     ;""         ;""        ;""
