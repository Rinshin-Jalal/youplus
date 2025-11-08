"""
Post-Call Processing for You+ Agent
Extracts insights and updates Supermemory after call ends
"""

import logging
from typing import Optional, Dict, Any
from datetime import datetime
from .memory import MemoryManager

logger = logging.getLogger(__name__)


class PostCallProcessor:
    """Handles post-call data processing and memory updates"""

    def __init__(self, memory_manager: Optional[MemoryManager] = None):
        self.memory_manager = memory_manager

    async def process_call_transcript(
        self,
        user_id: str,
        call_uuid: str,
        transcript: str,
        mood: str = "supportive",
    ) -> Dict[str, Any]:
        """
        Process call transcript and extract insights

        Args:
            user_id: User identifier
            call_uuid: Call UUID
            transcript: Full call transcript
            mood: Call mood/type

        Returns:
            Dictionary with extracted insights
        """
        logger.info(f"Processing transcript for call {call_uuid}")

        try:
            # Extract key information from transcript
            insights = {
                "promises_made": self._extract_promises(transcript),
                "goals_mentioned": self._extract_goals(transcript),
                "blockers_identified": self._extract_blockers(transcript),
                "progress_noted": self._extract_progress(transcript),
                "sentiment": self._analyze_sentiment(transcript),
            }

            # Save to Supermemory if available
            if self.memory_manager:
                memory_payload = {
                    "content": f"Call Summary ({mood}): {self._summarize_transcript(transcript)}",
                    "timestamp": datetime.utcnow().isoformat(),
                    "mood": mood,
                    "insights": insights,
                }
                await self.memory_manager.save_call_memory(
                    user_id=user_id,
                    call_uuid=call_uuid,
                    memory_data=memory_payload,
                )

            return insights

        except Exception as e:
            logger.error(f"Error processing transcript: {e}")
            return {
                "promises_made": [],
                "goals_mentioned": [],
                "blockers_identified": [],
                "progress_noted": [],
                "sentiment": "unknown",
                "error": str(e),
            }

    async def store_call_metadata(
        self,
        user_id: str,
        call_uuid: str,
        metadata: Dict[str, Any],
    ) -> bool:
        """
        Store call metadata to database

        Args:
            user_id: User identifier
            call_uuid: Call UUID
            metadata: Call metadata (duration, mood, etc.)

        Returns:
            True if successful
        """
        logger.info(f"Storing metadata for call {call_uuid}")

        # This would be sent to Cloudflare Workers webhook
        # Example payload:
        payload = {
            "user_id": user_id,
            "call_uuid": call_uuid,
            "timestamp": datetime.utcnow().isoformat(),
            "duration_seconds": metadata.get("duration_seconds"),
            "mood": metadata.get("mood"),
            "completion_status": metadata.get("completion_status", "completed"),
            "audio_recording_url": metadata.get("audio_recording_url"),
        }

        logger.debug(f"Call metadata: {payload}")
        return True

    @staticmethod
    def _extract_promises(transcript: str) -> list:
        """Extract promises/commitments from transcript"""
        # TODO: Use LLM to intelligently extract promises
        # For now, look for keywords
        keywords = ["i promise", "i will", "i commit", "i'll", "i'm going to"]
        promises = []

        for line in transcript.split("\n"):
            for keyword in keywords:
                if keyword.lower() in line.lower():
                    promises.append(line.strip())
                    break

        return promises

    @staticmethod
    def _extract_goals(transcript: str) -> list:
        """Extract goals from transcript"""
        keywords = ["goal", "want to", "plan to", "aim for", "target"]
        goals = []

        for line in transcript.split("\n"):
            for keyword in keywords:
                if keyword.lower() in line.lower():
                    goals.append(line.strip())
                    break

        return goals

    @staticmethod
    def _extract_blockers(transcript: str) -> list:
        """Extract identified blockers/challenges"""
        keywords = [
            "struggle",
            "challenge",
            "problem",
            "issue",
            "difficult",
            "can't",
            "can't",
        ]
        blockers = []

        for line in transcript.split("\n"):
            for keyword in keywords:
                if keyword.lower() in line.lower():
                    blockers.append(line.strip())
                    break

        return blockers

    @staticmethod
    def _extract_progress(transcript: str) -> list:
        """Extract progress updates"""
        keywords = [
            "progress",
            "improved",
            "better",
            "achieved",
            "completed",
            "finished",
        ]
        progress = []

        for line in transcript.split("\n"):
            for keyword in keywords:
                if keyword.lower() in line.lower():
                    progress.append(line.strip())
                    break

        return progress

    @staticmethod
    def _analyze_sentiment(transcript: str) -> str:
        """Analyze overall sentiment of call"""
        # TODO: Use LLM or sentiment analysis library
        # For now, simple heuristic
        positive_words = [
            "good",
            "great",
            "excellent",
            "happy",
            "positive",
        ]
        negative_words = ["bad", "sad", "worried", "anxious", "frustrated"]

        positive_count = sum(
            1 for word in positive_words if word in transcript.lower()
        )
        negative_count = sum(
            1 for word in negative_words if word in transcript.lower()
        )

        if positive_count > negative_count:
            return "positive"
        elif negative_count > positive_count:
            return "negative"
        else:
            return "neutral"

    @staticmethod
    def _summarize_transcript(transcript: str, max_length: int = 200) -> str:
        """Create a summary of the transcript"""
        # TODO: Use LLM to create intelligent summary
        # For now, just truncate
        if len(transcript) > max_length:
            return transcript[:max_length] + "..."
        return transcript
