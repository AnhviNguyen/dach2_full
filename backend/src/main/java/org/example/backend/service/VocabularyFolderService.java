package org.example.backend.service;

import org.example.backend.dto.*;

import java.util.List;

public interface VocabularyFolderService {
    List<VocabularyFolderResponse> getFoldersByUserId(Long userId);
    VocabularyFolderResponse getFolderById(Long folderId, Long userId);
    VocabularyFolderResponse createFolder(VocabularyFolderRequest request, Long userId);
    VocabularyFolderResponse updateFolder(Long folderId, VocabularyFolderRequest request, Long userId);
    void deleteFolder(Long folderId, Long userId);
    VocabularyWordResponse addWordToFolder(Long folderId, VocabularyWordRequest request, Long userId);
    VocabularyWordResponse updateWord(Long wordId, VocabularyWordRequest request, Long userId);
    void deleteWord(Long wordId, Long userId);
}

