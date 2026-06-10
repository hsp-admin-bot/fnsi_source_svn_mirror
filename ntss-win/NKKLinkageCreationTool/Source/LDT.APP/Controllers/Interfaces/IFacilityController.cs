using LDT.APP.Models.Interfaces;
using LDT.APP.Views.Interfaces;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;

namespace LDT.APP.Controllers.Interfaces
{
  public interface IFacilityController : IBaseController<MstFacilityEntity, IFacilityView, IFacilityModel, IMstFacilityService>
  {
    void LoadFacilityData();

    void OnUpdate();

    void OnAddNew();

    void OnCancel();

    void OnCopy();

    void LoadCoopLayoutByFacilityInfo(MstFacilityEntity coopLayoutEntity);
  }
}
