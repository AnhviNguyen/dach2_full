"""
OpenAI Service - ChatGPT & TTS Integration
Coach Ivy: Your personal Korean companion
"""
import logging
from openai import OpenAI
from config import settings
from pathlib import Path
import hashlib
import tempfile
import os
from typing import Literal, Optional
from fastapi import UploadFile

logger = logging.getLogger(__name__)

# Initialize OpenAI client
client = OpenAI(api_key=settings.openai_api_key)

# ===== COACH IVY SYSTEM PROMPTS =====

COACH_IVY_BASE_PROMPT = """Bạn là "Coach Ivy", một giáo viên tiếng Hàn cá nhân cho người Việt học tiếng Hàn.

**Tính cách:**
- Thân thiện, khuyến khích và hỗ trợ
- Kiên nhẫn và thấu hiểu
- Nhiệt tình với sự tiến bộ
- Chuyên nghiệp nhưng ấm áp

**Phong cách giao tiếp:**
- Sử dụng tiếng Việt để giải thích và hướng dẫn
- Đưa ra ví dụ bằng tiếng Hàn (한국어) kèm Hangul (한글)
- Giữ câu trả lời ngắn gọn (2-4 câu cho hầu hết trường hợp)
- Luôn tích cực và động viên
- Bao gồm Hangul (한글) khi dạy từ/cụm từ tiếng Hàn

**Phương pháp dạy:**
- Tập trung vào cách sử dụng thực tế
- Đưa ra ví dụ từ cuộc sống thực
- Giải thích "tại sao" chứ không chỉ "cái gì"
- Khuyến khích luyện tập và lặp lại
- Kỷ niệm những thành công nhỏ
- Giúp đỡ về phát âm và ngữ pháp tiếng Hàn
"""

MODE_PROMPTS = {
    "free_chat": """Người dùng đang có cuộc trò chuyện thân mật để luyện tập tiếng Hàn (한국어).
- Trả lời câu hỏi một cách tự nhiên bằng tiếng Việt
- Nhẹ nhàng sửa các lỗi lớn
- Giữ cuộc trò chuyện diễn ra tự nhiên
- Sử dụng cơ hội này để dạy khi phù hợp
- Bao gồm Hangul (한글) cho từ/cụm từ tiếng Hàn""",

    "explain": """Người dùng cần giúp đỡ để hiểu một khái niệm, từ, hoặc cụm từ tiếng Hàn.
- Cung cấp giải thích rõ ràng bằng tiếng Việt
- Đưa ra 2-3 ví dụ thực tế kèm Hangul (한글)
- Bao gồm bản dịch tiếng Việt cho các thuật ngữ quan trọng
- Giữ đơn giản và có thể thực hiện được
- Giải thích các mẫu ngữ pháp tiếng Hàn khi liên quan""",

    "speaking_feedback": """Người dùng vừa luyện nói tiếng Hàn. Cung cấp phản hồi mang tính xây dựng bằng tiếng Việt.
- Bắt đầu với lời động viên
- Chỉ ra những gì họ làm tốt
- Đề xuất MỘT cải thiện chính
- Cung cấp phiên bản đã sửa bằng Hangul (한글)
- Đưa ra ví dụ tương tự để luyện tập"""
}


def get_system_prompt(mode: str = "free_chat") -> str:
    """Get complete system prompt for Coach Ivy"""
    mode_specific = MODE_PROMPTS.get(mode, MODE_PROMPTS["free_chat"])
    return f"{COACH_IVY_BASE_PROMPT}\n\n{mode_specific}"


# ===== CHATGPT FUNCTIONS =====

