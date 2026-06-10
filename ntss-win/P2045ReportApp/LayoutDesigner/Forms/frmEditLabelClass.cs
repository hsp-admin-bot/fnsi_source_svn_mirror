using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;

namespace LayoutDesigner
{
    /// <summary>
    /// ラベル用汎用項目編集画面
    /// </summary>
    public partial class frmEditLabelClass : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        /// <summary>
        /// ラベルの汎用項目設定(XMLフォーマット)
        /// </summary>
        internal string LabelClassSetting = null;

        //<CaseData>
        //    <Item DataType="Dialyser" DataKey="" FixString="" />
        //    <Item DataType="Adsorption" DataKey="" FixString="" />
        //    <Item DataType="AntiCoagulan" DataKey="" FixString="" />
        //    <Item DataType="DialysisLiquid" DataKey="" FixString="" />
        //    <Item DataType="ReplenishLiquid" DataKey="" FixString="" />
        //    <Item DataType="Film1" DataKey="" FixString="" />
        //    <Item DataType="Film2" DataKey="" FixString="" />
        //    <Item DataType="Medicine" DataKey="" FixString="" />
        //    <Item DataType="Equip" DataKey="" FixString="" />
        //    <Item DataType="Puncture" DataKey="" FixString="" />
        //</CaseData>

        /// <summary>汎用設定のルートタグ名</summary>
        // mod #12050 FNW帳票コンバートで維持されない設定がある 高 start
        //private const string XML_ROOT = "CaseData";
        public const string XML_ROOT = "CaseData";
        // mod #12050 FNW帳票コンバートで維持されない設定がある 高 end
        /// <summary>汎用設定の各データの共通タグ名</summary>
        public const string XML_ITEM = "Item";
        /// <summary>汎用設定のデータ種別を示すアトリビュート名</summary>
        public const string XML_ATT_TYPE = "DataType";
        /// <summary>汎用設定のデータキーを示すアトリビュート名</summary>
        public const string XML_ATT_KEY = "DataKey";
        /// <summary>汎用設定の固定文字列を示すアトリビュート名</summary>
        public const string XML_ATT_FIX = "FixString";

