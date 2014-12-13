#!/bin/bash


#
# CSV -> MoneyPlex: "CSV-Import Geldtipps Homebanking"
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
                -j)
                        JAHR="${2}"
                        shift
                        shift
                        ;;
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

if [ -z "${JAHR}" ] ; then
        JAHR="$(date +'%Y')"
fi

#------------------------------------------------------------------------------#
#
### Geldtipps Homebanking - Format
#
(echo 'Hauptkategorie;Buchungsdatum;Verwendungszweck;Wertstellungsdatum;Betrag;Währung;KontoNr;BLZ;Geschäftsvorfall;Notizen;Empfänger;Unterkategorie';
cat "${CSVDATEI}" | grep -Ev '^Bahnkart;' | grep -Ev '^$' | while read ZEILE
do
	#----------------------------------------------------------------------#
        (
	### Kategorie
        KATEGORIE="$(echo "${ZEILE}" | awk -F';' '{ print $1 }')"
        if [ -n "${KATEGORIE}" ] ; then
        	if [ -n "${KATEGORIE_PARAMETER}" ] ; then
                	echo "${KATEGORIE};" | sed "s/${KATEGORIE_ALT};/${KATEGORIE_NEU};/"
        	else
                	echo "${KATEGORIE};"
        	fi
        else
                echo ";"
        fi

	### Datum / Umsatzdatum
        BUCHUNGSTAG="$(echo "${ZEILE}" | awk -F';' '{ print $2 }')"
        if [ -n "${BUCHUNGSTAG}" ] ; then
                BUCHUNGSDATUM="$(echo "${BUCHUNGSTAG}" | awk -v jahr=${JAHR} '{ print jahr"-"$2"-"$1}')"
                echo "${BUCHUNGSDATUM};"
        else
                echo ";"
        fi


	### Zweck / Verwendungszweck
        UNTERNEHMEN="$(echo "${ZEILE}" | awk -F';' '{ print $3 }')"
        ORT="$(echo "${ZEILE}" | awk -F';' '{ print $4 }')"
        AUSGABE="$(echo "${ZEILE}" | awk -F';' '{ print $5 }')"
        WAEHRUNG="$(echo "${ZEILE}" | awk -F';' '{ print $6 }')"
        KURS="$(echo "${ZEILE}" | awk -F';' '{ print $7 }')"
        if [ -n "${UNTERNEHMEN}${ORT}${AUSGABE}${WAEHRUNG}${KURS}" ] ; then
                echo "${UNTERNEHMEN} ${ORT} ${AUSGABE} ${WAEHRUNG} ${KURS};"
        else
                echo ";"
        fi

	### Valuta / Buchungsdatum
        VALUTATAG="$(echo "${ZEILE}" | awk -F';' '{ print $8 }')"
        if [ -n "${VALUTATAG}" ] ; then
                VALUTA="$(echo "${VALUTATAG}" | awk -v jahr=${JAHR} '{ print jahr"-"$2"-"$1}')"
                echo "${VALUTA};"
        else
                echo ";"
        fi

        ### Betrag
        BETRAG="$(echo "${ZEILE}" | awk -F';' '{ print $9}')"
        VORZEICHEN="$(echo "${ZEILE}" | awk -F';' '{ v="-"; if ($10 == "H") v="+" ; print v }')"
        if [ -n "${BETRAG}" ] ; then
                echo "${VORZEICHEN}${BETRAG};"
        fi
	) | tr -d '\n'
	#----------------------------------------------------------------------#

	### Waehrung
        echo "EUR;;;;;;"
done) > ${NEUERNAME}_moneyplex_geldtipps.csv

ls -lh ${NEUERNAME}_moneyplex_geldtipps.csv

echo "
libreoffice --calc ${NEUERNAME}_moneyplex_geldtipps.csv

Die soeben erzeugte Datei kann in MoneyPlex mit dem
Importfilter 'CSV-Import Geldtipps Homebanking' importiert werden.
"
