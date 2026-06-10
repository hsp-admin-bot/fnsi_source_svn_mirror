using LDT.SERVICE.Configuration;
using LDT.SERVICE.Extendsions;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Requests;
using LDT.SERVICE.Models.Responses;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace LDT.SERVICE.Implements
{
  public class MstFacilityService : BaseService<MstFacilityEntity>, IMstFacilityService
    {
        public async Task<GetAllFacilityResponse> GetAllFacility(GetAllFacilityRequest param)
        {
            GetAllFacilityResponse res = (await httpClient.GetAsync<List<MstFacilityEntity>>(AppSettingConfig.ApplicationConfigJSON.API.GET_ALL_FACILITY, param)).ToClass<List<MstFacilityEntity>, GetAllFacilityResponse>();
            return res;
        }
    }
}
