// Classifies a chat message as either a plain question or a request to
// correct an existing transaction, and if it's a correction, extracts
// structured filter hints for finding it. Never receives or returns any
// transaction data — matching happens entirely client-side in Dart — and
// never writes to the database.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY");
const ANTHROPIC_MODEL = "claude-haiku-4-5";

const TOOL_NAME = "record_correction_intent";

const TOOL_SCHEMA = {
  name: TOOL_NAME,
  description:
    "Classifies whether the message is a transaction-correction request and, if so, extracts structured hints for finding and updating the transaction.",
  input_schema: {
    type: "object",
    required: ["is_correction", "confidence"],
    properties: {
      is_correction: {
        type: "boolean",
        description: "True only if the user is reporting a mistake in an existing transaction.",
      },
      target_description: {
        type: ["string", "null"],
        description: "Short free-text description of the transaction being referred to, e.g. 'coffee'.",
      },
      category_hint: {
        type: ["string", "null"],
        description: "Free-text guess of the transaction's category, e.g. 'food'. Not a category id.",
      },
      date_hint: {
        type: ["string", "null"],
        description: "Resolved date in YYYY-MM-DD if a specific/relative date was mentioned, else null.",
      },
      old_amount_hint: {
        type: ["number", "null"],
        description: "The amount the user says is currently wrong, if stated.",
      },
      new_amount: { type: ["number", "null"] },
      new_category_hint: { type: ["string", "null"] },
      new_date: { type: ["string", "null"], description: "YYYY-MM-DD" },
      new_note: { type: ["string", "null"] },
      confidence: { type: "string", enum: ["high", "medium", "low"] },
    },
  },
};

interface ParseRequestBody {
  text?: string;
  clientNow?: string;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function buildSystemPrompt(clientNow: string): string {
  return `You classify a chat message from a personal-finance app as either a plain question, or a request to correct a mistake in an already-recorded transaction.

Today's date (user's local time) is ${clientNow}. Resolve relative dates ("today", "yesterday", "last Monday") against this date.

Examples of correction requests: "my coffee transaction should be 500k not 50k", "change yesterday's grocery expense to 200k", "the transport one on the 5th was actually income not expense". Set is_correction to true for these.

Examples of NOT corrections: plain questions about spending/income/goals ("how much did I spend on food last week?"), requests to add a brand-new transaction ("spent 50k on coffee today"), general chat. Set is_correction to false for these, and for anything ambiguous — when unsure, prefer false, since a wrong positive here is more disruptive than a wrong negative.

When is_correction is true, extract only what the user explicitly stated as hints for finding and updating the transaction — normalize shorthand amounts ("50k" -> 50000, "1.5jt"/"1.5 juta" -> 1500000, "10rb" -> 10000). Never guess a value that wasn't stated; leave it null instead. Do not invent a target_description or category_hint if the message doesn't give one.

Always call the ${TOOL_NAME} tool with your best-effort structured result.`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (!ANTHROPIC_API_KEY) {
      return jsonResponse({ ok: false, error: "AI service is not configured." });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ ok: false, error: "Missing authorization." }, 401);
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();
    if (userError || !user) {
      return jsonResponse({ ok: false, error: "Not authenticated." }, 401);
    }

    const body: ParseRequestBody = await req.json();
    const text = body.text?.trim();
    if (!text) {
      return jsonResponse({ ok: false, error: "No text provided." });
    }
    const clientNow = body.clientNow ?? new Date().toISOString();

    let anthropicRes: Response;
    try {
      anthropicRes = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "x-api-key": ANTHROPIC_API_KEY,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model: ANTHROPIC_MODEL,
          max_tokens: 300,
          system: buildSystemPrompt(clientNow),
          messages: [{ role: "user", content: text }],
          tools: [TOOL_SCHEMA],
          tool_choice: { type: "tool", name: TOOL_NAME },
        }),
      });
    } catch {
      return jsonResponse({ ok: false, error: "AI service temporarily unavailable." });
    }

    if (!anthropicRes.ok) {
      return jsonResponse({ ok: false, error: "AI service temporarily unavailable." });
    }

    const anthropicJson = await anthropicRes.json();
    const toolUse = (anthropicJson.content ?? []).find(
      (block: { type: string }) => block.type === "tool_use",
    );
    if (!toolUse) {
      return jsonResponse({ ok: false, error: "Could not process that." });
    }

    const input = toolUse.input as Record<string, unknown>;

    return jsonResponse({
      ok: true,
      intent: {
        is_correction: input.is_correction === true,
        target_description: input.target_description ?? null,
        category_hint: input.category_hint ?? null,
        date_hint: input.date_hint ?? null,
        old_amount_hint: input.old_amount_hint ?? null,
        new_amount: input.new_amount ?? null,
        new_category_hint: input.new_category_hint ?? null,
        new_date: input.new_date ?? null,
        new_note: input.new_note ?? null,
        confidence: input.confidence ?? "medium",
      },
    });
  } catch (error) {
    console.error("parse-correction error", error);
    return jsonResponse({ ok: false, error: "Something went wrong." });
  }
});
