# Portal de Socis — Flutter Web

Frontend del Portal de Socis del **Club d'Escacs Torredembarra**, fet amb **Flutter Web** i allotjat a
**GitHub Pages**: `https://escacstorre.github.io/portal_soci_escacs/`

El backend és **Google Apps Script** (Codi.gs). El Flutter s'hi comunica mitjançant
**HTTP POST directe** (`fetch`) cap a `doPost(e)` del Codi.gs. Apps Script fa les operacions (Sheet, Gmail, Drive)
i retorna la confirmació a Flutter (snackbar).

---

## Arquitectura

```text
lib/
├─ main.dart         → arrencada, tema, router + EstatScope (InheritedNotifier)
├─ estat.dart        → Estat singleton + EstatScope: sessió, caché 90s, navegació, crides
├─ pont.dart         → transport Apps Script (POST text/plain → doPost)
├─ models.dart       → models tipats (DadesSoci, GestorDades, ProfeDades amb sessions/festius/anyCurs)
├─ traduccions.dart  → traduccions: Apps Script > fallback local
├─ estils.dart       → colors, TextStyles, decoCard, IconaClub, Carda, BotoGran
├─ ginys.dart        → Capcalera, IdiomaMenu, Xips, CampText, CampDataTrim/Data (anyCurs>=8, Feb29), CalendariGraella per mes (✔/✖, navegació), selectors d'arxius (via serveis/fitxers.dart)
├─ serveis/
│  ├─ emmagatzematge.dart → abstracció localStorage (web/stub) per wasm
│  ├─ fitxers.dart         → triaArxiu/obrirUrl/descarregarArxiu/imprimirFormulari (web/stub)
│  └─ estat_scope.dart     → InheritedNotifier per Estat
├─ utils/dates.dart  → mostraData, normalitzaHora, DateUtils (cursAny, Feb29)
├─ widgets/
│  ├─ xip.dart, form_scaffold.dart (BastidaFormulari), pagament_toggle.dart (CommutadorPagament)
│  └─ filtra.dart
└─ pantalles/
   ├─ acces.dart       → IniciSessio, Registre (compte/quota 25€), Selector
   ├─ soci/            → inici.dart (IniciSoci, quotaVigent, vigentFins {0}), classes.dart (ClassesInici/Alta/Alumnes amb Calendari fullscreen sense hora + Al meu calendari sense hora), fitxa.dart (Fitxa, Jugadors, JugadorAnys/Alta amb Anvers DNI obligatori)
   ├─ profe.dart       → ProfePantalla (FutureBuilder, LLISTA toggle, CalendariGraella per mes amb hora + gap 16px amb €PREUS), ProfeAlumnes, FilaDataInici
   ├─ gestor/          → pagat.dart, escola.dart (Trimestres amb text @STRING@), fitxa.dart (EdicioSoci amb _filaTrimestre sempre visible, dataNaix split T), alumne.dart, comu.dart (AltaRapida)
   └─ configuracio.dart → Club/Correus/Usuaris/Sistema/Neteja
```

### Arquitectura Backend

```text
Flutter Web (frontend bonit)
    ↕ HTTP POST (fetch → doPost)
Apps Script (backend)
    ├── Google Sheets (dades)
    ├── Gmail (correus)
    └── Google Drive (fitxers)

Login.html = backup
```

- **Flutter** és el frontend principal (UI moderna)
- **Apps Script** és el backend (business logic, email, Sheet, Drive)
- **Login.html** és el frontend de respall si Flutter falla

### Flux de dades

1. `Estat.i.call(fn, args)` és l'única porta al backend.
2. Si `fn` és una lectura va amb **caché de 90 s**; si és escriptura neteja la caché i mostra la barra de progrés.
3. El transport (`pont.dart`) fa **POST** amb cos `{"fn": "...", "args": [...]}` (Content-Type `text/plain`,
   sense preflight CORS) cap a l'URL `/exec`; `doPost(e)` del Codi.gs fa dispatch a la funció i respon
   `{ok:true, data:...}` o `{ok:false, data:"#CLAU#"}`. Timeout 90 s → `ExcepcioPortal`.
4. Si el backend respon `SESSIO_CADUCADA`, l'app fa **logout automàtic** i torna al login.
5. **Impressió del formulari**: `obtenirDadesFormulari()` aporta club/compte/quota/preus; `imprimirFormulari()` genera un HTML amb logo, capçalera i taula de preus del curs actual i l'obre amb `window.open(Blob)` + `window.print()`.

