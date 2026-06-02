package com.ideapocket.item;

import com.ideapocket.tag.TagDtos.TagResponse;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class ItemDtos {
    private ItemDtos() {
    }

    public record ItemRequest(
        @NotNull ItemType type,
        @Size(max = 255) String title,
        @NotBlank String content,
        Priority priority,
        Instant dueDate,
        List<UUID> tagIds
    ) {
    }

    public record ItemResponse(
        UUID id,
        ItemType type,
        String title,
        String content,
        ItemStatus status,
        Priority priority,
        Instant dueDate,
        Instant completedAt,
        Instant createdAt,
        Instant updatedAt,
        List<TagResponse> tags
    ) {
        static ItemResponse from(Item item) {
            return new ItemResponse(
                item.getId(),
                item.getType(),
                item.getTitle(),
                item.getContent(),
                item.getStatus(),
                item.getPriority(),
                item.getDueDate(),
                item.getCompletedAt(),
                item.getCreatedAt(),
                item.getUpdatedAt(),
                item.getTags().stream().map(TagResponse::from).toList()
            );
        }
    }

}
