package com.prm.backend.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Toan bo DTO cua luong auth gom trong mot file.
 * Dung record nen khong can Lombok getter/setter, Jackson tu map theo ten component.
 */
public final class AuthDtos {

    private AuthDtos() {
    }

    // ----- Request -----

    public record RegisterRequest(

            @NotBlank(message = "Email không được để trống")
            @Email(message = "Email không hợp lệ")
            @Size(max = 255, message = "Email tối đa 255 ký tự")
            String email,

            @NotBlank(message = "Mật khẩu không được để trống")
            @Size(min = 6, max = 72, message = "Mật khẩu từ 6 đến 72 ký tự")
            String password,

            @NotBlank(message = "Họ tên không được để trống")
            @Size(max = 100, message = "Họ tên tối đa 100 ký tự")
            String fullName
    ) {
    }

    public record LoginRequest(

            @NotBlank(message = "Email không được để trống")
            @Email(message = "Email không hợp lệ")
            String email,

            @NotBlank(message = "Mật khẩu không được để trống")
            String password
    ) {
    }

    public record ForgotPasswordRequest(

            @NotBlank(message = "Email không được để trống")
            @Email(message = "Email không hợp lệ")
            String email
    ) {
    }

    public record ResetPasswordRequest(

            @NotBlank(message = "Mã đặt lại không được để trống")
            String token,

            @NotBlank(message = "Mật khẩu mới không được để trống")
            @Size(min = 6, max = 72, message = "Mật khẩu từ 6 đến 72 ký tự")
            String newPassword
    ) {
    }

    public record GoogleLoginRequest(
            @NotBlank(message = "idToken không được để trống")
            String idToken
    ) {
    }

    // ----- Response -----

    public record AuthResponse(
            String token,
            Integer userId,
            String email,
            String fullName,
            String role
    ) {
    }

    public record MessageResponse(String message) {
    }
}
