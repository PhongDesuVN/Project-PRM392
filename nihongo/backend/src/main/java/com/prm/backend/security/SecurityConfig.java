package com.prm.backend.security;

import com.prm.backend.repository.Repositories;
import com.prm.backend.repository.UserRepository;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.*;
import org.springframework.stereotype.Component;
import org.springframework.web.cors.*;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.crypto.SecretKey;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Cau hinh security, phat/kiem JWT va filter doc token.
 * Gom trong mot file vi ba phan nay chi dung lan nhau.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtFilter jwtFilter;

    // Constructor thuần thay thế Lombok @RequiredArgsConstructor
    public SecurityConfig(JwtFilter jwtFilter) {
        this.jwtFilter = jwtFilter;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/auth/**").permitAll()
                        .anyRequest().authenticated())
                .exceptionHandling(e -> e
                        .authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)))
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * CORS mo cho localhost de Flutter dev goi duoc API.
     * Can that chat lai domain that truoc khi deploy.
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(List.of("http://localhost:*", "http://127.0.0.1:*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /** Phat va doc JWT. */
    @Component
    public static class JwtProvider {

        private final SecretKey key;
        private final long expirationMs;

        public JwtProvider(@Value("${jwt.secret}") String secret,
                @Value("${jwt.expiration}") long expirationMs) {
            this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
            this.expirationMs = expirationMs;
        }

        public String generateToken(Integer userId, String email, String role) {
            Date now = new Date();
            return Jwts.builder()
                    .subject(email)
                    .claim("userId", userId)
                    .claim("role", role)
                    .issuedAt(now)
                    .expiration(new Date(now.getTime() + expirationMs))
                    .signWith(key)
                    .compact();
        }

        public String getEmail(String token) {
            return parse(token).getSubject();
        }

        public boolean isValid(String token) {
            try {
                parse(token);
                return true;
            } catch (JwtException | IllegalArgumentException ex) {
                return false;
            }
        }

        private Claims parse(String token) {
            return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
        }
    }

    /** Doc header Authorization, nap user vao SecurityContext neu token hop le. */
    @Component
    public static class JwtFilter extends OncePerRequestFilter {

        private final JwtProvider jwtProvider;
        private final UserRepository users;

        // Constructor thuần thay thế Lombok @RequiredArgsConstructor
        public JwtFilter(JwtProvider jwtProvider, UserRepository users) {
            this.jwtProvider = jwtProvider;
            this.users = users;
        }

        @Override
        protected void doFilterInternal(@NonNull HttpServletRequest request,
                @NonNull HttpServletResponse response,
                @NonNull FilterChain chain)
                throws ServletException, IOException {

            String header = request.getHeader("Authorization");

            if (header != null && header.startsWith("Bearer ")
                    && SecurityContextHolder.getContext().getAuthentication() == null) {

                String token = header.substring(7);

                if (jwtProvider.isValid(token)) {
                    users.findByEmail(jwtProvider.getEmail(token)).ifPresent(user -> {
                        var authorities = List.of(new SimpleGrantedAuthority(
                                "ROLE_" + user.getRole().name().toUpperCase()));
                        var auth = new UsernamePasswordAuthenticationToken(
                                user.getEmail(), null, authorities);
                        SecurityContextHolder.getContext().setAuthentication(auth);
                    });
                }
            }

            chain.doFilter(request, response);
        }
    }
}