# 🛡️ Traefik Security Roadmap

Este roadmap está diseñado para construir conocimientos de seguridad en Traefik de forma progresiva, partiendo de los conceptos básicos ya cubiertos (dashboard, routing, health checks, sticky sessions) hacia configuraciones de seguridad más avanzadas y robustas.

Cada proyecto aborda un problema real de seguridad y enseña las herramientas específicas de Traefik para resolverlo.

---

## 📍 Estado actual (ya completado)

- ✅ **01-TraefikDashboard** - Configuración básica del dashboard en modo insecure
- ✅ **02-TraefikRouting** - Routing basado en Host headers
- ✅ **03-TraefikHealthChecks** - Health checks a nivel Docker y Traefik
- ✅ **04-TraefikStickySessions** - Sesiones persistentes con cookies

---

## 🔐 Nivel 1: Protección básica de tráfico

### 05-TraefikTLS-SelfSigned

**Problema original:**
Todo el tráfico HTTP viaja en texto plano. Cualquier persona en la red puede interceptar credenciales, cookies de sesión, datos personales, y cualquier información sensible que se transmita entre el cliente y el servidor.

**Qué buscamos solucionar:**
Cifrar toda la comunicación entre clientes y Traefik usando TLS/HTTPS, incluso en entornos de desarrollo local donde no tenemos dominios reales ni certificados válidos.

**Qué vamos a aprender:**
- Configurar el entrypoint `websecure` (puerto 443) para aceptar conexiones TLS
- Generar certificados SSL auto-firmados con OpenSSL
- Configurar Traefik para cargar certificados estáticos desde archivos (`tls.certificates`)
- Entender la diferencia entre certificados estáticos y dinámicos
- Configurar el entrypoint `web` para redirigir tráfico HTTP a HTTPS
- Comprender cómo los navegadores manejan certificados no válidos y por qué aparecen advertencias

**Conceptos clave:**
- TLS termination en Traefik
- Certificados auto-firmados vs certificados de autoridad pública
- Entrypoints múltiples (web vs websecure)
- Configuración estática de certificados

**Resultado esperado:**
Traefik sirve tráfico HTTPS con certificados auto-firmados. Los navegadores muestran advertencias de seguridad (esperado), pero la conexión está cifrada. El tráfico HTTP se redirige automáticamente a HTTPS.

---

### 06-TraefikLetsEncrypt

**Problema original:**
Los certificados auto-firmados funcionan para desarrollo, pero no son viables para producción. Los navegadores muestran advertencias de seguridad, los usuarios desconfían, y las APIs modernas (como geolocalización o service workers) requieren certificados válidos. Comprar certificados es costoso y gestionarlos manualmente es propenso a errores.

**Qué buscamos solucionar:**
Automatizar la obtención y renovación de certificados TLS válidos y gratuitos usando Let's Encrypt, sin intervención manual.

**Qué vamos a aprender:**
- Configurar `certificatesResolvers` en la configuración estática de Traefik
- Implementar el challenge HTTP-01 (requiere acceso público al puerto 80)
- Implementar el challenge TLS-ALPN-01 (alternativa cuando el puerto 80 está bloqueado)
- Configurar el challenge DNS-01 para dominios wildcard (requiere integración con proveedores DNS)
- Entender cómo Traefik almacena los certificados obtenidos (`acme.json`)
- Configurar la renovación automática (Traefik lo hace por defecto cada 3 meses)
- Aprender sobre rate limits de Let's Encrypt y cómo evitar bloqueos
- Diferenciar entre entorno de staging (para pruebas) y producción

**Conceptos clave:**
- ACME protocol (Automated Certificate Management Environment)
- HTTP-01 challenge vs TLS-ALPN-01 vs DNS-01
- CertificatesResolvers
- Almacenamiento persistente de certificados
- Renovación automática
- Staging vs production endpoints

**Resultado esperado:**
Traefik obtiene automáticamente un certificado válido de Let's Encrypt para un dominio real. El certificado se almacena en `acme.json`, se renueva automáticamente, y los navegadores muestran el candado verde sin advertencias.

---

### 07-TraefikDashboardAuth

**Problema original:**
El dashboard de Traefik expone información sensible sobre la infraestructura: routers configurados, servicios backend, middlewares, entrypoints, métricas de tráfico, y logs. En las configuraciones anteriores, el dashboard está accesible sin autenticación (`insecure: true`), lo que significa que cualquiera que pueda alcanzar la URL del dashboard puede ver toda esta información y potencialmente usarla para atacar el sistema.

