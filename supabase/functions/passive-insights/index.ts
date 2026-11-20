// Generates a short, descriptive month-over-month spending observation (e.g.
// "You spent 30% more on Food this month") using Anthropic Claude. The model
// only ever sees a client-aggregated this-month/last-month summary — never
// raw transaction rows — and never writes to the database; this is a
// read-only insight endpoint, no confirmation required since nothing changes.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY");
const ANTHROPIC_MODEL = "claude-haiku-4-5";

const TOOL_NAME = "record_passive_insight";

const TOOL_SCHEMA = {
  name: TOOL_NAME,
  description:
    "Records a single short, notable observation about the user's month-over-month spending/income.",
  input_schema: {
    type: "object",
    required: ["headline", "detail", "trend"],
    properties: {
      headline: {
        type: "string",
        description: "Very short headline, e.g. 'Food spending is up 30%'.",
      },
      detail: {
        type: "string",
        description: "One short supporting sentence with more context.",
      },
      category: {
        type: ["string", "null"],
        description: "The category name this insight is about, if any, else null.",
      },
      trend: { type: "string", enum: ["up", "down", "neutral"] },
      percent_change: {
        type: ["number", "null"],
        description: "The percent change driving this insight, if applicable, else null.",
      },
    },
  },
};

interface PassiveInsightRequestBody {
  context?: Record<string, unknown>;
  clientNow?: string;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function buildSystemPrompt(clientNow: string, context: Record<string, unknown>): string {
  return `You are a personal finance assistant generating ONE short, notable observation about the user's own month-over-month spending or income.

Today's date is ${clientNow}.

You have been given the following pre-aggregated summary of the user's data. This is the ONLY data you have access to — you do not have row-level transaction history:

${JSON.stringify(context, null, 2)}

"this_month" and "last_month" each contain income, expense, and expense broken down by category.

Rules:
- Pick the single most notable signal: the category with the biggest expense percent change, or a notable overall income-vs-expense shift if no category stands out.
- If there isn't enough data in both months to compare (e.g. one month has no transactions), pick whatever mild observation is still honestly supportable, or a neutral/no-notable-change observation. Never fabricate numbers not derivable from the data above.
- Do NOT provide personalized investment, trading, or budgeting advice — this is a purely descriptive observation, not a recommendation.
- Keep headline under 8 words, detail under 20 words. Plain, concise language.
- Always call the ${TOOL_NAME} tool with your best-effort result — do not respond in free text.`;
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

    const body: PassiveInsightRequestBody = await req.json();
    const context = body.context ?? {};
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
          system: buildSystemPrompt(clientNow, context),
          messages: [{ role: "user", content: "Generate the insight." }],
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
      return jsonResponse({ ok: false, error: "Could not generate an insight." });
    }

    const input = toolUse.input as Record<string, unknown>;
    const headline = input.headline;
    const detail = input.detail;
    const trend = input.trend;

    if (typeof headline !== "string" || !headline.trim()) {
      return jsonResponse({ ok: false, error: "Could not generate an insight." });
    }
    if (typeof detail !== "string" || !detail.trim()) {
      return jsonResponse({ ok: false, error: "Could not generate an insight." });
    }
    if (trend !== "up" && trend !== "down" && trend !== "neutral") {
      return jsonResponse({ ok: false, error: "Could not generate an insight." });
    }

    return jsonResponse({
      ok: true,
      insight: {
        headline,
        detail,
        category: input.category ?? null,
        trend,
        percent_change: input.percent_change ?? null,
      },
    });
  } catch (error) {
    console.error("passive-insights error", error);
    return jsonResponse({ ok: false, error: "Something went wrong." });
  }
});
