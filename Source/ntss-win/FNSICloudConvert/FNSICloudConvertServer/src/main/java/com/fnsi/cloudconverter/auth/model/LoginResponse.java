package com.fnsi.cloudconverter.auth.model;

public record LoginResponse(
        String accessToken,
        String refreshToken,
        long expiresIn,
        String tokenType
) {
    public static LoginResponse of(String accessToken, String refreshToken, long expiresIn) {
        return new LoginResponse(accessToken, refreshToken, expiresIn, "Bearer");
    }
}
