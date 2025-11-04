/* ═══════════════════════════════════════════════════════════════════════════════
 * 🎤 BIG BRUH VOICE CLONING SERVICE - ELEVENLABS INTEGRATION
 *
 * Creates personalized AI voices for users during onboarding using ElevenLabs
 * advanced voice synthesis technology. The cloned voice becomes the user's
 * permanent AI accountability partner voice for all future calls.
 *
 * Core Philosophy: "Your voice, your accountability - maximizing psychological impact"
 * ═══════════════════════════════════════════════════════════════════════════════ */

// 📝 Voice cloning request structure
interface VoiceCloneRequest {
  audio_url: string; // 🔗 URL to user's audio sample (onboarding recording)
  voice_name: string; // 🏷️ Friendly name for the cloned voice
  user_id: string; // 👤 User identifier for tracking and cleanup
}

// 📋 Voice cloning operation result
interface VoiceCloneResponse {
  voice_id: string; // 🎯 ElevenLabs voice ID for future TTS calls
  success: boolean; // ✅ Whether the cloning operation succeeded
  error?: string; // ❌ Error message if cloning failed
}

// 🔧 Environment configuration for ElevenLabs API
interface VoiceCloneEnv {
  ELEVENLABS_API_KEY: string; // 🔑 ElevenLabs API authentication key
}

/* ═══════════════════════════════════════════════════════════════════════════════
 * 🏗️ ELEVENLABS VOICE CLONING SERVICE CLASS
 *
 * Handles the complete voice cloning pipeline during user onboarding:
 *
 * 🎯 ONBOARDING FLOW:
 *    1. User records voice sample in mobile app
 *    2. Audio uploaded to secure storage
 *    3. This service clones voice via ElevenLabs API
 *    4. Voice ID saved to database for future TTS calls
 *
 * 💡 PSYCHOLOGICAL IMPACT: Using user's own voice maximizes accountability
 *    effectiveness - the brain recognizes it as "self-talk" rather than external
 * ═══════════════════════════════════════════════════════════════════════════════ */
export class VoiceCloneService {
  private env: VoiceCloneEnv; // 🔧 ElevenLabs API configuration

  constructor(env: VoiceCloneEnv) {
    this.env = env;
  }

  /* ═══════════════════════════════════════════════════════════════════════════════
   * 🎤 MAIN VOICE CLONING FUNCTION
   *
   * The complete pipeline that transforms a user's audio sample into a permanent
   * AI voice clone for accountability calls. Handles all ElevenLabs API
   * complexity with robust error handling and validation.
   *
   * Process: Download Audio → Validate → Upload to ElevenLabs → Return Voice ID
   * ═══════════════════════════════════════════════════════════════════════════════ */
  async cloneUserVoice(
    request: VoiceCloneRequest
  ): Promise<VoiceCloneResponse> {
    try {
      console.log(
        `🎤 Initiating voice clone pipeline for user ${request.user_id}...`
      );

      // 📥 STEP 1: Download and validate audio file from secure storage
      const audioResponse = await fetch(request.audio_url);
      if (!audioResponse.ok) {
        throw new Error(`Audio download failed: ${audioResponse.status}`);
      }

      const audioBuffer = await audioResponse.arrayBuffer();

      // 🔍 STEP 2: Validate audio meets ElevenLabs requirements
      if (audioBuffer.byteLength > 10 * 1024 * 1024) {
        throw new Error("Audio exceeds 10MB ElevenLabs limit"); // 📏 Size constraint
      }

      if (audioBuffer.byteLength < 1024) {
        throw new Error("Audio too small - need at least 1KB"); // 📏 Minimum quality
      }

      // 📦 STEP 3: Prepare multipart form data for ElevenLabs API
      const formData = new FormData();
      formData.append("name", request.voice_name); // 🏷️ Voice display name
      formData.append(
        "description",
        `BIG BRUH AI voice clone for user ${request.user_id}`
      );
      formData.append(
        "files",
        new Blob([audioBuffer], { type: "audio/mpeg" }),
        "voice_sample.mp3" // 📄 Audio file for cloning
      );

      // 🚀 STEP 4: Submit to ElevenLabs voice cloning endpoint
      const response = await fetch("https://api.elevenlabs.io/v1/voices/add", {
        method: "POST",
        headers: {
          "xi-api-key": this.env.ELEVENLABS_API_KEY, // 🔑 API authentication
        },
        body: formData,
      });

      // 🔍 STEP 5: Handle ElevenLabs API response
      if (!response.ok) {
        const errorText = await response.text();
        console.error("❌ ElevenLabs API rejected request:", errorText);
        throw new Error(
          `Voice cloning failed: ${response.status} - ${errorText}`
        );
      }

      const result = await response.json();

      console.log(
        `✅ Voice clone successful! Voice ID: ${result.voice_id} for user ${request.user_id}`
      );

      // 🎯 Return success with ElevenLabs voice ID for future TTS calls
      return {
        voice_id: result.voice_id, // 🆔 Permanent voice identifier
        success: true,
      };
    } catch (error) {
      console.error(
        `💥 Voice cloning pipeline failed for user ${request.user_id}:`,
        error
      );

      // 🛟 Return safe error response - never crash onboarding flow
      return {
        voice_id: "",
        success: false,
        error: error instanceof Error ? error.message : "Unknown cloning error",
      };
    }
  }