**Qué buscamos solucionar:**
Proteger el dashboard con autenticación para que solo usuarios autorizados puedan acceder a él, eliminando el modo `insecure` y configurando middlewares de autenticación.

**Qué vamos a aprender:**
- Desactivar el modo `insecure` del dashboard (`api.insecure: false`)
- Crear un router específico para el dashboard con reglas de acceso
- Configurar el middleware `basicauth` para proteger el router del dashboard
- Generar hashes de contraseñas con `htpasswd` (bcrypt, md5, sha1, etc.)
- Almacenar credenciales de forma segura (variables de entorno, Docker secrets, o archivos)
- Entender la diferencia entre `api.insecure` y `api.dashboard`
- Configurar el middleware `digestauth` como alternativa a BasicAuth
- Aprender sobre el header `Authorization` y cómo se transmite la autenticación

**Conceptos clave:**
- Basic Authentication (RFC 7617)
- Digest Authentication (RFC 7616)
- Password hashing con htpasswd
- Middlewares de autenticación
- Protección de routers específicos
- Credenciales en variables de entorno vs archivos

**Resultado esperado:**
El dashboard solo es accesible después de introducir credenciales válidas. El modo `insecure` está desactivado. Las contraseñas están hasheadas y almacenadas de forma segura.

---

## 🔒 Nivel 2: Control de acceso granular

### 08-TraefikBackendAuth-IPWhitelist

**Problema original:**
No solo el dashboard necesita protección. Los servicios backend (APIs, aplicaciones web, bases de datos con interfaces gráficas) también pueden exponer funcionalidad sensible. Además, algunos servicios solo deberían ser accesibles desde redes específicas (por ejemplo, una API de administración solo debería responder a IPs de la oficina, no a tráfico público).

**Qué buscamos solucionar:**
Implementar autenticación en servicios backend específicos y restringir el acceso por dirección IP para crear capas adicionales de seguridad.

**Qué vamos a aprender:**
- Aplicar middlewares de autenticación (`basicauth`, `digestauth`) a routers de servicios backend
- Configurar el middleware `forwardauth` para delegar autenticación a un servicio externo (como OAuth2 Proxy, Authelia, o una API personalizada)
- Entender el flujo de ForwardAuth: Traefik envía una petición al servicio de autenticación antes de permitir el acceso al backend
- Configurar el middleware `ipWhiteList` para restringir acceso por IP
- Combinar múltiples middlewares en un mismo router (auth + IP whitelist)
- Aprender sobre listas de IPs permitidas y cómo manejar rangos CIDR
- Configurar headers personalizados que el middleware de autenticación puede inyectar en la petición al backend
- Entender cómo ForwardAuth puede devolver códigos de estado específicos (401, 403, 302 para redirección a login)

**Conceptos clave:**
- Backend authentication vs dashboard authentication
- ForwardAuth middleware
- External authentication services (OAuth2 Proxy, Authelia)
- IP whitelisting con CIDR notation
- Combinación de middlewares
- Headers de autenticación personalizados
- Flujos de autenticación centralizada

**Resultado esperado:**
Servicios backend protegidos con autenticación. Algunos servicios solo accesibles desde IPs específicas. Configuración de ForwardAuth con un servicio externo de ejemplo.

---

## 🛡️ Nivel 3: Hardening y protección avanzada

### 09-TraefikRateLimiting

**Problema original:**
Las APIs y aplicaciones web son vulnerables a ataques de fuerza bruta, denial-of-service (DoS), y abuso de recursos. Un atacante puede hacer miles de peticiones por segundo, agotando recursos del servidor, saturando bases de datos, o intentando adivinar credenciales de forma automatizada. Sin ningún mecanismo de limitación, un solo cliente puede consumir todos los recursos disponibles.

**Qué buscamos solucionar:**
Limitar la tasa de peticiones por cliente para prevenir abuso y ataques de fuerza bruta, asegurando que ningún cliente individual pueda monopolizar los recursos del servicio.

