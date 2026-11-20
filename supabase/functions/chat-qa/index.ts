// Answers free-text questions about the user's own financial data using
// Anthropic Claude. The model only ever sees client-aggregated summaries
// (weekly/monthly totals, balance, wishlist status) — never raw transaction
// rows — and never writes to the database; this is a read-only Q&A endpoint.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY");
const ANTHROPIC_MODEL = "claude-haiku-4-5";
const MAX_HISTORY_TURNS = 20;

interface ChatTurn {
  role: "user" | "assistant";
  content: string;
}

interface ChatQaRequestBody {
  messages?: ChatTurn[];
  context?: Record<string, unknown>;
  clientNow?: string;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function isValidTurn(turn: unknown): turn is ChatTurn {
  if (typeof turn !== "object" || turn === null) return false;
  const t = turn as Record<string, unknown>;
  return (
    (t.role === "user" || t.role === "assistant") &&
    typeof t.content === "string" &&
    t.content.trim().length > 0
  );
}

function buildSystemPrompt(clientNow: string, context: Record<string, unknown>): string {
  return `You are a personal finance assistant answering questions about the user's own financial data.

Today's date is ${clientNow}.

You have been given the following pre-aggregated summary of the user's data. This is the ONLY data you have access to — you do not have row-level transaction history:

${JSON.stringify(context, null, 2)}

Data coverage: "weekly" covers the last 8 Mon-Sun weeks (oldest first), "monthly" covers the last 12 calendar months (oldest first), "current_balance" is all-time net (income minus expense), "wishlist_goals" shows each goal's name/target amount/current amount/deadline/completion status only.

Rules:
- Answer ONLY using the data above. If the question needs data outside this range or granularity (e.g. a specific single transaction, a date older than 12 months, or something not present), say plainly that you don't have that data rather than guessing.
- Do NOT provide personalized investment, trading, or financial advice (e.g. "should I invest in X", "is this a good stock", "how should I allocate my portfolio"). If asked, politely decline and note you can only help understand the user's own recorded income/spending patterns.
- Do NOT recommend specific financial products, prescriptive budgeting percentages, or predict future market performance.
- You may offer general observational commentary about the user's own spending/saving patterns (e.g. "your transport spending rose 20% this month") since that's descriptive, not advice.
- Respond in plain, concise natural language (2-4 sentences typically). Do not output JSON, markdown tables, or code blocks — this is a chat conversation.
- If the user's question is ambiguous, ask a brief clarifying question instead of guessing.`;
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

    const body: ChatQaRequestBody = await req.json();
    const messages = (body.messages ?? []).filter(isValidTurn);
    if (messages.length === 0) {
      return jsonResponse({ ok: false, error: "No question provided." });
    }
    const context = body.context ?? {};
    const clientNow = body.clientNow ?? new Date().toISOString();

    const trimmedMessages = messages.slice(-MAX_HISTORY_TURNS);

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
          max_tokens: 400,
          system: buildSystemPrompt(clientNow, context),
          messages: trimmedMessages.map((m) => ({ role: m.role, content: m.content })),
        }),
      });
    } catch {
      return jsonResponse({ ok: false, error: "AI service temporarily unavailable." });
    }

    if (!anthropicRes.ok) {
      return jsonResponse({ ok: false, error: "AI service temporarily unavailable." });
    }

    const anthropicJson = await anthropicRes.json();
    const textBlocks = (anthropicJson.content ?? []).filter(
      (block: { type: string }) => block.type === "text",
    );
    const answer = textBlocks.map((block: { text: string }) => block.text).join("\n").trim();

    if (!answer) {
      return jsonResponse({ ok: false, error: "Could not answer that." });
    }

    return jsonResponse({ ok: true, answer });
  } catch (error) {
    console.error("chat-qa error", error);
    return jsonResponse({ ok: false, error: "Something went wrong." });
  }
});
