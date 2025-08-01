#!/usr/bin/env bash
# Setup a new Studio site with Caddy reverse proxy
# Usage: studio-caddy-setup.sh <domain> <port>
# Example: studio-caddy-setup.sh mysite.wp.local 8887

set -e

DOMAIN="${1:-}"
PORT="${2:-}"

if [[ -z "$DOMAIN" || -z "$PORT" ]]; then
    echo "Usage: $(basename "$0") <domain> <port>"
    echo "Example: $(basename "$0") mysite.wp.local 8887"
    echo ""
    echo "Setup process:"
    echo "1. In Studio: Disable hostname for the site"
    echo "2. Start the site in Studio (it will get assigned a port)"
    echo "3. Run this script with the domain and port"
    echo "4. In Studio: Re-enable/bind the hostname"
    exit 1
fi

echo "🎯 Setting up Studio site: $DOMAIN → localhost:$PORT"
echo ""

# Check if Caddy is running
if ! brew services list | grep -q "caddy.*started"; then
    echo "❌ Caddy is not running. Starting Caddy..."
    brew services start caddy
fi

# Backup current Caddyfile
cp /opt/homebrew/etc/Caddyfile /opt/homebrew/etc/Caddyfile.backup.$(date +%Y%m%d_%H%M%S)

# Check if domain already exists in Caddyfile
if grep -q "^${DOMAIN}" /opt/homebrew/etc/Caddyfile; then
    echo "⚠️  Domain $DOMAIN already exists in Caddyfile. Updating port..."
    # Update existing entry
    sed -i '' "s|^${DOMAIN} {|${DOMAIN} {|" /opt/homebrew/etc/Caddyfile
    sed -i '' "/^${DOMAIN} {/,/^}/ s|reverse_proxy localhost:[0-9]*|reverse_proxy localhost:${PORT}|" /opt/homebrew/etc/Caddyfile
else
    echo "✅ Adding new domain to Caddyfile..."
    # Add new entry before the closing of the file
    cat >> /opt/homebrew/etc/Caddyfile << EOF

# Studio site: $DOMAIN
$DOMAIN {
	tls internal
	reverse_proxy localhost:$PORT
}
EOF
fi

echo "📝 Updated Caddyfile:"
echo "----------------------------------------"
cat /opt/homebrew/etc/Caddyfile
echo "----------------------------------------"

echo ""
echo "🔄 Reloading Caddy configuration..."
brew services restart caddy

# Wait a moment for Caddy to start
sleep 2

# Check if Caddy is running properly
if brew services list | grep -q "caddy.*started"; then
    echo "✅ Caddy restarted successfully"
else
    echo "❌ Caddy failed to start. Check logs with: tail -f /opt/homebrew/var/log/caddy.log"
    exit 1
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. In Studio: Re-enable/bind the hostname '$DOMAIN'"
echo "2. Test the site: https://$DOMAIN"
echo "3. If you get a certificate error, the root cert should already be trusted"
echo ""
echo "💡 Troubleshooting:"
echo "   - Check Studio assigned port: lsof -i | grep Studio"
echo "   - Check Caddy logs: tail -f /opt/homebrew/var/log/caddy.log"
echo "   - Test direct access: curl -k https://localhost:$PORT"