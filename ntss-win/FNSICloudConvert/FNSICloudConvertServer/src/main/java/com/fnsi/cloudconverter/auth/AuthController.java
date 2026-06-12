package com.fnsi.cloudconverter.auth;

import com.fnsi.cloudconverter.auth.model.LoginRequest;
import com.fnsi.cloudconverter.auth.model.LoginResponse;
import com.fnsi.cloudconverter.auth.model.RefreshRequest;
import com.fnsi.cloudconverter.auth.model.RefreshResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 認証 API
 * POST /auth/login   — ログイン (02_api.md § 1)
 * POST /auth/refresh — トークン更新 (02_api.md § 2)
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<RefreshResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        return ResponseEntity.ok(authService.refresh(request));
    }
}
