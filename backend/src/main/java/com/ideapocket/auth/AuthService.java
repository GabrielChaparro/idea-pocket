package com.ideapocket.auth;

import com.ideapocket.auth.AuthDtos.AuthResponse;
import com.ideapocket.auth.AuthDtos.LoginRequest;
import com.ideapocket.auth.AuthDtos.RegisterRequest;
import com.ideapocket.auth.AuthDtos.UserResponse;
import com.ideapocket.common.ApiException;
import com.ideapocket.security.JwtService;
import com.ideapocket.user.User;
import com.ideapocket.user.UserRepository;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {
    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository users, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (users.existsByEmailIgnoreCase(request.email())) {
            throw new ApiException(HttpStatus.CONFLICT, "Email already registered");
        }
        User user = users.save(new User(
            request.email().trim().toLowerCase(),
            passwordEncoder.encode(request.password()),
            request.name()
        ));
        return response(user);
    }

    public AuthResponse login(LoginRequest request) {
        User user = users.findByEmailIgnoreCase(request.email())
            .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        return response(user);
    }

    public UserResponse me(UUID userId) {
        User user = users.findById(userId).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found"));
        return new UserResponse(user.getId(), user.getEmail(), user.getName());
    }

    private AuthResponse response(User user) {
        return new AuthResponse(jwtService.createToken(user), new UserResponse(user.getId(), user.getEmail(), user.getName()));
    }
}

