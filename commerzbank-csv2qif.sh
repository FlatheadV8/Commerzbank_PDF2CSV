#!/bin/bash


#
# CSV -> QIF (Quicken Interchange Format)
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
                        ${0} -j [Jahr der Abrechnung]
                        ${0} -k [Kategorie_alt/Kategorie_neu]
                        ${0} -j 2014
                        ${0} -k DB/Fahrtkosten
                        ${0} -j 2014 -k DB/Fahrtkosten
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

### nur für Tests
#echo "
#CSVDATEI='${CSVDATEI}'
#KATEGORIE_PARAMETER='${KATEGORIE_PARAMETER}'
#KATEGORIE_ALT='${KATEGORIE_ALT}'
#KATEGORIE_NEU='${KATEGORIE_NEU}'
#"
#------------------------------------------------------------------------------#
### MoneyPlex (http://www.matrica.de/download/importformate.pdf)

(echo '!Type:Bank';
cat "${CSVDATEI}" | grep -Ev '^Bahnkart;' | grep -Ev '^$' | while read ZEILE
do
        if [ -n "${KATEGORIE_PARAMETER}" ] ; then
                echo "L${ZEILE}" | awk -F';' '{ print $1 }' | sed "s/${KATEGORIE_ALT}/${KATEGORIE_NEU}/"
        else
                echo "L${ZEILE}" | awk -F';' '{ print $1 }'
        fi

        BUCHUNGSDATUM="$(echo "${ZEILE}" | awk -F';' -v jahr=${JAHR} '{ print $2,jahr }' | awk '{print $3"-"$2"-"$1}')"
        if [ -n "${BUCHUNGSDATUM}" ] ; then
        	echo "D${BUCHUNGSDATUM}"
        fi


        AUSGABE="$(echo "${ZEILE}" | awk -F';' '{ print $5 }')"	
        WAEHRUNG="$(echo "${ZEILE}" | awk -F';' '{ print $6 }')"
        KURS="$(echo "${ZEILE}" | awk -F';' '{ print $7 }')"
        if [ -n "${AUSGABE}${WAEHRUNG}${KURS}" ] ; then
        	echo "P${AUSGABE} ${WAEHRUNG} ${KURS}"
        fi

        WERTSTELLUNGSDATUM="$(echo "${ZEILE}" | awk -F';'  -v jahr=${JAHR} '{ print $8,jahr }' | awk '{print $3"-"$2"-"$1}')"
        if [ -n "${WERTSTELLUNGSDATUM}" ] ; then
        	echo "N${WERTSTELLUNGSDATUM}"
        fi


        UNTERNEHMEN="$(echo "${ZEILE}" | awk -F';' '{ print $3 }')"
        ORT="$(echo "${ZEILE}" | awk -F';' '{ print $4 }')"
        AUSGABE="$(echo "${ZEILE}" | awk -F';' '{ print $5 }')"	
        WAEHRUNG="$(echo "${ZEILE}" | awk -F';' '{ print $6 }')"
        KURS="$(echo "${ZEILE}" | awk -F';' '{ print $7 }')"
        #WERTSTELLUNGSDATUM="$(echo "${ZEILE}" | awk -F';'  -v jahr=${JAHR} '{ print $8,jahr }' | awk '{print $3"-"$2"-"$1}')"
        if [ -n "${UNTERNEHMEN}" ] ; then
        	#echo "M${WERTSTELLUNGSDATUM} ${UNTERNEHMEN} ${ORT} ${AUSGABE} ${WAEHRUNG} ${KURS}"
        	#echo "M${UNTERNEHMEN} ${ORT} ${AUSGABE} ${WAEHRUNG} ${KURS}"
        	echo "M${UNTERNEHMEN} ${ORT}"
        fi

        BETRAG="$(echo "${ZEILE}" | awk -F';' '{ print $9}')"
        VORZEICHEN="$(echo "${ZEILE}" | awk -F';' '{ v="-"; if ($10 == "H") v="+" ; print v }')"
        if [ -n "${BETRAG}" ] ; then
        	echo "T${VORZEICHEN}${BETRAG}"
        fi

        echo "^"
done) > ${NEUERNAME}.qif

ls -lh ${NEUERNAME}.qif

exit
#==============================================================================#
### Doku
#------------------------------------------------------------------------------#
### QIF (http://xl2qif.chez-alice.fr/download/QIF.pdf)
#
## D - Datum
## T - Betrag (Netto)
#  U - Betrag (Brutto)
#  C - Clearedstatus
## N - Nummer (Check / Referenz)
## P - Zahlungsbeschreibung / Verwendungszweck / Empfänger
## M - Notiz / Vermerk / Anmerkung
#  A - Adresse (bis zu 5 Zeilen / 6. Zeile: Adresszusatz)
## L - Kategorie
#  S - Kategorie (split)
#  E - Notiz / Vermerk / Anmerkung (split)
#  F - erstattungsfähig / rückzahlbar
## ^ - Trennung zwischen den Datensätzen
#
#------------------------------------------------------------------------------#
### Kreditkartenabrechnung der Commerzbank
#
# 01 - L - Bahnkart
# 02 - D - Umsatzdatum
# 03 - M - Unternehmen
# 04 - A - Ort
# 05 - M - Ausgabe (Betrag der Fremdwährung)
# 06 - M - Währung (Fremdwährung)
# 07 - M - Kurs    (Umrechnungskurs)
# 08 - N - Buchungsdatum (Valutadatum)
# 09 - T - Betrag in EUR
# 10 - T - Guthaben (Vorzeichen)
#
#==============================================================================#
