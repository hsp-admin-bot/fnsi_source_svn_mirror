package jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.job;

import lombok.Data;

/**
 * 職種の権限変更時にユーザの権限を更新するためのリクエスト詳細
 */
@Data
public class MstJobRequest {

    /**
     * 職種コード
     */
    public Long jobCd;
    /**
     * 許可機能一覧
     */
    public String defaultAuthorizedAuthorities;
    /**
     * デフォルトメニュー設定
     */
    public String defaultMenuSettings;
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
    /**
     * 施設コード
     */
    public String facilityCd;
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
    /**
     * デフォルト表示設定
     */
    public String defaultDispSettings;
    /**
     * デフォルト通知設定
     */
    public String defaultNotificationSettings;
}

