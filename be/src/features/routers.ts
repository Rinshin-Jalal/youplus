import { Hono } from "hono";
import identityRouter from "./identity/router";
import onboardingRouter from "./onboarding/router";
import webhookRouter from "./webhook/router";
import triggerRouter from "./trigger/router";
import voipRouter from "./voip/router";
import callRouter from "./call/router";
import coreRouter from "./core/router";

// Create a combined router that includes all feature routers
const combinedRouter = new Hono();

// Mount all feature routers with their respective paths
combinedRouter.route("/identity", identityRouter);
combinedRouter.route("/onboarding", onboardingRouter);
combinedRouter.route("/webhook", webhookRouter);
combinedRouter.route("/trigger", triggerRouter);
combinedRouter.route("/voip", voipRouter);
combinedRouter.route("/call", callRouter);

// Core router mounted at root to handle /api/*, /debug/*, etc.
combinedRouter.route("/", coreRouter);

// Note: Voice endpoints are mounted directly in index.ts:
// - /voice/clone (voice cloning)
// - /transcribe/audio (transcription)

export default combinedRouter;