**Correus i arxius** (via Apps Script):
- Els correus els envia `enviarCorreu_()` (MailApp) des del backend.
- Els arxius es pugen a Google Drive com a base64 (`guardarArxiu_`).

### Navegació

Stack propi de `Vista(nom, dades)` **sincronitzat amb l'historial del navegador**
(`pushState`/`replaceState` + `popstate`): el botó enrere del navegador funciona.

---

## Idiomes

- CA i ES de fàbrica (fallback local al codi compilat).
- Les traduccions del servidor (Apps Script) via `obtenirTraduccions()`.
- El canvi d'idioma és un **desplegable** 🌐 a la capçalera.
- Els errors del backend arriben com `#CLAU|p0#` i es tradueixen amb paràmetres `{0}`.

## Colors / disseny

Tota la paleta viu a `estils.dart`:

```dart
const pri = Color(0xFF051EF5);      // blau intens (web club)
const titol = Color(0xFF060201);    // negre
const textCol = Color(0xFF666666);  // gris text
const suau = Color(0xFFF3F3F3);     // fons targetes
const verd = Color(0xFF2E7D32);     // pagat / OK
const taronja = Color(0xFFF9A825);  // ambre (en revisió)
const vermell = Color(0xFFC62828);  // error / rebutjat
```

---

## Desenvolupament local

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome          # proves ràpides (el pont requereix el desplegament actiu)
```

## Desplegament (automàtic)

`.github/workflows/web.yml` fa, en cada push a `main`: analyze → test → build → deploy a Pages.

Requisits (només la primera vegada):

1. Settings → Pages → Source: **GitHub Actions**
2. Res més; cada push publica sola.

Per compilar en local:

```powershell
flutter build web --release --base-href /portal_soci_escacs/
```

## Backend (Apps Script)

Documentat al README del projecte principal (`H:\Mi unidad\Web\Soci\README.md`).

- `Codi.gs` amb `doGet(e)` (serveix `Login.html`, el fallback HTML) i `doPost(e)` (API JSON per al Flutter)
- **Correus**: `enviarCorreu_()` amb plantilles de la fulla `Config`
- **Arxius**: `guardarArxiu_()` puja a Google Drive, `obtenirArxiu()` descarrega
- **Impressió**: `imprimirFormulari()` genera al moment un HTML imprimible (logo SVG, compte, quota i preus base del curs actual) i l'obre en una pestanya nova amb `window.print()` — sense PDF estàtic, sempre adaptat
- **Menu Sheet**: gestió d'admins, triggers, eines (exportar CSV, estadístiques, netejar sessions)
- Desplegar sempre amb *Implementar → Nueva versión*

### Permisos Drive

Quan un usuari rep els rols **Admin** o **Junta**, automàticament se li comparteix la carpeta
`Portal Socis - Arxius` del Google Drive del club (`addViewer`). Així pot veure els enllaços
de fitxers (rebuts, fotos DNI, etc.) directament al navegador.

Quan es treu un rol Admin/Junta (o s'elimina l'usuari), es deixa de compartir (`removeViewer`).

**Requisit:** L'usuari ha d'estar logat amb el compte de Google que rep el shared folder.

## Disseny actualitzat 2026-09

- **Profe:** `CalendariGraella` per mes amb `< >`, per defecte mes actual, gap 16px, `FutureBuilder` fix càrrega.
- **Soci:** `Classes→Alumnes` botó `Calendari` → `Dialog.fullscreen` (només `X`) sense hora + `descarregarICSSenseHora`.
- **Trimestres:** `CampDataTrim` anyCurs `>=8` + `ultimDia` Feb29, `definirCfg @STRING@` fixa inversió.
- **Alta alumne:** `✓ Desat correctament` verd, `intentat=false` després de guardar.
- **Alta jugador:** Anvers DNI obligatori.
- **Fitxa:** `dataNaix split T` fixa `29T22.../04/2010`.
- **Inici:** `vigentFins {0}` amb params.

## Millores futures opcionals

- Migrar `dart:html` → `package:web` + `dart:js_interop` (requisit per a WASM) — parcialment fet via `serveis/*_web/_stub`
- go_router per deep-links complets
- Tests de widget per a les pantalles crítiques — fet parcial (22 tests)
