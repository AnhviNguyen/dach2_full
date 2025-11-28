# Mô hình Pronunciation Model - Giải thích chi tiết

## 📋 Tổng quan

File `pronunciation_model.pt` (13MB) là một **mô hình Deep Learning** được thiết kế đặc biệt để đánh giá phát âm tiếng Hàn. Đây là một mô hình **hybrid** kết hợp nhiều công nghệ AI hiện đại.

## 🏗️ Kiến trúc mô hình

### 1. **Wav2Vec2 (Facebook AI Research)**
- **Mục đích**: Trích xuất features (đặc trưng) từ audio
- **Model**: `facebook/wav2vec2-base`
- **Input**: Audio waveform (16kHz, mono)
- **Output**: Feature vectors (768 dimensions)
- **Chức năng**: Chuyển đổi tín hiệu âm thanh thô thành biểu diễn số học có ý nghĩa

### 2. **Conformer Architecture** 
- **Mục đích**: Xử lý và dự đoán phonemes từ features
- **Kiến trúc**: 
  - **Input**: Wav2Vec2 features (768 dim) → Projection (256 dim)
  - **Conformer Blocks** (3 layers):
    - **Feed-Forward Module**: Xử lý thông tin tuần tự
    - **Multi-Head Self-Attention**: Nắm bắt dependencies dài hạn
    - **Convolution Module**: Bắt local patterns
    - **Residual Connections**: Giúp training ổn định
  - **Output**: Logits cho 55 phonemes tiếng Hàn
- **Parameters**:
  - Input dimension: 768 (từ Wav2Vec2)
  - Hidden dimension: 256
  - Attention heads: 4
  - Depth: 3 Conformer blocks
  - Phoneme vocabulary: 55 phonemes

### 3. **CTC Decoding (Connectionist Temporal Classification)**
- **Mục đích**: Chuyển đổi logits thành chuỗi phonemes
- **Phương pháp**: Greedy decode (chọn phoneme có xác suất cao nhất)
- **Xử lý**: Loại bỏ blank tokens và duplicate liên tiếp

## 📊 Quy trình hoạt động

```
Audio Input (16kHz)
    ↓
[Wav2Vec2 Feature Extraction]
    ↓
Feature Vectors (T, 768)
    ↓
[Normalization: mean/std]
    ↓
[Conformer Model]
    ↓
Logits (T, 55)
    ↓
[CTC Greedy Decode]
    ↓
Predicted Phonemes (ㄱ, ㅏ, ㄴ, ...)
    ↓
[Compare with Expected Phonemes]
    ↓
[Levenshtein Distance]
    ↓
Pronunciation Score & Feedback
```

## 📁 Các file liên quan

### 1. `pronunciation_model.pt` (13MB)
- File chứa weights của Conformer model
- Được train trên dataset tiếng Hàn
- Format: PyTorch state_dict

### 2. `p2id.json` (780B)
- **Phoneme-to-ID mapping**
- Map từng phoneme tiếng Hàn sang ID số
- Ví dụ:
  ```json
  {
    "<blank>": 0,
    "ㄱ": 6,
    "ㅏ": 34,
    "ㄴ": 9,
    ...
  }
  ```
- Tổng cộng: **55 phonemes** (bao gồm các phụ âm, nguyên âm, và ký tự đặc biệt)

### 3. `wav2vec2_stats.npy` (136B)
- **Normalization statistics**
- Chứa mean và std để normalize Wav2Vec2 features
- Đảm bảo features có distribution phù hợp với model đã train

### 4. `korean_phrases.json` (6.6KB)
- Danh sách các câu/phrase tiếng Hàn mẫu
- Dùng cho pronunciation practice
- 289 entries

## 🎯 Công dụng chính

### 1. **Pronunciation Assessment (Đánh giá phát âm)**
- So sánh phát âm của người dùng với phát âm chuẩn
- Tính độ chính xác ở mức **phoneme level**
- Phát hiện lỗi phát âm chi tiết (initial, vowel, final consonants)

### 2. **Detailed Feedback**
- Chỉ ra từng phoneme nào đúng/sai
- Phân loại lỗi (substitution, insertion, deletion)
- Tính accuracy cho từng từ và toàn câu

### 3. **Real-time Processing**
- Xử lý audio trong vài giây
- Không cần GPU (có thể chạy trên CPU)
- Optimized cho inference speed

## 🔧 Công nghệ sử dụng

### Deep Learning Frameworks
- **PyTorch**: Framework chính cho training và inference
- **Transformers** (Hugging Face): Load Wav2Vec2 pre-trained model
- **Librosa**: Xử lý audio (resample, normalize)

### Algorithms
- **CTC Loss**: Training strategy để align audio với phonemes
- **Levenshtein Distance**: Tính độ tương đồng giữa sequences
- **Greedy Decoding**: Chuyển đổi logits → phonemes

## 📈 Model Performance

- **Input**: Audio file (webm, mp3, wav, m4a)
- **Output**: 
  - Predicted phonemes
  - Accuracy score (0-100%)
  - Detailed feedback (word-level, phoneme-level)
- **Processing time**: ~2-5 giây/câu (tùy độ dài audio)

## 🎓 Training Process

Model này được train trên:
- **Dataset**: Korean pronunciation dataset
- **Objective**: Minimize CTC loss giữa predicted và expected phonemes
- **Features**: Sử dụng Wav2Vec2 pre-trained features (transfer learning)
- **Fine-tuning**: Conformer layers được fine-tune cho tiếng Hàn

## 🔍 So sánh với các phương pháp khác

| Phương pháp | Ưu điểm | Nhược điểm |
|------------|---------|-----------|
| **Rule-based** | Nhanh, không cần model | Không chính xác, không linh hoạt |
| **Traditional ML** | Đơn giản | Cần nhiều feature engineering |
| **Deep Learning (Conformer)** ✅ | Chính xác cao, tự động học features | Cần GPU để train, model lớn hơn |

## 💡 Lý do chọn Conformer

1. **Self-Attention**: Nắm bắt dependencies dài hạn trong audio
2. **Convolution**: Bắt local patterns (phụ âm, nguyên âm)
3. **Efficiency**: Cân bằng tốt giữa accuracy và speed
4. **Proven**: Được sử dụng rộng rãi trong speech recognition (Google, Meta)

## 🔗 Tài liệu tham khảo

- **Wav2Vec2**: [Facebook AI Research](https://github.com/facebookresearch/fairseq)
- **Conformer**: [Google Research - Conformer Paper](https://arxiv.org/abs/2005.08100)
- **CTC**: [Connectionist Temporal Classification](https://distill.pub/2017/ctc/)

## 📝 Lưu ý

- Model này được train **offline** và load vào memory khi server khởi động
- Cần ~1-2GB RAM để load model và Wav2Vec2
- Có thể chạy trên CPU nhưng GPU sẽ nhanh hơn đáng kể
- Model chỉ hỗ trợ tiếng Hàn (Korean phonemes)

