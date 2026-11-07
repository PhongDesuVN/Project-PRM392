package com.prm.backend.service;

import com.prm.backend.dto.auth.AuthDtos.*;
import com.prm.backend.entity.Entities.ResetToken;
import com.prm.backend.entity.Entities.User;
import com.prm.backend.exception.GlobalExceptionHandler.BusinessException;
import com.prm.backend.repository.ResetTokenRepository;
import com.prm.backend.repository.UserRepository;
import com.prm.backend.security.SecurityConfig.JwtProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HexFormat;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private static final String INVALID_CREDENTIALS = "Email hoặc mật khẩu không đúng";
    private static final String INVALID_TOKEN = "Mã xác nhận không hợp lệ hoặc đã hết hạn";

    private final UserRepository userRepository;
    private final ResetTokenRepository resetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider tokenProvider;
    private final ObjectProvider<JavaMailSender> mailSenderProvider;
    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.password-reset.expiration-minutes:15}")
    private long resetExpirationMinutes;

    /** Khi true, /auth/forgot-password tra kem token trong response (chi dung cho dev). */
    @Value("${app.password-reset.expose-token:false}")
    private boolean exposeResetToken;

    @Value("${spring.mail.username:}")
    private String mailUsername;

    // Constructor thuần thay thế Lombok @RequiredArgsConstructor
    public AuthService(UserRepository userRepository,
                       ResetTokenRepository resetTokenRepository,
                       PasswordEncoder passwordEncoder,
                       JwtProvider tokenProvider,
                       ObjectProvider<JavaMailSender> mailSenderProvider) {
        this.userRepository = userRepository;
        this.resetTokenRepository = resetTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
        this.mailSenderProvider = mailSenderProvider;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = normalizeEmail(request.email());

        if (userRepository.existsByEmail(email)) {
            throw new BusinessException("Email đã được sử dụng");
        }

        User user = new User();
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setFullName(request.fullName().trim());
        user.setRole(User.Role.user);

        return toAuthResponse(userRepository.save(user));
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(normalizeEmail(request.email()))
                .orElseThrow(() -> new BusinessException(INVALID_CREDENTIALS));

        // password_hash co the null voi tai khoan tao qua social login
        if (user.getPasswordHash() == null
                || !passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new BusinessException(INVALID_CREDENTIALS);
        }

        return toAuthResponse(user);
    }

    @Transactional
    public AuthResponse googleLogin(GoogleLoginRequest request) {
        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(request.idToken());
            String email = normalizeEmail(decodedToken.getEmail());
            String name = decodedToken.getName();
            String picture = decodedToken.getPicture();

            User user = userRepository.findByEmail(email).orElseGet(() -> {
                User newUser = new User();
                newUser.setEmail(email);
                newUser.setFullName(name != null && !name.isBlank() ? name.trim() : email);
                newUser.setAvatarUrl(picture);
                newUser.setRole(User.Role.user);
                return userRepository.save(newUser);
            });

            boolean updated = false;
            if ((user.getFullName() == null || user.getFullName().isBlank()) && name != null && !name.isBlank()) {
                user.setFullName(name.trim());
                updated = true;
            }
            if (user.getAvatarUrl() == null && picture != null) {
                user.setAvatarUrl(picture);
                updated = true;
            }
            if (updated) {
                user = userRepository.save(user);
            }

            return toAuthResponse(user);
        } catch (FirebaseAuthException e) {
            log.error("Firebase verifyIdToken failed: {}", e.getMessage());
            throw new BusinessException("Xác thực Google không hợp lệ: " + e.getMessage());
        } catch (Exception e) {
            log.error("Google login error: {}", e.getMessage(), e);
            throw new BusinessException("Đăng nhập Google thất bại: " + e.getMessage());
        }
    }

    /**
     * Phat token dat lai mat khau. Luon tra ve cung mot message du email
     * co ton tai hay khong, tranh lo danh sach user.
     */
    @Transactional
    public MessageResponse forgotPassword(ForgotPasswordRequest request) {
        String email = normalizeEmail(request.email());
        String plainToken = null;

        var userOpt = userRepository.findByEmail(email);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            resetTokenRepository.invalidateActiveTokens(user.getId());

            plainToken = generateRawToken();

            ResetToken token = new ResetToken();
            token.setUser(user);
            token.setTokenHash(sha256(plainToken));
            token.setExpiresAt(LocalDateTime.now().plusMinutes(resetExpirationMinutes));
            resetTokenRepository.save(token);

            log.info("==================================================");
            log.info("MA OTP DAT LAI MAT KHAU CHO {}: {}", email, plainToken);
            log.info("==================================================");

            sendResetOtpEmail(email, user.getFullName(), plainToken);
        }

        String message = "Mã xác nhận OTP 6 số đã được gửi về email của bạn.";
        if (exposeResetToken && plainToken != null) {
            message = message + " [dev] token=" + plainToken;
        }
        return new MessageResponse(message);
    }

    private void sendResetOtpEmail(String toEmail, String fullName, String otpCode) {
        JavaMailSender mailSender = mailSenderProvider.getIfAvailable();
        if (mailSender == null || mailUsername == null || mailUsername.isBlank()) {
            log.warn("Chua cau hinh spring.mail.username/password trong application.properties. Su dung ma OTP trong log console: {}", otpCode);
            return;
        }

        try {
            SimpleMailMessage mail = new SimpleMailMessage();
            mail.setFrom(mailUsername);
            mail.setTo(toEmail);
            mail.setSubject("[Nihongo App] Mã xác nhận đặt lại mật khẩu của bạn");
            String displayName = (fullName != null && !fullName.isBlank()) ? fullName : toEmail;
            mail.setText(
                    "Xin chào " + displayName + ",\n\n"
                    + "Bạn vừa yêu cầu đặt lại mật khẩu trên ứng dụng học tiếng Nhật Nihongo.\n"
                    + "Mã xác nhận OTP (6 chữ số) của bạn là:\n\n"
                    + "    " + otpCode + "\n\n"
                    + "Mã này có hiệu lực trong vòng " + resetExpirationMinutes + " phút.\n"
                    + "Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.\n\n"
                    + "Trân trọng,\nĐội ngũ Nihongo App"
            );
            mailSender.send(mail);
            log.info("Da gui email OTP thanh cong toi {}", toEmail);
        } catch (Exception ex) {
            log.error("Loi khi gui email OTP toi {}: {}", toEmail, ex.getMessage());
        }
    }

    @Transactional
    public MessageResponse resetPassword(ResetPasswordRequest request) {
        String cleanToken = request.token().trim();
        ResetToken token = resetTokenRepository.findByTokenHash(sha256(cleanToken))
                .orElseThrow(() -> new BusinessException(INVALID_TOKEN));

        if (!token.isUsable(LocalDateTime.now())) {
            throw new BusinessException(INVALID_TOKEN);
        }

        User user = token.getUser();
        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);

        token.setUsedAt(LocalDateTime.now());
        resetTokenRepository.save(token);

        return new MessageResponse("Đặt lại mật khẩu thành công");
    }

    private AuthResponse toAuthResponse(User user) {
        String jwt = tokenProvider.generateToken(user.getId(), user.getEmail(), user.getRole().name());
        return new AuthResponse(jwt, user.getId(), user.getEmail(), user.getFullName(), user.getRole().name());
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase();
    }

    /**
     * Sinh mã OTP 6 chữ số ngẫu nhiên (từ 100000 đến 999999).
     */
    private String generateRawToken() {
        int otp = 100000 + secureRandom.nextInt(900000);
        return String.format("%06d", otp);
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 not available", ex);
        }
    }
}