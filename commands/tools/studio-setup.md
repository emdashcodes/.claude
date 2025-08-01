---
description: Setup a new Studio site with Caddy reverse proxy
allowed-tools: Read, Edit, Bash
---

# Studio Site Setup

Setup a new Studio site with Caddy reverse proxy configuration.

## Instructions

1. **Get Site Details**: Ask the user for:
   - Domain name (e.g., `mysite.wp.local`)
   - Port number (check with `lsof -i | grep Studio` or ask user)

2. **Backup Caddyfile**: Create a timestamped backup of the current Caddyfile

3. **Update Configuration**: Add or update the site configuration in `/opt/homebrew/etc/Caddyfile`:
   ```
   # Studio site: {domain}
   {domain} {
       tls internal
       reverse_proxy localhost:{port}
   }
   ```

4. **Restart Caddy**: Reload the Caddy configuration with `brew services restart caddy`

5. **Provide Instructions**: Give the user the Studio workaround steps:
   - In Studio: Disable hostname for the site
   - Start the site in Studio (gets assigned a port)  
   - Run this command with domain and port
   - In Studio: Re-enable/bind the hostname

## Additional User Context

$ARGUMENTS