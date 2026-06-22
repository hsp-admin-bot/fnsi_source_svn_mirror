using System;
using System.Collections.Generic;
using System.Text;

namespace CSILib
{
    /// <summary>
    /// シーエスアイ連携共通定数定義
    /// </summary>
    class CSIDefine
    {
        #region 共通定数

        /// <summary>
        /// CSI側処理区分「新規」
        /// </summary>
        public const string PROCDIV_INSERT = "1";

        /// <summary>
        /// CSI側処理区分「修正」
        /// </summary>
        public const string PROCDIV_MODIFY = "2";
        
        /// <summary>
        /// CSI側処理区分「削除」
        /// </summary>
        public const string PROCDIV_DELETE = "3";

        /// <summary>
        /// CSI側処理区分「進捗変更」
        /// </summary>
        public const string PROCDIV_MODSTATUS = "6";

        /// <summary>
        /// CSI側処理区分「情報更新」
        /// </summary>
        public const string PROCDIV_RENEWINFO = "9";

        /// <summary>
        /// FNW側長さ定義
        /// 表示用患者ID
        /// 患者ID
        /// 氏名
        /// 氏名フリガナ
        /// </summary>
        public const int LEN_DISP_PATID = 12;
        public const int LEN_PATID = 12;
        public const int LEN_NAME = 40;
        public const int LEN_NAME_KANA = 40;

        #endregion


        #region 個別設定値セクション名定数

        /// <summary>
        /// 共通設定
        /// </summary>
        public const string SYS_DIV_UNIQUE = "1";
        public const string SYS_SECT_COMMON = "CSI_COMMON";

        /// <summary>
        /// 透析予約送信
        /// </summary>
        public const string SYS_SECT_DIALYSISSCHESND = "CSI_DIALYSISSCHESND";

        /// <summary>
        /// 患者情報連携
        /// </summary>
        public const string SYS_SECT_PATIENTRCV = "CSI_PATIENTRCV";

        /// <summary>
        /// 透析実績送信
        /// </summary>
        public const string SYS_SECT_DIALYSISSND = "CSI_DIALYSISSND";

        /// <summary>
        /// 検査結果受信
        /// </summary>
        public const string SYS_SECT_EXAMINRCV = "CSI_EXAMINRCV";

        #endregion


        #region 個別設定値キー名定数

        /// <summary>
        /// 患者情報連携
        /// 定期更新時刻
        /// イベント通知DLL名
        /// </summary>
        public const string SYS_KEY_UPDATE_TIME = "PATIENTRCV_UPDATE_TIME";
        public const string SYS_KEY_SEND_TO_DLL_NAME = "PATIENTRCV_DLL_NAME";

        
        
        /// <summary>
        /// 科コード
        /// </summary>
        public const string SYS_KEY_DEPTCODE = "DEPTCODE";
        
        /// <summary>
        /// 予約科目コード
        /// </summary>
        public const string SYS_KEY_APPCODE = "APPCODE";
        
        /// <summary>
        /// 予約行為コード
        /// </summary>
        public const string SYS_KEY_APPACTIONCODE = "APPACTIONCODE";

        /// <summary>
        /// 入力端末名
        /// </summary>
        public const string SYS_KEY_TERMINALNAME = "TERMINALNAME";



        #endregion

    }
}
