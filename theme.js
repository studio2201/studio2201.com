(function () {
  var KEY = "studio2201_agency_theme";
  var COLORS = { light: "#f6f3ec", dark: "#121514" };

  function getInitial() {
    try {
      var saved = localStorage.getItem(KEY);
      if (saved === "light" || saved === "dark") return saved;
    } catch (e) {}
    return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  function applyTheme(theme) {
    document.documentElement.dataset.theme = theme;
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute("content", COLORS[theme] || COLORS.light);
    var btn = document.getElementById("theme-toggle");
    if (btn) {
      btn.textContent = theme === "dark" ? "Warm Light" : "Charcoal";
      btn.setAttribute("aria-pressed", theme === "dark" ? "true" : "false");
    }
  }

  var current = getInitial();
  applyTheme(current);

  document.addEventListener("DOMContentLoaded", function () {
    applyTheme(current);
    var btn = document.getElementById("theme-toggle");
    if (!btn) return;
    btn.addEventListener("click", function () {
      current = current === "dark" ? "light" : "dark";
      try { localStorage.setItem(KEY, current); } catch (e) {}
      applyTheme(current);
    });
  });
})();
