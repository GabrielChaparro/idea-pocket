package com.ideapocket.health;

import java.time.Instant;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/health")
public class HealthController {
    private final JdbcTemplate jdbcTemplate;
    private final String applicationName;

    public HealthController(JdbcTemplate jdbcTemplate, @Value("${spring.application.name}") String applicationName) {
        this.jdbcTemplate = jdbcTemplate;
        this.applicationName = applicationName;
    }

    @GetMapping
    Map<String, Object> health() {
        Integer result = jdbcTemplate.queryForObject("select 1", Integer.class);
        return Map.of(
            "status", "UP",
            "application", applicationName,
            "database", result != null && result == 1 ? "UP" : "DOWN",
            "time", Instant.now().toString()
        );
    }
}

