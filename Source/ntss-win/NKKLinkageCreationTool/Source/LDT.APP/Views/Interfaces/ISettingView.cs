using LDT.APP.Controllers.Interfaces;
using LDT.APP.Views.interfaces;
using LDT.SERVICE.Models;
using System.Collections.Generic;

namespace LDT.APP.Views.Interfaces
{
  public interface ISettingView : IBaseView
    {
        void SetController(ISettingController settingController);

        void RegisterEvent();

        void SetDefault();

        void OpenTypeView(List<CoopCdTypeModel> data);

        void InitView();

        void BindValueFacilityInformation(MstCoopLayoutEntity entity);

        void BindValueListElementKey(MstCoopLayoutEntity entity);

        void BindValueGridViewSettingElement(List<CoopSettingItemList> data, List<SysDataSetEntity> dataSet);

        void BindValueProtocolSend(MstCoopDistributeEntity entity);

        void BindValueProtocolReceive(MstCoopFacilityEntity entity);

        bool IsCancel { get; set; }

        void RunLoading();

        void StopLoading();

        void UpdateNumberNo1();

        void AddNodeToListView<TType>(TType nodeType, MstCoopLayoutEntity entity);

        void HandleEnableRowCell(int row);

        void HandleEnableAllRowCell();

        void BindDataDataSet(List<SysDataSetEntity> dataSetList);

        void SetMstCoopLayoutEntity(MstCoopLayoutEntity entity);

        void SetMstCoopLayoutDetailEntity(MstCoopLayoutDetailEntity entity);

        bool ValidateSubmit();

        void OnSubmit(bool isSuccess = true);
    }
}
