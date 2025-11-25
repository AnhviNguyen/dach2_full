package org.example.backend.controller;

import org.example.backend.dto.*;
import org.example.backend.service.VocabularyFolderService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vocabulary-folders")
@CrossOrigin(origins = "*")
public class VocabularyFolderController {
    private final VocabularyFolderService folderService;

    public VocabularyFolderController(VocabularyFolderService folderService) {
        this.folderService = folderService;
    }

    @GetMapping
    public ResponseEntity<List<VocabularyFolderResponse>> getFoldersByUserId(
            @RequestParam(value = "userId") Long userId) {
        List<VocabularyFolderResponse> response = folderService.getFoldersByUserId(userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<VocabularyFolderResponse> getFolderById(
            @PathVariable(value = "id") Long id,
            @RequestParam(value = "userId") Long userId) {
        VocabularyFolderResponse response = folderService.getFolderById(id, userId);
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<VocabularyFolderResponse> createFolder(
            @RequestBody VocabularyFolderRequest request,
            @RequestParam(value = "userId") Long userId) {
        VocabularyFolderResponse response = folderService.createFolder(request, userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<VocabularyFolderResponse> updateFolder(
            @PathVariable(value = "id") Long id,
            @RequestBody VocabularyFolderRequest request,
            @RequestParam(value = "userId") Long userId) {
        VocabularyFolderResponse response = folderService.updateFolder(id, request, userId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFolder(
            @PathVariable(value = "id") Long id,
            @RequestParam(value = "userId") Long userId) {
        folderService.deleteFolder(id, userId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{folderId}/words")
    public ResponseEntity<VocabularyWordResponse> addWordToFolder(
            @PathVariable(value = "folderId") Long folderId,
            @RequestBody VocabularyWordRequest request,
            @RequestParam(value = "userId") Long userId) {
        VocabularyWordResponse response = folderService.addWordToFolder(folderId, request, userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/words/{wordId}")
    public ResponseEntity<VocabularyWordResponse> updateWord(
            @PathVariable(value = "wordId") Long wordId,
            @RequestBody VocabularyWordRequest request,
            @RequestParam(value = "userId") Long userId) {
        VocabularyWordResponse response = folderService.updateWord(wordId, request, userId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/words/{wordId}")
    public ResponseEntity<Void> deleteWord(
            @PathVariable(value = "wordId") Long wordId,
            @RequestParam(value = "userId") Long userId) {
        folderService.deleteWord(wordId, userId);
        return ResponseEntity.noContent().build();
    }
}