async def chat_with_coach(
    message: str,
    mode: str = "free_chat",
    context: Optional[dict] = None
) -> tuple[str, str]:
    """
    Chat with Coach Ivy

    Args:
        message: User's message
        mode: Conversation mode (free_chat, explain, speaking_feedback)
        context: Additional context (lesson_id, level, etc.)

    Returns:
        tuple: (reply_text, emotion_tag)
    """
    try:
        system_prompt = get_system_prompt(mode)

        # Add context to system prompt if provided
        if context:
            context_str = f"\n\nContext: {context}"
            system_prompt += context_str

        # Call ChatGPT
        response = client.chat.completions.create(
            model=settings.openai_model_name,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message}
            ],
            temperature=0.7,
            max_tokens=300
        )

        reply = response.choices[0].message.content.strip()

        # Determine emotion tag based on response content
        emotion_tag = _analyze_emotion(reply)

        logger.info(f"Coach Ivy replied (mode={mode}, emotion={emotion_tag})")
        return reply, emotion_tag

    except Exception as e:
        logger.error(f"Error in chat_with_coach: {e}")
        raise


def _analyze_emotion(text: str) -> str:
    """
    Analyze text to determine appropriate emotion tag for avatar

    Returns: neutral | praise | corrective | encouraging
    """
    text_lower = text.lower()

    # Praise indicators
    praise_words = ["excellent", "perfect", "great", "wonderful", "amazing", "fantastic", "correct", "well done", "good job", "tuyệt vời", "hoàn hảo", "훌륭해", "완벽해"]
    if any(word in text_lower for word in praise_words):
        return "praise"

    # Corrective indicators
    corrective_words = ["however", "but", "correction", "should be", "mistake", "error", "incorrect", "sửa", "sai", "수정", "틀렸어"]
    if any(word in text_lower for word in corrective_words):
        return "corrective"

    # Encouraging indicators
    encouraging_words = ["keep", "practice", "try", "don't worry", "no problem", "keep going", "tiếp tục", "cố lên", "계속", "화이팅"]
    if any(word in text_lower for word in encouraging_words):
        return "encouraging"

    return "neutral"


# ===== EXERCISE FEEDBACK =====

