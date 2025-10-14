# Launchpad Website

A modern, responsive landing page for the Launchpad macOS application.

## 🎨 Features

- **Modern Design**: Clean, professional UI with glassmorphism effects
- **Fully Responsive**: Works perfectly on desktop, tablet, and mobile devices
- **Smooth Animations**: Fade-in effects, parallax scrolling, and smooth transitions
- **Interactive Elements**: Mobile menu, smooth scrolling, hover effects
- **SEO Ready**: Semantic HTML5 structure
- **Performance Optimized**: Lightweight CSS and vanilla JavaScript

## 📁 File Structure

```
website/
├── index.html       # Main HTML structure
├── styles.css       # All styling and responsive design
├── script.js        # Interactive functionality
└── README.md        # This file
```

## 🚀 Deployment Options

### Option 1: GitHub Pages (Recommended - Free)

1. **Push to GitHub:**
   ```bash
   cd /Users/pappkristof/Developer/Launchpad
   git add website/
   git commit -m "Add website"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to your repository on GitHub
   - Navigate to Settings → Pages
   - Under "Source", select the branch (e.g., `main`)
   - Set folder to `/website` or move website files to root
   - Click Save

3. **Access your site:**
   - Your site will be available at: `https://kristof12345.github.io/Launchpad/`
   - Wait a few minutes for deployment

### Option 2: Netlify (Free)

1. **Sign up at [Netlify](https://www.netlify.com/)**

2. **Deploy via drag & drop:**
   - Go to https://app.netlify.com/drop
   - Drag the `website` folder onto the page
   - Your site is live instantly!

3. **Or deploy via CLI:**
   ```bash
   npm install -g netlify-cli
   cd website
   netlify deploy --prod
   ```

### Option 3: Vercel (Free)

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Deploy:**
   ```bash
   cd website
   vercel --prod
   ```

3. **Follow the prompts** to complete deployment

### Option 4: Custom Hosting

Upload the `website` folder contents to any web hosting service:
- **Traditional hosting**: Upload via FTP/SFTP
- **Cloud providers**: AWS S3, Google Cloud Storage, Azure Storage
- **CDN**: Cloudflare Pages, Fastly

## 🔧 Local Development

To preview locally, you need a simple web server (not just opening the HTML file):

### Option 1: Python (macOS built-in)
```bash
cd website
python3 -m http.server 8000
```
Then open: http://localhost:8000

### Option 2: Node.js http-server
```bash
npm install -g http-server
cd website
http-server
```

### Option 3: VS Code Live Server Extension
1. Install "Live Server" extension in VS Code
2. Right-click `index.html`
3. Select "Open with Live Server"

## 🎨 Customization

### Colors
Edit CSS variables in `styles.css`:
```css
:root {
    --primary: #0066ff;          /* Primary brand color */
    --primary-dark: #0052cc;     /* Darker shade */
    --primary-light: #3385ff;    /* Lighter shade */
    /* ... more colors ... */
}
```

### Content
Edit text content directly in `index.html`:
- Hero title and subtitle
- Feature descriptions
- Pricing information
- Footer links

### Images
Replace screenshot placeholders:
1. Add your images to `website/images/` folder
2. Update `<div class="screenshot-placeholder">` sections in HTML
3. Use `<img src="images/screenshot.png" alt="Description">`

### Fonts
Current font: **Inter** from Google Fonts
To change, update the `<link>` in HTML head and CSS `font-family`

## 📱 Mobile Menu

The mobile menu automatically appears on screens < 768px wide.
Hamburger icon animates to X when opened.

## ⚡ Performance Tips

1. **Optimize images:**
   ```bash
   # Use tools like ImageOptim, TinyPNG, or:
   brew install imageoptim-cli
   imageoptim website/images/*.png
   ```

2. **Minify CSS/JS for production:**
   ```bash
   npm install -g clean-css-cli uglify-js
   cleancss -o styles.min.css styles.css
   uglifyjs script.js -o script.min.js
   ```

3. **Enable gzip compression** on your server

4. **Use CDN** for static assets

## 🎯 SEO Optimization

Add these to `<head>` section:

```html
<!-- Open Graph / Facebook -->
<meta property="og:type" content="website">
<meta property="og:url" content="https://yourdomain.com/">
<meta property="og:title" content="Launchpad - Modern App Launcher for macOS">
<meta property="og:description" content="A beautiful, customizable alternative to Apple's Launchpad">
<meta property="og:image" content="https://yourdomain.com/og-image.png">

<!-- Twitter -->
<meta property="twitter:card" content="summary_large_image">
<meta property="twitter:url" content="https://yourdomain.com/">
<meta property="twitter:title" content="Launchpad - Modern App Launcher for macOS">
<meta property="twitter:description" content="A beautiful, customizable alternative to Apple's Launchpad">
<meta property="twitter:image" content="https://yourdomain.com/twitter-image.png">

<!-- Favicon -->
<link rel="icon" type="image/png" href="favicon.png">
<link rel="apple-touch-icon" href="apple-touch-icon.png">
```

## 📊 Analytics (Optional)

### Google Analytics
Add before closing `</head>`:
```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### Plausible Analytics (Privacy-friendly alternative)
```html
<script defer data-domain="yourdomain.com" src="https://plausible.io/js/script.js"></script>
```

## 🐛 Troubleshooting

**Mobile menu not working:**
- Check browser console for JavaScript errors
- Ensure `script.js` is loaded correctly

**Animations not smooth:**
- Check if user has "Reduce motion" enabled in system preferences
- Animations respect `prefers-reduced-motion` media query

**Fonts not loading:**
- Check internet connection (Google Fonts requires network)
- Consider self-hosting fonts for offline use

## 📝 License

This website code follows the same license as the Launchpad application.
See parent LICENSE.md file for details.

## 🔗 Links

- **Main Repository**: https://github.com/kristof12345/Launchpad
- **Releases**: https://github.com/kristof12345/Launchpad/releases
- **Support**: https://buymeacoffee.com/kristofpapp

## 🎉 Easter Eggs

Try the Konami Code: ↑ ↑ ↓ ↓ ← → ← → B A

---

Built with ❤️ for Launchpad
