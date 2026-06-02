package com.ideapocket;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Instant;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ApiIntegrationTest {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void healthIsPublicAndReportsDatabase() throws Exception {
        mockMvc.perform(get("/api/health"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("UP"))
            .andExpect(jsonPath("$.application").value("ideapocket-api"))
            .andExpect(jsonPath("$.database").value("UP"))
            .andExpect(jsonPath("$.time").isString());
    }

    @Test
    void registerLoginAndRejectDuplicateEmail() throws Exception {
        String email = uniqueEmail("auth");

        register(email, "password123")
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").isString())
            .andExpect(jsonPath("$.user.email").value(email));

        register(email, "password123")
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.message").value("Email already registered"));

        login(email, "password123")
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").isString());

        login(email, "wrong-password")
            .andExpect(status().isUnauthorized())
            .andExpect(jsonPath("$.message").value("Invalid credentials"));
    }

    @Test
    void registerRejectsShortPasswordWithFriendlyMessage() throws Exception {
        register(uniqueEmail("short-password"), "short")
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("La contraseña debe tener al menos 8 caracteres"));
    }

    @Test
    void createListUpdateCompleteReopenAndDeleteItem() throws Exception {
        String token = registerAndToken(uniqueEmail("items"));

        String createResponse = mockMvc.perform(post("/api/items")
                .header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "type": "TASK",
                      "title": "Comprar libreta",
                      "content": "Comprar una libreta para capturas rápidas",
                      "priority": "HIGH",
                      "tagIds": []
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.type").value("TASK"))
            .andExpect(jsonPath("$.status").value("ACTIVE"))
            .andExpect(jsonPath("$.priority").value("HIGH"))
            .andReturn()
            .getResponse()
            .getContentAsString();

        String itemId = objectMapper.readTree(createResponse).get("id").asText();

        mockMvc.perform(get("/api/items")
                .header("Authorization", bearer(token))
                .param("search", "libreta"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content[0].id").value(itemId));

        mockMvc.perform(put("/api/items/{id}", itemId)
                .header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "type": "NOTE",
                      "title": "Libreta actualizada",
                      "content": "Nueva descripción",
                      "priority": "NORMAL",
                      "tagIds": []
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.type").value("NOTE"))
            .andExpect(jsonPath("$.title").value("Libreta actualizada"));

        mockMvc.perform(patch("/api/items/{id}/complete", itemId)
                .header("Authorization", bearer(token)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("COMPLETED"));

        mockMvc.perform(patch("/api/items/{id}/reopen", itemId)
                .header("Authorization", bearer(token)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("ACTIVE"));

        mockMvc.perform(delete("/api/items/{id}", itemId)
                .header("Authorization", bearer(token)))
            .andExpect(status().isNoContent());

        mockMvc.perform(get("/api/items/{id}", itemId)
                .header("Authorization", bearer(token)))
            .andExpect(status().isNotFound());
    }

    @Test
    void userCannotReadAnotherUsersItem() throws Exception {
        String ownerToken = registerAndToken(uniqueEmail("owner"));
        String otherToken = registerAndToken(uniqueEmail("other"));

        String createResponse = mockMvc.perform(post("/api/items")
                .header("Authorization", bearer(ownerToken))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "type": "IDEA",
                      "title": "Privada",
                      "content": "Idea privada",
                      "priority": "NORMAL",
                      "tagIds": []
                    }
                    """))
            .andExpect(status().isCreated())
            .andReturn()
            .getResponse()
            .getContentAsString();

        String itemId = objectMapper.readTree(createResponse).get("id").asText();

        mockMvc.perform(get("/api/items/{id}", itemId)
                .header("Authorization", bearer(otherToken)))
            .andExpect(status().isNotFound());
    }

    @Test
    void createTagRejectDuplicateAndFilterItemsByTag() throws Exception {
        String token = registerAndToken(uniqueEmail("tags"));

        String tagResponse = mockMvc.perform(post("/api/tags")
                .header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "name": "Proyecto",
                      "color": null
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("Proyecto"))
            .andReturn()
            .getResponse()
            .getContentAsString();

        String tagId = objectMapper.readTree(tagResponse).get("id").asText();

        mockMvc.perform(post("/api/tags")
                .header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "name": "proyecto",
                      "color": null
                    }
                    """))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.message").value("Tag already exists"));

        mockMvc.perform(post("/api/items")
                .header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "type": "IDEA",
                      "title": "Idea con etiqueta",
                      "content": "Contenido",
                      "priority": "NORMAL",
                      "tagIds": ["%s"]
                    }
                    """.formatted(tagId)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.tags[0].id").value(tagId));

        mockMvc.perform(get("/api/items")
                .header("Authorization", bearer(token))
                .param("tagId", tagId))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content[0].tags[0].name").value("Proyecto"));
    }

    @Test
    void filterItemsByDueDateRange() throws Exception {
        String token = registerAndToken(uniqueEmail("due"));
        Instant dueDate = Instant.parse("2026-06-05T10:00:00Z");

        mockMvc.perform(post("/api/items")
                .header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "type": "TASK",
                      "title": "Tarea con fecha",
                      "content": "Contenido",
                      "priority": "NORMAL",
                      "dueDate": "%s",
                      "tagIds": []
                    }
                    """.formatted(dueDate)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.dueDate").value(containsString("2026-06-05T10:00:00")));

        mockMvc.perform(get("/api/items")
                .header("Authorization", bearer(token))
                .param("dueFrom", "2026-06-05T00:00:00Z")
                .param("dueTo", "2026-06-06T00:00:00Z"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content[0].title").value("Tarea con fecha"));

        mockMvc.perform(get("/api/items")
                .header("Authorization", bearer(token))
                .param("dueFrom", "2026-06-06T00:00:00Z"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").isEmpty());
    }

    @Test
    void orderItemsByPriority() throws Exception {
        String token = registerAndToken(uniqueEmail("priority"));

        createItem(token, "LOW", "Baja");
        createItem(token, "HIGH", "Alta");
        createItem(token, "NORMAL", "Normal");

        mockMvc.perform(get("/api/items")
                .header("Authorization", bearer(token))
                .param("order", "PRIORITY_DESC"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content[0].title").value("Alta"))
            .andExpect(jsonPath("$.content[1].title").value("Normal"))
            .andExpect(jsonPath("$.content[2].title").value("Baja"));
    }

    @Test
    void endpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/items"))
            .andExpect(status().isForbidden());
    }

    private org.springframework.test.web.servlet.ResultActions register(String email, String password) throws Exception {
        return mockMvc.perform(post("/api/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "email": "%s",
                  "password": "%s",
                  "name": "Test User"
                }
                """.formatted(email, password)));
    }

    private org.springframework.test.web.servlet.ResultActions login(String email, String password) throws Exception {
        return mockMvc.perform(post("/api/auth/login")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "email": "%s",
                  "password": "%s"
                }
                """.formatted(email, password)));
    }

    private String registerAndToken(String email) throws Exception {
        String body = register(email, "password123")
            .andExpect(status().isOk())
            .andReturn()
            .getResponse()
            .getContentAsString();
        JsonNode json = objectMapper.readTree(body);
        return json.get("token").asText();
    }

    private void createItem(String token, String priority, String title) throws Exception {
        mockMvc.perform(post("/api/items")
                .header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "type": "TASK",
                      "title": "%s",
                      "content": "Contenido",
                      "priority": "%s",
                      "tagIds": []
                    }
                    """.formatted(title, priority)))
            .andExpect(status().isCreated());
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private String uniqueEmail(String prefix) {
        return prefix + "-" + System.nanoTime() + "@example.com";
    }
}
