# 📚 BookTracker

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue?style=for-the-badge&logo=apple" alt="iOS 17.0+">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/SwiftUI-4.0-purple?style=for-the-badge&logo=swift" alt="SwiftUI">
  <img src="https://img.shields.io/badge/SwiftData-1.0-green?style=for-the-badge&logo=apple" alt="SwiftData">
</p>

<p align="center">
  <strong>📖 Tu compañero de lectura personal</strong>
  <br>
  Rastrea tus sesiones de lectura, gestiona tu biblioteca y alcanza tus metas con Live Activities y Dynamic Island
</p>

---

## ✨ Características Principales

### 📚 Gestión de Biblioteca
- **Agregar libros** manualmente o buscar en Google Books
- **Estados de lectura**: Lista de deseos → Por leer → Leyendo → Finalizado/Abandonado
- **Seguimiento de propiedad**: Propio, Prestado, No lo tengo
- **Calificaciones y reseñas** personales
- **Portadas automáticas** desde Google Books API

### 📂 Colecciones de Libros
- **Crear colecciones** personalizadas con portada
- **Agregar/quitar libros** de colecciones
- **Vista en grid** adaptativo con búsqueda
- **Detalle de colección** con resumen de estados

### ⏱️ Sesiones de Lectura
- **Timer en tiempo real** para tus sesiones
- **Pausar y reanudar** sin perder el progreso
- **Registro de páginas** leídas por sesión
- **Historial completo** de sesiones por libro
- **Cálculo automático** de duración

### 🏝️ Live Activities & Dynamic Island
- **Dynamic Island** mostrando tu sesión activa
- **Lock Screen widget** con timer en vivo
- **Notificaciones interactivas** para controlar la sesión
- **Deep linking** - toca para volver directamente a tu sesión

### 🏠 Dashboard Inteligente
- **Leyendo actualmente**: Tus 3 libros más recientes en progreso
- **Próximos**: Libros listos para empezar
- **Terminados recientemente**: Tu historial de logros
- **Widget de estadísticas** con racha, velocidad y estado de biblioteca
- **Mensaje de bienvenida** personalizado con nombre de usuario

### 📊 Estadísticas y Dashboard
- **Heatmap de lectura** estilo GitHub (contribución diaria)
- **Progreso vs meta anual** de libros
- **Gráfico de esfuerzo mensual** (minutos por mes)
- **Racha de lectura** (días consecutivos)
- **Total de páginas** y promedio por hora
- **Estado de biblioteca** (leídos, pendientes, leyendo, abandonados)

### 🎯 Metas de Lectura
- **Meta anual de libros** a leer
- **Meta diaria de minutos** de lectura (opcional)
- **Seguimiento de progreso** visual
- **Historial de metas** por año

### ⚙️ Configuración
- **Modo oscuro/claro/sistema** personalizable
- **Perfil de usuario** con avatar (emoji) y nombre
- **Uso de almacenamiento** de portadas
- **Notificaciones** de lectura

### 🔍 Búsqueda Inteligente
- **Integración con Google Books API**
- **Búsqueda por título, autor o ISBN**
- **Importación directa** con metadatos completos
- **Prevención de duplicados**

---

## 🏗️ Arquitectura

BookTracker sigue los principios de **Clean Architecture** con un diseño orientado al dominio (DDD):