async def check_exercise_with_feedback(
    question: str,
    user_answers: list[str],
    correct_answers: list[str],
    exercise_type: str = "multiple_choice"
) -> tuple[bool, float, str, str]:
    """
    Check exercise and generate AI feedback

    Returns:
        tuple: (is_correct, score, feedback_text, emotion_tag)
    """
    try:
        # Calculate correctness
        is_correct = user_answers == correct_answers
        score = 100.0 if is_correct else 0.0

        # Generate AI feedback
        prompt = f"""Học viên đã trả lời câu hỏi học tiếng Hàn này:
Câu hỏi: {question}
Câu trả lời của họ: {' '.join(user_answers)}
Đáp án đúng: {' '.join(correct_answers)}

Cung cấp phản hồi ngắn gọn bằng tiếng Việt (2-3 câu):
- Nếu đúng: khen ngợi và giải thích tại sao đúng
- Nếu sai: nhẹ nhàng giải thích lỗi và cung cấp đáp án đúng kèm lý do
- Bao gồm Hangul (한글) khi giải thích từ/cụm từ tiếng Hàn"""

        response = client.chat.completions.create(
            model=settings.openai_model_name,
            messages=[
                {"role": "system", "content": get_system_prompt("explain")},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=200
        )

        feedback = response.choices[0].message.content.strip()
        emotion_tag = "praise" if is_correct else "corrective"

        logger.info(f"Exercise checked: correct={is_correct}, score={score}")
        return is_correct, score, feedback, emotion_tag

    except Exception as e:
        logger.error(f"Error in check_exercise_with_feedback: {e}")
        raise


# ===== TTS FUNCTIONS =====

# Directory for storing TTS audio files
MEDIA_DIR = Path("media/tts")
MEDIA_DIR.mkdir(parents=True, exist_ok=True)


def _get_audio_hash(text: str, voice: str) -> str:
    """Generate unique hash for text + voice combination"""
    content = f"{text}_{voice}"
    return hashlib.md5(content.encode()).hexdigest()


async def generate_speech(
    text: str,
    voice: Optional[str] = None
) -> str:
    """
    Generate speech from text using OpenAI TTS

    Args:
        text: Text to convert to speech
        voice: Voice to use (default from settings)

    Returns:
        str: Path to audio file
    """
    try:
        if not voice:
            voice = settings.openai_tts_voice

        # Check cache
        audio_hash = _get_audio_hash(text, voice)
        audio_path = MEDIA_DIR / f"{audio_hash}.mp3"

        # Return cached file if exists
        if audio_path.exists():
            logger.info(f"TTS cache hit for: {text[:50]}...")
            return str(audio_path)

        # Generate new audio
        logger.info(f"Generating TTS for: {text[:50]}...")
        response = client.audio.speech.create(
            model=settings.openai_tts_model,
            voice=voice,
            input=text,
            response_format="mp3"
        )

        # Save to file
        response.stream_to_file(audio_path)
        logger.info(f"TTS saved to: {audio_path}")

        return str(audio_path)

    except Exception as e:
        logger.error(f"Error in generate_speech: {e}")
        raise


# ===== WHISPER (SPEECH-TO-TEXT) FUNCTIONS =====

async def transcribe_audio(
    file: UploadFile,
    language: str = "ko"
) -> str:
    """
    Transcribe audio file to text using OpenAI Whisper

    Args:
        file: Audio file (webm, mp3, wav, etc.)
        language: Language code (default: "ko" for Korean)

    Returns:
        str: Transcribed text
    """
    temp_file_path = None
    try:
        # Create temp file with appropriate extension
        file_extension = Path(file.filename).suffix or ".webm"
        with tempfile.NamedTemporaryFile(delete=False, suffix=file_extension) as temp_file:
            temp_file_path = temp_file.name

            # Write uploaded file to temp location
            content = await file.read()
            temp_file.write(content)
            temp_file.flush()

        logger.info(f"Transcribing audio file: {file.filename} ({len(content)} bytes)")

        # Call Whisper API
        with open(temp_file_path, "rb") as audio_file:
            response = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                language=language,
                response_format="text"
            )

        transcript = response.strip() if isinstance(response, str) else response.text.strip()
        logger.info(f"Transcription complete: {transcript[:100]}...")

        return transcript

    except Exception as e:
        logger.error(f"Error in transcribe_audio: {e}")
        raise

    finally:
        # Cleanup temp file
        if temp_file_path and os.path.exists(temp_file_path):
            try:
                os.unlink(temp_file_path)
                logger.debug(f"Cleaned up temp file: {temp_file_path}")
            except Exception as e:
                logger.warning(f"Failed to delete temp file: {e}")


# ===== BILINGUAL FEEDBACK FUNCTIONS =====