**Qué vamos a aprender:**
- Configurar el middleware `rateLimit` para limitar peticiones por IP
- Entender los parámetros `average`, `burst`, y `period` del rate limiting
- Aprender cómo Traefik responde cuando se excede el límite (HTTP 429 Too Many Requests)
- Diferenciar entre `average` (tasa sostenida) y `burst` (picos permitidos)
- Aplicar rate limiting selectivamente a routers sensibles (login, APIs públicas)
- Entender cómo Traefik identifica clientes (IP origen, X-Forwarded-For)
- Configurar el header `Retry-After` para indicar al cliente cuándo reintentar
- Combinar rate limiting con otros middlewares (auth, headers) en un mismo router
- Aprender sobre las limitaciones del rate limiting por IP en entornos con proxy/NAT

**Conceptos clave:**
- Rate limiting por IP
- Token bucket algorithm (average + burst)
- HTTP 429 Too Many Requests
- Selective rate limiting por router
- Limitaciones en entornos con NAT/proxy

**Resultado esperado:**
Servicios protegidos contra abuso con rate limiting. Los clientes que exceden el límite reciben HTTP 429. Diferentes routers pueden tener límites diferentes según su sensibilidad.

---

### 10-TraefikHTTPToHTTPS-Redirect

**Problema original:**
Incluso con TLS configurado (proyectos 05 y 06), los usuarios pueden seguir accediendo al servicio por HTTP (puerto 80), ya sea por error, por usar un bookmark antiguo, o porque escriben la URL sin `https://`. Esto significa que parte del tráfico sigue viajando en texto plano, exponiendo datos sensibles. Además, sin HSTS, los navegadores no recuerdan que el sitio debe usarse siempre con HTTPS, lasciando la puerta abierta a ataques man-in-the-middle en redes inseguras (WiFi pública, por ejemplo).

**Qué buscamos solucionar:**
Forzar que todo el tráfico HTTP se redirija automáticamente a HTTPS, y configurar HSTS para que los navegadores recuerden esta preferencia y nunca intenten conectar por HTTP en el futuro.

**Qué vamos a aprender:**
- Configurar el middleware `redirectScheme` para redirigir HTTP→HTTPS
- Crear un router separado en el entrypoint `web` exclusivamente para redirección
- Entender la diferencia entre redirección 301 (permanente) y 302 (temporal)
- Configurar el header `Strict-Transport-Security` (HSTS) con `max-age`, `includeSubDomains`, y `preload`
- Entender cómo HSTS previene ataques de protocol downgrade y SSL stripping
- Aprender sobre la lista HSTS preload (navegadores que traen la lista hardcodeada)
- Combinar `redirectScheme` con el middleware `headers` para añadir HSTS
- Entender la diferencia entre redirección a nivel Traefik y redirección a nivel aplicación
- Verificar el comportamiento con `curl -v` y observar los códigos 301/302 y el header HSTS

**Conceptos clave:**
- redirectScheme middleware
- HTTP 301 vs 302 redirects
- HSTS (Strict-Transport-Security)
- HSTS preload list
- Protocol downgrade attacks
- SSL stripping (ataques tipo sslstrip)
- Router de redirección dedicado

**Resultado esperado:**
Cualquier petición HTTP se redirige automáticamente a HTTPS con un 301 permanente. El header HSTS indica al navegador que use siempre HTTPS en futuras peticiones. `curl -v` muestra la redirección y el header HSTS en la respuesta.

---

### 11-TraefikSecurityHeaders

**Problema original:**
Las aplicaciones web modernas están expuestas a una amplia variedad de ataques del lado del cliente: clickjacking (incrustar la página en un iframe malicioso), MIME-sniffing (el navegador interpreta archivos como otro tipo de contenido), cross-site scripting (XSS), robo de información mediante el header Referer, y acceso no autorizado a características del navegador como la cámara o el micrófono. Muchos de estos ataques se pueden mitigar simplemente añadiendo headers HTTP de seguridad a las respuestas.

**Qué buscamos solucionar:**
Añadir headers de seguridad HTTP a todas las respuestas de Traefik para proteger contra vulnerabilidades comunes del lado del cliente, sin necesidad de modificar el código de las aplicaciones backend.

