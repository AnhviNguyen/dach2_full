"""
Pydantic models for request/response validation

This module contains all Pydantic models used for:
- Request validation
- Response serialization
- Data validation and type checking
"""
from typing import List, Literal, Optional

from pydantic import BaseModel, Field


# ===== CHAT MODELS =====

class ChatRequest(BaseModel):
    """Request model for chat with teacher"""
    message: str = Field(..., description="User's message to the teacher")
    mode: Literal["free_chat", "explain", "speaking_feedback"] = Field(
        default="free_chat",
        description="Type of interaction"
    )
    context: Optional[dict] = Field(
        default=None,
        description="Additional context (lesson_id, level, etc.)"
    )


class ChatResponse(BaseModel):
    """Response model from teacher chat"""
    reply: str = Field(..., description="Teacher's reply")
    emotion_tag: Literal["neutral", "praise", "corrective", "encouraging"] = Field(
        default="neutral",
        description="Emotion tag for avatar state"
    )
    tts_url: Optional[str] = Field(
        default=None,
        description="URL to TTS audio (if generated)"
    )


# ===== EXERCISE MODELS =====

class ExerciseCheckRequest(BaseModel):
    """Request model for checking exercise answers"""
    lesson_id: str = Field(..., description="Lesson identifier")
    exercise_type: Literal["multiple_choice", "fill_blank", "reorder", "pronunciation"] = Field(
        default="multiple_choice",
        description="Type of exercise"
    )
    user_answers: List[str] = Field(default_factory=list, description="User's submitted answers (for text exercises)")
    correct_answers: List[str] = Field(default_factory=list, description="Correct answers (for text exercises)")
    question: Optional[str] = Field(
        default=None,
        description="The original question"
    )
    # For pronunciation exercises
    expected_text: Optional[str] = Field(
        default=None,
        description="Expected Korean text to read (for pronunciation exercises)"
    )
    audio_data: Optional[str] = Field(
        default=None,
        description="Base64 encoded audio data (for pronunciation exercises)"
    )


class ExerciseCheckResponse(BaseModel):
    """Response model for exercise check"""
    is_correct: bool = Field(..., description="Whether answer is correct")
    score: float = Field(..., description="Score percentage (0-100)")
    feedback: str = Field(..., description="Feedback from teacher")
    emotion_tag: Literal["neutral", "praise", "corrective", "encouraging"] = Field(
        default="neutral",
        description="Emotion tag for avatar"
    )
    tts_url: Optional[str] = Field(
        default=None,
        description="URL to TTS audio for correct answer"
    )
    # For pronunciation exercises
    exercise_type: str = Field(..., description="Type of exercise that was checked")
    pronunciation_details: Optional[dict] = Field(
        default=None,
        description="Detailed pronunciation results (for pronunciation exercises)"
    )


# ===== TTS MODELS =====

class TTSRequest(BaseModel):
    """Request model for text-to-speech using Google TTS"""
    text: str = Field(..., description="Text to convert to speech")
    lang: Optional[str] = Field(
        default=None,
        description="Language code (auto-detected if not provided: 'ko' for Korean, 'vi' for Vietnamese, 'en' for English)"
    )


class TTSResponse(BaseModel):
    """Response model for TTS"""
    audio_url: str = Field(..., description="URL to audio file")
    text: str = Field(..., description="Original text")


# ===== SPEAKING EVALUATION MODELS =====

class SpeakingEvaluationRequest(BaseModel):
    """Request model for speaking evaluation"""
    transcript: str = Field(..., description="User's speech transcript")
    target_phrase: Optional[str] = Field(
        default=None,
        description="Target phrase if practicing specific sentence"
    )
    context: Optional[dict] = Field(
        default=None,
        description="Additional context"
    )


class SpeakingEvaluationResponse(BaseModel):
    """Response model for speaking evaluation"""
    corrected_sentence: str = Field(..., description="Corrected version")
    feedback: str = Field(..., description="Feedback on pronunciation/grammar")
    score: float = Field(..., description="Score (0-100)")
    emotion_tag: Literal["neutral", "praise", "corrective", "encouraging"] = Field(
        default="neutral"
    )
    tts_url: Optional[str] = Field(
        default=None,
        description="URL to TTS of correct sentence"
    )


# ===== READ-ALOUD CHECK MODELS =====

class AccuracyDetails(BaseModel):
    """Detailed accuracy breakdown"""
    word_accuracy: float = Field(..., description="Word-level accuracy (0-100)")
    wer: float = Field(..., description="Word Error Rate (0-1, lower is better)")
    matches: int = Field(..., description="Number of correct words")
    substitutions: int = Field(..., description="Number of incorrect words")
    insertions: int = Field(..., description="Number of extra words")
    deletions: int = Field(..., description="Number of missing words")
    expected_words: List[str] = Field(..., description="Expected word list")
    spoken_words: List[str] = Field(..., description="Spoken word list")


