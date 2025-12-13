// ===============================
// Firefox Wayland / Hyprland Optimized
// ===============================

// WebRender / GPU acceleration
// user_pref("gfx.webrender.all", true);
// user_pref("gfx.webrender.enabled", true);
// user_pref("widget.wayland-dmabuf-vaapi.enabled", true);
user_pref("browser.cache.disk.enable",false)

// Multi-process tabs
// user_pref("browser.tabs.remote.autostart", true);

// Video hardware acceleration
user_pref("media.ffmpeg.vaapi.enabled", true);

// HiDPI scaling (automatic)
// user_pref("layout.css.devPixelsPerPx", -1.0);
user_pref("layout.frame_rate", 144)
user_pref("browser.uidensity", 1)
// Optional: Reduce UI animations
// user_pref("toolkit.cosmeticAnimations.enabled", false);
// user_pref("ui.prefersReducedMotion", 1);
user_pref("general.smoothScroll.lines.durationMaxMS", 125);
user_pref("general.smoothScroll.lines.durationMinMS", 125);
user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 200);
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 100);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.other.durationMaxMS", 125);
user_pref("general.smoothScroll.other.durationMinMS", 125);
user_pref("general.smoothScroll.pages.durationMaxMS", 125);
user_pref("general.smoothScroll.pages.durationMinMS", 125);

user_pref("mousewheel.min_line_scroll_amount", 30);
user_pref("mousewheel.system_scroll_override_on_root_content.enabled", true);
user_pref("mousewheel.system_scroll_override_on_root_content.horizontal.factor", 175);
user_pref("mousewheel.system_scroll_override_on_root_content.vertical.factor", 175);
user_pref("toolkit.scrollbox.horizontalScrollDistance", 6);
user_pref("toolkit.scrollbox.verticalScrollDistance", 2);

