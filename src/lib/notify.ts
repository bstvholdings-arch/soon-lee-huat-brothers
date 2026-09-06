/**
 * Admin alerting via WhatsApp (Meta Cloud API).
 *
 * Requires three env vars (server-only, do NOT prefix with NEXT_PUBLIC):
 *   WHATSAPP_TOKEN         - permanent or system-user access token
 *   WHATSAPP_PHONE_NUMBER_ID - the business phone number ID from Meta
 *   ADMIN_WHATSAPP         - recipient in E.164, digits only (e.g. 60174096251)
 *
 * If any is missing, notifyAdminViaWhatsApp() is a no-op (order flow continues).
 * The WhatsApp number must have an approved message template, OR be within the
 * 24h customer-service window for free-form text. For alerts we send a template
 * message if WHATSAPP_TEMPLATE is set, otherwise a free-form text (works only
 * inside the 24h window / with an approved template).
 */

const GRAPH_URL = "https://graph.facebook.com/v19.0";

function padE164(raw: string): string {
  const digits = raw.replace(/\D/g, "");
  return digits.startsWith("60") ? digits : `60${digits}`;
}

export async function notifyAdminViaWhatsApp(message: string): Promise<void> {
  const token = process.env.WHATSAPP_TOKEN;
  const phoneId = process.env.WHATSAPP_PHONE_NUMBER_ID;
  const admin = process.env.ADMIN_WHATSAPP;
  if (!token || !phoneId || !admin) return; // not configured -> skip silently

  const to = padE164(admin);
  const template = process.env.WHATSAPP_TEMPLATE;

  const body =
    template
      ? {
          messaging_product: "whatsapp",
          to,
          type: "template",
          template: {
            name: template,
            language: { code: process.env.WHATSAPP_TEMPLATE_LANG || "en" },
            components: [
              {
                type: "body",
                parameters: [{ type: "text", text: message.slice(0, 1024) }],
              },
            ],
          },
        }
      : {
          messaging_product: "whatsapp",
          to,
          type: "text",
          text: { body: message.slice(0, 4096) },
        };

  try {
    await fetch(`${GRAPH_URL}/${phoneId}/messages`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
  } catch {
    // best-effort: never break the order path on notify failure
  }
}
