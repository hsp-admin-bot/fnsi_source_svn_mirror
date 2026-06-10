using System;
using System.Collections.Generic;
using System.Text;

//////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：検査予定情報クラス
// ファイル名：ExamInfo.cs
// 説明      ：FNWの検査予定情報を表現する
//
//	Copyright(C) 2011 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2011/01/20	飛田隆太			新規作成
//
///////////////////////////////////////////////////////////////////////////////
namespace CSICoopExaminScheSendStd
{
    /// <summary>
    /// FNWの検査予定情報クラス
    /// </summary>
    public class ExamInfo
    {
        #region プロパティ

        /// <summary>
        /// 表示用患者ID
        /// </summary>
        public string DispPatID { get; set; }

        /// <summary>
        /// MIRAIsの患者番号
        /// </summary>
        public string MIRAIsPatID { get; set; }

        /// <summary>
        /// 患者ID
        /// </summary>
        public string PatID { get; set; }

        /// <summary>
        /// 患者名
        /// </summary>
        public string PatName { get; set; }

        /// <summary>
        /// 検査予定日時
        /// </summary>
        public DateTime ExamDate { get; set; }

        /// <summary>
        /// 検査予定区分
        /// </summary>
        public string ExamDivision { get; set; }

        /// <summary>
        /// MIRAIsの検査区分コメントコード
        /// </summary>
        public string MIRAIsExamDivisionCommentCode { get; set; }

        /// <summary>
        /// MIRAIsの検査区分コメント名称
        /// </summary>
        public string MIRAIsExamDivisionName { get; set; }

        /// <summary>
        /// 検査コメント設定フラグ
        /// <para>検査区分が透析前 or 透析後 or その他でコードと名称設定済み：設定する(true)／検査区分がその他でコードか名称が設定なし：設定しない(false)</para>
        /// </summary>
        public bool IsSetExamComment
        {
            get
            {
                // 検査区分が透析前、透析後の場合
                if (this.ExamDivision.Equals("0") || this.ExamDivision.Equals("1"))
                {
                    return true;
                }
                // 検査区分がその他で、コメントコード・名称のいずれも設定されている場合
                else if (this.ExamDivision.Equals("2") &&
                    !string.IsNullOrEmpty(this.MIRAIsExamDivisionCommentCode) &&
                    !string.IsNullOrEmpty(this.MIRAIsExamDivisionName))
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 指示医
        /// </summary>
        public string OrderDoctor { get; set; }

        /// <summary>
        /// オーダ日時
        /// </summary>
        public DateTime OrderDate { get; set; }

        /// <summary>
        /// オーダ入力者
        /// </summary>
        public string OrderStaff { get; set; }

        /// <summary>
        /// 更新者
        /// </summary>
        public string UpdateStaff { get; set; }

        /// <summary>
        /// 検査項目のリスト
        /// </summary>
        public List<string> ExamItemList { get; set; }

        /// <summary>
        /// イベント区分
        /// <para>新規：0 変更：1 削除：2</para>
        /// </summary>
        public string EventType { get; set; }

        /// <summary>
        /// MIRAIsの処理区分
        /// <para>新規：1 変更：2 削除：3</para>
        /// </summary>
        public string MIRAIsProcType { get; set; }

        /// <summary>
        /// MIRAIsのオーダ番号
        /// </summary>
        public string MIRAIsOrderNo { get; set; }

        /// <summary>
        /// MIRAIsのオーダサブ番号
        /// </summary>
        public string MIRAIsOrderSubNo { get; set; }

        /// <summary>
        /// 診療科
        /// </summary>
        public string Department { get; set; }

        #endregion

        #region メソッド

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public ExamInfo()
        {
            // 各プロパティ初期化
            this.DispPatID = string.Empty;
            this.MIRAIsPatID = string.Empty;
            this.PatID = string.Empty;
            this.PatName = string.Empty;
            this.ExamDate = DateTime.MinValue;
            this.ExamDivision = string.Empty;
            this.MIRAIsExamDivisionCommentCode = string.Empty;
            this.MIRAIsExamDivisionName = string.Empty;
            this.OrderDoctor = string.Empty;
            this.OrderDate = DateTime.MinValue;
            this.OrderStaff = string.Empty;
            this.UpdateStaff = string.Empty;
            this.ExamItemList = new List<string>();
            this.EventType = string.Empty;
            this.MIRAIsProcType = string.Empty;
            this.MIRAIsOrderNo = string.Empty;
            this.MIRAIsOrderSubNo = string.Empty;
            this.Department = string.Empty;
        }

        /// <summary>
        /// ログ情報テキストを取得します
        /// <para>患者ID：XXXX 表示用患者ID：XXXX 検査予定日時：XXXX 検査区分：XXXX 処理区分：XXXX</para>
        /// </summary>
        /// <returns>ログ情報用テキスト</returns>
        public string GetLogInfoText()
        {
            string eventTypeText = string.Empty;
            switch (this.EventType)
            { 
                case "0":
                    eventTypeText = "登録";
                    break;
                case "1":
                    eventTypeText = "変更";
                    break;
                case "2":
                    eventTypeText = "削除";
                    break;
                default:
                    eventTypeText = this.EventType;
                    break;
            }

            return string.Format("患者ID：{0} 表示用患者ID：{1} 検査日時：{2} 検査区分：{3} 処理区分：{4}",
                                 this.PatID,
                                 this.DispPatID,
                                 this.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"),
                                 this.ExamDivision,
                                 eventTypeText);
        }

        #endregion
    }
}
