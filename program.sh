#!bin/bash

#FUNKCJA - TRYB DZIEN
Dzien () 
{

echo
echo "Podaj numer stacji: "
read dzien_stacja

poprawna_stacja=`grep -w "$dzien_stacja" lista_stacji.txt`
echo "$poprawna_stacja"



{
	while [[ -z "$dzien_stacja" || "$dzien_stacja" = "" || "$poprawna_stacja" = "" ]] ## || "$stacja"  - jezeli numer stacji ma za malo cyfr lub liter ?!
		do
			echo "BŁAD"
			echo "Spróbuj ponownie"
			read dzien_stacja
			poprawna_stacja=`grep "$dzien_stacja" lista_stacji.txt` # CIĄG KRÓTKI 123 to przechodzi!!!

					done
}


echo
echo "Podaj rok: np. 2010"
read dzien_rok
{
	while [[ -z "$dzien_rok" || "$dzien_rok" = "" || "$dzien_rok" -gt 2019 || "$dzien_rok" -lt 2000 ]]
		do
			echo "BŁĄD"
			echo "Spróbuj ponownie"
			read dzien_rok
				done
}
echo
echo "Podaj miesiąc: np. 02"
read dzien_miesiac
{
	while [[ -z "$dzien_miesiac" || "$dzien_miesiac" = "" || "$dzien_miesiac" -lt 01 || "$dzien_miesiac" -gt 12 ]]
		do
			echo "BŁĄD"
			echo "Spróbuj ponownie"
			read dzien_miesiac
				done
}
echo
echo "Podaj dzień: np. 01"
read dzien_dzien
{
	while [[ -z "$dzien_dzien" || "$dzien_dzien" = "" || "$dzien_dzien" -lt 01 || "$dzien_dzien" -gt 31 ]]
		do
			echo "BŁĄÐ"
			echo "Spróbuj ponownie"
			read dzien_dzien
				done
}
echo
echo "Podaj godzinę pomiaru (północ wpisz 0 / południe wpisz 1): "
read dzien_pomiar_decyzja
{
	while [[ -z "$dzien_pomiar_decyzja" || "$dzien_pomiar_decyzja" = "" || "$dzien_pomiar_decyzja" -gt 2|| "$dzien_pomiar_decyzja" -lt 0 || "$dzien_pomiar_decyzja" = [a-zA-z] ]]
		do
			echo "BŁĄÐ"
			echo "Spróbuj ponownie"
			read dzien_pomiar_decyzja
				done
}

# POBIERANIE DANYCH ZE STRONY UZUPEŁNIONE POPRZEZ PODANE PARAMETRY
if [ $dzien_pomiar_decyzja = 0 ] ; then
wget -O dane_meteo_dla_stacji_"$dzien_stacja".csv "http://weather.uwyo.edu/cgi-bin/sounding?region=europe&TYPE=TEXT%3ALIST&YEAR=$dzien_rok&MONTH=$dzien_miesiac&FROM=$dzien_dzien"00"&TO=$dzien_dzien"00"&STNM=$dzien_stacja"  # link uzupełniony przez zmienne
elif [ $dzien_pomiar_decyzja = 1 ] ; then
wget -O dane_meteo_dla_stacji_"$dzien_stacja".csv "http://weather.uwyo.edu/cgi-bin/sounding?region=europe&TYPE=TEXT%3ALIST&YEAR=$dzien_rok&MONTH=$dzien_miesiac&FROM=$dzien_dzien"12"&TO=$dzien_dzien"12"&STNM=$dzien_stacja"  # link uzupełniony przez zmienne	
fi

# POBIERANIE WYSOKOSCI STSACJI
linia_wysokosc_dzien=`grep -w elevation dane_meteo_dla_stacji_"$dzien_stacja".csv > wys_stacji_"$dzien_stacja".txt`
wys_dzien=`awk '{print $3}' wys_stacji_"$dzien_stacja".txt`

echo "$wys_dzien"


# CZYSZCZENIE Z KODU HTML I Z LICZNYCH SPACJI
sed -i '/<HTML>/,+9d' dane_meteo_dla_stacji_"$dzien_stacja".csv
sed -i -e '/PRE><H3>/,+55d' dane_meteo_dla_stacji_"$dzien_stacja".csv
sed -i -e '/          /d' dane_meteo_dla_stacji_"$dzien_stacja".csv

awk '' dane_meteo_dla_stacji_"$dzien_stacja".csv


echo
echo "Wybierz parametr meteorologiczny: "
echo
echo "Temp. powietrza wpisz 		T"
echo "Ciśnienie wpisz 		P"
echo "Wilgotność względna wpisz 	RH"
read dzien_parametr

# PODSUMOWANIE PARAMETROW
echo
echo "Informacje dotyczące pobieranych danych meteo"
echo
echo "Numer stacji:    $dzien_stacja"
echo "Wysokość stacji: $wys_dzien"
echo "Rok:             $dzien_rok"
echo "Miesiąc:         $dzien_miesiac"
echo "Dzień:           $dzien_dzien"

if [ $dzien_pomiar_decyzja = 0 ] ; then
	echo "Godzina pomiaru: 0:00"
elif [ $dzien_pomiar_decyzja = 1 ] ; then
	echo "Godzina pomiaru: 12:00"
#elif [ $dzien_pomiar_decyzja = 2 ] ; then
	#echo "Godzina pomiaru: 0:00 i 12:00"
fi

if [ $dzien_parametr = "T" ] ; then
	echo "Parametr:        Temp. powietrza"
elif [ $dzien_parametr = "P" ] ; then
	echo "Parametr:        Ciśnienie"
elif [ $dzien_parametr = "RH" ] ; then
	echo "Parametr:        Wilgotność względna"
fi

# PYTANIE O WPROWADZENIE PONOWNE
echo
echo "Czy chcesz wprowadzić parametry jeszcze raz < TAK / NIE >?"
read dzien_decyzja
echo
if [ $dzien_decyzja = "TAK" ] ; then
	Dzien
fi

# NAGLOWEK DLA WYSWIETLANEJ TABELI DANYCH 
echo
echo "Dane dla stacji "$dzien_stacja" stan na "$dzien_dzien"_"$dzien_miesiac"_"$dzien_rok""
if [ $dzien_pomiar_decyzja = 0 ] ; then
	echo "Godzina pomiaru: 0:00"
elif [ $dzien_pomiar_decyzja = 1 ] ; then
	echo "Godzina pomiaru: 12:00"
elif [ $dzien_pomiar_decyzja = 2 ] ; then
	echo "Godzina pomiaru: 0:00 i 12:00"
fi
echo
if [ $dzien_parametr = "T" ] ; then
	awk 'BEGIN{printf "Wysokość n.p.m.\tTemperatura\n\n"} {print $2 "\t\t" $3}' dane_meteo_dla_stacji_"$dzien_stacja".csv #> sondaż_dla_stacji_"$dzien_stacja".csv
elif [ $dzien_parametr = "P" ] ; then
	awk 'BEGIN{printf "Wysokość n.p.m.\tCiśnienie\n\n"} {print $2 "\t\t" $1}' dane_meteo_dla_stacji_"$dzien_stacja".csv # sondaż_dla_stacji_"$dzien_stacja".csv
elif [ $dzien_parametr = "RH" ] ; then
	awk 'BEGIN{printf "Wysokość n.p.m.\tWilgotność wzgl.\n\n"} {print $2 "\t\t" $5}' dane_meteo_dla_stacji_"$dzien_stacja".csv #> sondaż_dla_stacji_"$dzien_stacja".csv
fi

# FUNKCJA WYSWIETLENIA I ZAPISU DO PLIKU
awk 'BEGIN{printf "Wysokość\tTemperatura\tCiśnienie\tWilgotność wzgl.\n\n"} {print $2 "\t\t\t" $3 "\t\t\t" $1 "\t\t\t" $5}' dane_meteo_dla_stacji_"$dzien_stacja".csv > sondaż_dla_stacji_"$dzien_stacja".csv
#sed -i '/----/d' sondaż_dla_stacji_"$dzien_stacja"_"$dzien_dzien"_"$dzien_miesiac"_"$dzien_rok".csv > sondaż_dla_stacji_"$dzien_stacja"_"$dzien_dzien"_"$dzien_miesiac"_"$dzien_rok".csv

echo
echo "Sondaż zapisany jako: sondaż_dla_stacji_"$dzien_stacja"_"$dzien_dzien"_"$dzien_miesiac"_"$dzien_rok".csv"
echo
echo "KONIEC"
echo
}


