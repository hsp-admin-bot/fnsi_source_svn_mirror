package com.fnsi.cloudconverter.auth.model;

import jakarta.validation.constraints.NotBlank;

/**
 * ログインリクエスト
 * 在線本番 DB の mst_user_authentication テーブルで認証する
 * facility_cd + disp_user_id の複合キーでユーザーを特定
 */
public record LoginRequest(
        @NotBlank String facilityCd,
        @NotBlank String dispUserId,
        @NotBlank String password
) {}
