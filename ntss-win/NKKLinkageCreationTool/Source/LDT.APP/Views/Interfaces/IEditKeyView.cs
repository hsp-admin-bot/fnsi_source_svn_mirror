using LDT.APP.Views.interfaces;

namespace LDT.APP.Views.Interfaces
{
  public interface IEditKeyView : IBaseView
  {
    void RegisterEvent();

    void SetDefault();

    void GetValueFromGridview();

    void BindDataSource();
  }
}
