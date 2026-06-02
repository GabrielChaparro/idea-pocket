package com.ideapocket.tag;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.UUID;

public final class TagDtos {
    private TagDtos() {
    }

    public record TagRequest(
        @NotBlank @Size(max = 80) String name,
        @Size(max = 20) String color
    ) {
    }

    public record TagResponse(
        UUID id,
        String name,
        String color
    ) {
        public static TagResponse from(Tag tag) {
            return new TagResponse(tag.getId(), tag.getName(), tag.getColor());
        }
    }
}
