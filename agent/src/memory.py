"""
Supermemory Integration for You+ Agent
Handles retrieval and storage of user memories
"""

import os
import logging
import requests
from typing import Optional, List, Dict, Any

logger = logging.getLogger(__name__)


class MemoryManager:
    """Manages user memories via Supermemory API"""

    def __init__(self, api_key: str, base_url: str = "https://api.supermemory.ai"):
        self.api_key = api_key
        self.base_url = base_url
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        }

    async def get_context_for_call(
        self,
        user_id: str,
        mood: str = "supportive",
        max_memories: int = 5,
    ) -> Dict[str, Any]:
        """
        Retrieve relevant memories for current call

        Args:
            user_id: Unique user identifier
            mood: Call mood/type (supportive, accountability, celebration)
            max_memories: Max memories to retrieve

        Returns:
            Dictionary with retrieved memories and context
        """
        try:
            # Query Supermemory for user's memories
            response = requests.get(
                f"{self.base_url}/v1/memories",
                headers=self.headers,
                params={
                    "user_id": user_id,
                    "limit": max_memories,
                    "tags": [mood, "recent"],
                },
                timeout=5,
            )

            if response.status_code == 200:
                memories = response.json().get("memories", [])
                logger.info(
                    f"Retrieved {len(memories)} memories for user {user_id}"
                )
                return {
                    "promises": self._extract_promises(memories),
                    "goals": self._extract_goals(memories),
                    "progress": self._extract_progress(memories),
                    "raw_memories": memories,
                }
            else:
                logger.warning(
                    f"Failed to retrieve memories: {response.status_code}"
                )
                return {
                    "promises": [],
                    "goals": [],
                    "progress": [],
                    "raw_memories": [],
                }

        except requests.RequestException as e:
            logger.error(f"Error retrieving memories: {e}")
            return {
                "promises": [],
                "goals": [],
                "progress": [],
                "raw_memories": [],
            }

    async def save_call_memory(
        self,
        user_id: str,
        call_uuid: str,
        memory_data: Dict[str, Any],
    ) -> bool:
        """
        Store call insights and extracted data to Supermemory

        Args:
            user_id: Unique user identifier
            call_uuid: Call UUID for reference
            memory_data: Dictionary with memory content

        Returns:
            True if successful, False otherwise
        """
        try:
            payload = {
                "user_id": user_id,
                "content": memory_data.get("content", ""),
                "tags": [
                    "call",
                    memory_data.get("mood", "supportive"),
                    "processed",
                ],
                "metadata": {
                    "call_uuid": call_uuid,
                    "timestamp": memory_data.get("timestamp"),
                },
            }

            response = requests.post(
                f"{self.base_url}/v1/memories",
                headers=self.headers,
                json=payload,
                timeout=5,
            )

            if response.status_code == 201:
                logger.info(f"Saved call memory for user {user_id}")
                return True
            else:
                logger.warning(f"Failed to save memory: {response.status_code}")
                return False

        except requests.RequestException as e:
            logger.error(f"Error saving memory: {e}")
            return False

    @staticmethod
    def _extract_promises(memories: List[Dict]) -> List[str]:
        """Extract promises from memories"""
        promises = []
        for memory in memories:
            if "promise" in memory.get("tags", []):
                promises.append(memory.get("content", ""))
        return promises

    @staticmethod
    def _extract_goals(memories: List[Dict]) -> List[str]:
        """Extract goals from memories"""
        goals = []
        for memory in memories:
            if "goal" in memory.get("tags", []):
                goals.append(memory.get("content", ""))
        return goals

    @staticmethod
    def _extract_progress(memories: List[Dict]) -> List[str]:
        """Extract progress updates from memories"""
        progress = []
        for memory in memories:
            if "progress" in memory.get("tags", []):
                progress.append(memory.get("content", ""))
        return progress


# Initialize manager
def init_memory_manager() -> Optional[MemoryManager]:
    """Create MemoryManager from environment variables"""
    api_key = os.getenv("SUPERMEMORY_API_KEY")
    base_url = os.getenv(
        "SUPERMEMORY_BASE_URL", "https://api.supermemory.ai"
    )

    if not api_key:
        logger.warning("SUPERMEMORY_API_KEY not set, memory features disabled")
        return None

    return MemoryManager(api_key=api_key, base_url=base_url)
