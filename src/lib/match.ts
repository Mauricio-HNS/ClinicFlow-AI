import OpenAI from "openai";

type MatchInput = {
  resumeText: string;
  jobText: string;
};

type MatchResult = {
  score: number;
  reasons: string[];
};

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

function cosineSimilarity(a: number[], b: number[]) {
  let dot = 0;
  let aNorm = 0;
  let bNorm = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    aNorm += a[i] * a[i];
    bNorm += b[i] * b[i];
  }
  if (aNorm === 0 || bNorm === 0) return 0;
  return dot / (Math.sqrt(aNorm) * Math.sqrt(bNorm));
}

export async function computeMatch({ resumeText, jobText }: MatchInput) {
  if (!process.env.OPENAI_API_KEY) {
    return {
      score: 0,
      reasons: ["OPENAI_API_KEY nao configurada"]
    } satisfies MatchResult;
  }

  const [resumeEmb, jobEmb] = await Promise.all([
    client.embeddings.create({
      model: "text-embedding-3-large",
      input: resumeText
    }),
    client.embeddings.create({
      model: "text-embedding-3-large",
      input: jobText
    })
  ]);

  const similarity = cosineSimilarity(
    resumeEmb.data[0].embedding,
    jobEmb.data[0].embedding
  );

  return {
    score: Math.round(similarity * 100),
    reasons: ["Similaridade semantica do curriculo com a vaga"]
  } satisfies MatchResult;
}
