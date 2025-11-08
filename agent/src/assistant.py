"""
Assistant Logic for You+ Agent
Handles conversation flow and personalization
"""

import logging
from typing import Optional, Dict, Any
from .memory import MemoryManager

logger = logging.getLogger(__name__)


class AssistantPersonality:
    """Manages agent personality and conversation style"""

    MOOD_PROMPTS = {
        "supportive": {
            "tone": "empathetic, kind, and encouraging",
            "approach": "Ask clarifying questions and provide emotional support",
            "examples": [
                "I hear you. Tell me more about what's been challenging.",
                "You're doing better than you think. Let's break this down.",
            ],
        },
        "accountability": {
            "tone": "direct, kind but firm, focused on action",
            "approach": "Gently challenge, ask about progress on commitments",
            "examples": [
                "Let's talk about what got in the way this week.",
                "I know this is hard, but you've committed to this. What's the first step?",
            ],
        },
        "celebration": {
            "tone": "enthusiastic, warm, celebratory",
            "approach": "Acknowledge progress, ask about next goals",
            "examples": [
                "This is amazing progress! You should be proud!",
                "You actually did it! How does that feel?",
            ],
        },
    }

    def __init__(self, mood: str = "supportive"):
        self.mood = mood
        self.prompt_config = self.MOOD_PROMPTS.get(mood, self.MOOD_PROMPTS["supportive"])

    def get_system_prompt(
        self,
        user_context: Optional[Dict[str, Any]] = None,
    ) -> str:
        """
        Generate personalized system prompt based on mood and user context

        Args:
            user_context: Optional user memories/history

        Returns:
            System prompt for the LLM
        """
        base_prompt = f"""You are You+, a supportive AI accountability assistant.

Personality & Tone:
- {self.prompt_config['tone']}
- {self.prompt_config['approach']}

Core Behaviors:
1. Ask clarifying questions to understand the user's situation
2. Acknowledge their emotions and experiences
3. Provide actionable, specific advice
4. Remember and reference previous commitments
5. Celebrate progress, no matter how small
6. Challenge gently when appropriate (for accountability mood)
7. Keep responses concise (1-3 sentences typically)

Call Guidelines:
- Listen more than you talk
- Ask follow-up questions
- Be genuine and authentic
- If unsure, ask clarifying questions
- Reference past promises when relevant
- End with actionable next steps when appropriate
"""

        # Add user context if available
        if user_context:
            context_section = self._build_context_section(user_context)
            base_prompt += f"\n{context_section}"

        return base_prompt

    def _build_context_section(
        self,
        user_context: Dict[str, Any],
    ) -> str:
        """Build context section from user memories"""
        context = "\nUser Context (from previous calls):\n"

        if user_context.get("promises"):
            context += "Recent Promises:\n"
            for promise in user_context.get("promises", [])[:3]:
                context += f"- {promise}\n"

        if user_context.get("goals"):
            context += "Current Goals:\n"
            for goal in user_context.get("goals", [])[:3]:
                context += f"- {goal}\n"

        if user_context.get("progress"):
            context += "Recent Progress:\n"
            for progress in user_context.get("progress", [])[:3]:
                context += f"- {progress}\n"

        return context

    def get_opening_message(self) -> str:
        """Get opening message based on mood"""
        openings = {
            "supportive": "Hi there! I'm so glad we can talk today. How are you doing?",
            "accountability": "Hey! Let's catch up on how things have been going with your goals.",
            "celebration": "I have a feeling today's going to be good. How have you been?",
        }
        return openings.get(self.mood, openings["supportive"])


class ConversationManager:
    """Manages conversation flow and context"""

    def __init__(
        self,
        user_id: str,
        mood: str = "supportive",
        memory_manager: Optional[MemoryManager] = None,
    ):
        self.user_id = user_id
        self.mood = mood
        self.personality = AssistantPersonality(mood=mood)
        self.memory_manager = memory_manager
        self.user_context = {}
        self.transcript = []

    async def initialize(self) -> str:
        """
        Initialize conversation with user context

        Returns:
            Opening message for the call
        """
        # Load user context from Supermemory
        if self.memory_manager:
            self.user_context = await self.memory_manager.get_context_for_call(
                user_id=self.user_id,
                mood=self.mood,
            )
            logger.info(
                f"Loaded context for user {self.user_id}: "
                f"{len(self.user_context.get('promises', []))} promises, "
                f"{len(self.user_context.get('goals', []))} goals"
            )

        return self.personality.get_opening_message()

    def get_system_prompt(self) -> str:
        """Get the system prompt for this conversation"""
        return self.personality.get_system_prompt(
            user_context=self.user_context,
        )

    def add_to_transcript(self, speaker: str, text: str) -> None:
        """Log message to transcript"""
        self.transcript.append({"speaker": speaker, "text": text})

    def get_transcript(self) -> str:
        """Get formatted transcript"""
        return "\n".join(
            [f"{msg['speaker']}: {msg['text']}" for msg in self.transcript]
        )

    def get_user_context(self) -> Dict[str, Any]:
        """Get current user context"""
        return self.user_context
