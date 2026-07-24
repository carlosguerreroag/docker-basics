Nivel básico - Protección inmediata:
1. TLS/HTTPS con certificados auto-firmados - Configurar el entrypoint websecure, generar certificados locales, y servir tráfico HTTPS. Aprenderás sobre tls.certificates y cómo Traefik termina conexiones TLS.
2. Let's Encrypt automático - Usar el ACME resolver para obtener certificados reales automáticamente. Configurar certificatesResolvers con challenge HTTP o TLS-ALPN. Esto es esencial para producción.
3. Autenticación en el dashboard - Eliminar el modo insecure y proteger el dashboard con BasicAuth o DigestAuth usando middlewares. Aprenderás sobre http.middlewares y hashing de contraseñas con htpasswd.
Nivel intermedio - Control de acceso:
4. Autenticación en servicios backend - Aplicar middlewares de autenticación a routers específicos (no solo al dashboard). Combinar con headers personalizados o ForwardAuth para integraciones externas.
5. IP Whitelisting - Restringir acceso por IP usando el middleware ipWhiteList. Útil para APIs internas o administración.
6. Rate Limiting - Proteger servicios contra abuso con el middleware rateLimit. Configurar límites por IP, burst, y periodos de tiempo.
Nivel avanzado - Hardening:
7. Redirección HTTP→HTTPS forzada - Usar redirectScheme para redirigir todo el tráfico HTTP a HTTPS automáticamente, combinado con HSTS headers.
8. Security headers - Añadir headers de seguridad (X-Frame-Options, X-Content-Type-Options, HSTS, etc.) con middlewares headers.
9. Network segmentation - Aislar Traefik en una red separada, limitar qué contenedores pueden comunicarse entre sí, y exponer solo los puertos necesarios.

Orden recomendado:
- Empieza con TLS con certificados auto-firmados (proyecto 05)
- Luego Let's Encrypt (proyecto 06)
- Después Dashboard auth (proyecto 07)
- Continúa con Backend auth + IP whitelist (proyecto 08)
- Termina con Rate limiting + Security headers (proyecto 09)
