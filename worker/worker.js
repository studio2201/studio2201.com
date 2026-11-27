import { EmailMessage } from "cloudflare:email";

const ALLOWED_ORIGINS = new Set([
  "https://studio2201.com",
  "https://www.studio2201.com",
]);
const SENDER = "hello@studio2201.com";
const RECIPIENT = "jerydleuck@gmail.com";
const MAX_BODY_BYTES = 10240;

function corsHeaders(origin) {
  const h = { "Content-Type": "application/json; charset=utf-8" };
  if (origin && ALLOWED_ORIGINS.has(origin)) {
    h["Access-Control-Allow-Origin"] = origin;
    h["Access-Control-Allow-Methods"] = "POST, OPTIONS";
    h["Access-Control-Allow-Headers"] = "Content-Type";
    h["Vary"] = "Origin";
  }
  return h;
}

function json(data, status, origin) {
  return new Response(JSON.stringify(data), { status, headers: corsHeaders(origin) });
}

function cleanHeader(val, maxLen) {
  return String(val || "").replace(/[\r\n]+/g, " ").trim().slice(0, maxLen);
}

function buildRawMime(name, email, service, textBody) {
  const safeName = name.replace(/["\\]/g, "");
  const msgId = `<${crypto.randomUUID()}@studio2201.com>`;
  const headers = [
    `From: "studio2201 Website" <${SENDER}>`,
    `To: <${RECIPIENT}>`,
    `Reply-To: "${safeName}" <${email}>`,
    `Subject: [studio2201] ${service} - ${name}`,
    `Date: ${new Date().toUTCString()}`,
    `Message-ID: ${msgId}`,
    `MIME-Version: 1.0`,
    `Content-Type: text/plain; charset=utf-8`,
  ];
  return headers.join("\r\n") + "\r\n\r\n" + textBody.replace(/\r?\n/g, "\r\n");
}

export default {
  async fetch(request, env) {
    const origin = request.headers.get("Origin") || "";
    if (request.method === "OPTIONS") {
      if (origin && !ALLOWED_ORIGINS.has(origin)) return json({ error: "Forbidden" }, 403, origin);
      return new Response(null, { status: 204, headers: corsHeaders(origin) });
    }
    if (request.method !== "POST") return json({ error: "Method not allowed" }, 405, origin);
    if (origin && !ALLOWED_ORIGINS.has(origin)) return json({ error: "Forbidden origin" }, 403, origin);

    let raw;
    try {
      raw = await request.text();
    } catch {
      return json({ error: "Invalid request body" }, 400, origin);
    }
    if (!raw || raw.length > MAX_BODY_BYTES) return json({ error: "Invalid payload size" }, 400, origin);

    let data;
    try {
      data = JSON.parse(raw);
    } catch {
      return json({ error: "Invalid JSON" }, 400, origin);
    }

    if (String(data.website || "").trim()) return json({ ok: true }, 200, origin);

    const name = cleanHeader(data.name, 100);
    const email = cleanHeader(data.email, 254);
    const service = cleanHeader(data.service || "General Inquiry", 100);
    const details = String(data.details || "").trim().slice(0, 4000);

    if (!name || !email || !details || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return json({ error: "Please provide a valid name, email, and project details." }, 400, origin);
    }

    const textBody = `Name: ${name}\nEmail: ${email}\nService: ${service}\n\nProject Details:\n${details}\n`;
    try {
      await env.EMAIL.send({
        from: { email: SENDER, name: "studio2201 Website" },
        to: RECIPIENT,
        replyTo: { email, name },
        subject: `[studio2201] ${service} — ${name}`,
        text: textBody,
      });
      return json({ ok: true }, 200, origin);
    } catch (err) {
      try {
        const mime = buildRawMime(name, email, service, textBody);
        await env.EMAIL.send(new EmailMessage(SENDER, RECIPIENT, mime));
        return json({ ok: true }, 200, origin);
      } catch (err2) {
        return json({ error: err2?.message || err?.message || "Failed to send email" }, 502, origin);
      }
    }
  },
};
