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
  public class MstCoopLayoutService : BaseService<MstCoopLayoutEntity>, IMstCoopLayoutService
  {
    public async Task<CreateOrUpdateCoopLayoutResponse> CreateOrUpdateAsync(CreateOrUpdateCoopLayoutRequest param)
    {
      BaseResponse<bool> res = (await httpClient.PostAsync<bool>(AppSettingConfig.ApplicationConfigJSON.API.CREATE_OR_UPDATE_MST_COOP_LAYOUT, param, true, true));
      CreateOrUpdateCoopLayoutResponse result = new CreateOrUpdateCoopLayoutResponse()
      {
        Data = res.Data,
        Error = res.Error,
        Exception = res.Exception,
        StatusCode = res.StatusCode
      };
      return result;
    }

    public async Task<GetAllMstCoopLayoutResponse> GetAllByFilterAsync(GetAllByFilterAsyncRequest param)
    {
      GetAllMstCoopLayoutResponse result = (await httpClient.PostAsync<List<MstCoopLayoutEntity>>(AppSettingConfig.ApplicationConfigJSON.API.GET_ALL_MST_COOP_LAYOUT, param, true, true)).ToClass<List<MstCoopLayoutEntity>, GetAllMstCoopLayoutResponse>();
      return result;
    }

    public async Task<GetAllMstCoopLayoutResponse> GetAllFacilityAsync(GetAllMstCoopLayoutRequest param)
    {
      GetAllMstCoopLayoutResponse result = (await httpClient.GetAsync<List<MstCoopLayoutEntity>>(AppSettingConfig.ApplicationConfigJSON.API.GET_ALL_MST_COOP_LAYOUT, param)).ToClass<List<MstCoopLayoutEntity>, GetAllMstCoopLayoutResponse>();
      return result;
    }

    public async Task<GetByMstCoopLayoutResponse> GetByFacilityAsync(GetByMstCoopLayoutRequest param)
    {
      GetByMstCoopLayoutResponse result = (await httpClient.GetAsync<MstCoopLayoutEntity>(AppSettingConfig.ApplicationConfigJSON.API.GET_ALL_MST_COOP_LAYOUT, param)).ToClass<MstCoopLayoutEntity, GetByMstCoopLayoutResponse>(); ;

      return result;
    }
  }
}
