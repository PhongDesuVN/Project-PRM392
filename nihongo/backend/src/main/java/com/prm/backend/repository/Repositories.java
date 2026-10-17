package com.prm.backend.repository;

import com.prm.backend.entity.Entities.ResetToken;
import com.prm.backend.entity.Entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Tat ca repository gom trong mot file.
 */
public final class Repositories {

    private Repositories() {
    }

    @Repository
    public interface Users extends JpaRepository<User, Integer> {

        Optional<User> findByEmail(String email);

        boolean existsByEmail(String email);
    }

    @Repository
    public interface ResetTokens extends JpaRepository<ResetToken, Integer> {

        Optional<ResetToken> findByTokenHash(String tokenHash);

        @Modifying
        @Query("UPDATE Entities$ResetToken t SET t.usedAt = CURRENT_TIMESTAMP WHERE t.user.id = :userId AND t.usedAt IS NULL")
        void invalidateActiveTokens(@Param("userId") Integer userId);
    }
}