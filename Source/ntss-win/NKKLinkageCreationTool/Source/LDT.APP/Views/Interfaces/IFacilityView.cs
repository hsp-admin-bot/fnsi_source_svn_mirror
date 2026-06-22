using LDT.APP.Controllers.Interfaces;
using LDT.APP.Views.interfaces;
using LDT.SERVICE.Models;
using System.Collections.Generic;
using System.Windows.Forms;

namespace LDT.APP.Views.Interfaces
{
  public interface IFacilityView : IBaseView
  {
    bool IsCancel { get; set; }

    void SetController(IFacilityController controller);

    void RegisterEvent();

    void HandleNextView(Form nextView);

    void InitDataInCombobox(List<MstFacilityEntity> data);

    void LoadDataCoopLayout(List<MstCoopLayoutEntity> data);

    void RunLoading();

    void StopLoading();
  }
}
