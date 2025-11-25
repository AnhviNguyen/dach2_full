package org.example.backend.service.impl;

import org.example.backend.dto.*;
import org.example.backend.entity.User;
import org.example.backend.entity.VocabularyFolder;
import org.example.backend.entity.VocabularyWord;
import org.example.backend.repository.UserRepository;
import org.example.backend.repository.VocabularyFolderRepository;
import org.example.backend.repository.VocabularyWordRepository;
import org.example.backend.service.VocabularyFolderService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class VocabularyFolderServiceImpl implements VocabularyFolderService {
    private final VocabularyFolderRepository folderRepository;
    private final VocabularyWordRepository wordRepository;
    private final UserRepository userRepository;

    public VocabularyFolderServiceImpl(
            VocabularyFolderRepository folderRepository,
            VocabularyWordRepository wordRepository,
            UserRepository userRepository
    ) {
        this.folderRepository = folderRepository;
        this.wordRepository = wordRepository;
        this.userRepository = userRepository;
    }

    @Override
    public List<VocabularyFolderResponse> getFoldersByUserId(Long userId) {
        List<VocabularyFolder> folders = folderRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return folders.stream()
                .map(this::toFolderResponse)
                .collect(Collectors.toList());
    }

    @Override
    public VocabularyFolderResponse getFolderById(Long folderId, Long userId) {
        VocabularyFolder folder = folderRepository.findByIdAndUserId(folderId, userId)
                .orElseThrow(() -> new RuntimeException("Folder not found"));
        return toFolderResponse(folder);
    }

    @Override
    @Transactional
    public VocabularyFolderResponse createFolder(VocabularyFolderRequest request, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        VocabularyFolder folder = new VocabularyFolder();
        folder.setUser(user);
        folder.setName(request.name());
        folder.setIcon(request.icon() != null ? request.icon() : "📁");
        folder = folderRepository.save(folder);

        return toFolderResponse(folder);
    }

    @Override
    @Transactional
    public VocabularyFolderResponse updateFolder(Long folderId, VocabularyFolderRequest request, Long userId) {
        VocabularyFolder folder = folderRepository.findByIdAndUserId(folderId, userId)
                .orElseThrow(() -> new RuntimeException("Folder not found"));

        folder.setName(request.name());
        if (request.icon() != null) {
            folder.setIcon(request.icon());
        }
        folder = folderRepository.save(folder);

        return toFolderResponse(folder);
    }

    @Override
    @Transactional
    public void deleteFolder(Long folderId, Long userId) {
        VocabularyFolder folder = folderRepository.findByIdAndUserId(folderId, userId)
                .orElseThrow(() -> new RuntimeException("Folder not found"));
        folderRepository.delete(folder);
    }

    @Override
    @Transactional
    public VocabularyWordResponse addWordToFolder(Long folderId, VocabularyWordRequest request, Long userId) {
        VocabularyFolder folder = folderRepository.findByIdAndUserId(folderId, userId)
                .orElseThrow(() -> new RuntimeException("Folder not found"));

        VocabularyWord word = new VocabularyWord();
        word.setFolder(folder);
        word.setKorean(request.korean());
        word.setVietnamese(request.vietnamese());
        word.setPronunciation(request.pronunciation());
        word.setExample(request.example());
        word = wordRepository.save(word);

        return toWordResponse(word);
    }

    @Override
    @Transactional
    public VocabularyWordResponse updateWord(Long wordId, VocabularyWordRequest request, Long userId) {
        VocabularyWord word = wordRepository.findById(wordId)
                .orElseThrow(() -> new RuntimeException("Word not found"));

        // Verify ownership
        if (!word.getFolder().getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }

        word.setKorean(request.korean());
        word.setVietnamese(request.vietnamese());
        word.setPronunciation(request.pronunciation());
        word.setExample(request.example());
        word = wordRepository.save(word);

        return toWordResponse(word);
    }

    @Override
    @Transactional
    public void deleteWord(Long wordId, Long userId) {
        VocabularyWord word = wordRepository.findById(wordId)
                .orElseThrow(() -> new RuntimeException("Word not found"));

        // Verify ownership
        if (!word.getFolder().getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }

        wordRepository.delete(word);
    }

    private VocabularyFolderResponse toFolderResponse(VocabularyFolder folder) {
        List<VocabularyWordResponse> words = folder.getWords().stream()
                .map(this::toWordResponse)
                .collect(Collectors.toList());

        return new VocabularyFolderResponse(
                folder.getId(),
                folder.getName(),
                folder.getIcon(),
                folder.getWords().size(),
                words,
                folder.getCreatedAt(),
                folder.getUpdatedAt()
        );
    }

    private VocabularyWordResponse toWordResponse(VocabularyWord word) {
        return new VocabularyWordResponse(
                word.getId(),
                word.getKorean(),
                word.getVietnamese(),
                word.getPronunciation(),
                word.getExample(),
                word.getCreatedAt(),
                word.getUpdatedAt()
        );
    }
}

