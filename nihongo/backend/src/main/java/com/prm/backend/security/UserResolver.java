package com.prm.backend.security;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;

@Component
public class UserResolver {

    private static final Logger log = LoggerFactory.getLogger(UserResolver.class);
    private final JdbcTemplate jdbcTemplate;

    public UserResolver(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Integer resolveOptionalUserId(HttpServletRequest request) {
        if (request == null) return null;

        // 1. Kiểm tra JWT token qua SecurityContextHolder
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            String email = auth.getName();
            if (email != null && !email.isBlank() && !"khách".equalsIgnoreCase(email.trim()) && !"guest".equalsIgnoreCase(email.trim())) {
                return getOrCreateUserId(email, email);
            }
        }

        // 2. Kiểm tra header X-User-Email
        String emailHeader = request.getHeader("X-User-Email");
        if (emailHeader != null && !emailHeader.isBlank() && !"khách".equalsIgnoreCase(emailHeader.trim()) && !"guest".equalsIgnoreCase(emailHeader.trim())) {
            return getOrCreateUserId(emailHeader, emailHeader);
        }

        // 3. Kiểm tra header X-User-Id
        String userIdHeader = request.getHeader("X-User-Id");
        if (userIdHeader != null && !userIdHeader.isBlank()) {
            try {
                int parsed = Integer.parseInt(userIdHeader.trim());
                if (parsed > 0) return parsed;
            } catch (NumberFormatException ignored) {
            }
        }

        // 4. Kiểm tra tham số request param
        String emailParam = request.getParameter("email");
        if (emailParam != null && !emailParam.isBlank() && !"khách".equalsIgnoreCase(emailParam.trim()) && !"guest".equalsIgnoreCase(emailParam.trim())) {
            return getOrCreateUserId(emailParam, emailParam);
        }

        return null;
    }

    public int resolveUserId(HttpServletRequest request) {
        Integer id = resolveOptionalUserId(request);
        return id != null ? id : 1;
    }

    public int getOrCreateUserId(String email, String fullName) {
        if (email == null || email.isBlank()) {
            return 1;
        }
        final String cleanEmail = email.trim().toLowerCase();
        try {
            List<Integer> list = jdbcTemplate.query(
                    "SELECT id FROM users WHERE LOWER(email) = ?",
                    (rs, rowNum) -> rs.getInt("id"),
                    cleanEmail);
            if (!list.isEmpty()) {
                return list.get(0);
            }

            KeyHolder keyHolder = new GeneratedKeyHolder();
            final String name = (fullName != null && !fullName.isBlank()) ? fullName.trim() : cleanEmail;
            jdbcTemplate.update(con -> {
                PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO users (email, full_name, role) VALUES (?, ?, 'user')",
                        Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, cleanEmail);
                ps.setString(2, name);
                return ps;
            }, keyHolder);

            Number key = keyHolder.getKey();
            return key != null ? key.intValue() : 1;
        } catch (Exception e) {
            log.warn("Lỗi getOrCreateUserId cho {}: {}", cleanEmail, e.getMessage());
            return 1;
        }
    }
}

