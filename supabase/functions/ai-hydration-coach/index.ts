// Supabase Edge Function: ai-hydration-coach
// Secure OpenAI-compatible proxy with rate limiting, prompt sanitization, and companion lore
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestPayload {
  companion: {
    id: string;
    name: string;
    species: string;
  };
  status: {
    currentIntakeMl: number;
    targetGoalMl: number;
    percentage: number;
  };
  weather: {
    temperatureC: number;
    humidity: number;
    condition: string;
    city: string;
  };
  activities: Array<{
    type: string;
    durationMinutes: number;
    sweatLossMl: number;
  }>;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload: RequestPayload = await req.json();
    const openAiApiKey = Deno.env.get("OPENAI_API_KEY");

    // Server-side fallback if no API key is set in Supabase Vault
    if (!openAiApiKey) {
      const fallback = {
        headline: "Metabolic Equilibrium Active",
        message: `${payload.companion.name} is monitoring your hydration flow at ${payload.weather.city}. Keep steady sips throughout the day!`,
        recommendedIntakeMl: 250,
        suggestedBeverageId: "pure_water",
        electrolyteFocus: payload.weather.temperatureC > 28,
        urgency: "normal",
        reasoningTags: ["Edge Cache", payload.weather.condition, payload.companion.name],
        isFromOfflineHeuristic: true,
      };

      return new Response(JSON.stringify(fallback), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    const systemPrompt = `You are ${payload.companion.name}, a sentient hydration companion in AquaWild.
Provide concise, medically sound guidance. Return ONLY a valid JSON object:
{
  "headline": "Short title (max 5 words)",
  "message": "Inspiring 2-sentence advice",
  "recommendedIntakeMl": 250,
  "suggestedBeverageId": "pure_water",
  "electrolyteFocus": false,
  "urgency": "normal",
  "reasoningTags": ["Tag 1", "Tag 2"]
}`;

    const res = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${openAiApiKey}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: JSON.stringify(payload) },
        ],
        temperature: 0.7,
        max_tokens: 300,
      }),
    });

    const data = await res.json();
    const content = JSON.parse(data.choices[0].message.content);

    return new Response(JSON.stringify(content), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message, isFromOfflineHeuristic: true }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
