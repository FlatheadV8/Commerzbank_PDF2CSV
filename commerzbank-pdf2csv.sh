#!/usr/bin/env bash


#
# PDF -> XML -> CSV
#


### Eingabeüberprüfung
if [ -z "${1}" ] ; then
	echo "${0} Kreditkartenabrechnung_der_Commerzbank.pdf"
	exit 1
else
	PDFDATEI="${1}"
fi


### PDF -> XML
NEUERNAME="$(echo "${PDFDATEI}" | sed 's/[( )][( )]*/_/g' | rev | sed 's/.*[.]//' | rev)"
SEITEN="$(pdftohtml -c -i -xml -enc UTF-8 -noframes -nodrm -hidden "${PDFDATEI}" ${NEUERNAME}_alle_Seiten.xml | nl | awk '{print $1}' ; rm -f ${NEUERNAME}_alle_Seiten.xml)"
for i in ${SEITEN}
do
	echo "pdftohtml -c -i -xml -enc UTF-8 -noframes -nodrm -hidden -f ${i} -l ${i} "${PDFDATEI}" ${NEUERNAME}_Seite_${i}.xml"
	pdftohtml -c -i -xml -enc UTF-8 -noframes -nodrm -hidden -f ${i} -l ${i} "${PDFDATEI}" ${NEUERNAME}_Seite_${i}.xml
	XMLDATEIEN="${XMLDATEIEN} ${NEUERNAME}_Seite_${i}.xml"
done

#exit

#XMLDATEIEN="Kreditkartenabrechnung-2014-04-09_Seite_1.xml Kreditkartenabrechnung-2014-04-09_Seite_2.xml Kreditkartenabrechnung-2014-04-09_Seite_3.xml"
#XMLDATEIEN="Kreditkartenabrechnung-2014-04-09_Seite_1.xml"
#XMLDATEIEN="Kreditkartenabrechnung_Seite_1.xml"
#XMLDATEIEN="Kreditkartenabrechnung-2014-04-09_Seite_2.xml"
#XMLDATEIEN="Kreditkartenabrechnung-2014-04-09_Seite_3.xml"


### XML -> CSV
for EINEXML in ${XMLDATEIEN}
do
	CSVNAME="$(echo "${EINEXML}" | rev | sed 's/.*[.]//' | rev)"
	XMLDATEN="$(cat ${EINEXML} | sed '1,/[<]b[>]H = Guthaben[<][/]b[>]/d;1,/[<]b[>]/d' | grep -E '^[<]text ')"
	TOP="$(echo "${XMLDATEN}" | tr -s '\r' '\n' | tr -s ' ' '\n' | fgrep 'top="' | awk -F'"' '{print $2}' | sort -n | uniq)"

### nur zum testen
#echo "${XMLDATEN};" > ${CSVNAME}_bereinigte_Daten.xml
#done
#exit

	SCHALTER_A="1"
	SCHALTER_B="0"
	for ZEILENNR in ${TOP}
	do
		if [ "${SCHALTER_A}" = "1" ] ; then
			FETT="$(echo "${XMLDATEN}" | fgrep "top=\"${ZEILENNR}\"" | grep -F '><b>' | head -n1)"
			if [ -n "${FETT}" ] ; then
				if [ "${SCHALTER_B}" = "1" ] ; then
					SCHALTER_A="0"
				fi
			else
				SCHALTER_B="1"
				SPALTE="1"
				for SPALTENNR in $(echo "${XMLDATEN}" | fgrep "top=\"${ZEILENNR}\"" | tr -s '\r' '\n' | tr -s ' ' '\n' | fgrep 'left="' | awk -F'"' '{print $2}' | sort -n)
				do
					SP_WERT="$(echo "${XMLDATEN}" | fgrep "top=\"${ZEILENNR}\"" | fgrep "left=\"${SPALTENNR}\"" | sed 's/[<][/]text[>]$//; s/^[<]text .*[>]//;')"
					if [ "${SPALTE}" = "1" ] ; then
						echo ""
						ZAHLEN="$(echo -n "${SP_WERT};"|grep -E '[0-9][0-9]*[ \t][ \t]*[0-9][0-9]*')"
						if [ -n "${ZAHLEN}" ] ; then
							#echo -n ";${SP_WERT} '${ZEILENNR}';"
							echo -n ";${SP_WERT};"
						else
							#echo -n "${SP_WERT} '${ZEILENNR}';"
							echo -n "${SP_WERT};"
						fi
					else
						echo -n "${SP_WERT};"
					fi
					SPALTE="$(echo "${SPALTE}" | awk '{print $1 + 1}')"
				done
			fi
		fi
	done > ${CSVNAME}.csv
done
echo

ls -lha ${XMLDATEIEN}
#rm -f ${XMLDATEIEN}
echo
ls -lha ${NEUERNAME}_Seite_*.csv

#------------------------------------------------------------------------------#
exit

### MoneyPlex-Reihenfolge
echo '"Saldo";"SdoWaehr";"AgBlz";"AgKto";"AgName1";"Storno";"OrigBtg";"Betrag";"BtgWaehr";"OCMTBetr";"OCMTWaehr";"Textschl";"VWZ1";"VWZ2";"VWZ3";"VWZ4";"VWZ5";"VWZ6";"VWZ7";"VWZ8";"VWZ9";"VWZ10";"VWZ11";"VWZ12";"VWZ13";"VWZ14";"BuchDatum";"WertDatum";"Primanota";"Kategorie";"Unterkat";"Kostenst"'

### Beispiel
# "Saldo";"SdoWaehr";"AgBlz";"AgKto";"AgName1"         ;"Storno";"OrigBtg";"Betrag";"BtgWaehr";"OCMTBetr";"OCMTWaehr";"Textschl";"VWZ1";"VWZ2"     ;"VWZ3";"VWZ4";"VWZ5";"VWZ6";"VWZ7";"VWZ8";"VWZ9";"VWZ10";"VWZ11";"VWZ12";"VWZ13";"VWZ14";"BuchDatum";"WertDatum";"Primanota";"Kategorie";"Unterkat";"Kostenst"
# 63,39  ;"EUR"     ;""     ;""     ;"TESTAUFTRAGGEBER";0       ;-26,93   ;-26,93  ;"EUR"     ;-26,93    ;"EUR"      ;5         ;""    ;"TESTZWECK";""    ;""    ;""    ;""    ;""    ;""    ;""    ;""     ;""     ;""     ;""     ;""     ;17.3.2004  ;17.3.2004  ;"9044"     ;""         ;""        ;""