#
#
#

Miesiac ()
{
echo
echo "Podaj numer stacji: np. 12374"
read miesiac_stacja

poprawna_stacja2=`grep -w "$miesiac_stacja" lista_stacji.txt`

{
	while [[ -z "$miesiac_stacja" || "$miesiac_stacja" = "" || "$poprawna_stacja2" = "" ]]
		do
			echo "BŁĄD"
			echo "Spróbuj ponownie"
			read miesiac_stacja
			poprawna_stacja2=`grep "$dzien_stacja" lista_stacji.txt`
				done
}

echo #pusta linia
echo "Podaj rok z zakresu 2000 do 2019"
read miesiac_rok
{
	while [[ -z "$miesiac_rok" || "$miesiac_rok" = "" || "$miesiac_rok" -lt 2010 || "$miesiac_rok" -gt 2019 ]]
		do
			echo "BŁĄD"
			echo "Spróbuj ponownie"
			read miesiac_rok
				done
}

echo #pusta linia
echo "Podaj miesiąc np. 05"
read miesiac_miesiac
{
	while [[ -z "$miesiac_miesiac" || "$miesiac_miesiac" = "" || "$miesiac_miesiac" -lt 01 || "$miesiac_miesiac" -gt 12 ]]
		do
			echo "BŁĄD"
			echo "Spróbuj ponownie"
			read miesiac_miesiac
				done
}

echo
echo "Wybierz parametr meteorologiczny: "
echo
echo "Temp. powietrza wpisz 		T"
echo "Ciśnienie wpisz 		P"
echo "Wilgotność względna wpisz 	RH"
read miesiac_parametr

# PODSUMOWANIE DANYCH
echo
echo "Informacje dotyczące pobieranych danych meteo"
echo
echo "Numer stacji:    $miesiac_stacja"
echo "Rok:             $miesiac_rok"
echo "Miesiąc:         $miesiac_miesiac"
if [ $miesiac_parametr = "T" ] ; then
	echo "Parametr:        Temp. powietrza"
elif [ $miesiac_parametr = "P" ] ; then
	echo "Parametr:        Ciśnienie"
elif [ $miesiac_parametr = "RH" ] ; then
	echo "Parametr:        Wilgotność względna"
fi

# CZY WPROWADZIC JESZCZE RAZ
echo
echo "Czy chcesz wprowadzić parametry jeszcze raz < TAK / NIE >?"
read miesiac_decyzja
echo
if [ $miesiac_decyzja = "TAK" ] ; then
	Miesiac
fi

# POBRANIE DANYCH Z WPROWADZONYMI PARAMETRAMI
wget -O dane_meteo_dla_stacji_"$miesiac_stacja".csv "http://weather.uwyo.edu/cgi-bin/sounding?region=europe&TYPE=TEXT%3ALIST&YEAR="$miesiac_rok"&MONTH="$miesiac_miesiac"&FROM=all&TO=all&STNM="$miesiac_stacja""

linia_wysokosc_miesiac=`grep -w elevation dane_meteo_dla_stacji_"$miesiac_stacja".csv > wys_stacji_"$miesiac_stacja"_podsum.txt`

# POBRANIE WYSOKOSCI STACJI
wys_miesiac=`awk 'NR==1{printf "%0f\n", $3}' wys_stacji_"$miesiac_stacja"_podsum.txt > wys_miesiac.csv`

wys2=$(awk '{printf "%.0f\n", $1}' wys_miesiac.csv) 

# CZYSZCZENIE DANYCH Z KODU HTML I SPACJI

sed -i '/<HTML>/,+5d' dane_meteo_dla_stacji_"$miesiac_stacja".csv
sed -i -e '/PRE><H3>/,+28d' dane_meteo_dla_stacji_"$miesiac_stacja".csv
sed -i -e '/Precipitable/,+3d' dane_meteo_dla_stacji_"$miesiac_stacja".csv
sed -i -e '/or <A/,+27d' dane_meteo_dla_stacji_"$miesiac_stacja".csv
sed -i '/----/,+3d' dane_meteo_dla_stacji_"$miesiac_stacja".csv
sed -i -e '/          /d' dane_meteo_dla_stacji_"$miesiac_stacja".csv

sed -i 's/  / /g' dane_meteo_dla_stacji_"$miesiac_stacja".csv
sed -i 's/  / /g' dane_meteo_dla_stacji_"$miesiac_stacja".csv
sed -i 's/  / /g' dane_meteo_dla_stacji_"$miesiac_stacja".csv


awk -v pat="$wys2" -F " " '$2==pat{print $3, $1, $5}' dane_meteo_dla_stacji_"$miesiac_stacja".csv > dane_miesieczne_$miesiac_stacja.csv #POBIERA DANE DLA WYS STACJI TEMP CISN WILG


if [ $miesiac_parametr = "T" ] ; then
	awk 'BEGIN{printf "Dzień\t\tTemp\n\n"}{print NR,"\t\t" $1}' dane_miesieczne_$miesiac_stacja.csv
elif [ $miesiac_parametr = "P" ] ; then
	awk 'BEGIN{printf "Dzień\t\tPres\n\n"}{print NR,"\t\t" $2}' dane_miesieczne_$miesiac_stacja.csv
elif [ $miesiac_parametr = "RH" ] ; then
	awk 'BEGIN{printf "Dzień\t\tRELG\n\n"}{print NR,"\t\t" $3}' dane_miesieczne_$miesiac_stacja.csv
fi																																						# zmien nr w jego miejsca wstaw funkcje podajaca date pomiaru pamietaj ze sa pomiary polnoc i poludnie!!


#STATYSTYKI
echo
awk '{sum+=$1}{srednia=sum/NR}END{print "Średnia temp dla tego okresu wynosiła: "srednia" C"}' dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$1; sumsq+=$1*$1} END {print "Odchylenie standardowe temperatury wynosi: "sqrt((sumsq/NR)-(sum/NR)^2) }' dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$1; sumsq+=$1*$1} END {war=(sumsq/NR)-(sum/NR)^2}END{print "Wariancja temperatury wynosiło: "war}' dane_miesieczne_$miesiac_stacja.csv 
echo
awk '{sum+=$2}{srednia=sum/NR}END{print "Średnie ciśnienie dla tego okresu wynosiła: "srednia" hPa"}' dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$2; sumsq+=$2*$2} END {print "Odchylenie standardowe ciśnienia wynosiło: "sqrt((sumsq/NR)-(sum/NR)^2) }' dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$2; sumsq+=$2*$2} END {war=(sumsq/NR)-(sum/NR)^2}END{print "Wariancja ciśnienia wynosiła: "war}' dane_miesieczne_$miesiac_stacja.csv 
echo
awk '{sum+=$3}{srednia=sum/NR}END{print "Średnia wilgotność dla tego okresu wynosiła: "srednia" %"}' dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$3; sumsq+=$3*$3} END {print "Odchylenie standardowe wilgotności wynosiło: "sqrt((sumsq/NR)-(sum/NR)^2) }' dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$3; sumsq+=$3*$3} END {war=(sumsq/NR)-(sum/NR)^2}END{print "Wariancja wilgotności wynosiła: "war}' dane_miesieczne_$miesiac_stacja.csv 