**Qué vamos a aprender:**
- Configurar el middleware `headers` para añadir headers de seguridad globales
- `X-Frame-Options: DENY` o `SAMEORIGIN` - Previene clickjacking al bloquear la incrustación en iframes
- `X-Content-Type-Options: nosniff` - Previene MIME-sniffing forzando al navegador a respetar el Content-Type
- `X-XSS-Protection: 1; mode=block` - Activa el filtro XSS del navegador (legacy, pero aún útil para navegadores antiguos)
- `Content-Security-Policy` (CSP) - Controla qué recursos (scripts, estilos, imágenes) puede cargar la página
- `Referrer-Policy: strict-origin-when-cross-origin` - Controla cuánta información del referer se envía
- `Permissions-Policy` - Controla qué características del navegador pueden usarse (cámara, micrófono, geolocalización)
- Aprender a remover headers sensibles que revelan información del servidor (como `Server`, `X-Powered-By`)
- Entender la diferencia entre aplicar headers globalmente vs por router
- Combinar el middleware `headers` con otros middlewares (auth, rateLimit, redirectScheme)
- Verificar los headers con `curl -I` y herramientas como securityheaders.com

**Conceptos clave:**
- Security headers middleware
- Clickjacking protection (X-Frame-Options)
- MIME-sniffing prevention
- Content Security Policy (CSP)
- Referrer-Policy
- Permissions-Policy (anteriormente Feature-Policy)
- Header removal (Server, X-Powered-By)
- Global vs per-router middleware application

**Resultado esperado:**
Todas las respuestas HTTP incluyen headers de seguridad apropiados. `curl -I` muestra X-Frame-Options, X-Content-Type-Options, CSP, Referrer-Policy, y Permissions-Policy. Los headers que revelan información del servidor han sido eliminados.

---

### 12-TraefikNetworkSegmentation

**Problema original:**
En las configuraciones anteriores, todos los contenedores (Traefik, backends, bases de datos) comparten la misma red Docker. Esto significa que cualquier contenedor puede comunicarse con cualquier otro directamente, lo cual viola el principio de mínimo privilegio. Si un atacante compromete un contenedor backend, puede moverse lateralmente y alcanzar Traefik, otros backends, o cualquier servicio en la red. Además, todos los contenedores son visibles para Traefik como potenciales backends, incluso aquellos que no deberían ser expuestos públicamente.

**Qué buscamos solucionar:**
Aislar Traefik en una red separada, controlar qué contenedores pueden comunicarse entre sí, y exponer solo los puertos estrictamente necesarios al host, siguiendo el principio de mínimo privilegio y defensa en profundidad.

**Qué vamos a aprender:**
- Crear múltiples redes Docker aisladas (`frontend`, `backend`, `database`)
- Conectar Traefik solo a la red `frontend` (expuesta al exterior)
- Conectar los backends a ambas redes `frontend` y `backend`
- Conectar bases de datos y servicios internos solo a la red `backend` (inaccesibles desde el exterior)
- Entender cómo Docker networks actúan como firewalls a nivel de contenedor
- Usar la label `traefik.docker.network` para indicar a Traefik qué red usar para reaching backends
- Evitar exponer puertos innecesarios al host (solo 80 y 443 para Traefik)
- Aprender sobre el principio de defensa en profundidad aplicado a Docker
- Verificar el aislamiento con `docker network inspect` y intentos de conexión entre contenedores aislados
- Entender las limitaciones de la segmentación de red en Docker (DNS resolution, ICMP, etc.)

**Conceptos clave:**
- Docker network isolation
- Frontend vs backend networks
- Principle of least privilege
- Defense in depth
- Lateral movement prevention
- `traefik.docker.network` label
- Puertos expuestos vs puertos internos
- Network segmentation con Docker Compose

**Resultado esperado:**
Traefik solo puede alcanzar los backends a través de la red `frontend`. Las bases de datos y servicios internos están completamente aislados en la red `backend`. Solo los puertos 80 y 443 están expuestos al host. `docker network inspect` confirma la separación de redes.

---

## 🎯 Resumen del aprendizaje

Al completar este roadmap, habrás aprendido:

1. **Cifrado de tráfico** - TLS con certificados auto-firmados y Let's Encrypt
2. **Autenticación** - BasicAuth, DigestAuth, ForwardAuth para dashboard y backends
3. **Control de acceso** - IP whitelisting y restricciones por red
4. **Protección contra abuso** - Rate limiting y throttling
5. **Redirección segura** - HTTP→HTTPS forzada con HSTS
6. **Hardening HTTP** - Security headers contra vulnerabilidades del lado del cliente
7. **Aislamiento de red** - Segmentación de redes y defensa en profundidad
8. **Integración externa** - ForwardAuth con servicios de autenticación centralizada

Cada proyecto construye sobre los anteriores, creando una base sólida de seguridad en Traefik que puedes aplicar en entornos reales de producción.
