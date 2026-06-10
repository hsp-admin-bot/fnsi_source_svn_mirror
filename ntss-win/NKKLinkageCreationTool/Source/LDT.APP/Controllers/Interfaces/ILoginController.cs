using LDT.APP.Models;
using LDT.APP.Views;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using System.Threading.Tasks;

namespace LDT.APP.Controllers.Interfaces
{
  public interface ILoginController : IBaseController<UserEntity, ILoginView, ILoginModel, IUserService>
    {
        Task LoginAsync();

        void ShowView();

        void ClearCookie();
    }
}
