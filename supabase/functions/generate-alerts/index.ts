// Daily cron-triggered rule evaluation for Spending & Income Alerts. Unlike
// the other Edge Functions in this repo, this one has no user context (it's
// invoked by pg_cron via net.http_post, not by an authenticated client), so
// it uses the service-role key to bypass RLS and evaluate rules across all
// users in one pass, and checks a shared secret header instead of a user JWT
// (config.toml sets verify_jwt = false for this function). Detection itself
// is deterministic SQL (see supabase/migrations/20260724000000_alerts.sql,
// evaluate_alerts()) — no LLM call in this path.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const CRON_SECRET = Deno.env.get("CRON_SECRET");

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (!CRON_SECRET || req.headers.get("x-cron-secret") !== CRON_SECRET) {
      return jsonResponse({ ok: false, error: "Unauthorized." }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data, error } = await supabase.rpc("evaluate_alerts");
    if (error) {
      console.error("generate-alerts rpc error", error);
      return jsonResponse({ ok: false, error: "Failed to evaluate alerts." }, 500);
    }

    return jsonResponse({ ok: true, inserted: data ?? 0 });
  } catch (error) {
    console.error("generate-alerts error", error);
    return jsonResponse({ ok: false, error: "Something went wrong." });
  }
});
