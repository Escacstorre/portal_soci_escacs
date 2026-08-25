class Traduccions {
  Traduccions._();
  static final Traduccions instance = Traduccions._();

  String lang = 'CA';
  Map<String, dynamic> lx = {};

  static const Map<String, String> ca = {
    'inicia': 'Inicia la sessió', 'usuari': 'Usuari (email)', 'contra': 'Contrasenya',
    'registrar': "Registrar-se", 'oblida': "He oblidat la contrasenya", 'msgOblida': "Contacta amb el club per restablir la contrasenya.",
    'confirma': 'Confirmar contrasenya',
    'altSoci': "Alta de soci", 'nom': 'Nom', 'dni': 'DNI', 'telefon': 'Telèfon', 'email': 'Email (usuari)',
    'banc': 'Núm. Banc', 'rebutQuota': "Rebut de la quota", 'pujaFitxer': 'Puja foto/arxiu (JPG/PNG/PDF · màx 5MB)',
    'compte': 'Compte del club:', 'hola': 'Hola', 'ambFuncio': 'Amb quina funció vols entrar?',
    'tanca': 'Tanca', 'torna': '← Torna', 'canviaRol': '⇄ Canviar rol',
    'benvingut': 'Benvingut/da,', 'quotaAny': 'Quota anual', 'pagat': 'Pagat ✔', 'enRev': 'En revisió ⏳',
    'pendent': 'Pendent ○', 'rebujat': 'Rebutjat ✖',
    'veureRebut': 'veure el meu rebut', 'fitxa': 'FITXA', 'classes': 'CLASSES', 'alta': 'ALTA',
    'alumnes': 'ALUMNES', 'jugadors': 'JUGADORS',
    'inscriu': "Inscriu un alumne", 'nomAlumne': "Nom de l'alumne", 'altre': '+ Un altre',
    'llistatAlumnes': "Llistat d'alumnes",
    'trimestre': 'Trimestre', 'estat': 'Estat', 'rebut': 'Rebut', 'substituir': 'Substituir',
    'noRebut': 'No hi ha rebut', 'valida': '✔ Valida', 'valida3': "✔✔ Valida els 3 trimestres de cop",
    'fedEscacs': "Federació d'escacs", 'nomJug': 'Nom del jugador', 'cognoms': 'Cognoms',
    'dataNaix': 'Data naixement', 'adreca': 'Adreça', 'fotoDni': 'Foto DNI',
    'anyActual': 'any actual', 'anyVinent': 'any proper', 'edicio': "Edició de soci",
    'editaDades': '✏ Editar dades', 'guardar': 'Guardar', 'restabContra': '🔑 Restablir contrasenya',
    'modifica': 'Modificar', 'elimina': '🗑',
    'profeBenv': 'Benvingut,', 'llista': 'LLISTA', 'calendari': 'Calendari de divendres',
    'preus': '€(PREUS)', 'baseTrim': 'Base', 'trimJunts': '3 trimestres junts', 'serSoci': 'Ser soci',
    'alCal': '📅 Al meu calendari', 'imprimir': '🖨 Imprimir formulari',
    'dataInici': 'Data inici', 'noDefinit': 'no definit', 'escola': 'ESCOLA', 'pagatTab': 'PAGAT',
    'config': 'Configuració',
    'festius': 'Festius', 'preusTab': 'Preus', 'trimTab': 'Trimestres', 'classesTab': 'Classes', 'dies': 'Dies',
    'afigData': 'Afegeix una data (AAAA-MM-DD):', 'afig': 'Afig', 'preuDive': 'Preu/divendres (€)',
    'nomesAdmin': 'només editable per Admin',
    'horaInici': "Hora inici", 'lloc': 'Lloc', 'buscador': '🔍 Cercar', 'filtre': 'Filtre', 'tots': 'Tots',
    'actPend': 'Actius i pendents',
    'altaRapida': '📋 Alta ràpida', 'formulariRapid': "Formulari paper d'alta ràpida",
    'alumnesOpt': 'ALUMNES (opcional — nom buit = no es dona d\'alta)',
    'desa': 'Desar', 'clubBloc': 'Club', 'correusBloc': 'Correus', 'usuarisBloc': 'Usuaris',
    'sistemaBloc': 'Sistema', 'netegaBloc': 'Neteja anual',
    'juliol': 'Neteja de juliol (arxivar alumnes)', 'capdany': "Cap d'any (desmarcar fitxes)", 'executa': 'Executar',
    'nouUsuari': 'Nou usuari', 'rol': 'Rol', 'contrasenyaOpt': 'Contrasenya (buida = aleatòria)',
    'selectorTrim': 'Trimestre:', 'sessioClasse': 'sessions', 'errGen': 'Error',
    'soci': 'SOCI', 'rebutAlta': "Rebut de l'alta", 'alumneU': 'Alumne', 'portalSocis': 'Portal de Socis',
    'triaUnRol': 'Tria almenys un rol', 'multiRol': "Pots marcar-ne més d'un (p. ex. Admin + Soci)",
    'enviant': 'Enviant…', 'refrescat': 'Actualitzat ✓',
    'campObligatori': 'Aquest camp és obligatori',
  };

  static const Map<String, String> es = {
    'inicia': 'Iniciar sesión', 'usuari': 'Usuario (email)', 'contra': 'Contraseña',
    'registrar': 'Registrarse', 'oblida': '¿He olvidado la contraseña?', 'msgOblida': 'Contacta con el club para restablecer la contraseña.',
    'confirma': 'Confirmar contraseña',
    'altSoci': 'Alta de socio', 'nom': 'Nombre', 'dni': 'DNI', 'telefon': 'Teléfono', 'email': 'Email (usuario)',
    'banc': 'Núm. Banco', 'rebutQuota': 'Recibo de la cuota', 'pujaFitxer': 'Sube foto/archivo (JPG/PNG/PDF · máx 5MB)',
    'compte': 'Cuenta del club:', 'hola': 'Hola', 'ambFuncio': '¿Con qué función quieres entrar?',
    'tanca': 'Cerrar sesión', 'torna': '← Volver', 'canviaRol': '⇄ Cambiar rol',
    'benvingut': 'Bienvenido/a,', 'quotaAny': 'Cuota anual', 'pagat': 'Pagado ✔', 'enRev': 'En revisión ⏳',
    'pendent': 'Pendiente ○', 'rebujat': 'Rechazado ✖',
    'veureRebut': 'ver mi recibo', 'fitxa': 'FICHA', 'classes': 'CLASES', 'alta': 'ALTA',
    'alumnes': 'ALUMNOS', 'jugadors': 'JUGADORES',
    'inscriu': 'Inscribe un alumno', 'nomAlumne': 'Nombre del alumno', 'altre': '+ Otro',
    'llistatAlumnes': 'Listado de alumnos',
    'trimestre': 'Trimestre', 'estat': 'Estado', 'rebut': 'Recibo', 'substituir': 'Sustituir',
    'noRebut': 'No hay recibo', 'valida': '✔ Valida', 'valida3': '✔✔ Valida los 3 trimestres de golpe',
    'fedEscacs': 'Federación de ajedrez', 'nomJug': 'Nombre del jugador', 'cognoms': 'Apellidos',
    'dataNaix': 'Fecha nacimiento', 'adreca': 'Dirección', 'fotoDni': 'Foto DNI',
    'anyActual': 'año actual', 'anyVinent': 'año próximo', 'edicio': 'Edición de socio',
    'editaDades': '✏ Editar datos', 'guardar': 'Guardar', 'restabContra': '🔑 Restablecer contraseña',
    'modifica': 'Modificar', 'elimina': '🗑',
    'profeBenv': 'Bienvenido,', 'llista': 'LISTA', 'calendari': 'Calendario de viernes',
    'preus': '€(PRECIOS)', 'baseTrim': 'Base', 'trimJunts': '3 trimestres juntos', 'serSoci': 'Ser socio',
    'alCal': '📅 A mi cal.', 'imprimir': '🖨 Imprimir formulario',
    'dataInici': 'Fecha inicio', 'noDefinit': 'no definido', 'escola': 'ESCUELA', 'pagatTab': 'PAGADO',
    'config': 'Configuración',
    'festius': 'Festivos', 'preusTab': 'Precios', 'trimTab': 'Trimestres', 'classesTab': 'Clases', 'dies': 'Días',
    'afigData': 'Añade una fecha (AAAA-MM-DD):', 'afig': 'Añadir', 'preuDive': 'Precio/viernes (€)',
    'nomesAdmin': 'solo editable por Admin',
    'horaInici': 'Hora inicio', 'lloc': 'Lugar', 'buscador': '🔍 Buscar', 'filtre': 'Filtro', 'tots': 'Todos',
    'actPend': 'Activos y pendientes',
    'altaRapida': '📋 Alta rápida', 'formulariRapid': 'Formulario papel de alta rápida',
    'alumnesOpt': 'ALUMNOS (opcional — nombre vacío = no se da de alta)',
    'desa': 'Guardar', 'clubBloc': 'Club', 'correusBloc': 'Correos', 'usuarisBloc': 'Usuarios',
    'sistemaBloc': 'Sistema', 'netegaBloc': 'Limpieza anual',
    'juliol': 'Limpieza de julio (archivar alumnos)', 'capdany': 'Fin de año (desmarcar fichas)', 'executa': 'Ejecutar',
    'nouUsuari': 'Nuevo usuario', 'rol': 'Rol', 'contrasenyaOpt': 'Contraseña (vacía = aleatoria)',
    'selectorTrim': 'Trimestre:', 'sessioClasse': 'sesiones', 'errGen': 'Error',
    'soci': 'SOCIO', 'rebutAlta': 'Recibo del alta', 'alumneU': 'Alumno', 'portalSocis': 'Portal de Socios',
    'triaUnRol': 'Elige al menos un rol', 'multiRol': 'Puedes marcar más de uno (p. ej. Admin + Socio)',
    'enviant': 'Enviando…', 'refrescat': 'Actualizado ✓',
    'campObligatori': 'Este campo es obligatorio',
  };

  static const List<String> baseLangs = ['CA', 'ES'];

  List<String> get langs {
    final lls = [...baseLangs];
    for (final k in lx.keys) {
      if (!lls.contains(k)) lls.add(k);
    }
    return lls;
  }

  /// Tradueix una clau. Prioritat: traduccions del servidor (lx) > fallback local.
  String t(String k) {
    // 1. Busca les traduccions del servidor (Apps Script)
    final dLx = lx[lang];
    if (dLx is Map && dLx[k] != null) return '${dLx[k]}';
    final caLx = lx['CA'];
    if (caLx is Map && caLx[k] != null) return '${caLx[k]}';

    // 2. Fallback local (codi compilat)
    final d = lang == 'ES' ? es : ca;
    return d[k] ?? ca[k] ?? k;
  }

  String tradueixError(String msg) {
    final s = msg.trim();
    if (!s.startsWith('#') || !s.endsWith('#') || s.length < 3) return s;
    final parts = s.substring(1, s.length - 1).split('|');
    final dic = (lx[lang] ?? lx['CA'] ?? {}) as Map?;
    var txt = (dic?[parts[0]] ?? (lx['CA'] as Map?)?[parts[0]] ?? parts[0]) as String;
    for (var i = 1; i < parts.length; i++) {
      txt = txt.replaceAll('{${i - 1}}', parts[i]);
    }
    return txt;
  }

  void setLx(Map<String, dynamic>? m) {
    lx = m ?? {};
  }
}
