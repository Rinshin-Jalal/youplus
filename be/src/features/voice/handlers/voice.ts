import { Context } from "hono";
import { updateUserVoiceId } from "@/features/core/utils/database";
import { getAuthenticatedUserId } from "@/middleware/auth";
import { Env } from "@/index";

// Voice cloning endpoint for ElevenLabs
export const postVoiceClone = async (c: Context) => {
  const formData = await c.req.formData();
  const audioFiles = formData.getAll("audio") as File[];
  const userId = getAuthenticatedUserId(c);
  const voiceName = (formData.get("voiceName") as string) || `voice_${userId}`;

  if (audioFiles.length === 0) {
    return c.json({ error: "Missing audio files" }, 400);
  }

  const env = c.env as Env;

  try {
    console.log(`🎤 Cloning voice for ${userId} - ${audioFiles.length} files`);

    // Build FormData for ElevenLabs with multiple files
    const elevenForm = new FormData();
    elevenForm.append("name", voiceName);
    elevenForm.append("description", `Voice clone for ${userId}`);

    let totalBytes = 0;
    for (const file of audioFiles) {
      const buf = await file.arrayBuffer();
      totalBytes += buf.byteLength;
      if (totalBytes > 10 * 1024 * 1024) {
        return c.json({ error: "Combined audio too large (max 10MB)" }, 400);
      }
      elevenForm.append(
        "files",
        new Blob([buf], { type: file.type || "audio/mpeg" }),
        file.name || "sample.mp3"
      );
    }

    const elevenRes = await fetch("https://api.elevenlabs.io/v1/voices/add", {
      method: "POST",
      headers: { "xi-api-key": env.ELEVENLABS_API_KEY },
      body: elevenForm,
    });

    if (!elevenRes.ok) {
      return c.json({ error: `ElevenLabs failed ${elevenRes.status}` }, 500);
    }

    const { voice_id } = await elevenRes.json();
    await updateUserVoiceId(env, userId, voice_id);

    return c.json({ success: true, voice_id });
  } catch (error) {
    console.error("Voice cloning endpoint error:", error);
    return c.json(
      {
        error: "Voice cloning failed",
        details: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

// Voice analysis endpoint - Analyze user's path from first voice recording
export const postOnboardingAnalyzeVoice = async (c: Context) => {
  const formData = await c.req.formData();
  const audioFile = formData.get("audio") as File;
  const sessionId = formData.get("sessionId") as string;
  const stepNumber = formData.get("stepNumber") as string;

  if (!audioFile || !sessionId) {
    return c.json({ error: "Missing audio file or sessionId" }, 400);
  }

  // Use sessionId as temporary identifier for pre-auth onboarding
  // TODO: After user authenticates, migrate this analysis to their actual user ID
  const userId = sessionId;

  const env = c.env as Env;

  try {
    // Convert audio file to buffer for Deepgram
    const audioBuffer = await audioFile.arrayBuffer();

    // Transcribe audio using Deepgram
    const transcript = await transcribeAudio(
      audioBuffer,
      env.DEEPGRAM_API_KEY || ""
    );

    return c.json({ transcript });
  } catch (error) {
    console.error("Voice analysis error:", error);
    return c.json(
      {
        error: "Voice analysis failed",
        details: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

// Helper function to transcribe audio using Deepgram
async function transcribeAudio(
  audioBuffer: ArrayBuffer,
  apiKey: string
): Promise<string> {
  const response = await fetch(
    "https://api.deepgram.com/v1/listen?model=nova-2&smart_format=true&punctuate=true",
    {
      method: "POST",
      headers: {
        Authorization: `Token ${apiKey}`,
        "Content-Type": "audio/wav",
      },
      body: audioBuffer,
    }
  );

  if (!response.ok) {
    throw new Error(`Deepgram transcription failed: ${response.status}`);
  }

  const result = await response.json();
  return result.results?.channels?.[0]?.alternatives?.[0]?.transcript || "";
}