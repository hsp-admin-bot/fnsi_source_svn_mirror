using System;
using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// ツール設定選択画面
    /// </summary>
    public partial class frmSelectToolSetting : LayoutDesignerUtilityLib.Controls.frmRldBase
    {
        /// <summary>
        /// ツール設定選択画面
        /// </summary>
        public frmSelectToolSetting()
        {
            InitializeComponent();
        }

        private void btnDialysis_Click(object sender, EventArgs e)
        {
            //ComParam.ExcelCtrl.ToolSetting = ToolSetType.DIALYSIS;
            //this.DialogResult = DialogResult.OK;
            //this.Close();
        }

        private void btnExamin_Click(object sender, EventArgs e)
        {
            //ComParam.ExcelCtrl.ToolSetting = ToolSetType.EXAMIN;
            //this.DialogResult = DialogResult.OK;
            //this.Close();
        }
    }
}
