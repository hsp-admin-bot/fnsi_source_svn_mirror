using LDT.APP.Controllers.Interfaces;
using LDT.APP.Views.interfaces;
using System.Windows.Forms;

namespace LDT.APP.Views
{
  public interface ILoginView : IBaseView
  {
    void SetController(ILoginController loginController);

    string UserID { get; set; }
    string Password { get; set; }

    void RegisterEvent();

    void HandleNextView(Form nextView);

    void RunLoading();

    void StopLoading();
  }
}
