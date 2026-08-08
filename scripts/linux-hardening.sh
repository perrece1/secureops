#!/usr/bin/env bash

# Exit immediately on error, treat unset variables as error, trace pipe failures
set -euo pipefail

echo "=========================================="
echo " 🛡️  Iniciando Script de Linux Hardening"
echo "=========================================="

# 1. Comprobar permisos de superusuario
if [[ $EUID -ne 0 ]]; then
   echo "❌ Este script debe ejecutarse como root (sudo)." 
   exit 1
fi

# 2. Configurar Kernel Hardening via sysctl
echo "🔒 Aplicando parámetros de seguridad al Kernel..."
SYSCTL_CONF="/etc/sysctl.d/99-hardening.conf"

cat <<'EOF' > "$SYSCTL_CONF"
# Ignorar pings ICMP de broadcast
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Proteger contra ataques SYN Flood
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048

# Desactivar redirecciones IP (prevenir ataques Man-in-the-Middle)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

# Habilitar protección de Reverse Path Filtering (Spoofing)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF

sysctl --system > /dev/null
echo "✅ Kernel configurado correctamente."

# 3. Hardening de SSH
echo "🔑 Configurando SSH Seguro..."
SSHD_DIR="/etc/ssh/sshd_config.d"
SSHD_CONFIG="$SSHD_DIR/hardening.conf"

# Crear la carpeta sshd_config.d si no existe
mkdir -p "$SSHD_DIR"

cat <<'EOF' > "$SSHD_CONFIG"
# Deshabilitar login como root
PermitRootLogin no

# Máximo de intentos de autenticación
MaxAuthTries 3
EOF

# Reiniciar SSH comprobando qué servicio está activo
if systemctl is-active --quiet sshd; then
    systemctl restart sshd
elif systemctl is-active --quiet ssh; then
    systemctl restart ssh
else
    echo "⚠️ Servicio SSH no detectado en ejecución, omitiendo reinicio."
fi

echo "✅ SSH Hardening aplicado."

# 4. Configuración del Firewall (UFW)
echo "🧱 Configurando Firewall (UFW)..."
if command -v ufw > /dev/null 2>&1; then
    ufw --force reset > /dev/null
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp comment 'SSH'
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    ufw allow 6443/tcp comment 'K3s API Server'
    ufw --force enable
    echo "✅ UFW activado y reglas aplicadas."
else
    echo "⚠️ UFW no está instalado. Instalándolo..."
    apt-get update -y && apt-get install -y ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 6443/tcp
    ufw --force enable
    echo "✅ UFW instalado y activado."
fi

echo "=========================================="
echo " 🎉 Hardening completado con éxito."
echo "=========================================="
