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
- **Acceso rápido** a todas las secciones

### 📊 Estadísticas de Lectura
- **Total de páginas** leídas
- **Promedio de páginas** por hora
- **Racha de lectura** (días consecutivos)
- **Historial detallado** por libro

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
└─────────┼────────────────┼───────────────────────────────────────┘
          │                │
          ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        🧠 DOMAIN                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  Entities   │  │  Use Cases  │  │  Services   │              │
│  │ (Pure Swift)│  │  (55 files) │  │ (Statistics)│              │
│  └─────────────┘  └──────┬──────┘  └─────────────┘              │
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
│  │                    Repositories                          │    │
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
│  │  Extension  │  │   Manager   │  │   Manager   │              │
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
│   │   └── ReadingGoal.swift           # Metas de lectura
│   │
│   ├── Interfaces/                     # Protocolos (contratos)
│   │   ├── BookRepositoryProtocol
│   │   ├── ReadingSessionRepositoryProtocol
│   │   └── ExternalBookProviderProtocol
│   │
│   ├── UseCases/                       # Lógica de negocio (30+ casos)
│   │   ├── Book/                       # CRUD + cambios de estado
│   │   ├── ReadingSession/             # Iniciar, pausar, finalizar
│   │   ├── BookCollection/             # Gestión de colecciones
│   │   └── ReadingGoal/                # Metas de lectura
│   │
│   └── Services/                       # Servicios de dominio
│       ├── ReadingStatisticsService    # Cálculo de estadísticas
│       └── ReadingProgressService      # Progreso de lectura
│
├── 🔧 Infraestructure/                 # Capa de Infraestructura
│   ├── DataSources/
│   │   ├── Local/SwiftData/            # Persistencia local
│   │   │   ├── Models/                 # BookSD, ReadingSessionSD
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
│   │   └── ReadingSessionRepositoryImpl
│   │
│   ├── Services/
│   │   ├── ImageCacheManager           # Cache de portadas
│   │   └── LiveActivities/             # Dynamic Island
│   │
│   └── Widgets/                        # Extensión de widgets
│       └── LiveActivities/ReadingSession/
│
├── 📱 Presentation/                    # Capa de Presentación
│   ├── Features/
│   │   ├── Home/                       # Dashboard principal
│   │   ├── Books/                      # Lista, detalle, formulario
│   │   │   ├── BookList/               # Filtros y búsqueda
│   │   │   ├── BookDetail/             # Vista detallada
│   │   │   ├── BookForm/               # Crear/editar
│   │   │   └── BookSessions/           # Historial de sesiones
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
├── MainTabView.swift                   # 📑 Navegación por tabs
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

### 🚧 En Desarrollo
- [ ] Pantalla de estadísticas completas
- [ ] Pantalla de configuración
- [ ] Colecciones de libros (UI)

### 🔮 Futuro
- [ ] Sincronización con iCloud
- [ ] Widget de estadísticas
- [ ] Metas de lectura con UI
- [ ] Exportar/importar biblioteca
- [ ] Modo oscuro personalizado
- [ ] Apple Watch companion app
- [ ] Integración con Goodreads

---

## 📈 Métricas del Proyecto

| Métrica | Valor |
|---------|-------|
| 📁 **Archivos Swift** | 113 |
| 🧠 **Use Cases** | 30+ |
| 📱 **ViewModels** | 7 |
| 🎨 **Componentes UI** | 15+ |
| 🔌 **Data Sources** | 3 (2 locales + 1 remoto) |

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
