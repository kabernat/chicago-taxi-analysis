-- 1. Wstępne sprawdzenie danych
SELECT *
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
LIMIT 10;


-- 2. Sprawdzenie kompletności danych (braki w kolumnach)
SELECT
  COUNT(*) AS total_trips,
  ROUND(COUNT(company) * 100.0 / COUNT(*), 1) AS company,
  ROUND(COUNT(payment_type) * 100.0 / COUNT(*), 1) AS payment_type,
  ROUND(COUNT(trip_miles) * 100.0 / COUNT(*), 1) AS trip_miles,
  ROUND(COUNT(tips) * 100.0 / COUNT(*), 1) AS tips,
  ROUND(COUNT(pickup_community_area) * 100.0 / COUNT(*), 1) AS pickup_community_area,
  ROUND(COUNT(trip_seconds) * 100.0 / COUNT(*), 1) AS trip_seconds,
  ROUND(COUNT(fare) * 100.0 / COUNT(*), 1) AS fare,
  ROUND(COUNT(trip_total) * 100.0 / COUNT(*), 1) AS trip_total
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`;


-- 3. Sprawdzenie duplikatów
SELECT
  COUNT(unique_key) AS wszystkie_wiersze,
  COUNT(DISTINCT unique_key) AS unikalne_wiersze
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`;


-- 4. Określenie godzin szczytu
SELECT
  EXTRACT(HOUR FROM trip_start_timestamp) AS godzina,
  COUNT(*) AS liczba_kursow
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
GROUP BY godzina
ORDER BY liczba_kursow DESC;


-- 5. Analiza przychodów (TOP 10 / BOTTOM 10 firm)
SELECT
  COMPANY AS firma,
  ROUND(SUM(trip_total), 2) AS calkowita_kwota,
  ROUND(SUM(fare), 2) AS przychod_bazowy
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE company IS NOT NULL
GROUP BY firma
ORDER BY przychod_bazowy DESC;


-- 6. Analiza średnich parametrów przejazdu
SELECT
  ROUND(AVG(trip_seconds), 2) AS sredni_czas_przejazdu,
  ROUND(AVG(trip_miles), 2) AS srednia_odleglosc_przejazdu,
  ROUND(AVG(trip_total), 2) AS sredni_koszt_przejazdu
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`;


-- 7. Segmentacja przejazdów ze względu na odległość
SELECT
  CASE
    WHEN trip_miles < 2 THEN 'krotki'
    WHEN trip_miles < 10 THEN 'sredni'
    ELSE 'dlugi'
  END AS typ_kursu,
  COUNT(*) AS liczba_kursow,
  ROUND(AVG(trip_total), 2) AS koszt_przejazdu
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
GROUP BY typ_kursu
ORDER BY liczba_kursow DESC;


-- 8. Analiza metod płatności i napiwków
SELECT
  ROUND(AVG(tips), 2) AS sredni_napiwek,
  COUNT(*) AS liczba_kursow,
  payment_type AS metoda_platnosci
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE tips > 0
GROUP BY metoda_platnosci
HAVING COUNT(*) > 10000
ORDER BY sredni_napiwek DESC;


-- 9. Porównanie kosztów za milę i profilu działalności firm
SELECT
  company AS firma,
  COUNT(*) AS liczba_kursow,
  ROUND(SUM(fare) / SUM(trip_miles), 2) AS koszt_za_mile,
  ROUND(AVG(trip_miles), 2) AS sredni_dystans,
  ROUND(AVG(fare), 2) AS srednia_oplata
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE trip_miles > 0
  AND company IS NOT NULL
GROUP BY firma
HAVING COUNT(*) > 10000
ORDER BY koszt_za_mile DESC;


-- 10. Porównanie cen i liczby kursów na przestrzeni lat
SELECT
  EXTRACT(YEAR FROM trip_start_timestamp) AS rok,
  COUNT(*) AS liczba_kursow,
  ROUND(AVG(fare), 2) AS srednia_oplata_bazowa,
  ROUND(AVG(trip_total), 2) AS srednia_oplata_calkowita
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
GROUP BY rok
ORDER BY rok ASC;


-- 11. Analiza lokalizacji – najlepsze i najgorsze strefy odbioru
SELECT pickup_community_area AS lokalizacja_odbioru,
  COUNT(*) AS liczba_kursow
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
WHERE pickup_community_area IS NOT NULL
GROUP BY lokalizacja_odbioru
ORDER BY liczba_kursow DESC;


-- 12. Wpływ pory dnia na czas przejazdu
SELECT
  ROUND(AVG(trip_seconds), 2) AS sredni_czas_przejazdu,
  ROUND(AVG(trip_miles), 2) AS sredni_dystans_przejazdu,
  EXTRACT(HOUR FROM trip_start_timestamp) AS godzina
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
GROUP BY godzina
ORDER BY sredni_czas_przejazdu DESC;
