# Logika i Struktura Danych - Testowniko

## 1. Model Danych (Pytanie)
Każde pytanie w aplikacji powinno zawierać:
*   `id`: Unikalny identyfikator.
*   `content`: Treść pytania.
*   `answers`: Lista obiektów odpowiedzi (treść + flaga czy poprawna).
*   `isMultipleChoice`: Flaga określająca typ pytania (Single vs Multiple).
*   `repetitionsDone`: Licznik udanych powtórek dla tego pytania (init: 0).
*   `requiredRepetitions`: Dynamiczny cel powtórek dla konkretnego pytania (init: TargetRepetitions z ustawień).
*   `status`: Stan pytania (`unopened`, `toRepeat`, `mastered`).

## 2. Logika Powtórek i Losowania

### 2.1 Algorytm Powtórek
System oparty na parametrach z ustawień:
*   **TargetRepetitions (X):** Ile razy trzeba odpowiedzieć dobrze, by uznać pytanie za opanowane (Domyślnie 2).
*   **MaxExtraRepetitions (Y):** Maksymalna liczba dodatkowych powtórek po błędzie (Domyślnie 4).

### 2.2 Mechanizm Losowania (Randomization)
Aplikacja musi dynamicznie wybierać pytania, aby nauka nie była przewidywalna:
*   **Inicjalizacja:** Przy załadowaniu testu cała pula pytań jest mieszana (shuffle).
*   **Wybór kolejnego pytania:** Po każdej udzielonej odpowiedzi, system losuje kolejne pytanie z puli dostępnych (nieopanowanych).
*   **Priorytetyzacja:** System najpierw wybiera z puli pytań "do powtórki" (`toRepeat`), a jeśli ta jest pusta, sięga po pytania jeszcze "nieotwarte" (`unopened`).
*   **Pamięć stanu:** Losowość nie wpływa na postęp. Każde pytanie niezależnie śledzi:
    *   `repetitionsDone`: ile razy udzielono poprawnej odpowiedzi.
    *   `requiredRepetitions`: aktualna liczba wymaganych poprawnych odpowiedzi (zwiększana przy błędach, aż do limitu `MaxExtraRepetitions`).

### 2.3 Scenariusze:
1.  **Poprawna odpowiedź:** Zwiększa `repetitionsDone`. Jeśli `repetitionsDone` >= `requiredRepetitions`, pytanie otrzymuje status `mastered`.
2.  **Błędna odpowiedź:** Pytanie otrzymuje status `toRepeat`. Jeśli `requiredRepetitions` < `MaxExtraRepetitions`, limit ten jest zwiększany o 1 dla tego pytania.
3.  **Kolejne losowanie:** Pytanie wraca do puli dostępnych i zostanie ponownie wylosowane zgodnie z algorytmem priorytetyzacji.

## 3. Przechowywanie Danych (Web Local Storage)
Ponieważ aplikacja nie posiada bazy danych, wykorzystujemy mechanizmy przeglądarki:
*   **Ustawienia:** Zapisywane na stałe (ilość powtórzeń, motyw).
*   **Historia testów:** Zapisujemy jedynie listę nazw ostatnio otwieranych plików (jako local storage), aby użytkownik mógł wiedzieć, co ostatnio ćwiczył.
*   **Baza pytań:** Sam plik z pytaniami jest ładowany do pamięci RAM (runtime). Nie przechowujemy treści całego testu w pamięci trwałej przeglądarki ze względu na możliwe limity wielkości.

## 4. Format Pliku Wejściowego
Aplikacja wspiera format TXT (według wzorca z `oipiipi.txt`), gdzie:
*   Pytanie zaczyna się od numeru i kropki (np. `1. `).
*   Poprawna odpowiedź jest poprzedzona gwiazdką `*`.
*   Brak gwiazdki oznacza błędną odpowiedź.
