package com.fnsi.cloudconverter.auth.model;

public record RefreshResponse(
        String accessToken,
        long expiresIn,
        String tokenType
) {
    public static RefreshResponse of(String accessToken, long expiresIn) {
        return new RefreshResponse(accessToken, expiresIn, "Bearer");
    }
}
