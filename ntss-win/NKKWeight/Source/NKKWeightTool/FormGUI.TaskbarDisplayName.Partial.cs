using System;
using System.Windows.Forms;

namespace NKKWeightTool
{
    public partial class FormGUI
    {
        /// <summary>
        /// NKSConverter.FormsTaskbarDisplayName.Partial と同様、ハンドル生成直後に Shell へ表示名を伝える。
        /// </summary>
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }
}