```
┌─────────────────────────────────────────────────────────────────┐
│                      📱 PRESENTATION                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │    Views    │  │  ViewModels │  │  Components │              │
│  │  (SwiftUI)  │  │ (@Observable)│  │  (DS/UI)   │              │
│  └──────┬──────┘  └──────┬──────┘  └─────────────┘              │
│         │                │                                       │
│  Features: Home, Books, BookCollection, ReadingGoals,           │
│            Statistics, Settings, Search, ReadingSessions        │
└─────────┼────────────────┼───────────────────────────────────────┘
          │                │
          ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        🧠 DOMAIN                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  Entities   │  │  Use Cases  │  │  Services   │              │
│  │ (Pure Swift)│  │  (40+ files)│  │ (Statistics)│              │
│  └─────────────┘  └──────┬──────┘  └─────────────┘              │
│                          │                                       │
│  Entities: Book, ReadingSession, BookCollection, ReadingGoal    │
│                          │                                       │
│  ┌───────────────────────┴───────────────────────┐              │
│  │              Interfaces (Protocols)            │              │
│  └───────────────────────┬───────────────────────┘              │
└──────────────────────────┼───────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    🔧 INFRASTRUCTURE                             │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │          Repositories (4 implementaciones)               │    │
│  └─────────────────────────────────────────────────────────┘    │
│         │                                    │                   │
│         ▼                                    ▼                   │
│  ┌─────────────┐                      ┌─────────────┐           │
│  │   Local     │                      │   Remote    │           │
│  │ (SwiftData) │                      │(GoogleBooks)│           │
│  └─────────────┘                      └─────────────┘           │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   Widgets   │  │ LiveActivity│  │ ImageCache  │              │
│  │  Extension  │  │   Manager   │  │ + Processor │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

### 📁 Estructura del Proyecto

```
booktracker/
├── 🧠 Domain/                          # Capa de Dominio (Pura)
│   ├── Entities/                       # Modelos de negocio
│   │   ├── Book.swift                  # Estado: wishlist→reading→finalized
│   │   ├── ReadingSession.swift        # Sesiones con validación
│   │   ├── BookCollection.swift        # Colecciones de libros
│   │   └── ReadingGoal.swift           # Metas de lectura anuales
│   │
│   ├── Interfaces/                     # Protocolos (contratos)
│   │   ├── BookRepositoryProtocol
│   │   ├── ReadingSessionRepositoryProtocol
│   │   ├── BookCollectionRepositoryProtocol
│   │   ├── ReadingGoalRepositoryProtocol
│   │   ├── ImageProcessorService
│   │   └── ExternalBookProviderProtocol
│   │
│   ├── UseCases/                       # Lógica de negocio (40+ casos)
│   │   ├── Book/                       # CRUD + cambios de estado
│   │   ├── ReadingSession/             # Iniciar, pausar, finalizar
│   │   ├── BookCollection/             # CRUD + gestión de libros
│   │   ├── ReadingGoal/                # CRUD de metas anuales
│   │   └── Stats/                      # Heatmap, dashboard, esfuerzo mensual
│   │
│   └── Services/                       # Servicios de dominio
│       ├── ReadingStatisticsService    # Cálculo de estadísticas
│       ├── LibraryStatisticsService    # Estado de biblioteca
│       └── ReadingProgressService      # Progreso de lectura
│
├── 🔧 Infraestructure/                 # Capa de Infraestructura
│   ├── DataSources/
│   │   ├── Local/SwiftData/            # Persistencia local
│   │   │   ├── Models/                 # BookSD, ReadingSessionSD, etc.
│   │   │   ├── *DataSource.swift       # Operaciones CRUD
│   │   │   └── Mappers/                # Domain ↔ SwiftData
│   │   │
│   │   └── Remote/GoogleBooks/         # API externa
│   │       ├── GoogleBooksProvider     # Cliente HTTP
│   │       ├── GoogleBooksDTO          # Data Transfer Objects
│   │       └── GoogleBookMapper        # DTO → Domain
│   │
│   ├── Repositories/                   # Implementaciones concretas
│   │   ├── BookRepositoryImpl
│   │   ├── ReadingSessionRepositoryImpl
│   │   ├── BookCollectionRepositoryImpl
│   │   └── ReadingGoalRepositoryImpl
│   │
│   ├── Services/
│   │   ├── ImageCacheManager           # Cache de portadas
│   │   ├── ImageProcessor              # Redimensionar y comprimir imágenes
│   │   └── LiveActivities/             # Dynamic Island
│   │
│   └── Widgets/                        # Extensión de widgets
│       └── LiveActivities/ReadingSession/
│
├── 📱 Presentation/                    # Capa de Presentación
│   ├── Common/
│   │   └── AppTheme.swift              # Tema (dark/light/system)
│   │
│   ├── Features/
│   │   ├── Home/                       # Dashboard principal
│   │   │   └── Widgets/                # StatsResumeWidget, CurrentReadingWidget
│   │   ├── Books/                      # Lista, detalle, formulario
│   │   │   ├── BookList/               # Filtros y búsqueda
│   │   │   ├── BookDetail/             # Vista detallada
│   │   │   ├── BookForm/               # Crear/editar
│   │   │   └── BookSessions/           # Historial de sesiones
│   │   ├── BookCollection/             # Gestión de colecciones
│   │   │   ├── BookCollectionList/     # Grid con búsqueda
│   │   │   ├── BookCollectionForm/     # Crear/editar con CoverPicker
│   │   │   ├── BookCollectionDetail/   # Vista detallada
│   │   │   └── BookSelection/          # Modal de selección
│   │   ├── ReadingGoals/               # Formulario de metas
│   │   │   └── ReadingGoalForm/        # Stepper de libros y minutos
│   │   ├── Statistics/                 # Dashboard de estadísticas
│   │   │   ├── DashboardView           # Vista principal
│   │   │   └── Widgets/                # Heatmap, gráficos, progreso
│   │   ├── Settings/                   # Configuración
│   │   │   └── SettingsView            # Tema, perfil, almacenamiento
│   │   ├── ReadingSessions/            # Timer y controles
│   │   └── Search/                     # Búsqueda en Google Books
│   │
│   ├── Ds/                             # Design System
│   └── Components/                     # Componentes reutilizables
│       ├── UI/                         # Botones, cards, etc.
│       ├── Form/                       # Inputs, pickers
│       └── Layout/                     # Estructura y navegación
│
├── DIContainer.swift                   # 💉 Inyección de dependencias
├── GlobalSessionManager.swift          # 🌐 Estado global de sesión
├── MainTabView.swift                   # 📑 Navegación por tabs (5 tabs)
└── booktrackerApp.swift                # 🚀 Entry point

