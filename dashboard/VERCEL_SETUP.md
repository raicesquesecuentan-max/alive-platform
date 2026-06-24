# Dashboard Alivé Voz - Guía de Integración con Vercel

## Requisitos Previos

- Cuenta en [Vercel](https://vercel.com)
- Proyecto vinculado a GitHub
- Variables de entorno configuradas

## Pasos para Integrar con Vercel

### 1. **Crear Proyecto en Vercel**

```bash
# Opción A: Desde la CLI de Vercel
npm i -g vercel
cd dashboard
vercel

# Opción B: Desde el dashboard web
# Visita https://vercel.com/new
```

### 2. **Configurar Variables de Entorno**

En `Vercel Dashboard > Settings > Environment Variables`, agrega:

```
NEXT_PUBLIC_API_URL=https://tu-api.herokuapp.com  # URL de tu backend
DATABASE_URL=postgresql://...                      # Si usas DB en Vercel
```

### 3. **Conectar con GitHub**

1. En Vercel, selecciona "Import Git Repository"
2. Conecta tu repositorio `raicesquesecuentan-max/alive-platform`
3. Selecciona la rama `feature/voice-app-dashboard`
4. Configura:
   - **Root Directory**: `dashboard`
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`
   - **Install Command**: `npm ci`

### 4. **Configurar Secrets de GitHub Actions**

Para deployment automático, agrega en GitHub:

**Settings > Secrets and variables > Actions > New repository secret**

```
VERCEL_TOKEN      # Token de Vercel (obtén en Vercel > Settings > Tokens)
VERCEL_ORG_ID     # ID de tu organización Vercel
VERCEL_PROJECT_ID # ID del proyecto en Vercel
```

### 5. **Obtener Credenciales de Vercel**

#### Token de Vercel:
1. Ve a https://vercel.com/account/tokens
2. Click en "Create Token"
3. Copia el token

#### Org ID y Project ID:
1. Copia desde la URL del proyecto Vercel:
   ```
   https://vercel.com/{org-id}/{project-name}/{project-id}
   ```

### 6. **Estructura del Proyecto para Vercel**

```
alive-platform/
├── dashboard/              # ← Tu aplicación Next.js
│   ├── src/
│   │   ├── pages/         # Rutas Next.js
│   │   ├── components/    # Componentes React
│   │   ├── hooks/         # Custom hooks
│   │   ├── services/      # Servicios API
│   │   └── types/         # Tipos TypeScript
│   ├── public/            # Archivos estáticos
│   ├── package.json
│   ├── tsconfig.json
│   └── next.config.ts
├── .github/
│   └── workflows/
│       └── deploy-dashboard.yml
└── README.md
```

### 7. **Deploy Manual Rápido**

```bash
cd dashboard
vercel --prod
```

### 8. **Monitorar Deployments**

- **Dashboard Vercel**: https://vercel.com/dashboard
- **GitHub Actions**: Repo > Actions > Deploy Dashboard a Vercel
- **Logs en Tiempo Real**: 
  ```bash
  vercel logs [url]
  ```

## Configuración Recomendada de Vercel

### Performance
- ✅ Habilitar **Edge Caching**
- ✅ **Automatic Deployments** en cada push
- ✅ **Preview Deployments** en PRs

### Seguridad
- ✅ **HTTPS automático** (habilitado por defecto)
- ✅ **DDoS Protection** (incluido)
- ✅ **Encryption at rest** (incluido)

### Escalabilidad
- ✅ **Auto-scaling** infinito
- ✅ **CDN Global** de Vercel
- ✅ **Serverless Functions** para APIs

## Archivos de Configuración

### `.vercelignore`
```
node_modules
.next
.git
.env.local
*.log
```

### Environment Variables por Entorno

**Development (Vercel Preview)**:
```
NEXT_PUBLIC_API_URL=https://api-preview.herokuapp.com
```

**Production (Vercel Production)**:
```
NEXT_PUBLIC_API_URL=https://api.herokuapp.com
```

## Troubleshooting

### Error: "Module not found"
```bash
# Reinicia instalación en Vercel
rm -rf node_modules package-lock.json
npm install
```

### API 502 Bad Gateway
- Verifica que `NEXT_PUBLIC_API_URL` sea accesible
- Comprueba CORS en tu backend

### Deployment falla en Tests
- Los tests marcan error en build
- Solución: 
  ```json
  "scripts": {
    "test": "jest --passWithNoTests"
  }
  ```

## Comandos Útiles

```bash
# Ver estado del deployment
vercel ls

# Rollback a versión anterior
vercel rollback

# Conectar directorio local al proyecto Vercel
vercel link

# Alias personalizado (dominio)
vercel alias set mi-app.vercel.app https://alive-voice-dashboard.vercel.app

# Inspeccionar build locally
vercel build
vercel start
```

## URL de Deployment

Después del deploy exitoso, tu app estará en:

```
https://alive-voice-dashboard.vercel.app
```

O tu dominio personalizado si lo configuraste.

## Próximos Pasos

1. ✅ [Integrar Backend API](../backend/README.md)
2. ✅ [Configurar Base de Datos](../database/README.md)
3. ✅ [Setup de Monitoreo](https://vercel.com/docs/monitoring)
4. ✅ [Configurar Dominio Personalizado](https://vercel.com/docs/concepts/projects/domains)

---

**Soporte**:
- Docs Vercel: https://vercel.com/docs
- GitHub Issues: Crear issue en el repositorio
- Email: tu-email@alivevoice.com
