package com.ideapocket.tag;

import com.ideapocket.security.AuthenticatedUser;
import com.ideapocket.tag.TagDtos.TagRequest;
import com.ideapocket.tag.TagDtos.TagResponse;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/tags")
public class TagController {
    private final TagService tagService;

    public TagController(TagService tagService) {
        this.tagService = tagService;
    }

    @GetMapping
    List<TagResponse> list(Authentication authentication) {
        return tagService.list(AuthenticatedUser.id(authentication));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    TagResponse create(Authentication authentication, @Valid @RequestBody TagRequest request) {
        return tagService.create(AuthenticatedUser.id(authentication), request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void delete(Authentication authentication, @PathVariable UUID id) {
        tagService.delete(AuthenticatedUser.id(authentication), id);
    }
}

