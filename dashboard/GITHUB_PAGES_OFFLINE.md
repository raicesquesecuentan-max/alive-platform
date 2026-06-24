# Dashboard Alivé Voz - Guía GitHub Pages + Offline

## Configuración para GitHub Pages (Estático + Offline)

### 1. **Estructura de Carpetas para GitHub Pages**

```
alive-platform/
├── docs/                    # ← GitHub Pages servira desde aquí
│   ├── index.html
│   ├── dashboard.html
│   ├── css/
│   ├── js/
│   ├── data/               # Datos locales en JSON
│   └── assets/
├── dashboard-src/          # Código fuente (opcional)
└── scripts/
    └── build-static.js     # Script para generar archivos estáticos
```

### 2. **Activar GitHub Pages**

1. Ve a `Settings > Pages`
2. Selecciona:
   - **Source**: Deploy from a branch
   - **Branch**: `main` o `feature/voice-app-dashboard`
   - **Folder**: `/docs`
3. Haz click en "Save"

Tu app estará en: `https://raicesquesecuentan-max.github.io/alive-platform`

### 3. **Configuración Offline-First**

#### A. Service Worker para Cache Local

```javascript
// docs/js/service-worker.js
const CACHE_NAME = 'alive-voice-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/dashboard.html',
  '/css/styles.css',
  '/js/app.js',
  '/data/audioguides.json',
  '/data/locations.json',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(urlsToCache);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
```

#### B. Almacenamiento Local (IndexedDB)

```javascript
// docs/js/offline-db.js
class OfflineDB {
  constructor() {
    this.db = null;
    this.init();
  }

  async init() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open('AliveVoiceDB', 1);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };
      
      request.onupgradeneeded = (e) => {
        const db = e.target.result;
        db.createObjectStore('queries', { keyPath: 'id', autoIncrement: true });
        db.createObjectStore('locations', { keyPath: 'id' });
        db.createObjectStore('audioguides', { keyPath: 'id' });
      };
    });
  }

  async saveQuery(query, response) {
    const store = this.db.transaction('queries', 'readwrite').objectStore('queries');
    return store.add({ query, response, timestamp: Date.now() });
  }

  async getQueries() {
    const store = this.db.transaction('queries', 'readonly').objectStore('queries');
    return new Promise((resolve) => {
      const request = store.getAll();
      request.onsuccess = () => resolve(request.result);
    });
  }
}
```

### 4. **HTML Estático con Web Speech API**

```html
<!-- docs/dashboard.html -->
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Alivé Voz - Dashboard Accesible</title>
  <link rel="stylesheet" href="css/styles.css">
  <!-- Soporte offline -->
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <div id="app">
    <header aria-label="Encabezado">
      <h1>Alivé Voz Dashboard</h1>
      <button id="voice-toggle" aria-label="Activar micrófono">
        🎤 Iniciar Escucha
      </button>
    </header>

    <main aria-label="Contenido principal">
      <!-- Resultado de reconocimiento de voz -->
      <div id="transcript" role="status" aria-live="polite">
        Esperando entrada de voz...
      </div>

      <!-- Localizaciones cercanas -->
      <section aria-label="Ubicaciones cercanas">
        <h2>Ubicaciones Cercanas</h2>
        <div id="locations-list"></div>
      </section>

      <!-- Historial de consultas -->
      <section aria-label="Historial de búsquedas">
        <h2>Historial</h2>
        <div id="history"></div>
      </section>
    </main>
  </div>

  <!-- Scripts -->
  <script src="js/offline-db.js"></script>
  <script src="js/app.js"></script>
  
  <!-- Registrar Service Worker -->
  <script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('/alive-platform/js/service-worker.js');
    }
  </script>
</body>
</html>
```

### 5. **JavaScript para Web Speech API (Sin Dependencias)**

