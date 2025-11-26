"""
Chat Router - Endpoints for chatting with Coach Ivy (Korean learning)
"""
from fastapi import APIRouter, HTTPException
from models.schemas import ChatRequest, ChatResponse
from services import openai_service
from services.error_handlers import handle_openai_error
import logging

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api",
    tags=["chat"]
)


@router.post("/chat-teacher", response_model=ChatResponse)
async def chat_with_teacher(request: ChatRequest):
    """
    Chat with Coach Ivy - Your personal Korean teacher

    This endpoint allows free-form conversation with the AI teacher.
    Use different modes for different types of interactions.

    Modes:
    - free_chat: General conversation practice in Korean
    - explain: Ask for explanations of Korean concepts
    - speaking_feedback: Get feedback on your Korean speaking
    """
    try:
        logger.info(f"Chat request - mode: {request.mode}, message: {request.message[:50]}...")

        # Call OpenAI service
        reply, emotion_tag = await openai_service.chat_with_coach(
            message=request.message,
            mode=request.mode,
            context=request.context
        )

        # Optionally generate TTS (for now, we'll leave it None)
        # In the future, we can add TTS generation here if needed
        tts_url = None

        return ChatResponse(
            reply=reply,
            emotion_tag=emotion_tag,
            tts_url=tts_url
        )

    except Exception as e:
        raise handle_openai_error(e, service_name="Chat")
