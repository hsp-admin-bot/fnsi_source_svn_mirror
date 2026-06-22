using System.Windows.Forms;

namespace NKK.BloodPurify
{
    public class ExBtnNoFocus : Button
    {
        public ExBtnNoFocus()
        {
            SetStyle(ControlStyles.Selectable, false);
        }
    }
}
