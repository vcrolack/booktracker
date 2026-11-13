# Salud general del proyecto

Evaluación del 2026-11-11, sobre unas 11.000 líneas de Swift y 82 commits. Hecha leyendo el código; complementa [reading-session-bugs.md](reading-session-bugs.md).

**Resumen:** la base es sólida y con buenas intenciones de arquitectura, por encima de lo habitual en un proyecto personal. El punto más débil es que no hay ningún test que respalde esa arquitectura, y casi todos los bugs encontrados vienen de ahí.

---

## ✅ Lo que está bien

- **Las capas están bien separadas.** Dominio, infraestructura y presentación están separados, y el dominio no importa SwiftData. Los modelos `@Model` están aparte de las entidades y los conectan mappers. Esto permitiría cambiar la persistencia sin tocar la lógica.
- **Las entidades protegen sus reglas.** Tienen `init` que lanzan errores, `private(set)`, y un init `reconstituting` separado para cargar desde la base de datos.
- **Todo está detrás de protocolos.** Los casos de uso y los repositorios son fáciles de sustituir y de probar.
- **El stack es moderno.** `@Observable`, Swift 6 con concurrencia estricta y `MainActor` por defecto.
- **Buenas prácticas básicas.** Los secretos están en un `.xcconfig` ignorado por git y los mensajes de commit siguen Conventional Commits.

---

## ⚠️ Lo que preocupa, por prioridad

### 1. No hay tests

La arquitectura está pensada para probarse, pero no hay target de tests. Varios de los bugs graves los habría detectado un test de pocas líneas:

- el filtro de fechas que se ignoraba
- el progreso que se reiniciaba a 0
- la racha que se cortaba en año nuevo

Es la inversión con mejor retorno ahora.

### 2. Hay lógica de negocio fuera del dominio

- La máquina de estados de la sesión (sprints, tiempo acumulado, pausa) vivía en `StartReadingSessionViewModel`.
- La duración se calculaba a mano (`endTime - startTime`) en 6 sitios distintos. Ya está centralizada en `ReadingSession.durationInSeconds`.

Cuando un valor derivado se calcula en varios lugares, tarde o temprano divergen. **Regla:** si es una regla del negocio, va en la entidad o en un caso de uso.

### 3. `DIContainer` funciona como localizador global de servicios

- Hay unas 50 referencias a `DIContainer.shared` desde `Presentation/`, y los ViewModels se crean dentro de `body`. Por ejemplo, `MainTabView` construye `HomeViewModel` en cada render; `@State` descarta los siguientes, pero igual se construyen.
- Los `#Preview` usan el contenedor real, así que **escriben en la base de datos persistente de verdad**.

**Sugerencia:** un contenedor en memoria para previews y tests, e inyectar factories por `Environment` en vez de llamar al singleton.

### 4. El estado de "sesión activa" tiene varias fuentes de verdad

- `GlobalSessionManager`, `HomeView` (con dos `sheet` propios, uno muerto) y `HomeViewModel` consultan y presentan la sesión activa cada uno por su cuenta.
- `GetActiveReadingSessionUseCase` borra datos dentro de un getter.

Muchos de los bugs medios de [reading-session-bugs.md](reading-session-bugs.md) vienen de aquí.

### 5. No hay transacciones

Cada data source hace su propio `context.save()`. Los casos de uso que guardan dos cosas (por ejemplo, sesión más progreso del libro en `FinishReadingSessionUseCase` y `UpdateReadingSessionUseCase`) pueden quedar a medias si falla la segunda. Como todo comparte el `mainContext`, sería fácil hacer un solo `save` por caso de uso.

### 6. Todo corre en el hilo principal

Los repositorios son `async`, pero en la práctica son síncronos sobre `modelContainer.mainContext`. Con pocos datos no importa. Las estadísticas, en cambio, traen el historial de sesiones, y con años de uso eso se va a notar en el scroll.

**No es urgente.** Más adelante, `@ModelActor` para las consultas pesadas.

### 7. El manejo de errores es básico

- `DataSourceError` envuelve un `localizedDescription` y pierde el tipo original, y al usuario le llegan mensajes técnicos.
- Hay 47 `print()` y ningún `Logger` (`os.Logger`).

### 8. La extensión de widget tiene restos de la plantilla que ven los usuarios

`ReadingSessionWidgetBundle` registra:

- `ReadingSessionWidget`: el widget de ejemplo ("My Widget", con un emoji).
- `ReadingSessionWidgetControl`: un Control "Start Timer" que no hace nada y siempre devuelve `true` ("On").

Aparecen en la galería de widgets y en el Centro de Control del usuario. Hay que quitarlos del bundle y dejar solo `ReadingSessionWidgetLiveActivity`.

### 9. Inconsistencias menores

- `BookListViewModel` usa `BookRepositoryProtocol` directamente y se salta los casos de uso.
- Nombres desalineados: la carpeta `Infraestructure` mezcla español e inglés, y hay cabeceras de archivo que no coinciden con el nombre (`Untitled.swift` en `GlobalSessionManager.swift`, `UpdateBookProgresUseCase.swift`).
- El README dice iOS 17+, pero `IPHONEOS_DEPLOYMENT_TARGET = 26.2` y la app usa APIs de iOS 26 como `tabViewBottomAccessory`.
- La app usa Swift 6 y el widget Swift 5. Además, `ReadingSessionLiveActivityManager.swift` se compila dentro del widget sin necesidad (solo hace falta `ReadingSessionAttributes.swift`).
- Con Xcode 27 el proyecto no compilaba por el aislamiento `@MainActor` de `ReadingSessionAttributes`. **Ya resuelto** con `nonisolated`.

---

## 🧭 Recomendaciones, en orden

1. **Crear un target de tests.** Empezar por el dominio (`ReadingSession`, `Book`) y por los data sources con un `ModelContainer` en memoria. Con eso se cubre la mayor parte del riesgo.
2. **Limpiar el widget.** Quitar los widgets de plantilla del bundle; son 5 minutos.
3. **Una sola fuente de verdad para la sesión activa.** Que `GlobalSessionManager` sea el único dueño de ese estado; esto resuelve de paso varios bugs medios del reporte.
4. **Contenedor en memoria para previews** y, poco a poco, sacar `DIContainer.shared` de las vistas.

El resto (transacciones, `@ModelActor`, logging) puede esperar a que la app crezca.
