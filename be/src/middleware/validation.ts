/**
 * Validation Middleware using Zod
 * 
 * This middleware provides runtime validation for API requests and responses
 * using Zod schemas. It ensures type safety at runtime and provides clear
 * error messages for invalid data.
 * 
 * Usage:
 * ```typescript
 * // Validate request body
 * app.post("/api/promises", validateJson(CreatePromiseRequestSchema), createPromiseHandler);
 * 
 * // Validate response
 * app.get("/api/promises/:id", validateResponse(PromiseResponseSchema), getPromiseHandler);
 * 
 * // Validate both request and response
 * app.put("/api/promises/:id", 
 *   validateJson(UpdatePromiseRequestSchema),
 *   validateResponse(PromiseResponseSchema),
 *   updatePromiseHandler
 * );

 */
import type { Context, Next } from "hono";   
import { z } from "zod";
import { ErrorResponseSchema } from "@/types/validation";       

/**
 * Validates JSON request body against a Zod schema
 */
export const validateJson = <T>(schema: z.ZodType<T>) => {
  return async (c: Context, next: Next) => {
    try {
      const body = await c.req.json();
      const validatedData = schema.parse(body);
      
      // Store validated data in context for handlers to use
      c.set("validatedBody", validatedData);
      
      await next();
      return;
    } catch (error: unknown) {
      if (error instanceof z.ZodError) {
        const errorDetails = error.errors.map(err => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }));
        
        const errorResponse = ErrorResponseSchema.parse({
          success: false,
          error: "Invalid request data",
          details: `Validation failed: ${error.errors.map(e => e.message).join(', ')}`,
          validationErrors: errorDetails,
        });
        
        return c.json(errorResponse, 400);
      }
      
      // Handle JSON parsing errors
      if (error instanceof SyntaxError) {
        const errorResponse = ErrorResponseSchema.parse({
          success: false,
          error: "Invalid JSON",
          details: "Request body contains invalid JSON",
        });
        
        return c.json(errorResponse, 400);
      }
      
      // Handle other errors
      const errorResponse = ErrorResponseSchema.parse({
        success: false,
        error: "Request validation failed",
        details: error instanceof Error ? error.message : "Unknown error",
      });
      
      return c.json(errorResponse, 500);
    }
  };
};

/**
 * Validates URL parameters against a Zod schema
 */
export const validateParams = <T>(schema: z.ZodType<T>) => {
  return async (c: Context, next: Next) => {
    try {
      const params = c.req.param();
      const validatedParams = schema.parse(params);
      
      // Store validated params in context
      c.set("validatedParams", validatedParams);
      
      await next();
      return;
    } catch (error: unknown) {
      if (error instanceof z.ZodError) {
        const errorDetails = error.errors.map(err => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }));
        
        const errorResponse = ErrorResponseSchema.parse({
          success: false,
          error: "Invalid URL parameters",
          details: `Parameter validation failed: ${error.errors.map(e => e.message).join(', ')}`,
          validationErrors: errorDetails,
        });
        
        return c.json(errorResponse, 400);
      }
      
      const errorResponse = ErrorResponseSchema.parse({
        success: false,
        error: "Parameter validation failed",
        details: error instanceof Error ? error.message : "Unknown error",
      });
      
      return c.json(errorResponse, 500);
    }
  };
};

/**
 * Validates query parameters against a Zod schema
 */
export const validateQuery = <T>(schema: z.ZodType<T>) => {
  return async (c: Context, next: Next) => {
    try {
      const query = Object.fromEntries(Object.entries(c.req.queries()));
      const validatedQuery = schema.parse(query);
      
      // Store validated query in context
      c.set("validatedQuery", validatedQuery);
      
      await next();
      return;
    } catch (error: unknown) {
      if (error instanceof z.ZodError) {
        const errorDetails = error.errors.map(err => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }));
        
        const errorResponse = ErrorResponseSchema.parse({
          success: false,
          error: "Invalid query parameters",
          details: `Query validation failed: ${error.errors.map(e => e.message).join(', ')}`,
          validationErrors: errorDetails,
        });
        
        return c.json(errorResponse, 400);
      }
      
      const errorResponse = ErrorResponseSchema.parse({
        success: false,
        error: "Query validation failed",
        details: error instanceof Error ? error.message : "Unknown error",
      });
      
      return c.json(errorResponse, 500);
    }
  };
};

/**
 * Validates response data against a Zod schema
 * This middleware wraps the response to ensure it matches the expected schema
 */
export const validateResponse = <T>(schema: z.ZodType<T>) => {
  return async (c: Context, next: Next) => {
    // Store original json method
    const originalJson = c.json.bind(c);
    
    // Override json method to validate response
    c.json = ((data: unknown, init?: unknown) => {
      try {
        const validatedData = schema.parse(data);
        return originalJson(validatedData as any, init as any);
      } catch (error: unknown) {
        if (error instanceof z.ZodError) {
          console.error("Response validation failed:", error.errors);
          const errorResponse = ErrorResponseSchema.parse({
            success: false,
            error: "Internal server error",
            details: "Response validation failed",
          });
          return originalJson(errorResponse, 500);
        }
        console.error("Response validation error:", error);
        const errorResponse = ErrorResponseSchema.parse({
          success: false,
          error: "Internal server error",
          details: "Response validation error",
        });
        return originalJson(errorResponse, 500);
      }
    }) as typeof c.json;
    
    await next();
    return;
  };
};

/**
 * Type-safe helper to get validated data from context
 */
export const getValidatedBody = <T>(c: Context): T => {
  const body = c.get("validatedBody");
  if (!body) {
    throw new Error("No validated body found in context. Make sure to use validateJson middleware.");
  }
  return body as T;
};

export const getValidatedParams = <T>(c: Context): T => {
  const params = c.get("validatedParams");
  if (!params) {
    throw new Error("No validated params found in context. Make sure to use validateParams middleware.");
  }
  return params as T;
};

export const getValidatedQuery = <T>(c: Context): T => {
  const query = c.get("validatedQuery");
  if (!query) {
    throw new Error("No validated query found in context. Make sure to use validateQuery middleware.");
  }
  return query as T;
};

/**
 * Compose multiple validation middlewares
 */
export const validate = {
  json: validateJson,
  params: validateParams,
  query: validateQuery,
  response: validateResponse,
};