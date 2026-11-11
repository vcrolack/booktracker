# Bugs: módulo ReadingSession y Live Activities

Revisión del 2026-11-10, hecha leyendo el código (sin compilar ni ejecutar la app). Cubre dominio, casos de uso, data source de SwiftData, ViewModel, vistas, `GlobalSessionManager` y la extensión de widget/Live Activity.

Ordenados por gravedad.

---

## 🔴 Graves

> ✅ Arreglados el 2026-11-10. Pausas persistidas en `ReadingSessionSD` (`pausedDuration`, `pausedAt`), casos de uso `PauseReadingSessionUseCase` / `ResumeReadingSessionUseCase`, filtro de fechas `[fromDate, toDate)` sobre `startTime`, y estadísticas usando `durationInSeconds`.

### ✅ 1. Cancelar una sesión puede dejar el progreso del libro en 0

**Archivo:** `booktracker/Domain/UseCases/ReadingSession/DeleteReadingSessionUseCase.swift:35`

`DeleteReadingSessionUseCase` recalcula `currentPage` como el `max(endPage)` de las sesiones que quedan, y si no queda ninguna usa `0`. `cancelSession()` usa este caso de uso.

- Ejemplo: el libro se creó con `currentPage = 120` y no tiene sesiones previas. Inicias una sesión, cancelas y el libro queda en la página 0.
- Lo mismo pasa si actualizaste la página a mano en el formulario: retrocede al `endPage` de la última sesión.

**Arreglo:** cancelar no debería tocar el progreso. Lo más simple es no llamar a `updateBookProgress` cuando la sesión borrada seguía activa (`endTime == nil`).

### ✅ 2. El tiempo en pausa no se guarda y se cuenta como tiempo leído

**Archivos:** `booktracker/Domain/Entities/ReadingSession.swift:29-32`, `booktracker/Presentation/Features/ReadingSessions/StartReadingSession/StartReadingSessionViewModel.swift:52-58`

`ReadingSession` solo guarda `startTime` y `endTime`. `accumulatedTime` vive únicamente en memoria del ViewModel.

- Al terminar, la duración es `endTime - startTime`, así que incluye todas las pausas. Las estadísticas quedan infladas.
- Al reabrir una sesión activa desde el banner o la Live Activity, el `init` del ViewModel asume que estabas leyendo y fija `accumulatedTime = now - startTime`. Si la dejaste en pausa 30 minutos, aparecen como leídos y el timer arranca corriendo.

**Arreglo:** persistir `accumulatedTime` y `isPaused`/`pausedAt` en `ReadingSessionSD` (o un `pausedDuration` total), y calcular la duración real con eso.

### ✅ 3. `fromDate` / `toDate` se ignoran en el data source

**Archivo:** `booktracker/Infraestructure/DataSources/Local/SwiftData/ReadingSessionSDDataSource.swift:91-108`

El predicate solo se arma con `bookId` e `isActive`. Las fechas nunca se aplican. Esto rompe todos los casos de uso que filtran por fecha:

- `GetWeeklyReadingSessionsUseCase`
- `GetMonthlyEffortUseCase`
- `GetReadingHeatmapUseCase`
- `GetCurrentStreakUseCase`
- `GetDashboardTodayStatsUseCase`

Todos reciben **todas** las sesiones de la historia. Además incluyen la sesión activa, cuya `durationInSeconds` sigue creciendo con el reloj.

### ✅ 4. "Terminar" queda deshabilitado para siempre si la sesión está en pausa y la app pasa a inactive

**Archivos:** `StartReadingSessionViewModel.swift:204, 216-226`, `StartReadingSessionView.swift:46, 66-75`

- `appDidEnterBackground()` pone `isRecalculatingTime = true`. Se llama también en `.inactive`, que ocurre al bajar el Centro de Control o la pantalla de notificaciones.
- `appWillEnterForeground()` solo reinicia el loop si `isReading == true`.
- El flag solo se apaga dentro del loop del timer.

Resultado: pausas, bajas el Centro de Control, vuelves, y "Terminar" queda deshabilitado hasta que le des play otra vez.

### ✅ 5. El timer de la Live Activity se reinicia en cada pausa o reanudación

**Archivo:** `ReadingSessionWidget/ReadingSessionWidgetLiveActivity.swift:31, 85, 108`

El widget usa `Text(startTime, style: .timer)` con `currentSprintStartTime` y nunca lee `accumulatedTime`. Después de pausar y reanudar, la isla muestra `0:00` mientras la app muestra, por ejemplo, `12:34`. En pausa muestra "Pausado" sin el tiempo acumulado.

**Arreglo:** pasar `startTime.addingTimeInterval(-accumulatedTime)` como inicio del timer, o usar `Text(timerInterval:pauseTime:)`, que también resuelve el estado pausado.

---

## 🟠 Medios

### 6. Race en `startActivity` que mata la Live Activity recién creada

**Archivo:** `booktracker/Infraestructure/Widgets/LiveActivities/ReadingSession/ReadingSessionLiveActivityManager.swift:38-40`

```swift
if currentActivity != nil { Task { await endActivity() } }
...
currentActivity = try Activity.request(...)
```

El `Task` corre *después* de que `startActivity` retorna, cuando `currentActivity` ya apunta a la actividad **nueva**. `endActivity()` la termina de inmediato.

- Se dispara cuando queda una referencia vieja, por ejemplo si `cancelSession` falla en el delete. En ese caso nunca se llama a `endActivity` (`StartReadingSessionViewModel.swift:120-121`).