class ReadAloudResponse(BaseModel):
    """Response model for read-aloud check"""
    transcript: str = Field(..., description="What the user said (transcribed)")
    expected_text: str = Field(..., description="What they should have said")
    word_accuracy: float = Field(..., description="Word-level accuracy (0-100)")
    ai_feedback: str = Field(..., description="AI-generated feedback (legacy, combined)")
    overall_score: float = Field(..., description="Final hybrid score (0-100)")
    emotion_tag: Literal["neutral", "praise", "corrective", "encouraging"] = Field(
        default="neutral",
        description="Emotion tag for avatar"
    )
    accuracy_details: Optional[AccuracyDetails] = Field(
        default=None,
        description="Detailed accuracy breakdown"
    )
    # Bilingual feedback
    feedback_en: str = Field(..., description="Short feedback in English (1-2 sentences)")
    feedback_vi: str = Field(..., description="Short feedback in Vietnamese (1-2 sentences)")
    tts_en_url: Optional[str] = Field(
        default=None,
        description="URL to English feedback audio"
    )
    tts_vi_url: Optional[str] = Field(
        default=None,
        description="URL to Vietnamese feedback audio"
    )
    # Tricky words
    tricky_words: Optional[List[str]] = Field(
        default=None,
        description="List of difficult words user struggled with"
    )
    tts_url: Optional[str] = Field(
        default=None,
        description="URL to TTS of correct pronunciation (legacy)"
    )


# ===== LIVE TALK MODELS =====

class LiveTalkMessage(BaseModel):
    """Single message in live talk conversation"""
    role: Literal["user", "assistant"] = Field(..., description="Message role")
    content: str = Field(..., description="Message content")


class LiveTalkSessionStats(BaseModel):
    """Session statistics for live talk"""
    turn_count: int = Field(..., description="Number of conversation turns")
    word_count: int = Field(..., description="Total words spoken by user")
    duration_minutes: int = Field(default=0, description="Session duration in minutes")


class PhonemeFeedback(BaseModel):
    """Feedback for individual phoneme"""
    expected: str = Field(..., description="Expected phoneme (Hangul)")
    predicted: str = Field(..., description="What user actually pronounced")
    position: int = Field(..., description="Position in word/phrase")
    is_correct: bool = Field(..., description="Whether phoneme is correct")

class WordPronunciationFeedback(BaseModel):
    """Feedback for individual word pronunciation"""
    word: str = Field(..., description="Word in Hangul")
    phonemes: List[PhonemeFeedback] = Field(..., description="Phoneme-level feedback")
    accuracy: float = Field(..., description="Word pronunciation accuracy (0-100)")

class FreeSpeakResponse(BaseModel):
    """Response model for free-speak endpoint"""
    transcript: str = Field(..., description="What the user said (transcribed from audio)")
    reply: str = Field(..., description="Coach Ivy's response in Korean (conversational)")
    emotion_tag: Literal["neutral", "praise", "corrective", "encouraging"] = Field(
        default="neutral",
        description="Emotion tag for avatar"
    )
    tts_url: Optional[str] = Field(
        default=None,
        description="URL to TTS audio of coach's response"
    )
    # Pronunciation feedback (if model is available)
    pronunciation_feedback: Optional[Dict[str, Any]] = Field(
        default=None,
        description="Detailed pronunciation feedback from model (phoneme-level)"
    )
    pronunciation_accuracy: Optional[float] = Field(
        default=None,
        description="Overall pronunciation accuracy (0-100) from model"
    )


class LiveTalkResponse(BaseModel):
    """Response model for live talk turn"""
    user_text: str = Field(..., description="Transcribed user speech")
    assistant_text: str = Field(..., description="Coach's response")
    audio_url: str = Field(..., description="URL to TTS audio of coach's response")
    correction: Optional[str] = Field(
        default=None,
        description="Gentle correction if user made errors"
    )
    session_stats: LiveTalkSessionStats = Field(
        ...,
        description="Current session statistics"
    )


class LiveTalkMission(BaseModel):
    """Mission definition for Live Talk topic"""
    mission: str = Field(..., description="Mission description (what to talk about)")
    focus_grammar: str = Field(..., description="Grammar structure to focus on")
    sample_phrases: List[str] = Field(..., description="Example phrases to use")
    icon: str = Field(..., description="Lucide icon name for this topic")


class SessionSummary(BaseModel):
    """Summary generated after Live Talk session"""
    turns: int = Field(..., description="Number of conversation turns")
    total_words: int = Field(..., description="Total words spoken by user")
    duration_minutes: int = Field(..., description="Session duration in minutes")
    strengths: str = Field(..., description="What the user did well (1-2 sentences)")
    weaknesses: str = Field(..., description="Common mistakes to watch out for (1-2 patterns)")
    good_sentences: List[str] = Field(..., description="2 sentences the user said well")
    practice_suggestion: str = Field(..., description="1 sentence pattern to practice more")


# ===== USER PROGRESS MODELS =====

class WeakWord(BaseModel):
    """Word that user struggles with in pronunciation"""
    word: str = Field(..., description="The problematic word")
    error_type: Literal["substitution", "deletion", "mispronunciation"] = Field(
        ...,
        description="Type of error made"
    )
    error_count: int = Field(..., description="Number of times mispronounced")
    last_practiced: str = Field(..., description="ISO timestamp of last practice")


class SavedPhrase(BaseModel):
    """Phrase saved by user to their personal bank"""
    phrase: str = Field(..., description="The saved phrase")
    source: str = Field(..., description="Where it came from (e.g., 'lesson_1', 'live_talk_travel')")
    topic: str = Field(..., description="Topic category (food, travel, work, etc.)")
    saved_at: str = Field(..., description="ISO timestamp when saved")


class UserProgress(BaseModel):
    """Aggregate user progress data"""
    user_id: str = Field(..., description="User identifier")
    weak_words: List[WeakWord] = Field(default_factory=list, description="Words to practice")
    saved_phrases: List[SavedPhrase] = Field(default_factory=list, description="User's phrase bank")
    session_count: int = Field(default=0, description="Total sessions completed")
