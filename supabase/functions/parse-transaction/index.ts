// Parses free-text transaction descriptions (e.g. "spent 50k on coffee today")
// into structured suggestion data using Anthropic Claude. Never writes to the
// database itself — the client only commits after explicit user confirmation.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY");
const ANTHROPIC_MODEL = "claude-haiku-4-5";

// Mirrors lib/core/utils/icon_mapper.dart — keep in sync if that list changes.
const ALLOWED_ICON_KEYS = [
  "work",
  "store",
  "card_giftcard",
  "attach_money",
  "restaurant",
  "directions_car",
  "shopping_bag",
  "receipt_long",
  "movie",
  "local_hospital",
  "school",
  "category",
  "savings",
  "home",
  "flight",
  "pets",
  "fitness_center",
  "sports_esports",
];

const TOOL_NAME = "record_parsed_transaction";

const TOOL_SCHEMA = {
  name: TOOL_NAME,
  description:
    "Records the structured transaction parsed from the user's free-text description.",
  input_schema: {
    type: "object",
    required: ["amount", "type", "date", "confidence"],
    properties: {
      amount: {
        type: "number",
        description: "Positive numeric amount, with shorthand normalized (e.g. 50k -> 50000).",
      },
      type: { type: "string", enum: ["income", "expense"] },
      date: { type: "string", description: "Resolved date in YYYY-MM-DD format." },
      note: { type: ["string", "null"], description: "Short note/description, if any." },
      matched_category_id: {
        type: ["string", "null"],
        description: "id of the best-matching category from the provided list, or null.",
      },
      proposed_new_category: {
        type: ["object", "null"],
        properties: {
          name: { type: "string" },
          icon: { type: "string", enum: ALLOWED_ICON_KEYS },
          type: { type: "string", enum: ["income", "expense"] },
        },
        required: ["name", "icon", "type"],
      },
      confidence: { type: "string", enum: ["high", "medium", "low"] },
    },
  },
};

interface ParseRequestBody {
  text?: string;
  clientNow?: string;
}

interface CategoryRow {
  id: string;
  name: string;
  type: string;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function buildSystemPrompt(clientNow: string, categories: CategoryRow[]): string {
  const categoryList = categories
    .map((c) => `- id=${c.id} name="${c.name}" type=${c.type}`)
    .join("\n");

  return `You turn a short free-text description of a personal-finance transaction into structured data.

Today's date (user's local time) is ${clientNow}. Resolve relative dates ("today", "yesterday", "last Monday") against this date.

Normalize shorthand amounts: "50k" -> 50000, "1.5jt" or "1.5 juta" -> 1500000, "10rb" -> 10000. Amounts must be a positive number.

The user's existing categories are:
${categoryList || "(none yet)"}

Pick the best-matching category by meaning (not just exact text) and return its id as matched_category_id. Only return matched_category_id when you are reasonably confident it fits. If nothing fits well, leave matched_category_id null and instead return proposed_new_category with a short sensible name, an icon chosen from the allowed list, and the correct type. Never invent a category id that isn't in the list above.

Allowed icon keys: ${ALLOWED_ICON_KEYS.join(", ")}.

Set confidence to "low" if the input is ambiguous (e.g. unclear whether income or expense, unclear amount), "medium" if mostly clear, "high" if unambiguous. Always call the ${TOOL_NAME} tool with your best-effort structured result — do not ask clarifying questions in free text.`;
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

    const { data: categories, error: categoriesError } = await supabase
      .from("categories")
      .select("id, name, type")
      .or(`user_id.is.null,user_id.eq.${user.id}`)
      .eq("is_deleted", false);

    if (categoriesError) {
      return jsonResponse({ ok: false, error: "Could not load categories." });
    }

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
          max_tokens: 512,
          system: buildSystemPrompt(clientNow, (categories ?? []) as CategoryRow[]),
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
      return jsonResponse({ ok: false, error: "Could not understand that transaction." });
    }

    const input = toolUse.input as Record<string, unknown>;
    const amount = Number(input.amount);
    const type = input.type;
    const date = input.date;

    if (!Number.isFinite(amount) || amount <= 0) {
      return jsonResponse({ ok: false, error: "Could not determine a valid amount." });
    }
    if (type !== "income" && type !== "expense") {
      return jsonResponse({ ok: false, error: "Could not determine income or expense." });
    }
    if (typeof date !== "string" || Number.isNaN(Date.parse(date))) {
      return jsonResponse({ ok: false, error: "Could not determine a valid date." });
    }

    return jsonResponse({
      ok: true,
      suggestion: {
        amount,
        type,
        date,
        note: input.note ?? null,
        matched_category_id: input.matched_category_id ?? null,
        proposed_new_category: input.proposed_new_category ?? null,
        confidence: input.confidence ?? "medium",
      },
    });
  } catch (error) {
    console.error("parse-transaction error", error);
    return jsonResponse({ ok: false, error: "Something went wrong." });
  }
});
