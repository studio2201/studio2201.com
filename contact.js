(function () {
  var ADDR = "hello@studio2201.com";
  var form = document.getElementById("contact-form");
  var statusBox = document.getElementById("form-status");
  var copyEmailBtn = document.getElementById("copy-email");

  function copyText(text, btn, doneLabel) {
    if (!navigator.clipboard) return;
    navigator.clipboard.writeText(text).then(function () {
      var prev = btn.textContent;
      btn.textContent = doneLabel;
      setTimeout(function () { btn.textContent = prev; }, 1800);
    });
  }

  if (copyEmailBtn) {
    copyEmailBtn.addEventListener("click", function () {
      copyText(ADDR, copyEmailBtn, "Copied");
    });
  }

  function showStatus(msg, isErr, copyBody) {
    statusBox.className = "form-status visible" + (isErr ? " err" : "");
    statusBox.textContent = "";
    var p = document.createElement("span");
    p.textContent = msg;
    statusBox.appendChild(p);
    if (copyBody) {
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "mini-btn";
      btn.style.marginLeft = "0";
      btn.style.justifySelf = "start";
      btn.textContent = "Copy Inquiry Text";
      btn.addEventListener("click", function () {
        copyText(copyBody, btn, "Copied Inquiry");
      });
      statusBox.appendChild(btn);
    }
  }

  if (!form) return;

  form.addEventListener("submit", async function (e) {
    e.preventDefault();
    var data = new FormData(form);
    var name = String(data.get("name") || "").trim();
    var email = String(data.get("email") || "").trim();
    var service = String(data.get("service") || "").trim();
    var details = String(data.get("details") || "").trim();
    var website = String(data.get("website") || "").trim();

    if (!name || !email || !details) {
      showStatus("Please enter your name, email, and a short summary of your project.", true);
      return;
    }

    var subject = "[studio2201] " + service + " — " + name;
    var body = "Name: " + name + "\nEmail: " + email + "\nService: " + service + "\n\nProject Details:\n" + details;
    var endpoint = (form.dataset.endpoint || "").trim();
    var submitBtn = form.querySelector('button[type="submit"]');

    if (endpoint) {
      var prevLabel = submitBtn ? submitBtn.textContent : "";
      if (submitBtn) { submitBtn.disabled = true; submitBtn.textContent = "Sending..."; }
      try {
        var res = await fetch(endpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json", "Accept": "application/json" },
          body: JSON.stringify({ name: name, email: email, service: service, details: details, website: website })
        });
        if (!res.ok) throw new Error("Request failed");
        form.reset();
        showStatus("Inquiry sent! We will reply within 1–2 business days.", false);
        return;
      } catch (err) {
        showStatus("Could not send automatically. Email " + ADDR + " or copy your inquiry below.", true, body);
        return;
      } finally {
        if (submitBtn) { submitBtn.disabled = false; submitBtn.textContent = prevLabel; }
      }
    }

    window.location.href = "mailto:" + ADDR + "?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body);
    showStatus("Opening your email app addressed to " + ADDR + ". If it did not open, copy your inquiry below.", false, body);
  });
})();
