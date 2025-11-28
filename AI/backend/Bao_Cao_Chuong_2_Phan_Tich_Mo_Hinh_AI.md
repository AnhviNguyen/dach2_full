# CHƯƠNG 2: PHÂN TÍCH MÔ HÌNH AI

## 2.1. Tổng quan

Hệ thống sử dụng mô hình AI để đánh giá phát âm tiếng Hàn dựa trên audio. Mô hình kết hợp Wav2Vec2 để trích xuất đặc trưng và Conformer để nhận dạng phoneme, sử dụng CTC loss để xử lý vấn đề alignment giữa audio và phoneme sequence.

---

## 2.2. Dataset

### 2.2.1. Nguồn dữ liệu
- **Dataset**: Korean Speech Synthesis (KSS)
- **Metadata**: File `transcript.v.1.4.txt` chứa 12,853 mẫu
- **Audio**: Thư mục `/kaggle/input/kss` chứa các file `.wav`
- **Format**: Mỗi dòng metadata có format: `wav_name|duration|korean_text`

### 2.2.2. Tiền xử lý
- **Resample audio**: Tất cả audio được resample về 16kHz (chuẩn cho Wav2Vec2)
- **Phoneme conversion**: Chuyển đổi văn bản tiếng Hàn (Hangul) sang phoneme sequence sử dụng hàm `hangul_g2p()`
- **Train/Val split**: 90% training (11,567 mẫu), 10% validation (1,286 mẫu)

### 2.2.3. Phoneme Dictionary
- **Tổng số phonemes**: 55 (bao gồm `<blank>` token cho CTC)
- **Cấu trúc**: 
  - `<blank>`: ID = 0 (token đặc biệt cho CTC)
  - Các phoneme tiếng Hàn: ㄱ, ㄲ, ㄴ, ㄷ, ..., ㅏ, ㅐ, ㅑ, ..., <sp>, <unk>
- **Mapping**: Sử dụng bảng `KOREAN_TO_IPA` để chuyển đổi sang IPA khi cần

---

## 2.3. Trích xuất đặc trưng (Feature Extraction)

### 2.3.1. Wav2Vec2 Model
- **Model**: `facebook/wav2vec2-base` (pretrained)
- **Input**: Audio waveform (16kHz, mono)
- **Output**: Feature vectors có chiều 768
- **Cơ chế**: 
  - Wav2Vec2 là self-supervised model học biểu diễn audio từ raw waveform
  - Output `last_hidden_state` có shape `(T, 768)` với T là độ dài sequence sau khi downsampling

### 2.3.2. Normalization
- **Mean-Std normalization**: Tính mean và std từ 1,000 mẫu ngẫu nhiên
- **Công thức**: `features = (features - mean) / (std + 1e-8)`
- **Mục đích**: Chuẩn hóa features để training ổn định hơn

---

## 2.4. Kiến trúc mô hình (Model Architecture)

### 2.4.1. Conformer Pronunciation Model

**Cấu trúc tổng thể:**
```
Input (T, 768) 
  → Linear Projection (768 → 256)
  → Positional Encoding
  → 3x Conformer Blocks
  → Linear Output (256 → 55 phonemes)
```

**Tham số:**

| Thành phần | Giá trị |
|------------|---------|
| Input dim | 768 |
| Hidden dim | 256 |
| Số Conformer blocks | 3 |
| Attention heads | 4 |
| FFN inner dim | 1024 |
| Conv kernel size | 15 |
| Dropout | 0.2 |
| Tổng số tham số | ~3.3 triệu |

**Giải thích:**
- **Input dim**: 768 là chiều của Wav2Vec2 features
- **Hidden dim**: 256 là chiều ẩn của model sau projection
- **FFN inner dim**: 1024 = 256 × 4 (ff_mult=4 trong ConformerBlock)
- **Tổng số tham số**: 3,317,303 parameters

### 2.4.2. Conformer Block

Mỗi Conformer Block gồm 4 thành phần chính:

1. **Feed-Forward Module 1**:
   - Linear(256 → 1024) → GELU → Linear(1024 → 256)
   - Residual connection + LayerNorm

2. **Multi-Head Self-Attention (MHSA)**:
   - 4 attention heads
   - Batch-first format
   - Residual connection + LayerNorm

3. **Convolution Module**:
   - Conv1d với kernel size = 15
   - GLU activation
   - Depthwise convolution
   - BatchNorm + GELU
   - Residual connection + LayerNorm

4. **Feed-Forward Module 2**:
   - Tương tự Module 1
   - Final LayerNorm

**Đặc điểm**: Conformer kết hợp Transformer (attention) và Convolution để nắm bắt cả global và local patterns trong audio features.

---

## 2.5. Thuật toán Training

### 2.5.1. CTC Loss (Connectionist Temporal Classification)

**Vấn đề**: Audio sequence và phoneme sequence có độ dài khác nhau và không có alignment rõ ràng.

**Giải pháp**: CTC loss cho phép:
- Map một audio sequence dài hơn sang phoneme sequence ngắn hơn
- Sử dụng `<blank>` token để xử lý alignment
- Không cần forced alignment trước

**Công thức**:
```
Loss = -log P(phoneme_sequence | audio_features)
```

