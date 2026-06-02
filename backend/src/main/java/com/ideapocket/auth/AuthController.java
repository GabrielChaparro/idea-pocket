package com.ideapocket.auth;

import com.ideapocket.auth.AuthDtos.AuthResponse;
import com.ideapocket.auth.AuthDtos.LoginRequest;
import com.ideapocket.auth.AuthDtos.RegisterRequest;
import com.ideapocket.auth.AuthDtos.UserResponse;
import com.ideapocket.security.AuthenticatedUser;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @GetMapping("/me")
    UserResponse me(Authentication authentication) {
        return authService.me(AuthenticatedUser.id(authentication));
    }
}

