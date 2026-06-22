using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 書式選択画面
    /// </summary>
    public partial class frmSelectFormat : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 編集箇所を特定できる情報の取得及び設定を行います。
        /// </summary>
        internal String DataPath { get; set; } = String.Empty;

        internal String SelectedFormat { get; set; } = String.Empty;

        internal String DataType { get; set; } = String.Empty;

        #endregion

        /// <summary>
        /// 数値の書式文字列
        /// </summary>
        public static readonly string[] DECIMAL_FORMAT =
        {
            "0",
            "0.0",
            "0.00",
            "0.000"
        };

        /// <summary>
        /// 日付時刻の書式文字列
        /// </summary>
        public static readonly string[] DATETIME_FORMAT =
        {
            // mod #8394(1) 動作に関する指摘 luantian start
            "yyyy\"年\"m\"月\"d\"日\"(aaa) h\"時\"mm\"分\"",
            "yyyy\"年\"m\"月\"d\"日\" h\"時\"mm\"分\"",
            "yyyy/m/d h:mm",
            "yyyy/mm/dd hh:mm",
            "yyyy\"年\"m\"月\"",
            "gy/m",
            "yyyy\"年\"m\"月\"d\"日\"(aaa)",
            "yyyy\"年\"m\"月\"d\"日\"",
            "yyyy/m/d",
            "yyyy/mm/dd",
            "ggge\"年\"m\"月\"d\"日\"(aaa)",
            "ggge\"年\"m\"月\"d\"日\"",
            "ge/m/d",
            "m\"月\"d\"日\"(aaa)",
            "m\"月\"d\"日\"",
            "m/d(aaa)",
            "m/d",
            "(aaa)",
            "aaa\"曜日\"",
            "m/d h:mm",
            "[h]:mm:ss",
            "h:mm:ss",
            "[h]\"時間\"mm\"分\"ss\"秒\"",
            "h\"時\"mm\"分\"ss\"秒\"",
            "[h]:mm",
            "h:mm",
            "hh:mm",
            "[h]\"時間\"mm\"分\"",
            "h\"時\"mm\"分\"",
            "h:mm AM/PM"
            // mod #8394(1) 動作に関する指摘 luantian end
        };

        #region 生成と破棄

        /// <summary>
        /// 書式選択画面
        /// </summary>
        public frmSelectFormat()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て
            this.lstFormat.DoubleClick += new System.EventHandler(this.lstFormat_DoubleClick);

            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);

            //chkDevelopment.Visible = ComParam.IsNKKMode;
        }

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode) return;

            // 画面をクリア
            this.DataClear(true);

            this.lblDataPathAddr.Text = this.DataPath;

            switch (this.DataType)
            {
                case RldConst.ParamData.VAL_DATATYPE_DECIMAL:
                    // 数値の書式文字列をlstFormatに追加する
                    this.SetDecimal();
                    break;
                case RldConst.ParamData.VAL_DATATYPE_DATETIME:
                    // 日付時刻の書式文字列をlstFormatに追加する
                    this.SetDateTime();
                    break;
                // add #11535 帳票の汎用バーコード出力対応 高 start
                case "BarCode":
                    this.winlblTitle.Text = "バーコード選択";
                    // バーコードの文字列をlstFormatに追加する
                    this.SetBarCode();
                    break;
                // add #11535 帳票の汎用バーコード出力対応 高 end
                default:
                    break;
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear"></param>
        private void DataClear(Boolean aIsKeyClear)
        {
            this.lstFormat.Items.Clear();
        }

        /// <summary>
        /// 数値の書式文字列をlstFormatに追加する
        /// </summary>
        private void SetDecimal()
        {
            DECIMAL_FORMAT.ToList().ForEach(ele => lstFormat.Items.Add(ele));

            if (!this.lstFormat.Items.Contains(this.SelectedFormat))
            {
                this.lstFormat.Items.Insert(0, this.SelectedFormat);
            }

            this.lstFormat.SelectedItem = this.SelectedFormat;
        }

        /// <summary>
        /// 日付時刻の書式文字列をlstFormatに追加する
        /// </summary>
        private void SetDateTime()
        {
            DATETIME_FORMAT.ToList().ForEach(ele => this.lstFormat.Items.Add(ele));

            if (!this.lstFormat.Items.Contains(this.SelectedFormat))
            {
                this.lstFormat.Items.Insert(0, this.SelectedFormat);
            }

            this.lstFormat.SelectedItem = this.SelectedFormat;
        }

        // add #11535 帳票の汎用バーコード出力対応 高 start
        /// <summary>
        /// バーコードの文字列をlstFormatに追加する
        /// </summary>
        private void SetBarCode()
        {
            RldLib.barCodeDic.Keys.ToList().ForEach(ele => this.lstFormat.Items.Add(ele));

            if (!this.lstFormat.Items.Contains(this.SelectedFormat))
            {
                this.lstFormat.Items.Insert(0, this.SelectedFormat);
            }

            this.lstFormat.SelectedItem = this.SelectedFormat;
        }
        // add #11535 帳票の汎用バーコード出力対応 高 end

        #endregion

        #region コントロールイベントハンドラ定義

        private void lstFormat_DoubleClick(object sender, EventArgs e)
        {
            this.btnOK.PerformClick();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            if (this.lstFormat.SelectedIndex < 0)
            {
                RldMsgBox.Show("書式を選択してください", "書式未選択", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            this.SelectedFormat = this.lstFormat.SelectedItem as String;
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        #endregion
    }
}
