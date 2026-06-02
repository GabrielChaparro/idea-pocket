package com.ideapocket.item;

import com.ideapocket.common.ApiException;
import com.ideapocket.item.ItemDtos.ItemRequest;
import com.ideapocket.item.ItemDtos.ItemResponse;
import com.ideapocket.tag.Tag;
import com.ideapocket.tag.TagRepository;
import com.ideapocket.user.User;
import com.ideapocket.user.UserRepository;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.time.Instant;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ItemService {
    private final ItemRepository items;
    private final UserRepository users;
    private final TagRepository tags;

    public ItemService(ItemRepository items, UserRepository users, TagRepository tags) {
        this.items = items;
        this.users = users;
        this.tags = tags;
    }

    @Transactional(readOnly = true)
    public Page<ItemResponse> list(
        UUID userId,
        ItemType type,
        ItemStatus status,
        String search,
        UUID tagId,
        Instant dueFrom,
        Instant dueTo,
        ItemOrder order,
        Pageable pageable
    ) {
        String normalizedSearch = search == null || search.isBlank() ? null : search.trim();
        return items.findAll(
            specification(userId, type, status, normalizedSearch, tagId, dueFrom, dueTo, order),
            orderedPageable(pageable, order)
        ).map(ItemResponse::from);
    }

    @Transactional(readOnly = true)
    public ItemResponse get(UUID userId, UUID id) {
        return ItemResponse.from(findOwned(userId, id));
    }

    @Transactional
    public ItemResponse create(UUID userId, ItemRequest request) {
        User user = users.findById(userId).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found"));
        Item item = new Item(user, request.type(), request.title(), request.content(), request.priority(), request.dueDate());
        item.update(request.type(), request.title(), request.content(), request.priority(), request.dueDate(), resolveTags(userId, request));
        return ItemResponse.from(items.save(item));
    }

    @Transactional
    public ItemResponse update(UUID userId, UUID id, ItemRequest request) {
        Item item = findOwned(userId, id);
        item.update(request.type(), request.title(), request.content(), request.priority(), request.dueDate(), resolveTags(userId, request));
        return ItemResponse.from(item);
    }

    @Transactional
    public ItemResponse complete(UUID userId, UUID id) {
        Item item = findOwned(userId, id);
        item.complete();
        return ItemResponse.from(item);
    }

    @Transactional
    public ItemResponse reopen(UUID userId, UUID id) {
        Item item = findOwned(userId, id);
        item.reopen();
        return ItemResponse.from(item);
    }

    @Transactional
    public void delete(UUID userId, UUID id) {
        findOwned(userId, id).softDelete();
    }

    private Item findOwned(UUID userId, UUID id) {
        return items.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Item not found"));
    }

    private Set<Tag> resolveTags(UUID userId, ItemRequest request) {
        if (request.tagIds() == null || request.tagIds().isEmpty()) {
            return Set.of();
        }

        Set<Tag> resolved = new HashSet<>();
        for (UUID tagId : request.tagIds()) {
            resolved.add(tags.findByIdAndUserId(tagId, userId)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid tag: " + tagId)));
        }
        return resolved;
    }

    private Specification<Item> specification(
        UUID userId,
        ItemType type,
        ItemStatus status,
        String search,
        UUID tagId,
        Instant dueFrom,
        Instant dueTo,
        ItemOrder order
    ) {
        return (root, query, cb) -> {
            if (query != null && tagId != null) {
                query.distinct(true);
            }

            var predicates = new ArrayList<Predicate>();
            predicates.add(cb.equal(root.get("user").get("id"), userId));
            predicates.add(cb.isNull(root.get("deletedAt")));

            if (type != null) {
                predicates.add(cb.equal(root.get("type"), type));
            }

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            if (search != null) {
                String like = "%" + search.toLowerCase() + "%";
                predicates.add(cb.or(
                    cb.like(cb.lower(cb.coalesce(root.get("title"), "")), like),
                    cb.like(cb.lower(root.get("content")), like)
                ));
            }

            if (tagId != null) {
                var tagJoin = root.join("tags", JoinType.INNER);
                predicates.add(cb.equal(tagJoin.get("id"), tagId));
            }

            if (dueFrom != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("dueDate"), dueFrom));
            }

            if (dueTo != null) {
                predicates.add(cb.lessThan(root.get("dueDate"), dueTo));
            }

            if (query != null && query.getResultType() != Long.class && order == ItemOrder.PRIORITY_DESC) {
                var priorityRank = cb.selectCase()
                    .when(cb.equal(root.get("priority"), Priority.HIGH), 0)
                    .when(cb.equal(root.get("priority"), Priority.NORMAL), 1)
                    .otherwise(2);
                query.orderBy(
                    cb.asc(priorityRank),
                    cb.desc(root.get("createdAt"))
                );
            }

            return cb.and(predicates.toArray(Predicate[]::new));
        };
    }

    private Pageable orderedPageable(Pageable pageable, ItemOrder order) {
        Sort sort = switch (order) {
            case DUE_ASC -> Sort.by(
                Sort.Order.asc("dueDate").nullsLast(),
                Sort.Order.desc("createdAt")
            );
            case PRIORITY_DESC -> Sort.unsorted();
            case CREATED_DESC -> Sort.by(Sort.Order.desc("createdAt"));
        };

        return PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), sort);
    }
}