**Implementation**:
- `CTCLoss(blank=0, zero_infinity=True)` từ PyTorch
- Input: Log probabilities `(T, batch, num_phonemes)` và target phoneme IDs
- Output: Scalar loss value

### 2.5.2. Decoding Strategy

**CTC Greedy Decode**:
1. Lấy argmax tại mỗi time step: `pred = argmax(log_probs, dim=-1)`
2. Loại bỏ `<blank>` tokens (ID=0)
3. Loại bỏ duplicate tokens liên tiếp
4. Trả về phoneme sequence

**Ví dụ**:
```
Raw prediction: [0, 6, 6, 0, 38, 0, 9, 9, 0]
After decode: [6, 38, 9]  → phonemes: [ㄱ, ㅓ, ㄴ]
```

### 2.5.3. Training Configuration

- **Optimizer**: AdamW với learning rate = 1e-4, weight decay = 1e-4
- **Scheduler**: OneCycleLR với max_lr = 3e-4, cosine annealing
- **Batch size**: 24
- **Epochs**: 25 (với early stopping, patience = 5)
- **Gradient clipping**: max_norm = 1.0
- **Device**: CUDA (GPU) nếu có, ngược lại CPU

### 2.5.4. Evaluation Metric

**PER (Phoneme Error Rate)**:
```
PER = (S + D + I) / N
```
- **S**: Substitutions (thay thế sai)
- **D**: Deletions (thiếu phoneme)
- **I**: Insertions (thêm phoneme)
- **N**: Tổng số phonemes trong reference

**Implementation**: Sử dụng Levenshtein distance (edit distance) để tính số lỗi.

---

## 2.6. Input và Output

### 2.6.1. Input

**Training/Inference**:
- **Audio file**: File `.wav` (bất kỳ sample rate, được resample về 16kHz)
- **Format**: Mono, float32, normalized về [-1, 1]

**Pipeline xử lý**:
```
Audio (16kHz) 
  → Wav2Vec2 → Features (T, 768)
  → Normalization (mean/std)
  → Tensor (1, T, 768)
```

### 2.6.2. Output

**Model output**:
- **Logits**: `(batch, T, 55)` - raw scores cho 55 phonemes tại mỗi time step
- **Log probabilities**: `log_softmax(logits)` - chuẩn hóa thành probabilities

**Decoded output**:
- **Phoneme sequence**: Danh sách phoneme IDs (ví dụ: `[6, 38, 9]`)
- **Phoneme symbols**: Chuyển đổi sang ký hiệu (ví dụ: `['ㄱ', 'ㅓ', 'ㄴ']`)
- **IPA transcription**: Chuyển đổi sang IPA nếu cần (ví dụ: `/ k ʌ n /`)

**Pronunciation score**:
- **Score**: `(1 - PER) * 100` (phần trăm)
- **Feedback**: So sánh predicted phonemes với reference phonemes

---

## 2.7. Ứng dụng: AI Pronunciation Trainer

### 2.7.1. Chức năng

Hệ thống cung cấp giao diện đánh giá phát âm tiếng Hàn:

1. **Input**: 
   - Văn bản tiếng Hàn (reference)
   - Audio file người dùng phát âm

2. **Xử lý**:
   - Trích xuất phonemes từ audio
   - So sánh với reference phonemes

3. **Output**:
   - Score phần trăm (0-100%)
   - Visualization với màu sắc:
     - Xanh lá: Phát âm đúng
     - Đỏ: Phát âm sai
   - IPA transcription cho cả reference và user pronunciation

### 2.7.2. Visualization

Giao diện hiển thị:
- **Original text**: Văn bản tiếng Hàn với underline màu (xanh/đỏ)
- **Reference IPA**: Phoneme sequence chuẩn
- **User IPA**: Phoneme sequence người dùng phát âm
- **Score**: Phần trăm chính xác

---

## 2.8. Kết quả Training

### 2.8.1. Metrics

- **Best Validation PER**: ~0.25 (25% error rate)
- **Phoneme Accuracy**: ~75%
- **Training Loss**: Giảm từ ~3.2 xuống ~0.8
- **Validation Loss**: Giảm từ ~1.6 xuống ~0.7

### 2.8.2. Đánh giá

**Ưu điểm**:
- Sử dụng pretrained Wav2Vec2 → không cần train từ đầu
- Conformer architecture hiệu quả cho sequence modeling
- CTC loss xử lý tốt vấn đề alignment
- Model nhỏ gọn (~3.3M parameters) → inference nhanh

**Hạn chế**:
- PER = 25% vẫn còn cao, cần cải thiện
- Chỉ sử dụng greedy decode → có thể cải thiện bằng beam search
- Model chỉ nhận diện phonemes, chưa đánh giá prosody (ngữ điệu)

---

## 2.9. Kết luận

Mô hình sử dụng kiến trúc Wav2Vec2 + Conformer với CTC loss để nhận diện phoneme từ audio tiếng Hàn. Hệ thống đạt độ chính xác ~75% và có thể ứng dụng vào AI Pronunciation Trainer để đánh giá phát âm người học. Mô hình nhỏ gọn, hiệu quả và có thể deploy trong môi trường thực tế.


