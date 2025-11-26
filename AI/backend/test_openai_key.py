"""
Script để test OpenAI API key
Chạy script này để kiểm tra API key có hoạt động không
"""
import sys
from config import settings
from openai import OpenAI

def test_openai_key():
    """Test OpenAI API key"""
    print("=" * 60)
    print("  Test OpenAI API Key")
    print("=" * 60)
    print()
    
    # Check API key
    api_key = settings.openai_api_key
    if not api_key or api_key == "your_openai_api_key_here":
        print("❌ API key chưa được cấu hình!")
        print("   Kiểm tra file .env và đảm bảo OPENAI_API_KEY đã được set")
        return False
    
    print(f"✅ API key đã được load: {api_key[:10]}...{api_key[-4:]}")
    print()
    
    # Test API key
    try:
        client = OpenAI(api_key=api_key)
        
        print("📤 Testing API key với simple request...")
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "user", "content": "Say hello in Korean"}
            ],
            max_tokens=10
        )
        
        reply = response.choices[0].message.content.strip()
        print(f"✅ API key hoạt động!")
        print(f"   Response: {reply}")
        return True
        
    except Exception as e:
        error_str = str(e)
        print(f"❌ API key không hoạt động!")
        print(f"   Error: {e}")
        print()
        
        # Check specific error types
        if "insufficient_quota" in error_str or "429" in error_str:
            print("⚠️  LỖI: Tài khoản đã hết credit/quota!")
            print()
            print("💡 Giải pháp:")
            print("   1. Kiểm tra billing tại: https://platform.openai.com/account/billing")
            print("   2. Thêm payment method và nạp credit")
            print("   3. Hoặc đợi đến chu kỳ billing mới")
            print()
            print("📝 Lưu ý:")
            print("   - API key của bạn là đúng")
            print("   - Chỉ cần nạp credit là có thể sử dụng được")
        elif "invalid_api_key" in error_str or "401" in error_str:
            print("⚠️  LỖI: API key không hợp lệ!")
            print()
            print("💡 Giải pháp:")
            print("   1. Kiểm tra API key trong file .env")
            print("   2. Tạo API key mới tại: https://platform.openai.com/api-keys")
            print("   3. Đảm bảo không có khoảng trắng thừa")
        else:
            print("💡 Kiểm tra:")
            print("   1. API key có đúng không")
            print("   2. Tài khoản có credit không")
            print("   3. API key có bị revoke không")
            print("   4. Kết nối internet có ổn định không")
        
        return False

if __name__ == "__main__":
    success = test_openai_key()
    sys.exit(0 if success else 1)

