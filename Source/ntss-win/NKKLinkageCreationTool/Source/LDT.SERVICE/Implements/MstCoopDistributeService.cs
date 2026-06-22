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
  public class MstCoopDistributeService : BaseService<MstCoopDistributeEntity>, IMstCoopDistributeService
  {
    public async Task<GetByMstCoopDistributeResponse> GetBy(GetByMstCoopDistributeRequest param)
    {
      var res = await httpClient.PostAsync<BaseContent<List<MstCoopDistributeEntity>>>(AppSettingConfig.ApplicationConfigJSON.API.GET_BY_MST_COOP_DISTRIBUTE, param, true, true);
      GetByMstCoopDistributeResponse result = res.ToClass<BaseContent<List<MstCoopDistributeEntity>>, GetByMstCoopDistributeResponse>();
      return result;
    }
  }
}