        /// <summary>
        /// ラベル用汎用項目編集画面コンストラクタ
        /// </summary>
        public frmEditLabelClass()
        {
            InitializeComponent();

            // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 start
            // 全分類の候補登録
            clsAll.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
            };
            // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 end
            // ダイアライザの候補登録
            clsDialyser.ClassItems = new ComboItem[]
            {

                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("機能分類","function_class"),
                new ComboItem("面積","area"),
                new ComboItem("UFR","ufr"),
                new ComboItem("KOA","koa"),
                new ComboItem("材質","material"),
                new ComboItem("DRYWET","wetdry"),
                new ComboItem("抗凝固剤","anticoagulant_name"),
                new ComboItem("血液回路","equip_circuit"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // 吸着カラムの候補登録
            clsAdsorption.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // 抗凝固剤の候補登録
            clsAntiCoagulan.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("ワンショット量","cond_ac_shot"),
                new ComboItem("持続速度","cond_ac_spd"),
                new ComboItem("持続総量","cond_ac_dur_total"),
                //new ComboItem("総量","COND_AC_TOTAL"),
                new ComboItem("IP使用選択","cond_ip_use"),
                new ComboItem("IPスタート","cond_ip_start"),
                new ComboItem("IP速度","cond_ip_spd"),
                new ComboItem("自動ワンショット","cond_ip_shot_st"),
                new ComboItem("IPワンショット量","cond_ip_shot"),
                new ComboItem("IP電源自動切り","cond_ip_off"),
                new ComboItem("IP電源自動切り時間","cond_ip_off_tm"),
                new ComboItem("IP電源OKモニタ切り","cond_ip_ok"),
                new ComboItem("IP電源OKモニタ切り時間","cond_ip_ok_tm"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // 透析液の候補登録
            clsDialysisLiquid.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("透析液流量","cond_dl_fl"),
                new ComboItem("透析液量","cond_dl_am"),
                new ComboItem("透析温度","cond_dl_temp"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // 補液の候補登録
            clsReplenishLiquid.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("補液量","cond_rl_am"),
                new ComboItem("補液選択","cond_rl_sel"),
                new ComboItem("補液使用数","cond_rl_use"),
                new ComboItem("補液温度","cond_rl_temp"),
                new ComboItem("補液速度","cond_rl_spd"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),

            };
            // 1次膜の候補登録
            clsFilm1.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // 2次膜の候補登録
            clsFilm2.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // 薬剤の候補登録
            clsMedicine.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("投与時間帯","medi_timing"),
                new ComboItem("手技","medi_proc"),
                new ComboItem("数量･単位","num_unit"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // 医材の候補登録
            clsEquip.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("数量･単位","num_unit"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // 穿刺針の候補登録
            clsPuncture.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
                new ComboItem("数量･単位","num_unit"),
                new ComboItem("VA方向","cond_va_dir"),
                new ComboItem("VA","cond_va"),
                new ComboItem("穿刺針区分","equip_pnc_cls"),
                new ComboItem("院内コード1","in_hospital_cd_1"),
                new ComboItem("院内コード2","in_hospital_cd_2"),
            };
            // add #11595 分類別情報編集ダイアログに項目が足りない 高 start
            // 血液回路の候補登録
            clsCircuit.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
            };
            // 検査の候補登録
            clsExam.ClassItems = new ComboItem[]
            {
                new ComboItem("",""),
                new ComboItem("透析時間","plan_time"),
                new ComboItem("DW","cond_dw"),
                new ComboItem("目標体重","cond_tg_wei"),
                new ComboItem("治療項目","cond_tre_nm"),
                new ComboItem("血流量","cond_bld_fl"),
            };
            // add #11595 分類別情報編集ダイアログに項目が足りない 高 end
        }

        /// <summary>
        /// フォームロード
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void frmEditLabelClass_Load(object sender, EventArgs e)
        {
            if (false == string.IsNullOrEmpty(this.LabelClassSetting))
            {
                // 設定を受け取っている場合はその情報を画面にセット
                XmlDocument doc = new XmlDocument();
                try
                {
                    // XMLをロード
                    doc.LoadXml(this.LabelClassSetting);
                }
                catch (Exception ex)
                {
                    //LogManager.WriteErrorLog(this, null, "ラベル汎用項目のロードに失敗", ex);
                    MessageBox.Show("分類別情報のロードに失敗しました。\r\n設定をやり直してください。", "取得エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // ルートを無視して中のアイテムを取得
                XmlNodeList nodes = doc.GetElementsByTagName(frmEditLabelClass.XML_ITEM);

                for (int i = 0; i < nodes.Count; i++)
                {
                    // データのタイプを取得
                    XmlAttribute att = nodes[i].Attributes[frmEditLabelClass.XML_ATT_TYPE];
                    if (null == att)
                    {
                        continue;
                    }

                    // データのタイプに応じてユーザコントロールを特定
                    ExcelReportTool.ucLabelClass lc = null;
                    switch (att.Value)
                    {
                        // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 start
                        case "AllClass": lc = clsAll; break;
                        // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 end
                        case "Dialyser": lc = clsDialyser; break;
                        case "Adsorption": lc = clsAdsorption; break;
                        case "AntiCoagulan": lc = clsAntiCoagulan; break;
                        case "DialysisLiquid": lc = clsDialysisLiquid; break;
                        case "ReplenishLiquid": lc = clsReplenishLiquid; break;
                        case "Film1": lc = clsFilm1; break;
                        case "Film2": lc = clsFilm2; break;
                        case "Medicine": lc = clsMedicine; break;
                        case "Equip": lc = clsEquip; break;
                        case "Puncture": lc = clsPuncture; break;
                        // add #11595 分類別情報編集ダイアログに項目が足りない 高 start
                        case "BloodRoad": lc = clsCircuit; break;
                        case "Exam": lc = clsExam; break;
                        // add #11595 分類別情報編集ダイアログに項目が足りない 高 end
                        default: break;
                    }

                    if (null == lc)
                    {
                        // どれにも当てはまらなかったら無視
                        continue;
                    }

                    att = nodes[i].Attributes[frmEditLabelClass.XML_ATT_KEY];
                    if (null != att)
                    {
                        // データの種別をユーザコントロールにセット
                        lc.SelectClassItem = att.Value;
                    }
                    att = nodes[i].Attributes[frmEditLabelClass.XML_ATT_FIX];
                    if (null != att)
                    {
                        // 固定文字列をユーザコントロールにセット
                        lc.FixString = att.Value;
                    }
                }
            }
        }

        /// <summary>
        /// OKボタンクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            //List<ExcelReportTool.ucLabelClass> list = base.GetControl<ExcelReportTool.ucLabelClass>();
            //for (int i = 0; i < list.Count; i++)
            //{
            //    if (false == list[i].IsEmpty)
            //    {
            //        list = null;
            //        break;
            //    }
            //}
            //if (null != list)
            //{
            //    if (DialogResult.Yes != MessageBox.Show("全ての項目が未編集の場合は何も表示されません。\r\nこのまま確定してよろしいですか？", "未編集", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
            //    {
            //        this.DialogResult = DialogResult.None;
            //        return;
            //    }
            //}

            // 保存用にXMLインスタンス作成
            XmlDocument doc = new XmlDocument();

            // XMLのルートを作成
            XmlElement root = doc.CreateElement(XML_ROOT);
            doc.AppendChild(root);

            // 各ユーザコントロールの設定を保存
            // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 start
            root.AppendChild(MakeEle(doc, "AllClass", clsAll));
            // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 end
            root.AppendChild(MakeEle(doc, "Dialyser", clsDialyser));
            root.AppendChild(MakeEle(doc, "Adsorption", clsAdsorption));
            root.AppendChild(MakeEle(doc, "AntiCoagulan", clsAntiCoagulan));
            root.AppendChild(MakeEle(doc, "DialysisLiquid", clsDialysisLiquid));
            root.AppendChild(MakeEle(doc, "ReplenishLiquid", clsReplenishLiquid));
            root.AppendChild(MakeEle(doc, "Film1", clsFilm1));
            root.AppendChild(MakeEle(doc, "Film2", clsFilm2));
            root.AppendChild(MakeEle(doc, "Medicine", clsMedicine));
            root.AppendChild(MakeEle(doc, "Equip", clsEquip));
            root.AppendChild(MakeEle(doc, "Puncture", clsPuncture));
            // add #11595 分類別情報編集ダイアログに項目が足りない 高 start
            root.AppendChild(MakeEle(doc, "BloodRoad", clsCircuit));
            root.AppendChild(MakeEle(doc, "Exam", clsExam));
            // add #11595 分類別情報編集ダイアログに項目が足りない 高 start

            // 設定をパラメータにセットしてクローズ
            this.LabelClassSetting = doc.OuterXml;
        }

        /// <summary>
        /// 汎用情報の設定Itemタグに対応するエレメントを作成
        /// </summary>
        /// <param name="doc">登録のベースとなるXML</param>
        /// <param name="name">データ種別名</param>
        /// <param name="lc">対応した情報を保持しているユーザコントロール</param>
        /// <returns>作成したXmlElement</returns>
        private static XmlElement MakeEle(XmlDocument doc, string name, ExcelReportTool.ucLabelClass lc)
        {
            // Itemタグ作成
            XmlElement ele = doc.CreateElement(frmEditLabelClass.XML_ITEM);
            XmlAttribute att;

            // データ種別のアトリビュート登録
            att = doc.CreateAttribute(frmEditLabelClass.XML_ATT_TYPE);
            att.Value = name;
            ele.Attributes.Append(att);

            // データキー情報のアトリビュート登録
            att = doc.CreateAttribute(frmEditLabelClass.XML_ATT_KEY);
            att.Value = lc.SelectClassItem;
            ele.Attributes.Append(att);

            // 固定文字列のアトリビュート登録
            att = doc.CreateAttribute(frmEditLabelClass.XML_ATT_FIX);
            att.Value = lc.FixString;
            ele.Attributes.Append(att);

            // 作成したエレメントを返却
            return ele;
        }
    }

    /// <summary>
    /// コンボボックス要素用クラス
    /// </summary>
    class ComboItem
    {
        /// <summary>
        /// 表示用キー
        /// </summary>
        public const string KEY_DISP = "Disp";
        /// <summary>
        /// 値用キー
        /// </summary>
        public const string KEY_VAL = "Val";

        /// <summary>
        /// 表示データ
        /// </summary>
        public string Disp { get; private set; }
        /// <summary>
        /// 値データ
        /// </summary>
        public string Val { get; private set; }

        /// <summary>
        /// コンボボックス要素用クラスのコンストラクタ
        /// </summary>
        /// <param name="disp">表示データ</param>
        /// <param name="val">値データ</param>
        internal ComboItem(string disp, string val)
        {
            this.Disp = disp;
            this.Val = val;
        }
    }
}
