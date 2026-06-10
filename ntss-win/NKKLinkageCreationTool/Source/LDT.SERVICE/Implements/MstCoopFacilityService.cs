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
  public class MstCoopFacilityService : BaseService<MstCoopFacilityEntity>, IMstCoopFacilityService
  {
    public async Task<GetByMstCoopFacilityResponse> GetBy(GetByMstCoopFacilityRequest param)
    {
      GetByMstCoopFacilityResponse result = (await httpClient.PostAsync<BaseContent<List<MstCoopFacilityEntity>>>(AppSettingConfig.ApplicationConfigJSON.API.GET_BY_MST_COOP_FACILITY, param, true, true)).ToClass<BaseContent<List<MstCoopFacilityEntity>>, GetByMstCoopFacilityResponse>();
      return result;
    }
  }
}
