using LDT.APP.Models.Interfaces;
using LDT.SERVICE.Models;

namespace LDT.APP.Models.Implements
{
  public class FacilityModel : BaseModel, IFacilityModel
    {
        private MstFacilityEntity _selectItem;
        public MstFacilityEntity SelectItem { get => _selectItem; set => _selectItem = value; }
        private MstCoopLayoutEntity _mstCoopLayoutSelected;
        public MstCoopLayoutEntity MstCoopLayoutSelected { get => _mstCoopLayoutSelected; set => _mstCoopLayoutSelected = value; }
    }
}
