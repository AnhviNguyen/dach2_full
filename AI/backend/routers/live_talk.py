"""
Live Talk Router - Free Korean conversation with AI Coach (Ivy/Leo)
Real-time voice conversation with gentle corrections and natural flow
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from models.schemas import (
    LiveTalkResponse,
    LiveTalkMessage,
    LiveTalkSessionStats,
    LiveTalkMission,
    SessionSummary
)
from services import openai_service
from pathlib import Path
import logging
import json
from typing import Optional, List

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/live-talk",
    tags=["live-talk"]
)

# ===== COACH PERSONAS FOR LIVE TALK =====

COACH_PERSONAS = {
    "ivy": {
        "system_prompt": """Bạn là Coach Ivy, một đối tác trò chuyện tiếng Hàn ấm áp và khuyến khích cho người Việt học tiếng Hàn.

**Phong cách dạy của bạn:**
- Thân thiện, kiên nhẫn và hỗ trợ
- Sử dụng tiếng Hàn (한국어) đơn giản, tự nhiên với từ vựng phù hợp người mới bắt đầu
- Giữ câu trả lời NGẮN GỌN (tối đa 1-3 câu)
- Bao gồm Hangul (한글) khi sử dụng từ/cụm từ tiếng Hàn
- Thỉnh thoảng (không phải lúc nào!) nhẹ nhàng sửa lỗi bằng cách diễn đạt lại
- Đặt câu hỏi tiếp theo để giữ cuộc trò chuyện diễn ra tự nhiên
- Tập trung vào các chủ đề thực tế, hàng ngày
- Trả lời bằng tiếng Việt, nhưng đưa ra ví dụ bằng tiếng Hàn kèm Hangul

**Khi sửa lỗi:**
- Đừng chỉ ra mọi lỗi - hãy chọn lọc (chỉ lỗi lớn)
- Sử dụng cách diễn đạt tích cực: "Cách tự nhiên hơn để nói điều đó là..." (bằng tiếng Việt)
- Chỉ sửa các vấn đề ảnh hưởng đến hiểu biết
- Không bao giờ giảng bài hoặc làm học viên choáng ngợp
- Hiển thị tiếng Hàn đúng bằng Hangul (한글)

**Ví dụ sửa lỗi:**
Người dùng: "저는 커피를 매우 좋아해요" (ngữ pháp sai)
Bạn: "Tốt lắm! Thường thì chúng ta nói '저는 커피를 정말 좋아해요'. Bạn thích loại cà phê nào?"

**Quan trọng:**
- Giữ cuộc trò chuyện ấm áp - như trò chuyện với một người bạn hỗ trợ
- Kỷ niệm nỗ lực và tiến bộ
- Giữ nhẹ nhàng và khuyến khích
- Luôn bao gồm Hangul (한글) cho văn bản tiếng Hàn
- Trả lời bằng tiếng Việt""",
        "voice": "nova"  # Warm female voice for TTS
    },

    "leo": {
        "system_prompt": """Bạn là Coach Leo, một đối tác trò chuyện tiếng Hàn thân thiện và thoải mái cho người Việt học tiếng Hàn.

**Phong cách dạy của bạn:**
- Thoải mái, dễ gần, trò chuyện tự nhiên
- Sử dụng tiếng Hàn (한국어) hàng ngày, tự nhiên
- Giữ câu trả lời NGẮN GỌN (tối đa 1-3 câu)
- Bao gồm Hangul (한글) khi sử dụng từ/cụm từ tiếng Hàn
- Thỉnh thoảng nhẹ nhàng sửa lỗi một cách thân thiện, thoải mái
- Chia sẻ những câu chuyện cá nhân ngắn để giữ thú vị
- Khuyến khích học viên nói nhiều tiếng Hàn hơn
- Trả lời bằng tiếng Việt, nhưng đưa ra ví dụ bằng tiếng Hàn kèm Hangul

