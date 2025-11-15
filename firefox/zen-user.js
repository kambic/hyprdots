// ===============================
// Firefox Wayland / Hyprland + Zen
// ===============================

// --- GPU / Wayland ---
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.enabled", true);
user_pref("layers.acceleration.force-enabled", true);
user_pref("widget.wayland-dmabuf-vaapi.enabled", true);

// --- Smooth scrolling / zoom ---
user_pref("general.smoothScroll", true);
user_pref("apz.allow_zooming", true);

// --- Multi-process tabs ---
user_pref("browser.tabs.remote.autostart", true);

// --- Video hardware acceleration ---
user_pref("media.ffmpeg.vaapi.enabled", true);

// --- HiDPI scaling (automatic) ---
user_pref("layout.css.devPixelsPerPx", -1.0);

// --- Reduce UI animations ---
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("ui.prefersReducedMotion", 1);

// --- Zen / minimal distractions ---
user_pref("browser.fullscreen.autohide", true);           // Auto-hide toolbars in fullscreen
user_pref("browser.urlbar.suggest.searches", false);       // Hide search suggestions
user_pref("browser.urlbar.suggest.history", false);        // Hide history suggestions
user_pref("browser.startup.page", 3);                      // Restore previous session
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false); // Remove Top Stories
user_pref("browser.toolbars.bookmarks.visibility", "never"); // Hide bookmarks toolbar
user_pref("browser.tabs.drawInTitlebar", true);            // Clean titlebar look
user_pref("browser.uiCustomization.state", '{"placements":{}}'); // Blank UI layout
