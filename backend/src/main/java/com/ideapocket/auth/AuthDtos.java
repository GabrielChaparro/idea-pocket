package com.ideapocket.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.UUID;

public final class AuthDtos {
    private AuthDtos() {
    }

    public record RegisterRequest(
        @Email @NotBlank String email,
        @NotBlank @Size(min = 8, message = "debe tener al menos 8 caracteres") String password,
        String name
    ) {
    }

    public record LoginRequest(
        @Email @NotBlank String email,
        @NotBlank String password
    ) {
    }

    public record AuthResponse(
        String token,
        UserResponse user
    ) {
    }

    public record UserResponse(
        UUID id,
        String email,
        String name
    ) {
    }
}
