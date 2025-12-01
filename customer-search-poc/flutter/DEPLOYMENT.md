# Apache Configuration for Customer Search POC

## Apache Virtual Host Configuration

Create or edit: `/etc/apache2/sites-available/customer-search.conf`

```apache
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /var/www/customer-search-poc

    # Enable required modules (run these commands first):
    # sudo a2enmod proxy
    # sudo a2enmod proxy_http
    # sudo a2enmod rewrite
    # sudo a2enmod headers

    # React app (main web interface) - served at root
    <Directory /var/www/customer-search-poc/frontend/dist>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted

        # Enable React Router (SPA routing)
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>

    # Flutter app (mobile-optimized) - served at /flutter
    Alias /flutter /var/www/customer-search-poc/flutter/build/web
    <Directory /var/www/customer-search-poc/flutter/build/web>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted

        # Enable Flutter routing
        RewriteEngine On
        RewriteBase /flutter
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /flutter/index.html [L]
    </Directory>

    # API Proxy to Node.js backend (port 9000)
    ProxyPreserveHost On
    ProxyPass /search-test http://127.0.0.1:9000
    ProxyPassReverse /search-test http://127.0.0.1:9000

    # Logging
    ErrorLog ${APACHE_LOG_DIR}/customer-search-error.log
    CustomLog ${APACHE_LOG_DIR}/customer-search-access.log combined
</VirtualHost>
```

---

## Deployment Steps

### 1. Build Flutter App

On your Windows machine:
```powershell
cd "c:\JOB\HackMotion Test\customer-search-poc\Flutter"
flutter build web --release --base-href /flutter/
```

**Note:** The `--base-href /flutter/` is important for Apache subdirectory deployment.

### 2. Upload to Ubuntu Server

```bash
# Upload Flutter build
scp -r build/web/* user@your-server:/var/www/customer-search-poc/flutter/

# Or if using Git, commit and push, then pull on server
```

### 3. Enable Apache Modules (on Ubuntu server)

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo a2enmod headers
```

### 4. Create Apache Configuration

```bash
sudo nano /etc/apache2/sites-available/customer-search.conf
# Paste the configuration above
```

### 5. Enable Site and Restart Apache

```bash
# Enable the site
sudo a2ensite customer-search.conf

# Disable default site (optional)
sudo a2dissite 000-default.conf

# Test configuration
sudo apache2ctl configtest

# Restart Apache
sudo systemctl restart apache2
```

### 6. Set Permissions

```bash
sudo chown -R www-data:www-data /var/www/customer-search-poc
sudo chmod -R 755 /var/www/customer-search-poc
```

---

## Alternative: Using .htaccess Files

If you prefer using `.htaccess` files instead of VirtualHost configuration:

### Frontend .htaccess
Create: `/var/www/customer-search-poc/frontend/dist/.htaccess`

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

### Flutter .htaccess
Create: `/var/www/customer-search-poc/flutter/build/web/.htaccess`

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /flutter/
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /flutter/index.html [L]
</IfModule>
```

---

## Testing

After deployment, test these URLs:

1. **React app:** `http://your-domain.com/`
2. **Flutter app:** `http://your-domain.com/flutter/`
3. **API:** `http://your-domain.com/api/search?q=test&page=1`

---

## Troubleshooting

### Issue: 404 errors on refresh

**Solution:** Ensure `mod_rewrite` is enabled:
```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### Issue: API proxy not working

**Solution:** Check if proxy modules are enabled:
```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo systemctl restart apache2
```

### Issue: Permission denied

**Solution:** Fix permissions:
```bash
sudo chown -R www-data:www-data /var/www/customer-search-poc
sudo chmod -R 755 /var/www/customer-search-poc
```

### Issue: Flutter app shows blank page

**Solution:** Rebuild with correct base href:
```bash
flutter build web --release --base-href /flutter/
```

---

## Current vs Deployed Structure

**Local (Windows):**
```
customer-search-poc/
├── backend/src/
├── frontend/dist/         # After npm run build
└── Flutter/build/web/     # After flutter build web
```

**Server (Ubuntu):**
```
/var/www/customer-search-poc/
├── backend/               # Node.js running as service
├── frontend/dist/         # Served by Apache at /
└── flutter/build/web/     # Served by Apache at /flutter/
```

---

## Quick Reference

| Component | URL | Location |
|-----------|-----|----------|
| React Web App | `http://your-domain.com/` | `/var/www/customer-search-poc/frontend/dist` |
| Flutter App | `http://your-domain.com/flutter/` | `/var/www/customer-search-poc/flutter/build/web` |
| Node.js API | `http://your-domain.com/api/` | Proxied to `localhost:3000` |
