# PRM Backend â€” Auth API

Backend Spring Boot cho app há»c tiáº¿ng Nháº­t. Pháº¡m vi hiá»‡n táº¡i: **Ä‘Äƒng kÃ½, Ä‘Äƒng nháº­p, quÃªn máº­t kháº©u**.

## MÃ´i trÆ°á»ng Ä‘Ã£ xÃ¡c minh

| ThÃ nh pháº§n | GiÃ¡ trá»‹ |
|---|---|
| MySQL | 8.0, `localhost:3306`, user `root`, database `PRM` |
| JDK | 21 táº¡i `C:\Users\Admin\Desktop\PRM\Project-PRM392\nihongo\tools\jdk\jdk-21.0.12.1+1` |
| Maven | 3.9.9 táº¡i `C:\Users\Admin\Desktop\PRM\Project-PRM392\nihongo\tools\apache-maven-3.9.9` |
| Server | `http://localhost:8080` |

MÃ¡y Ä‘ang cÃ i Java 27, nhÆ°ng Spring Boot 3.2 chÆ°a há»— trá»£ nÃªn project dÃ¹ng JDK 21 riÃªng. `run.bat` Ä‘Ã£ trá» `JAVA_HOME` sáºµn.

## Cháº¡y

```bat
run.bat
```

## Database

Module auth dÃ¹ng báº£ng `users` (cÃ³ sáºµn) vÃ  `password_reset_tokens` (Ä‘Ã£ táº¡o thÃªm):

```sql
-- src/main/resources/db/password_reset_tokens.sql
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reset_token_hash (token_hash),
    INDEX idx_reset_user (user_id, expires_at)
);
```

`ddl-auto=none` nÃªn Hibernate khÃ´ng tá»± sá»­a schema.

## Endpoints

### POST /auth/register

```json
{ "email": "a@example.com", "password": "matkhau123", "fullName": "Nguyen Van A" }
```

200:
```json
{ "token": "eyJ...", "userId": 1, "email": "a@example.com", "fullName": "Nguyen Van A", "role": "user" }
```

### POST /auth/login

```json
{ "email": "a@example.com", "password": "matkhau123" }
```

Tráº£ vá» cÃ¹ng dáº¡ng `AuthResponse`. Sai thÃ´ng tin â†’ 400 `"Email hoac mat khau khong dung"` (khÃ´ng phÃ¢n biá»‡t email sai hay máº­t kháº©u sai, trÃ¡nh dÃ² tÃ i khoáº£n).

### POST /auth/forgot-password

```json
{ "email": "a@example.com" }
```

LuÃ´n tráº£ 200 vá»›i cÃ¹ng má»™t message, ká»ƒ cáº£ email khÃ´ng tá»“n táº¡i:
```json
{ "message": "Neu email ton tai trong he thong, link dat lai mat khau da duoc gui." }
```

ChÆ°a cÃ³ email service, nÃªn token Ä‘Æ°á»£c ghi ra log. Khi `app.password-reset.expose-token=true` token cÅ©ng kÃ¨m trong message Ä‘á»ƒ test.

### POST /auth/reset-password

```json
{ "token": "<token tá»« bÆ°á»›c trÃªn>", "newPassword": "matkhaumoi456" }
```

200 â†’ `{ "message": "Dat lai mat khau thanh cong" }`. Token háº¿t háº¡n, sai, hoáº·c Ä‘Ã£ dÃ¹ng â†’ 400.

## Báº£o máº­t

- Máº­t kháº©u hash báº±ng BCrypt.
- Token reset sinh tá»« `SecureRandom` 32 byte, lÆ°u dÆ°á»›i dáº¡ng SHA-256 â€” DB khÃ´ng giá»¯ báº£n rÃµ.
- Token dÃ¹ng má»™t láº§n (`used_at`), hiá»‡u lá»±c 30 phÃºt, phÃ¡t token má»›i sáº½ vÃ´ hiá»‡u token cÅ©.
- `/auth/**` public, cÃ¡c route khÃ¡c yÃªu cáº§u JWT. Session stateless.

Cáº§n siáº¿t trÆ°á»›c khi deploy:
- `jwt.secret` vÃ  máº­t kháº©u DB Ä‘ang Ä‘á»ƒ plaintext trong `application.properties` â†’ chuyá»ƒn sang biáº¿n mÃ´i trÆ°á»ng.
- `app.password-reset.expose-token=true` â†’ Ä‘áº·t `false` vÃ  gá»­i token qua email tháº­t.
- CORS Ä‘ang má»Ÿ cho `localhost:*` â†’ Ä‘á»•i sang domain tháº­t.
- ChÆ°a cÃ³ rate limit trÃªn `/auth/login` vÃ  `/auth/forgot-password`.

## Cáº¥u trÃºc

```
src/main/java/com/prm/backend/
â”œâ”€â”€ BackendApplication.java
â”œâ”€â”€ controller/AuthController.java
â”œâ”€â”€ service/AuthService.java
â”œâ”€â”€ repository/{UserRepository, PasswordResetTokenRepository}.java
â”œâ”€â”€ entity/{User, PasswordResetToken}.java
â”œâ”€â”€ dto/auth/{RegisterRequest, LoginRequest, ForgotPasswordRequest,
â”‚             ResetPasswordRequest, AuthResponse, MessageResponse}.java
â”œâ”€â”€ security/{SecurityConfig, JwtTokenProvider, JwtAuthenticationFilter}.java
â””â”€â”€ exception/{BusinessException, GlobalExceptionHandler}.java
```
