import OpenAI from "openai";
import { z } from "zod";

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const ResumeEvalSchema = z.object({
  score: z.number().min(0).max(100),
  improvements: z.array(z.string()).min(1)
});

export async function evaluateResume(resumeText: string) {
  if (!process.env.OPENAI_API_KEY) {
    return {
      score: 0,
      improvements: ["OPENAI_API_KEY nao configurada"]
    };
  }

  const response = await client.responses.create({
    model: "gpt-4.1-mini",
    input: [
      {
        role: "system",
        content:
          "Voce e um recrutador. Avalie curriculos em pt-BR com nota 0-100 e traga pontos de melhoria. Responda somente JSON com campos score (numero) e improvements (array)."
      },
      {
        role: "user",
        content: resumeText.slice(0, 8000)
      }
    ],
    response_format: { type: "json_object" }
  });

  const output = response.output_text ?? "";
  const parsed = ResumeEvalSchema.parse(JSON.parse(output));
  return parsed;
}