**Khi sửa lỗi:**
- Hãy thoải mái và thân thiện về điều đó
- Sử dụng các cụm từ như: "Nhân tiện, thường thì chúng ta nói..."
- Đừng sửa quá nhiều - giữ cuộc trò chuyện diễn ra tự nhiên
- Tập trung vào việc giúp đỡ, không phải dạy
- Hiển thị tiếng Hàn đúng bằng Hangul (한글)

**Ví dụ sửa lỗi:**
Người dùng: "어제 저는 시장에 가요" (thì sai)
Bạn: "Tốt lắm! Nhân tiện, chúng ta nói '어제 저는 시장에 갔어요'. Bạn đã mua gì ở đó?"

**Quan trọng:**
- Giữ thoải mái, thân thiện và vui vẻ
- Làm cho học viên cảm thấy thoải mái
- Giữ cuộc trò chuyện tự nhiên và hấp dẫn
- Luôn bao gồm Hangul (한글) cho văn bản tiếng Hàn
- Trả lời bằng tiếng Việt""",
        "voice": "echo"  # Casual male voice for TTS
    }
}

# ===== TOPIC CONTEXT HINTS =====

TOPIC_CONTEXTS = {
    "daily_life": "Cuộc trò chuyện về thói quen hàng ngày, sở thích và hoạt động hàng ngày bằng tiếng Hàn (한국어).",
    "travel": "Cuộc trò chuyện về trải nghiệm du lịch, kế hoạch và điểm đến bằng tiếng Hàn (한국어).",
    "work": "Cuộc trò chuyện về công việc, sự nghiệp và cuộc sống chuyên nghiệp bằng tiếng Hàn (한국어).",
    "hobbies": "Cuộc trò chuyện về sở thích cá nhân, thú vui và hoạt động thời gian rảnh bằng tiếng Hàn (한국어)."
}

# ===== TOPIC MISSIONS (for goal-oriented practice) =====

TOPIC_MISSIONS = {
    "daily_life": {
        "mission": "Talk about what you did yesterday (어제 뭐 했어요?)",
        "focus_grammar": "Past tense: 했어요, 갔어요, 샀어요, 봤어요, 먹었어요",
        "sample_phrases": [
            "어제 시장에 갔어요",
            "야채를 샀어요",
            "좋은 하루였어요"
        ],
        "icon": "coffee"
    },
    "travel": {
        "mission": "Describe a place you want to visit (가고 싶은 곳을 설명해주세요)",
        "focus_grammar": "Future: 갈 거예요, 볼 거예요, 하고 싶어요",
        "sample_phrases": [
            "내년에 일본에 갈 거예요",
            "후지산을 볼 거예요",
            "거기서 초밥을 먹고 싶어요"
        ],
        "icon": "plane"
    },
    "work": {
        "mission": "Talk about your typical workday (일반적인 하루를 말해주세요)",
        "focus_grammar": "Present tense: 일해요, 회의가 있어요, 끝나요",
        "sample_phrases": [
            "9시부터 5시까지 일해요",
            "보통 회의가 있어요",
            "제 직업이 흥미로워요"
        ],
        "icon": "briefcase"
    },
    "hobbies": {
        "mission": "Share your favorite hobby or activity (좋아하는 취미를 공유해주세요)",
        "focus_grammar": "Present: 배우고 있어요, 즐겨요, 좋아해요",
        "sample_phrases": [
            "책 읽는 것을 즐겨요",
            "기타를 배우고 있어요",
            "영화 보는 것을 좋아해요"
        ],
        "icon": "film"
    }
}


@router.post("/turn", response_model=LiveTalkResponse)
async def live_talk_turn(
    audio: UploadFile = File(..., description="User's voice audio"),
    user_id: str = Form(..., description="User ID"),
    coach_id: str = Form(default="ivy", description="Coach ID (ivy or leo)"),
    topic: Optional[str] = Form(default=None, description="Conversation topic context"),
    history: str = Form(default="[]", description="JSON array of conversation history")
):
    """
    Handle one turn of live conversation

    Process flow:
    1. Transcribe user's audio (STT)
    2. Build conversation context with coach persona
    3. Get AI response from ChatGPT
    4. Generate TTS audio for response
    5. Calculate session stats
    6. Return response with audio URL

    Args:
        audio: Audio file from user (webm, mp3, wav)
        user_id: User identifier
        coach_id: Coach to talk with (ivy or leo)
        topic: Optional topic context (daily_life, travel, work, hobbies)
        history: JSON string of previous messages [{"role": "user", "content": "..."}]

    Returns:
        LiveTalkResponse with transcription, AI response, audio URL, and stats
    """
    try:
        logger.info(f"Live Talk turn - user: {user_id}, coach: {coach_id}, topic: {topic}")

        # Step 1: Transcribe user audio using Whisper STT
        user_text = await openai_service.transcribe_audio(
            file=audio,
            language="ko"
        )

        if not user_text.strip():
            raise HTTPException(
                status_code=400,
                detail="Could not transcribe audio. Please try speaking again."
            )

        logger.info(f"User said: '{user_text}'")

        # Step 2: Parse conversation history
        try:
            messages = json.loads(history)
        except json.JSONDecodeError:
            logger.warning("Invalid history JSON, starting fresh")
            messages = []

        # Step 3: Build ChatGPT prompt with coach persona
        coach = COACH_PERSONAS.get(coach_id, COACH_PERSONAS["ivy"])

        system_prompt = coach["system_prompt"]

        # Add topic context if provided
        if topic and topic in TOPIC_CONTEXTS:
            system_prompt += f"\n\n**Current topic context:** {TOPIC_CONTEXTS[topic]}"

        # Build message array for ChatGPT
        chat_messages = [{"role": "system", "content": system_prompt}]
        chat_messages.extend(messages)
        chat_messages.append({"role": "user", "content": user_text})

        # Step 4: Call ChatGPT for coach response
        response = client.chat.completions.create(
            model="gpt-4",
            messages=chat_messages,
            max_tokens=150,  # Keep responses short
            temperature=0.7  # Natural but not too random
        )

        assistant_text = response.choices[0].message.content.strip()
        logger.info(f"Coach {coach_id} replied: '{assistant_text[:100]}...'")

        # Step 5: Generate TTS for coach's response
        tts_voice = coach["voice"]
        tts_path = await openai_service.generate_speech(
            text=assistant_text,
            voice=tts_voice
        )
        audio_url = f"/media/{Path(tts_path).name}"

        # Step 6: Calculate session statistics
        turn_count = len([m for m in messages if m["role"] == "user"]) + 1
        word_count = sum(
            len(m["content"].split())
            for m in messages
            if m["role"] == "user"
        )
        word_count += len(user_text.split())

        session_stats = LiveTalkSessionStats(
            turn_count=turn_count,
            word_count=word_count,
            duration_minutes=0  # Frontend will calculate duration
        )

        logger.info(f"Session stats - turns: {turn_count}, words: {word_count}")

        return LiveTalkResponse(
            user_text=user_text,
            assistant_text=assistant_text,
            audio_url=audio_url,
            correction=None,  # Corrections are embedded in assistant_text
            session_stats=session_stats
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in live_talk_turn: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process conversation turn: {str(e)}"
        )


@router.get("/mission", response_model=LiveTalkMission)
async def get_mission(topic: str = "daily_life"):
    """
    Get mission definition for a specific topic

    Returns mission description, focus grammar, and sample phrases
    to guide the user's practice session.

    Args:
        topic: Topic ID (daily_life, travel, work, hobbies)

    Returns:
        LiveTalkMission with mission details
    """
    if topic not in TOPIC_MISSIONS:
        logger.warning(f"Unknown topic: {topic}, defaulting to daily_life")
        topic = "daily_life"

    mission_data = TOPIC_MISSIONS[topic]

    return LiveTalkMission(
        mission=mission_data["mission"],
        focus_grammar=mission_data["focus_grammar"],
        sample_phrases=mission_data["sample_phrases"],
        icon=mission_data["icon"]
    )


@router.post("/end-session", response_model=SessionSummary)
async def end_live_talk_session(
    history: str = Form(..., description="JSON array of conversation messages"),
    topic: str = Form(..., description="Conversation topic"),
    user_id: str = Form(..., description="User ID")
):
    """
    Generate AI summary for completed Live Talk session

    Analyzes the conversation to provide:
    - What went well (strengths)
    - Common mistakes (weaknesses)
    - Good example sentences the user said
    - Practice suggestion for improvement

    Args:
        history: JSON string of conversation messages
        topic: Topic that was discussed
        user_id: User identifier

    Returns:
        SessionSummary with AI-generated feedback
    """
    try:
        logger.info(f"Generating session summary - user: {user_id}, topic: {topic}")

        # Parse conversation history
        try:
            messages = json.loads(history)
        except json.JSONDecodeError:
            raise HTTPException(
                status_code=400,
                detail="Invalid history JSON format"
            )

        if not messages:
            raise HTTPException(
                status_code=400,
                detail="Cannot generate summary for empty conversation"
            )

        # Get mission context
        mission = TOPIC_MISSIONS.get(topic, TOPIC_MISSIONS["daily_life"])

        # Format conversation for analysis
        conversation_text = "\n".join([
            f"{msg['role'].upper()}: {msg['content']}"
            for msg in messages
        ])

        # Build analysis prompt
        analysis_prompt = f"""Bạn đang phân tích một phiên trò chuyện Live Talk cho người học tiếng Hàn.

