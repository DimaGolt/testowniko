# Testowniko 🍺

Aplikacja webowa do nauki oparta na systemie powtórek, stworzona w Flutterze. Pomaga w opanowaniu materiału na podstawie własnych baz pytań.

## 🚀 Wypróbuj online
Aplikacja jest dostępna pod adresem: **[https://dimagolt.github.io/testowniko/](https://dimagolt.github.io/testowniko/)**

## 📝 Funkcje
- **Trzy tryby statusu:** Pytania nieotwarte, do powtórki i opanowane.
- **Inteligentne losowanie:** System skupia się na aktywnej puli pytań (domyślnie 8), mieszając nowe zadania z tymi do powtórzenia.
- **Dynamiczne trudności:** Błędna odpowiedź zwiększa liczbę wymaganych poprawnych powtórzeń dla danego pytania.
- **Obsługa plików:** Możliwość ładowania własnych testów w formacie `.txt`.
- **Pamięć sesji:** Aplikacja zapamiętuje ostatnio używane testy (treść i nazwę) oraz Twoje ustawienia.
- **Motywy:** Jasny i ciemny tryb.

## 📁 Przykład pliku tekstowego (`test.txt`)
Aby załadować własny test, przygotuj plik `.txt` według poniższego wzorca:

```text
1. Jakiego koloru jest bezchmurne niebo w środku słonecznego dnia?
a. Zielonego
*b. Niebieskiego
c. Czerwonego

2. Które z poniższych zwierząt są ssakami?
*a. Pies
b. Krokodyl
*c. Kot
d. Żaba

3. Ile wynosi wynik dodawania 2 + 2?
a. 3
b. 5
*c. 4
```

*Zasady formatowania:*
- Pytanie musi zaczynać się od numeru i kropki (np. `1. `).
- Poprawna odpowiedź musi być poprzedzona gwiazdką `*`.
- Pytania wielokrotnego wyboru są wykrywane automatycznie, jeśli przypiszesz więcej niż jedną gwiazdkę do odpowiedzi.

## 🛠 Technologie
- Flutter Web
- Provider (zarządzanie stanem)
- Shared Preferences (pamięć lokalna)
- File Picker
