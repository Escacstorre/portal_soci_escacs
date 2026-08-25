# Portal de Socis — Flutter Web

Frontend del Portal de Socis del **Club d'Escacs Torredembarra**, fet amb **Flutter Web** i allotjat a
**GitHub Pages**: `https://escacstorre.github.io/portal_soci_escacs/`

El backend és el mateix de sempre (**Google Sheets + Apps Script**); aquesta app només el consumeix.

---

## Arquitectura

```text
lib/
├─ main.dart         → arrencada, tema, router de vistes + overlays globals (progrés/toast)
├─ estat.dart        → Estat singleton: sessió, caché de lectures, navegació, crides
├─ pont.dart         → transport cap a Apps Script (iframe pont + postMessage)
├─ models.dart       → models tipats (DadesSoci, GestorDades, ProfeDades…)
├─ traduccions.dart  → diccionaris CA/ES + traduccions dinàmiques (fulla Traduccions)
├─ ginys.dart        → colors, Capcalera, xips, CampText, selector d'arxius, idioma…
└─ pantalles/
   ├─ acces.dart       → IniciSessioPantalla · RegistrePantalla · SelectorPantalla
   ├─ soci.dart        → IniciSociPantalla, ClassesInici/Alta/AlumnesPantalla, TrimestresPantalla, FitxaIniciPantalla, Jugadors/Anys/AltaPantalla
   ├─ profe.dart       → ProfePantalla, ProfeAlumnesPantalla, FilaDataInici
   ├─ gestor.dart      → AdminIniciPantalla, PagatPantalla, EdicioSociPantalla, JugadorEdicioPantalla, AlumneEdicioPantalla, AltaRapidaPantalla, EscolaPantalla
   └─ configuracio.dart → ConfiguracioPantalla, EditorBloc, PestanyaUsuaris, PestanyaNeteja, FormulariUsuari
```

### Flux de dades

1. `Estat.i.crida(fn, args)` és l'única porta al backend.
2. Si `fn` és una lectura va amb **caché de 90 s**; si és escriptura neteja la caché i mostra la barra de progrés.
3. El transport (`pont.dart`) envia `{tipo:'ps-call',id,fn,args}` com a string JSON via `postMessage`
   a un iframe ocult d'1px carregat de `.../exec?page=bridge`; `Bridge.html` fa `google.script.run` i respon
   `{tipo:'ps-resp',id,ok,data}`. Timeout 90 s → `ExcepcioPortal`.
4. Si el backend respon `SESSIO_CADUCADA`, l'app fa **logout automàtic** i torna al login.

### Navegació

Stack propi de `Vista(nom, dades)` **sincronitzat amb l'historial del navegador**
(`pushState`/`replaceState` + `popstate`): el botó enrere del navegador funciona.

---

## Idiomes

- CA i ES de fàbrica; la fulla `Traduccions` pot afegir-ne més (apareixen automàticament al desplegable).
- El canvi d'idioma és un **desplegable** 🌐 a la capçalera (no un botó que alterna).
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

Canviar la paleta = editar aquestes constants (cap hex dispers pel codi).

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

Per compilar en local (comprovació prèvia):

```powershell
flutter build web --release --base-href /portal_soci_escacs/
```

## Backend (Apps Script)

Documentat al README del projecte principal (`H:\Mi unidad\Web\Soci\README.md`).
Resum del que hi ha allà:

- `Codi.gs` amb branca `doGet(e)` → `?page=bridge` serveix `Bridge.html`
- Desplegar sempre amb *Implementar → Nueva versión*

## Millores futures opcionals

- Migrar `dart:html` → `package:web` + `dart:js_interop` (requisit per a WASM; no urgeix)
- go_router per deep-links complets (ara el hash no restaura la vista exacta després de login)
- Tests de widget per a les pantalles crítiques
