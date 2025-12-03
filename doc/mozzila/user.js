
// === Firefox Wayland / Hyprland Optimized Settings ===

// WebRender / GPU Acceleration
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.enabled", true);
user_pref("layers.acceleration.force-enabled", true);
user_pref("widget.wayland-dmabuf-vaapi.enabled", true);

// Smooth scrolling / touchpad zoom
user_pref("general.smoothScroll", true);
user_pref("apz.allow_zooming", true);

// Multi-process tabs
user_pref("browser.tabs.remote.autostart", true);

// Video acceleration
user_pref("media.ffmpeg.vaapi.enabled", true);

// HiDPI scaling (automatic)
user_pref("layout.css.devPixelsPerPx", -1.0);

// Optional: Disable animations for performance
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("ui.prefersReducedMotion", 1);
