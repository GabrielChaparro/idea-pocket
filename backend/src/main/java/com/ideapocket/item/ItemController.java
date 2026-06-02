package com.ideapocket.item;

import com.ideapocket.item.ItemDtos.ItemRequest;
import com.ideapocket.item.ItemDtos.ItemResponse;
import com.ideapocket.security.AuthenticatedUser;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/items")
public class ItemController {
    private final ItemService itemService;

    public ItemController(ItemService itemService) {
        this.itemService = itemService;
    }

    @GetMapping
    Page<ItemResponse> list(
        Authentication authentication,
        @RequestParam(required = false) ItemType type,
        @RequestParam(required = false) ItemStatus status,
        @RequestParam(required = false) String search,
        @RequestParam(required = false) UUID tagId,
        @PageableDefault(size = 50, sort = "createdAt") Pageable pageable
    ) {
        return itemService.list(AuthenticatedUser.id(authentication), type, status, search, tagId, pageable);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ItemResponse create(Authentication authentication, @Valid @RequestBody ItemRequest request) {
        return itemService.create(AuthenticatedUser.id(authentication), request);
    }

    @GetMapping("/{id}")
    ItemResponse get(Authentication authentication, @PathVariable UUID id) {
        return itemService.get(AuthenticatedUser.id(authentication), id);
    }

    @PutMapping("/{id}")
    ItemResponse update(Authentication authentication, @PathVariable UUID id, @Valid @RequestBody ItemRequest request) {
        return itemService.update(AuthenticatedUser.id(authentication), id, request);
    }

    @PatchMapping("/{id}/complete")
    ItemResponse complete(Authentication authentication, @PathVariable UUID id) {
        return itemService.complete(AuthenticatedUser.id(authentication), id);
    }

    @PatchMapping("/{id}/reopen")
    ItemResponse reopen(Authentication authentication, @PathVariable UUID id) {
        return itemService.reopen(AuthenticatedUser.id(authentication), id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void delete(Authentication authentication, @PathVariable UUID id) {
        itemService.delete(AuthenticatedUser.id(authentication), id);
    }
}