**Arreglo:** capturar la actividad vieja en una variable local y terminar esa, no `currentActivity`.

### 7. Al recuperar una actividad existente no se sincroniza su estado

**Archivo:** `ReadingSessionLiveActivityManager.swift:28-32`

Si ya hay una actividad para ese libro, `startActivity` la reutiliza y hace `return` sin `update`. Si quedó en "Pausado" (o con un `startTime` viejo), sigue así aunque el ViewModel diga que estás leyendo.

### 8. Autor incorrecto en la Live Activity

**Archivo:** `StartReadingSessionViewModel.swift:83`

Se pasa `author: book.title`, cuando debería ser `book.author`. Hoy no se ve porque la actividad casi siempre se recupera en vez de crearse (punto 7), pero aparece apenas se cree desde esa ruta.

### 9. Tocar la Live Activity con la app cerrada no abre la sesión

**Archivos:** `booktracker/MainTabView.swift:88-96`, `booktracker/Presentation/Common/RootView.swift`

`onOpenURL` vive en `MainTabView`, pero:

- Durante los 2,5 s del splash, `MainTabView` todavía no existe, así que la URL se pierde.
- Aunque existiera, `sessionManager.activeSession` sigue en `nil` hasta que termina `checkActiveSession()`, así que el `if` falla.

**Arreglo:** mover `onOpenURL` a `RootView` o al `WindowGroup`, guardar un flag "pendiente de abrir" y presentar la hoja cuando cargue la sesión. Revisar también que el scheme `booktracker` esté registrado: no hay `CFBundleURLTypes` en el proyecto.

### 10. Live Activities huérfanas

**Archivo:** `booktracker/GlobalSessionManager.swift`

Nunca se reconcilian las actividades del sistema con la base de datos al arrancar. Si la app se cierra después de guardar el fin de la sesión pero antes de `endActivity()`, o si se borra un libro con una sesión activa (`DeleteBookUseCase` borra sus sesiones), la actividad queda viva hasta que iOS la mata (unas 8 h).

**Arreglo:** en `checkActiveSession()`, terminar toda actividad cuyo `bookId` no coincida con la sesión activa, o todas si no hay sesión.

### 11. La hoja se puede cerrar deslizando y el ViewModel queda vivo

**Archivos:** `StartReadingSessionView.swift`, `StartReadingSessionViewModel.swift:194-214`

- `StartReadingSessionView` no tiene `.interactiveDismissDisabled`. Al deslizarla hacia abajo, la sesión queda activa (aparece el banner), pero el pausado nunca se persiste (punto 2).
- El `timerTask` captura `self` de forma fuerte y nadie lo cancela (no hay `onDisappear`). El ViewModel queda en memoria con un loop corriendo cada segundo. Cada vez que se reabre desde el banner se crea otro.

**Arreglo:** `[weak self]` en el Task, cancelar en `onDisappear`, y decidir si deslizar significa "minimizar" (y entonces persistir el estado) o bloquearlo.

### 12. Race al primer play

**Archivo:** `StartReadingSessionViewModel.swift:93-173`

`toggleSession()` lanza `Task { await startTimer() }`, que hace un `await` del create. Si el usuario toca pausa durante ese `await`, `pauseTimer()` corre primero. Después `startTimer` continúa, fija `currentSprintStartTime` y arranca el loop con `isReading == false`: el timer avanza en pausa.

**Arreglo:** deshabilitar el botón mientras se crea la sesión.

---

## 🟡 Menores

- **`finishSession` termina la Live Activity aunque falle el guardado** (`StartReadingSessionViewModel.swift:105-113`). La sesión queda activa en la base de datos sin actividad. Mejor terminarla solo si se guardó bien. Además la función es `throws` pero nunca lanza.
- **Operaciones no atómicas.** `FinishReadingSessionUseCase` guarda la sesión y después actualiza el libro. `UpdateReadingSessionUseCase.swift:35-39` lo hace al revés: actualiza el libro y después guarda la sesión. Si falla el segundo paso quedan inconsistentes.
- **Error equivocado.** `ReadingSession.finishSession` lanza `invalidPageProgression` cuando el problema es de fechas (`ReadingSession.swift:102`); debería ser `invalidDateRange`.
- **Borrado dentro de un getter.** `GetActiveReadingSessionUseCase` borra sesiones "fantasma" en silencio, y lo llaman a la vez `HomeViewModel` y `GlobalSessionManager`. Hoy no rompe porque todo corre en `mainContext`, pero esconde bugs de origen.
- **Hoja duplicada.** `.onChange(of: isSessionSheetPresented)` en `MainTabView` llama a `checkActiveSession()`. Si falla, `clearSessionState()` cierra la hoja que el usuario acaba de abrir.
- **Timer cortado.** `compactTrailing` tiene `maxWidth: 30`, así que pasada la primera hora (`1:00:00`) el timer se corta.
- **Sin límite de duración.** Si alguien olvida una sesión abierta, la Live Activity muere a las ~8 h pero la sesión sigue sumando días. Conviene un `staleDate` y un tope de duración al reabrir.
- **Código muerto.** `showingActiveSessionSheet` en `HomeView` nunca se pone en `true`, así que esa hoja no se usa.

---

## Prioridad sugerida

Empezar por los puntos 1, 3, 4, 5 y 6: son los que más impacto tienen en los datos y en lo que ve el usuario.
