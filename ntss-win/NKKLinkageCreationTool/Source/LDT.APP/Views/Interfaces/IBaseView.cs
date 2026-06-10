using LDT.APP.Enums;
using System.Windows.Forms;

namespace LDT.APP.Views.interfaces
{
  public interface IBaseView
  {
    void ShowMessage(string message, string caption, MessageTypeEnum type);

    void HideView();

    Form ShowView();

    void CloseView();
  }
}
