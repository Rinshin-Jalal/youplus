/**
 * Runtime Type Validation for External API Integrations
 * 
 * This file provides runtime validation utilities for external API integrations
 * like ElevenLabs, OpenAI, Supabase, etc. It ensures type safety when consuming
 * external APIs and handles validation errors gracefully.
 */

import { z } from "zod";
import { AppError, createError } from "@/types/errors";

// Generic external API response wrapper
export const ExternalApiResponseSchema = <T extends z.ZodType>(dataSchema: T) =>
  z.object({
    success: z.boolean(),
    data: dataSchema.optional(),
    error: z.object({
      code: z.string(),
      message: z.string(),
      details: z.any().optional(),
    }).optional(),
    metadata: z.object({
      requestId: z.string().optional(),
      timestamp: z.string(),
      latency: z.number().optional(),
    }).optional(),
  });

export type ExternalApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  metadata?: {
    requestId?: string;
    timestamp: string;
    latency?: number;
  };
};

// ElevenLabs API schemas
export const ElevenLabsVoiceSchema = z.object({
  voice_id: z.string(),
  name: z.string(),
  samples: z.array(z.object({
    sample_id: z.string(),
    file_name: z.string(),
    mime_type: z.string(),
    size_bytes: z.number(),
    hash: z.string(),
  })),
  category: z.string(),
  fine_tuning: z.object({
    model_id: z.string().optional(),
    is_allowed_to_fine_tune: z.boolean(),
    finetuning_state: z.string(),
    verification_attempts: z.array(z.any()),
    verification_failures: z.array(z.string()),
    verification_attempts_count: z.number(),
    manual_verification_requested: z.boolean(),
    language: z.string().optional(),
  }),
  labels: z.record(z.string()),
  description: z.string().optional(),
  preview_url: z.string().optional(),
  available_for_tiers: z.array(z.string()),
  settings: z.object({
    stability: z.number(),
    similarity_boost: z.number(),
    style: z.number().optional(),
    use_speaker_boost: z.boolean(),
  }),
  sharing: z.object({
    status: z.string(),
    history_item_sample_id: z.string().optional(),
    original_voice_id: z.string().optional(),
    public_owner_id: z.string().optional(),
    liked_by_count: z.number(),
    cloned_by_count: z.number(),
    name: z.string().optional(),
    description: z.string().optional(),
    labels: z.record(z.string()),
    created_at_unix: z.number(),
    share_link_id: z.string().optional(),
  }),
  safety_control: z.string().optional(),
  voice_verification: z.object({
    requires_verification: z.boolean(),
    is_verified: z.boolean(),
    verification_failures: z.array(z.string()),
    verification_attempts_count: z.number(),
    language: z.string().optional(),
  }),
  permission_on_resource: z.string(),
});

export const ElevenLabsCloneRequestSchema = z.object({
  name: z.string(),
  files: z.array(z.string()), // Base64 encoded audio files
  description: z.string().optional(),
  labels: z.record(z.string()).optional(),
});

export const ElevenLabsCloneResponseSchema = z.object({
  voice_id: z.string(),
  name: z.string(),
  samples: z.array(z.object({
    sample_id: z.string(),
    file_name: z.string(),
    mime_type: z.string(),
    size_bytes: z.number(),
    hash: z.string(),
  })),
  category: z.string(),
  fine_tuning: z.object({
    model_id: z.string().optional(),
    is_allowed_to_fine_tune: z.boolean(),
    finetuning_state: z.string(),
    verification_attempts: z.array(z.any()),
    verification_failures: z.array(z.string()),
    verification_attempts_count: z.number(),
    manual_verification_requested: z.boolean(),
    language: z.string().optional(),
  }),
  labels: z.record(z.string()),
  description: z.string().optional(),
  preview_url: z.string().optional(),
  available_for_tiers: z.array(z.string()),
  settings: z.object({
    stability: z.number(),
    similarity_boost: z.number(),
    style: z.number().optional(),
    use_speaker_boost: z.boolean(),
  }),
  sharing: z.object({
    status: z.string(),
    history_item_sample_id: z.string().optional(),
    original_voice_id: z.string().optional(),
    public_owner_id: z.string().optional(),
    liked_by_count: z.number(),
    cloned_by_count: z.number(),
    name: z.string().optional(),
    description: z.string().optional(),
    labels: z.record(z.string()),
    created_at_unix: z.number(),
    share_link_id: z.string().optional(),
  }),
  safety_control: z.string().optional(),
  voice_verification: z.object({
    requires_verification: z.boolean(),
    is_verified: z.boolean(),
    verification_failures: z.array(z.string()),
    verification_attempts_count: z.number(),
    language: z.string().optional(),
  }),
  permission_on_resource: z.string(),
});

export type ElevenLabsVoice = z.infer<typeof ElevenLabsVoiceSchema>;
export type ElevenLabsCloneRequest = z.infer<typeof ElevenLabsCloneRequestSchema>;
export type ElevenLabsCloneResponse = z.infer<typeof ElevenLabsCloneResponseSchema>;

// OpenAI API schemas
export const OpenAIMessageSchema = z.object({
  role: z.enum(["system", "user", "assistant"]),
  content: z.string(),
});