ReadingSessionWidget/                   # 📦 Widget Extension
├── ReadingSessionWidgetLiveActivity    # Dynamic Island + Lock Screen
└── ReadingSessionWidgetBundle          # Configuración del widget
```

---

## 🛠️ Stack Tecnológico

| Categoría | Tecnología |
|-----------|------------|
| 🎨 **UI Framework** | SwiftUI 4.0 |
| 💾 **Persistencia** | SwiftData |
| ⚡ **Concurrencia** | Swift Concurrency (async/await) |
| 🏝️ **Live Activities** | ActivityKit |
| 📱 **Widgets** | WidgetKit |
| 🔄 **Estado** | @Observable, @State |
| 🌐 **Networking** | URLSession nativo |
| 📖 **API Externa** | Google Books API |
| 🏗️ **Arquitectura** | Clean Architecture + DDD |
| 💉 **DI** | Contenedor de dependencias manual |

---

## 📊 Modelo de Datos

### 📖 Book

```swift
Book {
    id: UUID
    title: String                    // Título del libro
    author: String                   // Autor
    totalPages: Int                  // Total de páginas
    currentPage: Int                 // Página actual
    status: BookStatus               // wishlist | toRead | reading | finalized | abandoned
    ownership: BookOwnership         // owner | notOwner | borrowed

    // Metadatos
    isbn: String?
    editorial: String?
    genre: String?
    overview: String?
    coverUrl: String?

    // Calificación
    userRating: Int?                 // 1-5 estrellas
    userReview: String?
    globalRating: Double?

    // Timeline
    startDate: Date?                 // Inicio de lectura
    endDate: Date?                   // Fin de lectura
    abandonReason: String?           // Razón de abandono
}
```

### ⏱️ ReadingSession

```swift
ReadingSession {
    id: UUID
    bookId: UUID                     // Referencia al libro
    startTime: Date                  // Inicio de sesión
    endTime: Date?                   // Fin (nil = activa)
    startPage: Int                   // Página inicial
    endPage: Int?                    // Página final

    // Calculados
    duration: TimeInterval           // Duración de la sesión
    isActive: Bool                   // endTime == nil
    pagesRead: Int                   // endPage - startPage
}
```

### 📂 BookCollection

```swift
BookCollection {
    id: UUID
    name: String                     // Nombre de la colección
    description: String?             // Descripción opcional
    cover: String?                   // Nombre archivo de portada
    bookIds: Set<UUID>               // IDs de libros en la colección
    createdAt: Date
    updatedAt: Date
}
```

### 🎯 ReadingGoal

```swift
ReadingGoal {
    id: UUID
    year: Int                        // Año de la meta
    targetBooks: Int                 // Libros objetivo (>= 1)
    targetMinutesPerDay: Int?        // Minutos diarios (1-1440, opcional)
    createdAt: Date
}
```

---

## 🚀 Empezando

### Prerrequisitos

- 📱 iOS 17.0+
- 🛠️ Xcode 15.0+
- 🔑 API Key de Google Books (opcional, para búsqueda)

### Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/booktracker.git
   cd booktracker
   ```