  /* ═══════════════════════════════════════════════════════════════════════════════
   * 📋 VOICE LIBRARY MANAGEMENT
   * Get all available voices from ElevenLabs (includes default + user clones)
   * ═══════════════════════════════════════════════════════════════════════════════ */
  async getVoices(): Promise<any[]> {
    try {
      const response = await fetch("https://api.elevenlabs.io/v1/voices", {
        headers: {
          "xi-api-key": this.env.ELEVENLABS_API_KEY,
        },
      });

      if (!response.ok) {
        throw new Error(`Voice library fetch failed: ${response.status}`);
      }

      const data = await response.json();
      return data.voices || []; // 🎭 Array of all available voices
    } catch (error) {
      console.error("💥 Voice library access failed:", error);
      return []; // 🛟 Safe fallback - empty array
    }
  }

  /* ═══════════════════════════════════════════════════════════════════════════════
   * 🗑️ VOICE CLEANUP SYSTEM
   * Delete user voice clones when accounts are terminated or voices are replaced
   * ═══════════════════════════════════════════════════════════════════════════════ */
  async deleteVoice(voiceId: string): Promise<boolean> {
    try {
      const response = await fetch(
        `https://api.elevenlabs.io/v1/voices/${voiceId}`,
        {
          method: "DELETE",
          headers: {
            "xi-api-key": this.env.ELEVENLABS_API_KEY,
          },
        }
      );

      if (response.ok) {
        console.log(`🗑️ Voice ${voiceId} successfully deleted`);
      } else {
        console.error(`❌ Voice deletion failed: ${response.status}`);
      }

      return response.ok;
    } catch (error) {
      console.error("💥 Voice deletion error:", error);
      return false; // 🛟 Safe failure response
    }
  }

  /* ═══════════════════════════════════════════════════════════════════════════════
   * 🔍 VOICE INSPECTION SYSTEM
   * Get detailed information about a specific voice clone for debugging/validation
   * ═══════════════════════════════════════════════════════════════════════════════ */
  async getVoiceInfo(voiceId: string): Promise<any | null> {
    try {
      const response = await fetch(
        `https://api.elevenlabs.io/v1/voices/${voiceId}`,
        {
          headers: {
            "xi-api-key": this.env.ELEVENLABS_API_KEY,
          },
        }
      );

      if (!response.ok) {
        console.error(`❌ Voice info fetch failed: ${response.status}`);
        return null; // 🛟 Voice doesn't exist or is inaccessible
      }

      return await response.json(); // 📊 Complete voice metadata
    } catch (error) {
      console.error("💥 Voice info lookup error:", error);
      return null; // 🛟 Safe failure response
    }
  }
}

/* ═══════════════════════════════════════════════════════════════════════════════
 * 🏭 FACTORY & UTILITY FUNCTIONS
 * ═══════════════════════════════════════════════════════════════════════════════ */

/**
 * 🏗️ Voice cloning service factory - creates configured service instance
 */
export function createVoiceCloneService(env: VoiceCloneEnv): VoiceCloneService {
  return new VoiceCloneService(env);
}

/**
 * 🚀 One-shot voice cloning utility - for simple use cases
 * Perfect for onboarding flows that just need to clone once and get the voice ID
 */
export async function cloneVoice(
  request: VoiceCloneRequest,
  env: VoiceCloneEnv
): Promise<VoiceCloneResponse> {
  const service = createVoiceCloneService(env);
  return service.cloneUserVoice(request);
}