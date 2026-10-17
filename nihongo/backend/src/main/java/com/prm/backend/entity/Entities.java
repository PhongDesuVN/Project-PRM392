package com.prm.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Cac entity dung chung gom trong mot file.
 * Entity cua feature moi them vao day duoi dang class long.
 */
public final class Entities {

    private Entities() {
    }

    @Entity
    @Table(name = "users")
    public static class User {

        public enum Role {
            user, admin, moderator
        }

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Integer id;

        @Column(nullable = false, unique = true, length = 255)
        private String email;

        @Column(name = "password_hash", length = 255)
        private String passwordHash;

        @Column(name = "full_name", length = 100)
        private String fullName;

        @Column(name = "avatar_url", length = 500)
        private String avatarUrl;

        @Enumerated(EnumType.STRING)
        @Column(columnDefinition = "enum('user','admin','moderator')")
        private Role role = Role.user;

        @Column(name = "created_at", insertable = false, updatable = false)
        private LocalDateTime createdAt;

        public User() {
        }

        // --- Getters & Setters ---
        public Integer getId() {
            return id;
        }

        public void setId(Integer id) {
            this.id = id;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getPasswordHash() {
            return passwordHash;
        }

        public void setPasswordHash(String passwordHash) {
            this.passwordHash = passwordHash;
        }

        public String getFullName() {
            return fullName;
        }

        public void setFullName(String fullName) {
            this.fullName = fullName;
        }

        public String getAvatarUrl() {
            return avatarUrl;
        }

        public void setAvatarUrl(String avatarUrl) {
            this.avatarUrl = avatarUrl;
        }

        public Role getRole() {
            return role;
        }

        public void setRole(Role role) {
            this.role = role;
        }

        public LocalDateTime getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
        }
    }

    /** Token quen mat khau. Luu dang hash, DB khong giu ban ro. */
    @Entity
    @Table(name = "password_reset_tokens")
    public static class ResetToken {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Integer id;

        @ManyToOne(fetch = FetchType.LAZY, optional = false)
        @JoinColumn(name = "user_id", nullable = false)
        private User user;

        @Column(name = "token_hash", nullable = false, length = 255)
        private String tokenHash;

        @Column(name = "expires_at", nullable = false)
        private LocalDateTime expiresAt;

        @Column(name = "used_at")
        private LocalDateTime usedAt;

        @Column(name = "created_at", insertable = false, updatable = false)
        private LocalDateTime createdAt;

        public ResetToken() {
        }

        public boolean isUsable(LocalDateTime now) {
            return usedAt == null && expiresAt.isAfter(now);
        }

        // --- Getters & Setters ---
        public Integer getId() {
            return id;
        }

        public void setId(Integer id) {
            this.id = id;
        }

        public User getUser() {
            return user;
        }

        public void setUser(User user) {
            this.user = user;
        }

        public String getTokenHash() {
            return tokenHash;
        }

        public void setTokenHash(String tokenHash) {
            this.tokenHash = tokenHash;
        }

        public LocalDateTime getExpiresAt() {
            return expiresAt;
        }

        public void setExpiresAt(LocalDateTime expiresAt) {
            this.expiresAt = expiresAt;
        }

        public LocalDateTime getUsedAt() {
            return usedAt;
        }

        public void setUsedAt(LocalDateTime usedAt) {
            this.usedAt = usedAt;
        }

        public LocalDateTime getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
        }
    }
}