2. **Configura la API Key de Google Books** (opcional)

   Crea un archivo `Secrets.xcconfig` en la raíz del proyecto:
   ```
   GOOGLE_BOOKS_API_KEY = tu_api_key_aquí
   ```

3. **Abre el proyecto en Xcode**
   ```bash
   open booktracker.xcodeproj
   ```

4. **Compila y ejecuta** ▶️

---

## 🗺️ Roadmap

### ✅ Completado
- [x] Gestión completa de libros (CRUD)
- [x] Sistema de estados de lectura
- [x] Sesiones de lectura con timer
- [x] Live Activities & Dynamic Island
- [x] Integración con Google Books API
- [x] Dashboard con secciones inteligentes
- [x] Deep linking desde notificaciones
- [x] Cache de imágenes
- [x] Colecciones de libros (CRUD completo con UI)
- [x] Pantalla de estadísticas (Heatmap, gráficos, progreso)
- [x] Pantalla de configuración (tema, perfil, almacenamiento)
- [x] Metas de lectura anuales con UI
- [x] Modo oscuro/claro/sistema
- [x] Procesador de imágenes (redimensionar/comprimir)
- [x] Widget de estadísticas en Home

### 🔮 Futuro
- [ ] Sincronización con iCloud
- [ ] Widget de estadísticas para pantalla de inicio
- [ ] Exportar/importar biblioteca
- [ ] Apple Watch companion app
- [ ] Integración con Goodreads
- [ ] Audiobooks con reproductor

---

## 📈 Métricas del Proyecto

| Métrica | Valor |
|---------|-------|
| 📁 **Archivos Swift** | 152+ |
| 🧠 **Use Cases** | 40+ |
| 📱 **ViewModels** | 15+ |
| 🎨 **Componentes UI** | 25+ |
| 🔌 **Data Sources** | 5 (4 locales + 1 remoto) |
| 📦 **Repositorios** | 4 |
| 📊 **Entidades** | 4 |

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si quieres mejorar BookTracker:

1. 🍴 Haz fork del proyecto
2. 🌿 Crea tu rama de feature (`git checkout -b feature/AmazingFeature`)
3. 💾 Commit tus cambios (`git commit -m 'Add: AmazingFeature'`)
4. 📤 Push a la rama (`git push origin feature/AmazingFeature`)
5. 🔃 Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

<p align="center">
  Hecho con ❤️ y mucha ☕ para los amantes de la lectura
  <br><br>
  ⭐ Si te gusta el proyecto, ¡dale una estrella! ⭐
</p>