#POBIERANIE STATYSTYK DO PLIKU Z DANYMI MIESIECZNYMI


awk '{sum+=$1}{srednia=sum/NR}END{print "Średnia temp dla tego okresu wynosiła: "srednia" C"}' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$1; sumsq+=$1*$1} END {print "Odchylenie standardowe temperatury wynosi: "sqrt((sumsq/NR)-(sum/NR)^2) }' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$1; sumsq+=$1*$1} END {war=(sumsq/NR)-(sum/NR)^2}END{print "Wariancja temperatury wynosiło: "war}' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv 
echo
awk '{sum+=$2}{srednia=sum/NR}END{print "Średnie ciśnienie dla tego okresu wynosiła: "srednia" hPa"}' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$2; sumsq+=$2*$2} END {print "Odchylenie standardowe ciśnienia wynosiło: "sqrt((sumsq/NR)-(sum/NR)^2) }' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$2; sumsq+=$2*$2} END {war=(sumsq/NR)-(sum/NR)^2}END{print "Wariancja ciśnienia wynosiła: "war}' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv 
echo
awk '{sum+=$3}{srednia=sum/NR}END{print "Średnia wilgotność dla tego okresu wynosiła: "srednia" %"}' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$3; sumsq+=$3*$3} END {print "Odchylenie standardowe wilgotności wynosiło: "sqrt((sumsq/NR)-(sum/NR)^2) }' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv
awk '{sum+=$3; sumsq+=$3*$3} END {war=(sumsq/NR)-(sum/NR)^2}END{print "Wariancja wilgotności wynosiła: "war}' dane_miesieczne_$miesiac_stacja.csv >> dane_miesieczne_$miesiac_stacja.csv 

}


### 
###	
###

# OD TEGO ZACZYNA SIE PROGRAM POTEM WYBIERA FUNKCJE
echo
echo "Witaj w programie pobierającym dane meteorologiczne z sondaży aerologicznych."
echo "Program został stworzony przez Arkadiusza Babulę jako projekt zaliczeniowy z Programowania."
echo #pusta linia
printf "Wybierz tryb pracy:\nPojedyncza data \twpisz\t1\nPodsumowanie miesiąca \twpisz\t2"
echo #pusta linia
read tryb_pracy
echo
{
if [ $tryb_pracy = 1 ] ; then
	Dzien
elif [ $tryb_pracy = 2 ] ; then
	Miesiac
fi
}


# BABULA ARKADIUSZ
# GEOINFORMATYKA I KARTOGRAFIA
# ROK 1 
# CWICZENIA - PROGRAMOWANIE, program/skrypt zaliczeniowy