async def generate_bilingual_feedback(
    expected_text: str,
    spoken_text: str,
    word_accuracy: float,
    accuracy_details: dict,
    model_result: Optional[dict] = None
) -> tuple[str, list[str]]:
    """
    Tạo phản hồi bằng tiếng Việt cho bài luyện phát âm
    Kết hợp kết quả từ model pronunciation check (nếu có) với GPT

    Args:
        expected_text: Văn bản đúng
        spoken_text: Những gì người dùng đã nói
        word_accuracy: Tỷ lệ chính xác ở mức từ
        accuracy_details: Các chỉ số chính xác chi tiết
        model_result: Kết quả từ pronunciation model (nếu có) với các keys:
            - phoneme_accuracy: Độ chính xác ở mức phoneme (0-100)
            - per: Phoneme Error Rate (0-1)
            - wrong_phonemes: List of (expected, predicted) tuples
            - wrong_words: List of words with errors

    Returns:
        tuple: (feedback_vi, tricky_words)
    """
    try:
        matches = accuracy_details.get('matches', 0)
        substitutions = accuracy_details.get('substitutions', 0)
        deletions = accuracy_details.get('deletions', 0)
        insertions = accuracy_details.get('insertions', 0)

        # Build prompt với thông tin từ model (nếu có)
        prompt_parts = [f"""Học viên đã luyện đọc to tiếng Hàn (한국어).

Văn bản mong đợi: "{expected_text}"
Họ đã nói: "{spoken_text}"

Độ chính xác từ: {word_accuracy:.1f}%
- Từ đúng: {matches}
- Từ sai: {substitutions}
- Từ thiếu: {deletions}
- Từ thừa: {insertions}"""]

        # Thêm thông tin từ model pronunciation check nếu có
        if model_result:
            phoneme_accuracy = model_result.get('phoneme_accuracy', word_accuracy)
            per = model_result.get('per', 0.0)
            wrong_phonemes = model_result.get('wrong_phonemes', [])
            wrong_words = model_result.get('wrong_words', [])
            
            prompt_parts.append(f"""
📊 KẾT QUẢ TỪ MODEL PHÁT ÂM CHUYÊN DỤNG:
- Độ chính xác phoneme (âm vị): {phoneme_accuracy:.1f}%
- Phoneme Error Rate (PER): {per:.4f}
- Số phoneme sai: {len(wrong_phonemes)}
- Từ có lỗi: {', '.join(wrong_words[:5]) if wrong_words else 'Không có'}

🔍 CHI TIẾT LỖI PHONEME (nếu có):
""")
            
            if wrong_phonemes:
                for i, (exp, pred) in enumerate(wrong_phonemes[:5], 1):
                    prompt_parts.append(f"  {i}. Mong đợi: '{exp}' → Đã nói: '{pred}'")
            else:
                prompt_parts.append("  Không có lỗi phoneme lớn")

        prompt_parts.append("""

Tạo phản hồi CHI TIẾT và HỮU ÍCH bằng tiếng Việt trong định dạng JSON:

1. "feedback_vi": 2-3 câu bằng tiếng Việt
   - Bắt đầu với lời động viên tích cực
   - Nếu có thông tin từ model, giải thích cụ thể về lỗi phoneme (ví dụ: "Bạn đã phát âm 'ㄱ' thành 'ㄲ'")
   - Chỉ ra từ nào cần luyện tập thêm (nếu có wrong_words)
   - Đưa ra 1-2 lời khuyên cụ thể để cải thiện (ví dụ: "Hãy chú ý phát âm rõ ràng các phụ âm cuối")
   - Giữ tích cực và khuyến khích
   - Bao gồm Hangul (한글) khi đề cập đến từ tiếng Hàn

2. "tricky_words": Mảng 2-3 từ tiếng Hàn khó mà học viên gặp khó khăn (từ wrong_words, bao gồm Hangul)

Output ONLY valid JSON in this exact format:
{{
  "feedback_vi": "...",
  "tricky_words": ["word1", "word2"]
}}""")

        prompt = "\n".join(prompt_parts)

        response = client.chat.completions.create(
            model=settings.openai_model_name,
            messages=[
                {"role": "system", "content": get_system_prompt("speaking_feedback")},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=300
        )

        response_text = response.choices[0].message.content.strip()

        # Parse JSON response
        import json
        try:
            # Try to extract JSON from response (handle cases where GPT adds markdown)
            if "```json" in response_text:
                response_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                response_text = response_text.split("```")[1].split("```")[0].strip()

            data = json.loads(response_text)
            feedback_vi = data.get("feedback_vi", "Tốt lắm! Tiếp tục luyện tập nhé.")
            tricky_words = data.get("tricky_words", [])

            logger.info(f"Feedback generated - VI: {len(feedback_vi)} chars")
            return feedback_vi, tricky_words

        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON from GPT: {e}")
            logger.error(f"Response was: {response_text}")
            # Fallback to simple feedback
            if word_accuracy >= 85:
                feedback_vi = "Phát âm tiếng Hàn rất tốt! Tiếp tục như vậy nhé."
            elif word_accuracy >= 70:
                feedback_vi = "Khá tốt! Luyện thêm một chút để phát âm tiếng Hàn rõ ràng hơn."
            else:
                feedback_vi = "Tiếp tục luyện tập tiếng Hàn! Hãy nói chậm và rõ ràng hơn."

            return feedback_vi, []

    except Exception as e:
        logger.error(f"Error in generate_bilingual_feedback: {e}")
        # Return safe defaults
        return "Cố gắng tốt! Tiếp tục luyện tập tiếng Hàn nhé.", []
