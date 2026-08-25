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
├─ main.dart         → arrencada, tema, router de vistes + overlays globals (progrés/toast)
├─ estat.dart        → Estat singleton: sessió, caché de lectures, navegació, crides
├─ pont.dart         → transport cap a Apps Script (HTTP POST → doPost)
├─ models.dart       → models tipats (DadesSoci, GestorDades, ProfeDades…)
├─ traduccions.dart  → traduccions: Apps Script > fallback local
├─ estils.dart       → colors del club, TextStyles, decoracions i widgets (IconaClub SVG, Carda, BotoGran…)
├─ ginys.dart        → Capcalera, IdiomaMenu, xips, CampText, selector d'arxius…
└─ pantalles/
   ├─ acces.dart       → IniciSessioPantalla · RegistrePantalla · SelectorPantalla
   ├─ soci.dart        → IniciSociPantalla, ClassesInici/Alta/AlumnesPantalla, TrimestresPantalla, FitxaIniciPantalla, Jugadors/Anys/AltaPantalla
   ├─ profe.dart       → ProfePantalla, ProfeAlumnesPantalla, FilaDataInici
   ├─ gestor.dart      → AdminIniciPantalla (amb ⚙), PagatPantalla, EdicioSociPantalla, JugadorEdicioPantalla, AlumneEdicioPantalla, AltaRapidaPantalla, EscolaPantalla
   └─ configuracio.dart → ConfiguracioPantalla, EditorBloc, PestanyaUsuaris, PestanyaNeteja, FormulariUsuari
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
- **Menu Sheet**: gestió d'admins, triggers, eines (exportar CSV, estadístiques, netejar sessions)
- Desplegar sempre amb *Implementar → Nueva versión*

## Millores futures opcionals

- Migrar `dart:html` → `package:web` + `dart:js_interop` (requisit per a WASM)
- go_router per deep-links complets
- Tests de widget per a les pantalles crítiques
