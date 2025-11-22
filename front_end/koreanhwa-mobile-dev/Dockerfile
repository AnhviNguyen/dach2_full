FROM cirrusci/flutter:stable

# Copy chỉ những thứ cần thiết
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .

# Build web hoặc apk tùy bạn muốn
# CMD ["flutter", "run", "--release"]           # chạy trên máy có USB
# CMD ["flutter", "build", "apk", "--release"]  # build APK
CMD ["flutter", "build", "web"]                 # ví dụ build web