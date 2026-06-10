using LDT.SERVICE.Models;

namespace LDT.APP.Models.Interfaces
{
  public interface IFacilityModel : IBaseModel
  {
    MstFacilityEntity SelectItem { get; set; }
    MstCoopLayoutEntity MstCoopLayoutSelected { get; set; }
  }
}
