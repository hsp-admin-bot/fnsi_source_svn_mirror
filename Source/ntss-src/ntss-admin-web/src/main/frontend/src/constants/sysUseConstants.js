/**
 * システム利用設定用定数
 */

// システム利用設定別ページ名称セット
// [0]は想定外エラー時のデフォルトページ名
export const TITLE = {
    0: "日機装"
    , 1: "日機装 ReMS"
    , 2: "日機装 FutureNetWeb⁺Si"
    , 3: "日機装 FutureNetWeb⁺Si×ReMS"
};

// システム利用設定(system_use_setting)
export const SYS_USE_TYPE = {
    REMS_ONLY: "1",
    FNSI_ONLY: "2",
    REMS_AND_FNSI: "3"
};

// マスタ一覧表示:
// system_use_dispとsystem_use_settingの組み合わせ
export const SYS_USE_DISP = {
    REMS_ONLY: ["1","3"],
    FNSI_ONLY:  ["2","3"],
    REMS_AND_FNSI:  ["1","2","3"]
};

// システム利用設定別faviconセット
// [0]は想定外エラー時のデフォルトのfavicon
export const FAVICON_PATH = {
    0: "img/login/NIKKISO.ico"
    , 1: "img/login/NIKKISO.ico"  // ReMS
    , 2: "img/login/favicon.ico"  // FNSi
    , 3: "img/login/favicon.ico"  // FNSi＋ReMS
};
