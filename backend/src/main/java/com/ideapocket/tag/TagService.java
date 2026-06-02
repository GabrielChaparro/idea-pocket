package com.ideapocket.tag;

import com.ideapocket.common.ApiException;
import com.ideapocket.tag.TagDtos.TagRequest;
import com.ideapocket.tag.TagDtos.TagResponse;
import com.ideapocket.user.User;
import com.ideapocket.user.UserRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TagService {
    private final TagRepository tags;
    private final UserRepository users;

    public TagService(TagRepository tags, UserRepository users) {
        this.tags = tags;
        this.users = users;
    }

    public List<TagResponse> list(UUID userId) {
        return tags.findAllByUserIdOrderByNameAsc(userId).stream().map(TagResponse::from).toList();
    }

    @Transactional
    public TagResponse create(UUID userId, TagRequest request) {
        String name = request.name().trim();
        if (tags.existsByUserIdAndNameIgnoreCase(userId, name)) {
            throw new ApiException(HttpStatus.CONFLICT, "Tag already exists");
        }
        User user = users.findById(userId).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found"));
        Tag tag = tags.save(new Tag(user, name, request.color()));
        return TagResponse.from(tag);
    }

    @Transactional
    public void delete(UUID userId, UUID id) {
        Tag tag = tags.findByIdAndUserId(id, userId)
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Tag not found"));
        tags.delete(tag);
    }
}