Chủ đề: {topic}
Nhiệm vụ: {mission['mission']}
Ngữ pháp tập trung: {mission['focus_grammar']}

Cuộc trò chuyện:
{conversation_text}

Vui lòng cung cấp phân tích hỗ trợ và khuyến khích bằng tiếng Việt trong định dạng JSON:

{{
  "strengths": "1-2 câu ngắn về những gì người dùng làm tốt (bằng tiếng Việt)",
  "weaknesses": "1-2 mẫu lỗi tiếng Hàn, diễn đạt nhẹ nhàng và khuyến khích (bằng tiếng Việt)",
  "good_sentences": ["Câu tiếng Hàn 1 người dùng nói tốt (copy nguyên văn kèm Hangul)", "câu 2"],
  "practice_suggestion": "1 mẫu câu tiếng Hàn cụ thể họ nên luyện tập thêm (bao gồm Hangul)"
}}

Hãy rất khuyến khích và hỗ trợ. Tập trung vào tiến bộ, không phải sự hoàn hảo. Bao gồm Hangul (한글) khi đề cập đến ví dụ tiếng Hàn. Tất cả phản hồi bằng tiếng Việt."""

        # Call GPT for analysis
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": "Bạn là một giáo viên tiếng Hàn hỗ trợ đang phân tích bài luyện tập trò chuyện của học viên. Trả lời bằng tiếng Việt."
                },
                {"role": "user", "content": analysis_prompt}
            ],
            response_format={"type": "json_object"},
            temperature=0.3
        )

        summary_data = json.loads(response.choices[0].message.content)
        logger.info(f"Summary generated: {summary_data}")

        # Calculate session stats
        user_turns = [m for m in messages if m["role"] == "user"]
        total_words = sum(len(turn["content"].split()) for turn in user_turns)

        return SessionSummary(
            turns=len(user_turns),
            total_words=total_words,
            duration_minutes=0,  # Frontend calculates this
            strengths=summary_data.get("strengths", "Nỗ lực tuyệt vời trong việc luyện tập tiếng Hàn!"),
            weaknesses=summary_data.get("weaknesses", "Tiếp tục luyện tập tiếng Hàn để xây dựng sự trôi chảy."),
            good_sentences=summary_data.get("good_sentences", []),
            practice_suggestion=summary_data.get("practice_suggestion", "Tiếp tục luyện tập các cuộc trò chuyện tiếng Hàn hàng ngày.")
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating session summary: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate session summary: {str(e)}"
        )


# Import OpenAI client at module level (after openai_service is imported)
from openai import OpenAI
from config import settings

client = OpenAI(api_key=settings.openai_api_key)
