"""
Script để test API endpoints
Chạy script này sau khi server đã khởi động: python main.py
"""
import requests
import json
from pathlib import Path
import sys
from typing import Optional

# Base URL của API
BASE_URL = "http://localhost:8000"

def print_section(title):
    """In tiêu đề section"""
    print("\n" + "=" * 60)
    print(f"  {title}")
    print("=" * 60)

def print_success(message):
    """In message thành công"""
    print(f"✅ {message}")

def print_error(message):
    """In message lỗi"""
    print(f"❌ {message}")

def print_warning(message):
    """In message cảnh báo"""
    print(f"⚠️  {message}")

def print_info(message):
    """In message thông tin"""
    print(f"ℹ️  {message}")

def test_health_check():
    """Test health check endpoints"""
    print_section("Health Check")
    
    # Test /ping
    try:
        response = requests.get(f"{BASE_URL}/ping", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success(f"GET /ping: {response.status_code}")
            print(f"   Response: {json.dumps(data, indent=2)}")
        else:
            print_error(f"GET /ping: {response.status_code}")
    except requests.exceptions.ConnectionError:
        print_error("Không thể kết nối đến server!")
        print_info("Đảm bảo server đang chạy: python main.py")
        return False
    except Exception as e:
        print_error(f"GET /ping failed: {e}")
        return False
    
    # Test /health
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success(f"GET /health: {response.status_code}")
            print(f"   Status: {data.get('status')}")
            print(f"   Environment: {data.get('environment')}")
            print(f"   OpenAI configured: {data.get('openai_configured')}")
        else:
            print_error(f"GET /health: {response.status_code}")
    except Exception as e:
        print_error(f"GET /health failed: {e}")
    
    return True

def test_openai_key_debug():
    """Test OpenAI API key debug endpoint"""
    print_section("OpenAI API Key Debug")
    
    try:
        response = requests.get(f"{BASE_URL}/debug/openai-key", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success(f"GET /debug/openai-key: {response.status_code}")
            
            if data.get('configured'):
                print(f"   API Key preview: {data.get('key_preview')}")
                print(f"   Test result: {data.get('test_result')}")
                if data.get('error'):
                    print_error(f"   Error: {data.get('error')}")
                    if data.get('error') == 'quota_exceeded':
                        print_warning("   ⚠️  Server đang sử dụng API key đã hết quota!")
                        print_info("   💡 So sánh với test_openai_key.py để kiểm tra")
                else:
                    print_success("   ✅ API key hoạt động tốt trên server")
            else:
                print_warning("   API key chưa được cấu hình trên server")
        else:
            print_error(f"GET /debug/openai-key: {response.status_code}")
    except Exception as e:
        print_error(f"GET /debug/openai-key failed: {e}")

def test_model_status():
    """Test model status endpoint"""
    print_section("Model Status")
    
    try:
        response = requests.get(f"{BASE_URL}/api/speaking/model-status", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success(f"GET /api/speaking/model-status: {response.status_code}")
            print(f"   Model loaded: {data.get('model_loaded')}")
            print(f"   Status: {data.get('status')}")
            print(f"   Message: {data.get('message')}")
            return data.get('model_loaded', False)
        else:
            print_error(f"GET /api/speaking/model-status: {response.status_code}")
            return False
    except Exception as e:
        print_error(f"GET /api/speaking/model-status failed: {e}")
        return False

def test_lesson_list():
    """Test lesson list endpoint"""
    print_section("Lesson List")
    
    try:
        response = requests.get(f"{BASE_URL}/api/lesson/list", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success(f"GET /api/lesson/list: {response.status_code}")
            print(f"   Total lessons: {data.get('total', 0)}")
            if data.get('lessons'):
                print(f"\n   Lessons:")
                for lesson in data['lessons'][:3]:  # Show first 3
                    print(f"     - {lesson.get('lesson_id')}: {lesson.get('title')}")
        else:
            print_error(f"GET /api/lesson/list: {response.status_code}")
    except Exception as e:
        print_error(f"GET /api/lesson/list failed: {e}")

def test_text_exercise():
    """Test text-based exercise (multiple choice)"""
    print_section("Text Exercise Test (Multiple Choice)")
    
    try:
        payload = {
            "lesson_id": "lesson_1",
            "exercise_type": "multiple_choice",
            "user_answers": ["안녕하세요"],
            "correct_answers": ["안녕하세요"],
            "question": "Chọn câu chào hỏi đúng"
        }
        
        print_info("Sending request...")
        print(f"   Lesson ID: {payload['lesson_id']}")
        print(f"   Exercise type: {payload['exercise_type']}")
        
        response = requests.post(
            f"{BASE_URL}/api/lesson/check-exercise",
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"POST /api/lesson/check-exercise: {response.status_code}")
            print(f"\n📊 Kết quả:")
            print(f"   Is correct: {data.get('is_correct')}")
            print(f"   Score: {data.get('score')}%")
            print(f"   Emotion tag: {data.get('emotion_tag')}")
            print(f"   Feedback: {data.get('feedback')[:100]}...")
        else:
            print_error(f"POST /api/lesson/check-exercise: {response.status_code}")
            print(f"   {response.text}")
    except Exception as e:
        print_error(f"POST /api/lesson/check-exercise failed: {e}")

def test_pronunciation_exercise(audio_file: Optional[str] = None):
    """Test pronunciation exercise"""
    print_section("Pronunciation Exercise Test")
    
    # Tìm file audio test
    if not audio_file:
        test_audio_paths = [
            "test_audio.wav",
            "test_audio.mp3",
            "test_audio.webm",
            "../test_audio.wav",
            "../test_audio.mp3"
        ]
        
        for path in test_audio_paths:
            if Path(path).exists():
                audio_file = path
                break
    
    if not audio_file or not Path(audio_file).exists():
        print_warning("Không tìm thấy file audio test")
        print_info("Tạo file test_audio.wav hoặc chỉnh đường dẫn trong script")
        print_info("Bỏ qua test pronunciation")
        return
    
    print(f"📁 Sử dụng file audio: {audio_file}")
    
    expected_text = "안녕하세요"
    
    try:
        with open(audio_file, "rb") as f:
            files = {"audio": (Path(audio_file).name, f, "audio/wav")}
            data = {
                "lesson_id": "lesson_1",
                "exercise_type": "pronunciation",
                "expected_text": expected_text,
                "question": "Đọc to câu sau"
            }
            
            print_info("Sending request...")
            print(f"   Expected text: {expected_text}")
            print(f"   Lesson ID: {data['lesson_id']}")
            
            response = requests.post(
                f"{BASE_URL}/api/lesson/check-exercise",
                files=files,
                data=data,
                timeout=60  # Timeout 60s vì có thể mất thời gian
            )
            
            if response.status_code == 200:
                result = response.json()
                print_success(f"POST /api/lesson/check-exercise (pronunciation): {response.status_code}")
                
                print(f"\n📊 Kết quả:")
                print(f"   Is correct: {result.get('is_correct')}")
                print(f"   Score: {result.get('score')}%")
                print(f"   Emotion tag: {result.get('emotion_tag')}")
                
                if result.get('pronunciation_details'):
                    details = result['pronunciation_details']
                    print(f"\n📈 Chi tiết phát âm:")
                    print(f"   Transcript: {details.get('transcript')}")
                    print(f"   Expected: {details.get('expected_text')}")
                    print(f"   Word accuracy: {details.get('word_accuracy')}%")
                    if details.get('phoneme_accuracy'):
                        print(f"   Phoneme accuracy: {details.get('phoneme_accuracy')}%")
                    if details.get('tricky_words'):
                        print(f"   Tricky words: {', '.join(details.get('tricky_words', []))}")
                
                if result.get('feedback'):
                    print(f"\n💬 Feedback: {result.get('feedback')[:150]}...")
            else:
                print_error(f"POST /api/lesson/check-exercise: {response.status_code}")
                print(f"   {response.text}")
                
    except requests.exceptions.Timeout:
        print_warning("Request timeout (có thể do model đang xử lý)")
    except Exception as e:
        print_error(f"POST /api/lesson/check-exercise failed: {e}")

def test_tts():
    """Test TTS endpoint"""
    print_section("TTS Test")
    
    try:
        payload = {
            "text": "안녕하세요",
            "lang": "ko"  # Korean
        }
        
        print_info("Sending request...")
        print(f"   Text: {payload['text']}")
        print(f"   Language: {payload['lang']}")
        
        response = requests.post(
            f"{BASE_URL}/api/tts",
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"POST /api/tts: {response.status_code}")
            print(f"   Audio URL: {data.get('audio_url')}")
            print(f"   Text: {data.get('text')}")
        else:
            print_error(f"POST /api/tts: {response.status_code}")
            print(f"   {response.text}")
    except Exception as e:
        print_error(f"POST /api/tts failed: {e}")

def test_chat():
    """Test chat endpoint"""
    print_section("Chat Test")
    
    try:
        payload = {
            "message": "안녕하세요 là gì?",
            "mode": "explain",
            "context": {"lesson_id": "lesson_1"}
        }
        
        print_info("Sending request...")
        print(f"   Message: {payload['message']}")
        print(f"   Mode: {payload['mode']}")
        
        response = requests.post(
            f"{BASE_URL}/api/chat-teacher",
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"POST /api/chat-teacher: {response.status_code}")
            print(f"   Reply: {data.get('reply')[:150]}...")
            print(f"   Emotion tag: {data.get('emotion_tag')}")
        else:
            print_error(f"POST /api/chat-teacher: {response.status_code}")
            print(f"   {response.text}")
    except Exception as e:
        print_error(f"POST /api/chat-teacher failed: {e}")

def main():
    """Main test function"""
    print("\n" + "=" * 60)
    print("  API TEST SCRIPT")
    print("=" * 60)
    print(f"\n🔗 Base URL: {BASE_URL}")
    print("⚠️  Đảm bảo server đang chạy tại http://localhost:8000")
    print()
    
    # Kiểm tra server có đang chạy không
    if not test_health_check():
        print("\n❌ Server không phản hồi!")
        print("   Khởi động server: python main.py")
        sys.exit(1)
    
    print("\n✅ Server đang chạy!\n")
    
    # Kiểm tra OpenAI API key trên server
    test_openai_key_debug()
    print()
    
    # Chạy các test
    model_loaded = test_model_status()
    
    test_lesson_list()
    test_text_exercise()
    
    if model_loaded:
        print_info("Model đã load, sẽ test pronunciation...")
        test_pronunciation_exercise()
    else:
        print_warning("Model chưa load, bỏ qua test pronunciation")
    
    test_tts()
    test_chat()
    
    print_section("Test Complete")
    print_success("Đã hoàn thành tất cả test!")
    print()
    print("💡 Tips:")
    print("   - Xem chi tiết API tại: http://localhost:8000/docs")
    print("   - Kiểm tra logs của server để debug")
    print("   - Nếu model chưa load, kiểm tra file trong models/")
    print()
    print("📚 Endpoints đã test:")
    print("   ✅ GET  /ping")
    print("   ✅ GET  /health")
    print("   ✅ GET  /api/speaking/model-status")
    print("   ✅ GET  /api/lesson/list")
    print("   ✅ POST /api/lesson/check-exercise (text)")
    if model_loaded:
        print("   ✅ POST /api/lesson/check-exercise (pronunciation)")
    print("   ✅ POST /api/tts")
    print("   ✅ POST /api/chat-teacher")

if __name__ == "__main__":
    main()

