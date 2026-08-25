# Portal de Socis — Flutter Web

Frontend del Portal de Socis del **Club d'Escacs Torredembarra**, fet amb **Flutter Web** i allotjat a
**GitHub Pages**: `https://escacstorre.github.io/portal_soci_escacs/`

El backend és **Google Sheets + Apps Script**. Aquesta app hi accedeix de dues vies:
- **Directament** via Google Sheets API (per a dades públiques: traduccions, configuració)
- **A través d'Apps Script** (per a dades privades, correus Gmail i pujada d'arxius a Drive)

---

## Arquitectura

```text
lib/
├─ main.dart         → arrencada, tema, router de vistes + overlays globals (progrés/toast)
├─ estat.dart        → Estat singleton: sessió, caché de lectures, navegació, crides
├─ pont.dart         → transport cap a Apps Script (iframe pont + postMessage)
├─ servei_fulls.dart → accés directe al Google Sheet (API v4 REST) per a traduccions i config
├─ models.dart       → models tipats (DadesSoci, GestorDades, ProfeDades…)
├─ traduccions.dart  → traduccions: full Google Sheets > Apps Script > fallback local
├─ ginys.dart        → colors, Capcalera, xips, CampText, selector d'arxius, idioma…
└─ pantalles/
   ├─ acces.dart       → IniciSessioPantalla · RegistrePantalla · SelectorPantalla
   ├─ soci.dart        → IniciSociPantalla, ClassesInici/Alta/AlumnesPantalla, TrimestresPantalla, FitxaIniciPantalla, Jugadors/Anys/AltaPantalla
   ├─ profe.dart       → ProfePantalla, ProfeAlumnesPantalla, FilaDataInici
   ├─ gestor.dart      → AdminIniciPantalla, PagatPantalla, EdicioSociPantalla, JugadorEdicioPantalla, AlumneEdicioPantalla, AltaRapidaPantalla, EscolaPantalla
   └─ configuracio.dart → ConfiguracioPantalla, EditorBloc, PestanyaUsuaris, PestanyaNeteja, FormulariUsuari
```

### Doble accés al backend

| Canal | Què hi passa | Autenticació |
|-------|--------------|--------------|
| **Google Sheets API** (`servei_fulls.dart`) | Traduccions del full `Traduccions`, configuració pública del full `Config` | Clau d'API + full públic |
| **Apps Script Bridge** (`pont.dart`) | Login, dades de socis/alumnes/jugadors, pagaments, correus (Gmail), pujada d'arxius (Drive) | Token de sessió |

### Flux de dades

**Lectures públiques** (sense login):
1. `ServeiFulls().llegeixTraduccions()` → llegeix directament el full `Traduccions` via HTTP REST.
2. Les traduccions del full tenen **prioritat** sobre les traduccions del servidor i les locals.

**Operacions privades** (amb login):
1. `Estat.i.crida(fn, args)` és l'única porta al backend.
2. Si `fn` és una lectura va amb **caché de 90 s**; si és escriptura neteja la caché i mostra la barra de progrés.
3. El transport (`pont.dart`) envia `{tipo:'ps-call',id,fn,args}` com a string JSON via `postMessage`
   a un iframe ocult d'1px carregat de `.../exec?page=bridge`; `Bridge.html` fa `google.script.run` i respon
   `{tipo:'ps-resp',id,ok,data}`. Timeout 90 s → `ExcepcioPortal`.
4. Si el backend respon `SESSIO_CADUCADA`, l'app fa **logout automàtic** i torna al login.

**Correus i arxius** (via Apps Script):
- Els correus es envien amb `MailApp.sendEmail()` a través del bridge.
- Els arxius es pujen a Google Drive com a base64 a través del bridge.

### Navegació

Stack propi de `Vista(nom, dades)` **sincronitzat amb l'historial del navegador**
(`pushState`/`replaceState` + `popstate`): el botó enrere del navegador funciona.

---

## Configuració del Google Sheets API

Per llegir les traduccions directament del full:

1. Crear un projecte a [Google Cloud Console](https://console.cloud.google.com/)
2. Activar l'**Google Sheets API**
3. Crear una **clau d'API** (API key)
4. Compartir el full amb **"Tothom que tingui l'enllaç pot veure-ho"**
5. Editar `lib/servei_fulls.dart` i posar:
   - `fullId`: l'ID del full (treure de la URL)
   - `clauApi`: la clau d'API

## Idiomes

- CA i ES de fàbrica (fallback local al codi compilat).
- Les traduccions del full `Traduccions` tenen **prioritat** (carregades via Google Sheets API).
- Les traduccions del servidor (Apps Script) són el segon fallback.
- El canvi d'idioma és un **desplegable** 🌐 a la capçalera.
- Els errors del backend arriben com `#CLAU|p0#` i es tradueixen amb paràmetres `{0}`.

## Colors / disseny

Tota la paleta viu a `ginys.dart`:

```dart
const pri = Color(0xFF1A5FB4);      // color principal
const titol = Color(0xFF1B2733);
const textCol = Color(0xFF3D4A57);
const suau = Color(0xFFF4F6F8);     // fons
const verd = Color(0xFF2E7D32);     // pagat / OK
const taronja = Color(0xFFB36B00);  // en revisió
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

- `Codi.gs` amb branca `doGet(e)` → `?page=bridge` serveix `Bridge.html`
- **Correus**: `MailApp.sendEmail()` amb plantilles de la fulla `Config`
- **Arxius**: `guardarArxiu_()` puja a Google Drive, `getArxiu()` descarrega
- Desplegar sempre amb *Implementar → Nueva versión*

## Millores futures opcionals

- Migrar `dart:html` → `package:web` + `dart:js_interop` (requisit per a WASM)
- go_router per deep-links complets
- Tests de widget per a les pantalles crítiques
