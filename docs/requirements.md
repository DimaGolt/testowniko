# Wymagania Funkcjonalne - Testowniko

## 1. Cel aplikacji
Aplikacja "Testowniko" to narzędzie webowe stworzone we Flutterze, służące do nauki na podstawie bazy pytań dostarczonej przez użytkownika. Aplikacja opiera się na systemie powtórek, pomagając użytkownikowi opanować materiał.

## 2. Ekrany

### 2.1 Ekran Powitalny (Welcome Screen)
*   **Nagłówek:** Wyświetla nazwę aplikacji: "Testowniko".
*   **Zarządzanie testami:**
    *   Możliwość załadowania nowego testu (tylko w czasie działania aplikacji - runtime).
    *   Jeśli użytkownik korzystał wcześniej z aplikacji, powinna pojawić się opcja wyboru poprzednich testów (zapamiętana ścieżka/identyfikator).
    *   Interfejs: "Poprzednie testy LUB załaduj nowy".
*   **Ustawienia Nauki (Learning Settings):**
    *   Ilość powtórzeń wymagana do "opanowania" pytania (domyślnie: 2).
    *   Maksymalna ilość dodatkowych powtórzeń po niepoprawnej odpowiedzi (domyślnie: 4).
    *   Opcja zapisu tych ustawień w pamięci lokalnej przeglądarki.

### 2.2 Ekran Quizu (Quiz Screen)
*   **Statystyki (Liczniki):**
    *   Pytania opanowane.
    *   Pytania jeszcze nieotwarte.
    *   Pytania do powtórki.
*   **Prezentacja pytania:**
    *   Treść pytania.
    *   Lista odpowiedzi.
*   **Interakcja z odpowiedziami:**
    *   **Jednokrotny wybór:** Okrągłe znaczniki (Radio buttons).
    *   **Wielokrotny wybór:** Kwadratowe znaczniki (Checkboxy). Wymaga przycisku "Zatwierdź".
*   **Nawigacja:** Przycisk "Wyjdź" pozwalający przerwać quiz.

### 2.3 Ekran Po Quizie (Summary Screen)
*   **Element wizualny:** Obrazek piwa (nagroda za ukończenie).
*   **Statystyki końcowe:** Całkowity czas spędzony na rozwiązywaniu quizu.
*   **Akcja:** Przycisk powrotu do ekranu powitalnego.

## 3. Logika Nauki i Informacja Zwrotna

### 3.1 Informacja zwrotna po wybraniu odpowiedzi
*   **Poprawne odpowiedzi:** Podświetlone na zielono.
*   **Błędne odpowiedzi (wybrane przez użytkownika):** Podświetlone na czerwono.
*   **Pominięte poprawne odpowiedzi:** Podświetlone na wyblakły zielony.

### 3.2 System powtórek
*   **Opanowanie pytania:** Jeśli użytkownik odpowie poprawnie określoną liczbę razy (ustawienia), pytanie trafia do "opanowanych".
*   **Błąd:** Jeśli użytkownik odpowie źle, licznik powtórków dla tego pytania zwiększa się o 1 (aż do osiągnięcia maksimum z ustawień). Pytanie trafia do puli "do powtórki".

## 4. Wygląd i Responsywność
*   **Motywy:** Jasny i ciemny (przełącznik w ustawieniach lub systemowy).
*   **Responsywność:**
    *   **Desktop:** Elementy interfejsu (np. przyciski) nie powinny być rozciągnięte na pełną szerokość ekranu (centrowanie, maksymalna szerokość kontenera).
    *   **Mobile:** Wszystkie elementy muszą być widoczne i łatwo dostępne (brak przepełnienia ekranu).
