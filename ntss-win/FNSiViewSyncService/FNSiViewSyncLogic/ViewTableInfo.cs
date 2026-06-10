using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FNSiViewSyncLogicLib
{
    /// <summary>
    /// XMLファイルの設定情報
    /// </summary>
    public class ViewTableInfo
    {
        /// <summary>
        /// VIEWテーブル名称（物理）
        /// </summary>
        public string TableName { get; set; }

        /// <summary>
        /// 表示用VIEWテーブル名
        /// </summary>
        public string DispName { get; set; }

        /// <summary>
        /// VIEWテーブル名称（論理）
        /// </summary>
        public string Desc { get; set; }

        /// <summary>
        /// 取得に必要なsys_data_setのsql_cd群
        /// </summary>
        public string SqlCd { get; set; }

        /// <summary>
        /// テーブル形態 0：全項目型　1:蓄積型
        /// </summary>
        public string Mode { get; set; }

        /// <summary>
        /// ファイル名
        /// </summary>
        public string Sqlfile { get; set; }

        /// <summary>
        /// 初回処理実行済フラグ（0;未実施　1:済み）
        /// </summary>
        public bool IsInit { get; set; }

        /// <summary>
        /// 起動時更新実行フラグ（0:実行しない　1:実行する）
        /// </summary>
        public bool OnceFlg { get; set; }

        /// <summary>
        /// 更新処理が動作するテーブル対象（0:対象外　1:対象（動かす））
        /// </summary>
        public bool IsEffect { get; set; }

        /// <summary>
        /// 取得期間　過去日方向値
        /// </summary>
        public int PastRangeTotal { get; set; }

        /// <summary>
        /// 取得期間　未来日方向値
        /// </summary>
        public int FutureRangeTotal { get; set; }

        /// <summary>
        /// 保持期限　過去方向
        /// </summary>
        public int KeepOldLimit { get; set; }

        /// <summary>
        /// 保持期限　未来方向
        /// </summary>
        public int KeepNewLimit { get; set; }

        /// <summary>
        /// 単位期間
        /// </summary>
        public string UpRange { get; set; }

        /// <summary>
        /// 更新間隔（分）
        /// </summary>
        public string UpdateInterval { get; set; }

        /// <summary>
        /// 定時処理時　指定時刻（HH24:MM)
        /// </summary>
        public string Time { get; set; }

        /// <summary>
        /// 定時処理時　指定曜日（1:月曜日、2:火曜日…0:日曜日)
        /// </summary>
        public string Week { get; set; }

        /// <summary>
        /// 実行開始日時　秒まで
        /// </summary>
        public DateTime LastStartDate { get; set; }

        /// <summary>
        /// 実行終了日時　秒まで
        /// </summary>
        public DateTime LastEndDate { get; set; }

        /// <summary>
        /// 強制インターバル設定値　分単位
        /// </summary>
        public int ExecInterval { get; set; }

        /// <summary>
        /// 開始日時(yyyyMMddhhmmss)
        /// </summary>
        public string FromDate { get; internal set; }

        /// <summary>
        /// 終了日時(yyyyMMddhhmmss)
        /// </summary>
        public string ToDate { get; internal set; }

        /// <summary>
        /// 分割データ
        /// </summary>
        public List<string> SplitAllItemModeData { get; internal set; }

        /// <summary>
        /// レコードNo
        /// </summary>
        public int No { get; internal set; }

        /// <summary>
        /// 識別名
        /// </summary>
        public string KeyName { get; internal set; }

        /// <summary>
        /// ジョブ識別名
        /// </summary>
        public string JobKeyName { get; internal set; }

        // 以下項目は実行結果を利用する

        /// <summary>
        /// 登録日時(yyyyMMddhhmmss)(実行結果場合、PK項目)
        /// </summary>
        public string RegDate { get; internal set; }

        /// <summary>
        /// 同期モード(1:起動、2:固定同期頻度1、3:固定同期頻度2、4:間隔同期、5:手動再同期)
        /// </summary>
        public int SyncMode { get; internal set; }


        public ViewTableInfo(ViewTableInfo copyFrom)
        {
            TableName = copyFrom.TableName;
            DispName = copyFrom.DispName;
            Desc = copyFrom.Desc;
            SqlCd = copyFrom.SqlCd;
            Mode = copyFrom.Mode;
            IsInit = copyFrom.IsInit;
            OnceFlg = copyFrom.OnceFlg;
            IsEffect = copyFrom.IsEffect;
            PastRangeTotal = copyFrom.PastRangeTotal;
            FutureRangeTotal = copyFrom.FutureRangeTotal;
            KeepOldLimit = copyFrom.KeepOldLimit;
            KeepNewLimit = copyFrom.KeepNewLimit;
            UpRange = copyFrom.UpRange;
            UpdateInterval = copyFrom.UpdateInterval;
            Time = copyFrom.Time;
            Week = copyFrom.Week;
            LastStartDate = copyFrom.LastStartDate;
            LastEndDate = copyFrom.LastEndDate;
            ExecInterval = copyFrom.ExecInterval;
            FromDate = copyFrom.FromDate;
            ToDate = copyFrom.ToDate;
            RegDate = copyFrom.RegDate;
            SyncMode = copyFrom.SyncMode;
            No = copyFrom.No;
            KeyName = copyFrom.KeyName;
            JobKeyName = copyFrom.JobKeyName;
        }

        public ViewTableInfo()
        {
        }
    }

    // 同期モード
    public class SyncMode
    {
        /// <summary>
        /// 1:起動
        /// </summary>
        public const int START = 1;

        /// <summary>
        /// 2:固定同期頻度1
        /// </summary>
        public const int MODE1 = 2;

        /// <summary>
        /// 3:固定同期頻度2
        /// </summary>
        public const int MODE2 = 3;

        /// <summary>
        /// 4:間隔同期
        /// </summary>
        public const int TIME_SPAN = 4;

        /// <summary>
        /// 5:手動再同期
        /// </summary>
        public const int Manual = 5;
    }

    // モード
    public class Mode
    {
        /// <summary>
        /// 全項目型
        /// </summary>
        public const int FULL_ITEM = 0;

        /// <summary>
        /// 蓄積型
        /// </summary>
        public const int ACCUMULATION = 1;
    }

}
