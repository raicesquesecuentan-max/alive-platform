# Alivé Cloud Platform
## El turismo se siente
Pulsera inteligente multisensorial para turismo accesible e inclusivo.

ALIVÉ es una solución tecnológica diseñada para mejorar la experiencia turística de personas con discapacidad visual mediante navegación háptica, audioguías inteligentes, inteligencia artificial conversacional y asistencia de emergencia.

---

## Problema

Millones de personas visitan sitios turísticos cada año, pero gran parte de la experiencia sigue siendo predominantemente visual.
Donde 80% de destinos turísticos carecen de información. (OMT, 2021) y 71% dependen de terceros (WBU, 2022) siendo 21% como prohibir el acceso a perros guía, carecer de menús en braille o señalética táctil, y/o la falta de personal capacitado.

Esto limita la autonomía de personas con discapacidad visual en espacios culturales, arqueológicos y turísticos.

---

## Solución

ALIVÉ integra una pulsera inteligente, una aplicación accesible y una plataforma cloud para ofrecer:

- Navegación mediante vibraciones hápticas.
- Audioguías automáticas.
- Inteligencia artificial por voz.
- Botón SOS.
- Funcionamiento offline.
- Gestión centralizada para destinos turísticos.

---

# Arquitectura

```text
                  ┌────────────────────┐
                  │  Plataforma Cloud  │
                  │      ALIVÉ         │
                  └─────────┬──────────┘
                            │
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼

   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
   │ Balizas BLE │   │ App ALIVÉ   │   │ Dashboard   │
   └──────┬──────┘   └──────┬──────┘   └─────────────┘
          │                 │
          ▼                 ▼

      ┌─────────────────────────┐
      │  Pulsera Inteligente    │
      │         ALIVÉ           │
      └─────────────────────────┘
```

---

# Componentes

## Pulsera Inteligente

Funciones:

- Vibraciones hápticas
- Botón SOS
- Bluetooth BLE
- Batería recargable
- Funcionamiento offline

---

## Aplicación Móvil

Funciones:

- Audioguías automáticas
- Navegación accesible
- IA conversacional
- Descarga offline
- Gestión de recorridos

---

## Plataforma Cloud

Funciones:

- Monitoreo de visitantes
- Gestión de audioguías
- Alertas SOS
- Analítica turística
- Administración de sitios turísticos

---

# Estructura del Proyecto

```text
├── README.md
├── LICENSE
├── .gitignore
├── package.json
├── vite.config.js
│
├── public/
│   ├── manifest.json
│   ├── favicon.ico
│   ├── logo-alive.png
│   └── service-worker.js
│
├── src/
│
│   ├── index.html
│   │
│   ├── css/
│   │   ├── style.css
│   │   ├── accessibility.css
│   │   └── responsive.css
│   │
│   ├── js/
│   │
│   │   ├── app.js
│   │
│   │   ├── speech/
│   │   │   ├── recognition.js
│   │   │   ├── commands.js
│   │   │   ├── wakeword.js
│   │   │   └── tts.js
│   │
│   │   ├── beacons/
│   │   │   ├── beaconManager.js
│   │   │   ├── bluetooth.js
│   │   │   └── signalProcessor.js
│   │
│   │   ├── navigation/
│   │   │   ├── routes.js
│   │   │   ├── guidance.js
│   │   │   └── vibration.js
│   │
│   │   ├── accessibility/
│   │   │   ├── screenReader.js
│   │   │   ├── haptics.js
│   │   │   └── audioDescriptions.js
│   │
│   │   └── offline/
│   │       ├── cacheManager.js
│   │       ├── offlineMaps.js
│   │       └── sync.js
│
│   ├── data/
│   │
│   │   ├── huaca-pucllana.json
│   │   ├── machupicchu.json
│   │   ├── pachacamac.json
│   │   └── museo-larco.json
│   │
│   ├── audio/
│   │
│   │   ├── bienvenida.mp3
│   │   ├── ayuda.mp3
│   │   ├── emergencia.mp3
│   │   └── recorridos/
│   │
│   ├── assets/
│   │
│   │   ├── logo/
│   │   ├── icons/
│   │   └── images/
│
│   └── components/
│       ├── Home.js
│       ├── Tour.js
│       ├── Emergency.js
│       └── Settings.js
│
└── docs/
    ├── arquitectura.pdf
    ├── pitch-deck.pdf
    └── manual-usuario.pdf
```

---

# Tecnologías

## Aplicación móvil

- Flutter
- Dart
- Bluetooth BLE
- SQLite
- Text To Speech
- Speech To Text

---

## Backend

- Next.js
- NestJS
- PostgreSQL
- Docker
- Firebase

---

## Firmware

- ESP32-C3
- Bluetooth Low Energy
- Arduino Framework

---

# Funcionalidades

## Navegación Háptica

| Vibración | Acción |
|------------|---------|
| 📳 | Avanzar |
| 📳📳 | Girar izquierda |
| 📳📳📳 | Girar derecha |
| 📳━━━━ | Atención |

---

## Audioguías Inteligentes

- Reproducción automática
- Multilenguaje
- Funcionamiento offline

Idiomas:

- Español
- Inglés
- Portugués
- Quechua

---

## Asistente IA

Ejemplos:

Usuario:

> ¿Qué estoy visitando?

Respuesta:

> Frente a usted se encuentra la Gran Pirámide Ceremonial de Huaca Pucllana.

Usuario:

> ¿Dónde está la salida?

Respuesta:

> Continúe recto durante 120 metros.

---

## Seguridad SOS

Permite:

- Solicitar ayuda inmediata
- Registrar ubicación
- Alertar personal del sitio
- Notificar a la plataforma cloud

---

# MVP

El producto mínimo viable incluye:

- Conexión BLE
- Vibraciones hápticas
- Audioguías
- Botón SOS
- Dashboard básico
- Modo offline

---

# Casos de Uso (por el momento)

## Sitios Arqueológicos

- Huaca Pucllana
- Pachacámac
- Machu Picchu
- Chan Chan

## Museos

- Museos nacionales
- Centros culturales
- Exposiciones temporales

## Turismo Urbano

- Centros históricos
- Rutas accesibles
- Circuitos turísticos

---

# Impacto

ALIVÉ busca:

- Incrementar la autonomía de personas con discapacidad visual.
- Mejorar la accesibilidad turística.
- Reducir barreras tecnológicas.
- Promover el turismo inclusivo.

---

# Roadmap

## Fase 1

- MVP funcional.
- Pulsera BLE.
- Audioguías offline.

## Fase 2

- IA conversacional.
- Dashboard avanzado.
- Analítica de recorridos.

## Fase 3

- Escalamiento nacional.
- Integración con destinos turísticos.
- Smart Tourism.

---

# Equipo

Proyecto desarrollado para promover un turismo accesible, inclusivo y sostenible.
- CEO Founder  Elida Nuñez Vasquez
- CPO          Valeria Alexandra Villacorta Landeo
- CTO          Verónica Gazzo
---

# Licencia

MIT License

---

## ALIVÉ

**"Siente el camino, vive la experiencia."**