export const OpenAICompletionRequestSchema = z.object({
  model: z.string(),
  messages: z.array(OpenAIMessageSchema),
  temperature: z.number().min(0).max(2).optional(),
  max_tokens: z.number().positive().optional(),
  top_p: z.number().min(0).max(1).optional(),
  frequency_penalty: z.number().min(-2).max(2).optional(),
  presence_penalty: z.number().min(-2).max(2).optional(),
});

export const OpenAICompletionResponseSchema = z.object({
  id: z.string(),
  object: z.string(),
  created: z.number(),
  model: z.string(),
  choices: z.array(z.object({
    index: z.number(),
    message: OpenAIMessageSchema,
    finish_reason: z.string().optional(),
  })),
  usage: z.object({
    prompt_tokens: z.number(),
    completion_tokens: z.number(),
    total_tokens: z.number(),
  }),
});

export const OpenAIEmbeddingRequestSchema = z.object({
  model: z.string(),
  input: z.union([z.string(), z.array(z.string())]),
  encoding_format: z.string().optional(),
});

export const OpenAIEmbeddingResponseSchema = z.object({
  object: z.string(),
  data: z.array(z.object({
    object: z.string(),
    index: z.number(),
    embedding: z.array(z.number()),
  })),
  model: z.string(),
  usage: z.object({
    prompt_tokens: z.number(),
    total_tokens: z.number(),
  }),
});

export type OpenAIMessage = z.infer<typeof OpenAIMessageSchema>;
export type OpenAICompletionRequest = z.infer<typeof OpenAICompletionRequestSchema>;
export type OpenAICompletionResponse = z.infer<typeof OpenAICompletionResponseSchema>;
export type OpenAIEmbeddingRequest = z.infer<typeof OpenAIEmbeddingRequestSchema>;
export type OpenAIEmbeddingResponse = z.infer<typeof OpenAIEmbeddingResponseSchema>;

// Supabase API schemas
export const SupabaseAuthResponseSchema = z.object({
  user: z.object({
    id: z.string(),
    email: z.string().email(),
    created_at: z.string(),
    updated_at: z.string(),
  }),
  session: z.object({
    access_token: z.string(),
    refresh_token: z.string(),
    expires_in: z.number(),
    token_type: z.string(),
    user: z.object({
      id: z.string(),
      email: z.string().email(),
      created_at: z.string(),
      updated_at: z.string(),
    }),
  }),
});

export const SupabaseErrorSchema = z.object({
  code: z.string(),
  message: z.string(),
  details: z.any().optional(),
  hint: z.string().optional(),
});

export type SupabaseAuthResponse = z.infer<typeof SupabaseAuthResponseSchema>;
export type SupabaseError = z.infer<typeof SupabaseErrorSchema>;

// Generic external API validator
export class ExternalApiValidator {
  static validateResponse<T>(
    schema: z.ZodType<T>,
    response: unknown,
    service: string
  ): T {
    try {
      return schema.parse(response);
    } catch (error) {
      if (error instanceof z.ZodError) {
        throw createError.externalService(
          service,
          new Error(`Invalid response format: ${error.errors.map(e => e.message).join(", ")}`)
        );
      }
      throw createError.externalService(service, error);
    }
  }

  static validateRequest<T>(
    schema: z.ZodType<T>,
    request: unknown,
    service: string
  ): T {
    try {
      return schema.parse(request);
    } catch (error) {
      if (error instanceof z.ZodError) {
        throw createError.validation(
          `Invalid request format for ${service}`,
          error.errors.map(e => e.message).join(", ")
        );
      }
      throw createError.validation(`Invalid request format for ${service}`);
    }
  }

  static createSafeApiCall<T>(
    schema: z.ZodType<T>,
    service: string
  ) {
    return (response: unknown): T => {
      return this.validateResponse(schema, response, service);
    };
  }
}

// Specific validators for each service
export const ElevenLabsValidator = {
  validateCloneResponse: (response: unknown) =>
    ExternalApiValidator.validateResponse(ElevenLabsCloneResponseSchema, response, "ElevenLabs"),
  
  validateCloneRequest: (request: unknown) =>
    ExternalApiValidator.validateRequest(ElevenLabsCloneRequestSchema, request, "ElevenLabs"),
  
  validateVoice: (response: unknown) =>
    ExternalApiValidator.validateResponse(ElevenLabsVoiceSchema, response, "ElevenLabs"),
};

export const OpenAIValidator = {
  validateCompletionResponse: (response: unknown) =>
    ExternalApiValidator.validateResponse(OpenAICompletionResponseSchema, response, "OpenAI"),
  
  validateCompletionRequest: (request: unknown) =>
    ExternalApiValidator.validateRequest(OpenAICompletionRequestSchema, request, "OpenAI"),
  
  validateEmbeddingResponse: (response: unknown) =>
    ExternalApiValidator.validateResponse(OpenAIEmbeddingResponseSchema, response, "OpenAI"),
  
  validateEmbeddingRequest: (request: unknown) =>
    ExternalApiValidator.validateRequest(OpenAIEmbeddingRequestSchema, request, "OpenAI"),
};

export const SupabaseValidator = {
  validateAuthResponse: (response: unknown) =>
    ExternalApiValidator.validateResponse(SupabaseAuthResponseSchema, response, "Supabase"),
  
  validateError: (response: unknown) =>
    ExternalApiValidator.validateResponse(SupabaseErrorSchema, response, "Supabase"),
};
