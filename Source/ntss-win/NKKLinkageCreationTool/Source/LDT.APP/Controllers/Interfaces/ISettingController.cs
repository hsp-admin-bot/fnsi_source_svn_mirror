using LDT.APP.Models.Interfaces;
using LDT.APP.Views.Interfaces;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using System.Threading.Tasks;

namespace LDT.APP.Controllers.Interfaces
{
  public interface ISettingController : IBaseController<SettingEntity, ISettingView, ISettingModel, ISettingService>
  {
    void LoadCoopCdType();

    void LoadInfoDataForPage();

    Task LoadDataSet(bool IsReload = false);

    void LoadProtocolInfo(string direction);

    void OnCancel();

    void OnSubmit(bool isOcc = false);

    void LoadMstCoopLayoutByItem(string coopCdSub);

    void LoadMstCoopLayoutByOcc(string name);

    void LoadMstCoopLayoutByRoot();

    void RefreshDisplayData();
  }
}
