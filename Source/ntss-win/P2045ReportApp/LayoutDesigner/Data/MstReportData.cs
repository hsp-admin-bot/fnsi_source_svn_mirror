using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票マスタデータ
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class MstReportData
    {
        #region メンバ定数定義

        public const String VAL_IS_DISPLAY_NONE = "0";
        public const String VAL_IS_DISPLAY_DONE = "1";

        public const String VAL_IS_DELETE_NONE = "0";
        public const String VAL_IS_DELETE_DONE = "1";

        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        public const String VAL_IS_SELECT_NONE = "0";
        public const String VAL_IS_SELECT_DONE = "1";
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end

        #endregion

        #region 内部クラス定義

        /// <summary>
        /// ３ファイルのフルパスデータ
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class Path
        {
            #region 生成と破棄

            /// <summary>
            /// ３ファイルのフルパスデータの新しいインスタンスを初期化します。
            /// </summary>
            public Path() { }

            /// <summary>
            /// コピー元の３ファイルのフルパスデータを指定して新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aSource"></param>
            public Path(Path aSource) : this()
            {
                this.S3Bucket = aSource.S3Bucket;
                this.ZipExcelFileName = aSource.ZipExcelFileName;
                this.ZipReportFileName = aSource.ZipReportFileName;
                this.ExcelFileName = aSource.ExcelFileName;
                this.HtmlFileName = aSource.HtmlFileName;
                this.XmlFileName = aSource.XmlFileName;
            }

            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// S3上のバケット名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "bucket")]
            public String S3Bucket { get; set; } = String.Empty;

            /// <summary>
            /// 帳票デザイン Excel 圧縮ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "xlsx_zip")]
            public String ZipExcelFileName { get; set; } = String.Empty;

            /// <summary>
            /// Html と帳票定義.xml 圧縮ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "report_zip")]
            public String ZipReportFileName { get; set; } = String.Empty;

            /// <summary>
            /// 帳票デザイン Excel ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "xlsx_filename")]
            public String ExcelFileName { get; set; } = String.Empty;

            /// <summary>
            /// 帳票デザイン Html ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "html_filename")]
            public String HtmlFileName { get; set; } = String.Empty;

            /// <summary>
            /// 帳票デザイン Xml ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "xml_filename")]
            public String XmlFileName { get; set; } = String.Empty;

            #endregion
        }

        #endregion

        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
        /// <summary>
        /// 抽出条件データ
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class Extraction
        {
            #region 生成と破棄

            /// <summary>
            /// 抽出条件データの新しいインスタンスを初期化します。
            /// </summary>
            public Extraction() { }

            /// <summary>
            /// コピー元の抽出条件データを指定して新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aSource"></param>
            public Extraction(Extraction aSource) : this()
            {
                if (aSource != null) {
                    this.UseCD = aSource.UseCD;
                    // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    //this.RecordCD = aSource.RecordCD;
                    //this.LayoutCD = aSource.LayoutCD;
                    this.MachineTypeCD = aSource.MachineTypeCD;
                    // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                }
            }

            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// 用途CDの取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "layout_class")]
            public String UseCD { get; set; } = String.Empty;
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            ///// <summary>
            ///// 記録簿CDの取得及び設定を行います。
            ///// </summary>
            //[System.Runtime.Serialization.DataMember(Name = "detail_info_class")]
            //public String RecordCD { get; set; } = String.Empty;

            ///// <summary>
            ///// 点検レイアウトCDの取得及び設定を行います。
            ///// </summary>
            //[System.Runtime.Serialization.DataMember(Name = "mainte_layout_cd")]
            //public String LayoutCD { get; set; } = String.Empty;

            /// <summary>
            /// 型式CDの取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "machine_type_cd")]
            public String MachineTypeCD { get; set; } = String.Empty;
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

            #endregion
        }
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        /// <summary>
        /// 帳票更新履歴
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class ReportHst
        {
            #region 生成と破棄

            /// <summary>
            /// 帳票更新履歴の新しいインスタンスを初期化します。
            /// </summary>
            public ReportHst() { }

            /// <summary>
            /// コピー元の帳票更新履歴を指定して新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aSource"></param>
            public ReportHst(ReportHst aSource) : this()
            {
                this.CtlNo = aSource.CtlNo;
                this.UpdDate = aSource.UpdDate;
                this.S3Bucket = aSource.S3Bucket;
                this.ZipExcelFileName = aSource.ZipExcelFileName;
                this.ZipReportFileName = aSource.ZipReportFileName;
                this.ExcelFileName = aSource.ExcelFileName;
                this.HtmlFileName = aSource.HtmlFileName;
                this.XmlFileName = aSource.XmlFileName;
                this.IsSelect = aSource.IsSelect;
                this.UpdUserId = aSource.UpdUserId;
                this.UpdUserName = aSource.UpdUserName;
            }
            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// 版数の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "ctl_no")]
            public String CtlNo { get; set; } = String.Empty;

            /// <summary>
            /// 更新日時(yyyyMMddHHmmss)の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "upd_date")]
            public String UpdDate { get; set; } = String.Empty;

            /// <summary>
            /// S3上のバケット名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "bucket")]
            public String S3Bucket { get; set; } = String.Empty;

            /// <summary>
            /// 帳票デザイン Excel 圧縮ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "xlsx_zip")]
            public String ZipExcelFileName { get; set; } = String.Empty;

            /// <summary>
            /// Html と帳票定義.xml 圧縮ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "report_zip")]
            public String ZipReportFileName { get; set; } = String.Empty;

            /// <summary>
            /// 帳票デザイン Excel ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "xlsx_filename")]
            public String ExcelFileName { get; set; } = String.Empty;

            /// <summary>
            /// 帳票デザイン Html ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "html_filename")]
            public String HtmlFileName { get; set; } = String.Empty;

            /// <summary>
            /// 帳票デザイン Xml ファイル名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "xml_filename")]
            public String XmlFileName { get; set; } = String.Empty;

            /// <summary>
            /// 適用フラグ(適用：1、未適用：0)の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "is_select")]
            public String IsSelect { get; set; } = String.Empty;

            /// <summary>
            /// 更新者IDの取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "upd_user_id")]
            public String UpdUserId { get; set; } = String.Empty;

            /// <summary>
            /// 更新者名の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "upd_user_name")]
            public String UpdUserName { get; set; } = String.Empty;
            #endregion
        }

        /// <summary>
        /// 帳票更新履歴データ
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class HstInfo
        {
            #region 生成と破棄

            /// <summary>
            /// 帳票更新履歴データの新しいインスタンスを初期化します。
            /// </summary>
            public HstInfo() { }

            /// <summary>
            /// コピー元の帳票更新履歴データを指定して新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aSource"></param>
            public HstInfo(HstInfo aSource) : this()
            {
                if (aSource!= null && aSource.ReportHstList != null)
                {
                    this.ReportHstList = aSource.ReportHstList;
                }
            }
            #endregion

            /// <summary>
            /// 票更新履歴配列の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "items")]
            public List<ReportHst> ReportHstList { get; set; } = new List<ReportHst>();
        }
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end

        #region 生成と破棄

        /// <summary>
        /// 帳票マスタデータの新しいインスタンスを初期化します。
        /// </summary>
        public MstReportData()
        {
            this.ReportPath = new Path();

            // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
            this.ReportHstInfo = new HstInfo();
            // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end

            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
            this.ExtractionCondition = new Extraction();
            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
        }

        /// <summary>
        /// 帳票マスタデータを指定して新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aSource"></param>
        public MstReportData(MstReportData aSource)
        {
            this.ReportCode = aSource.ReportCode;
            this.FacilityCode = aSource.FacilityCode;
            this.ReportName = aSource.ReportName;
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
            if((aSource.ReportPath is null) == false)
            {
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                this.ReportPath = new Path(aSource.ReportPath);
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
            }
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
            this.ReportClass = aSource.ReportClass;
            this.IsDisplay = aSource.IsDisplay;
            // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
            this.DispOrder = aSource.DispOrder;
            // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end

            // add 2020/11/19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
            this.ReportHstInfo = new HstInfo(aSource.ReportHstInfo);
            // add 2020/11/19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
            this.IsDelete = aSource.IsDelete;
            if ((aSource.AdditionalInfo is null) == false)
            {
                this.AdditionalInfo = aSource.AdditionalInfo.Clone();
            }
            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
            this.ReportType = aSource.ReportType;
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            //this.ExtractionCondition = new Extraction(aSource.ExtractionCondition);
            if ((aSource.ExtractionCondition is null) == false)
            {
                this.ExtractionCondition = new Extraction(aSource.ExtractionCondition);
            }
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// レポートCDの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportCd")]
        public Int64 ReportCode { get; set; } = Int64.MinValue;

        /// <summary>
        /// 施設コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "facilityCd")]
        public String FacilityCode { get; set; } = String.Empty;

        /// <summary>
        /// 帳票名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportName")]
        public String ReportName { get; set; } = String.Empty;

        /// <summary>
        /// 3ファイルのフルパスの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportPath")]
        public MstReportData.Path ReportPath { get; set; } = null;

        /// <summary>
        /// 帳票種別の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportClass")]
        public Int32 ReportClass { get; set; } = 0;

        /// <summary>
        /// 表示フラグの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "isDisp")]
        public String IsDisplay { get; set; } = String.Empty;

        // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
        /// <summary>
        /// 表示順の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "dispOrder")]
        public Int32 DispOrder { get; set; } = 0;
        // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end

        /// <summary>
        /// 削除フラグの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "isDel")]
        public String IsDelete { get; set; } = String.Empty;

        /// <summary>
        /// 作成日時の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "regDate")]
        public String CreateDate { get; set; } = String.Empty;

        /// <summary>
        /// 更新日時の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "upDate")]
        public String UpdateDate { get; set; } = String.Empty;

        // add 2020-09-29 FNSI-仕様追加 帳票更新者情報を追加する 李 start
        /// <summary>
        /// 更新者の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "upUser")]
        public String UpdateUser { get; set; } = String.Empty;
        // add 2020-09-29 FNSI-仕様追加 帳票更新者情報を追加する 李 end

        /// <summary>
        /// 既定のプリンター
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "defaultPrinter")]
        public long? DefaultPrinter { get; internal set; }

        /// <summary>
        /// 追加情報
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "additionalInfo")]
        public AdditionalInfo AdditionalInfo { get; set; } = null;

        // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        /// <summary>
        /// 帳票更新履歴の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportHstInfo")]
        public MstReportData.HstInfo ReportHstInfo { get; set; } = null;
        // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end

        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
        /// <summary>
        /// 帳票区分の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportType")]
        public String ReportType { get; set; } = String.Empty;

        /// <summary>
        /// 抽出条件の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "extractionCondition")]
        public MstReportData.Extraction ExtractionCondition { get; set; } = null;
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
        // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe start
        ////add 6608 2次元帳票excel エクスポート 吉 start
        //[System.Runtime.Serialization.DataMember(Name = "multiTotalDefaul")]
        //public String MultiTotalDefaul { get; set; } = String.Empty;
        ////add 6608 2次元帳票excel エクスポート 吉 end
        // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe end
        #endregion

    }

}