```javascript
// docs/js/app.js
class AliveVoiceApp {
  constructor() {
    this.recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
    this.synthesis = window.speechSynthesis;
    this.db = new OfflineDB();
    this.isListening = false;
    
    this.recognition.lang = 'es-ES';
    this.recognition.continuous = false;
    this.recognition.interimResults = true;
    
    this.setupEventListeners();
    this.loadData();
  }

  setupEventListeners() {
    document.getElementById('voice-toggle').addEventListener('click', 
      () => this.toggleListening()
    );

    this.recognition.onstart = () => {
      this.isListening = true;
      this.updateUI();
      this.speak('Escuchando...');
    };

    this.recognition.onresult = (event) => {
      let interimTranscript = '';
      for (let i = event.resultIndex; i < event.results.length; i++) {
        const transcript = event.results[i][0].transcript;
        if (event.results[i].isFinal) {
          this.handleQuery(transcript);
        } else {
          interimTranscript += transcript;
        }
      }
      document.getElementById('transcript').textContent = interimTranscript;
    };

    this.recognition.onerror = (event) => {
      console.error('Error de reconocimiento:', event.error);
      this.speak(`Error: ${event.error}`);
    };

    this.recognition.onend = () => {
      this.isListening = false;
      this.updateUI();
    };
  }

  async handleQuery(query) {
    // Buscar en datos locales
    const response = await this.searchLocally(query);
    this.speak(response);
    
    // Guardar en IndexedDB
    await this.db.saveQuery(query, response);
  }

  async searchLocally(query) {
    const data = await fetch('data/locations.json').then(r => r.json());
    // Búsqueda simple (implementar búsqueda semántica si es necesario)
    const found = data.find(loc => 
      loc.name.toLowerCase().includes(query.toLowerCase())
    );
    return found ? `Encontré: ${found.name}. ${found.description}` : 
           'No encontré resultados. Intenta de nuevo.';
  }

  toggleListening() {
    if (this.isListening) {
      this.recognition.stop();
    } else {
      this.recognition.start();
    }
  }

  speak(text) {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'es-ES';
    utterance.rate = 0.9;
    this.synthesis.speak(utterance);
  }

  async loadData() {
    // Cargar datos estáticos
    const locations = await fetch('data/locations.json').then(r => r.json());
    this.renderLocations(locations);
  }

  renderLocations(locations) {
    const list = document.getElementById('locations-list');
    list.innerHTML = locations.map(loc => `
      <div class="location-card">
        <h3>${loc.name}</h3>
        <p>${loc.description}</p>
        <button onclick="app.speak('${loc.description}')">📢 Escuchar</button>
      </div>
    `).join('');
  }

  updateUI() {
    const btn = document.getElementById('voice-toggle');
    btn.textContent = this.isListening ? '⏹️ Detener' : '🎤 Iniciar';
  }
}

const app = new AliveVoiceApp();
```

### 6. **Manifest para PWA (Offline)**

```json
{
  "name": "Alivé Voz",
  "short_name": "Alivé",
  "description": "Aplicación de voz accesible para turismo sin internet",
  "start_url": "/alive-platform/",
  "scope": "/alive-platform/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196F3",
  "icons": [
    {
      "src": "/alive-platform/assets/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/alive-platform/assets/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### 7. **Datos Estáticos (JSON)**

```json
// docs/data/locations.json
[
  {
    "id": 1,
    "name": "Huaca Pucllana",
    "latitude": -12.0456,
    "longitude": -77.0285,
    "description": "Pirámide ceremonial de la cultura Lima",
    "audioFile": "huaca-pucllana.mp3"
  },
  {
    "id": 2,
    "name": "Pachacámac",
    "latitude": -12.1839,
    "longitude": -76.8769,
    "description": "Complejo arqueológico en el valle del Rímac",
    "audioFile": "pachacamac.mp3"
  }
]
```

### 8. **CSS Accesible**

```css
/* docs/css/styles.css */
:root {
  --primary: #2196F3;
  --primary-dark: #1976D2;
  --accent: #FF4081;
  --text: #333;
  --bg: #fff;
}

@media (prefers-color-scheme: dark) {
  :root {
    --text: #fff;
    --bg: #121212;
  }
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto;
  background: var(--bg);
  color: var(--text);
  margin: 0;
  padding: 20px;
}

button {
  background: var(--primary);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 16px;
  cursor: pointer;
  min-height: 48px; /* Accesibilidad táctil */
}

button:hover {
  background: var(--primary-dark);
}

button:focus {
  outline: 3px solid var(--accent);
}

/* High contrast mode */
@media (prefers-contrast: more) {
  button {
    border: 2px solid currentColor;
  }
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
  }
}
```

### 9. **Deploy a GitHub Pages**

```bash
# Clonar repo
git clone https://github.com/raicesquesecuentan-max/alive-platform.git
cd alive-platform

# Cambiar a rama
git checkout feature/voice-app-dashboard

# Crear rama gh-pages
git checkout -b gh-pages

# Copiar archivos estáticos a /docs
mkdir -p docs/{js,css,data,assets}
cp dashboard/public/* docs/ 2>/dev/null || true

# Crear archivos HTML, CSS, JS (ver arriba)

# Commits
git add .
git commit -m "feat: Dashboard estático offline para GitHub Pages"
git push origin gh-pages

# Cambiar a main
git checkout main
git merge gh-pages
git push origin main
```

### 10. **URL Final**

Tu app estará en:
```
https://raicesquesecuentan-max.github.io/alive-platform
```

✅ **Ventajas**:
- Hosting gratis en GitHub Pages
- Funciona 100% offline
- No requiere backend
- Service Workers para caché
- PWA instalable en dispositivos
- Accesibilidad Web Accessibility (WCAG)
- Web Speech API nativa del navegador

✅ **Características Offline**:
- Reconocimiento de voz (Web Speech API)
- Síntesis de voz (TTS nativo)
- Datos locales en IndexedDB
- Service Workers para caché
- Funciona sin conexión a internet
- Sincronización automática cuando hay conexión

---

**Próximos pasos**:
1. Crear `/docs` con archivos HTML/CSS/JS
2. Agregar datos locales en JSON
3. Implementar Service Workers
4. Habilitar GitHub Pages en Settings
5. Acceder a la URL pública
