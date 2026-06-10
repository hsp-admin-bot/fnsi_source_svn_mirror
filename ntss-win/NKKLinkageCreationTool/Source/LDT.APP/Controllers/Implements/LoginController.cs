using LDT.APP.Controllers.Implements;
using LDT.APP.Controllers.Interfaces;
using LDT.APP.DI;
using LDT.APP.Models;
using LDT.APP.Properties;
using LDT.APP.Views;
using LDT.APP.Views.Implements;
using LDT.APP.Views.Interfaces;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using System.Threading.Tasks;

namespace LDT.APP.Controllers
{
  public class LoginController : BaseController<UserEntity, ILoginView, ILoginModel, IUserService>, ILoginController
    {
        public LoginController(ILoginView view, ILoginModel model, IUserService service) : base(view, model, service)
        {
        }

        public void ClearCookie()
        {
            this.Tservice.ClearCookie();
        }

        public async Task LoginAsync()
        {
            this.Tview.RunLoading();
            var result = await Tservice.LoginAsync(Tview.UserID, Tview.Password);
            if (result.StatusCode == System.Net.HttpStatusCode.OK)
            {
                var facilityView = CompositionRoot.Resolve<IFacilityView>() as FacilityView;
                this.Tview.HideView();
                var facilityForm = facilityView.ShowView();
                this.Tview.HandleNextView(facilityForm);
            }
            else
            {
                this.Tview.ShowMessage(Resources.LOGIN_FAILED, Resources.ERROR, Enums.MessageTypeEnum.ERROR);
            }
            this.Tview.StopLoading();
        }

        public void ShowView()
        {
            this.Tview.ShowView();
        }
    }
}
