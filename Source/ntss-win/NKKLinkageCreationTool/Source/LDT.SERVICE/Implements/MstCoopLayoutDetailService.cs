using LDT.SERVICE.Configuration;
using LDT.SERVICE.Extendsions;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Requests;
using LDT.SERVICE.Models.Responses;
using System.Threading.Tasks;

namespace LDT.SERVICE.Implements
{
  public class MstCoopLayoutDetailService : BaseService<MstCoopLayoutDetailEntity>, IMstCoopLayoutDetailService
  {
    public async Task<CreateOrUpdateCoopLayoutDetailResponse> CreateOrUpdateAsync(CreateOrUpdateMstCoopLayoutDetailRequest param)
    {
      BaseResponse<bool> res = (await httpClient.PostAsync<bool>(AppSettingConfig.ApplicationConfigJSON.API.CREATE_OR_UPDATE_MST_COOP_LAYOUT_DETAIL, param, true, true));
      CreateOrUpdateCoopLayoutDetailResponse result = new CreateOrUpdateCoopLayoutDetailResponse()
      {
        Data = res.Data,
        Error = res.Error,
        Exception = res.Exception,
        StatusCode = res.StatusCode
      };
      return result;
    }

    public async Task<GetByMstCoopLayoutDetailResponse> GetBy(GetByMstCoopLayoutDetailRequest param)
    {
      GetByMstCoopLayoutDetailResponse result = (await httpClient.PostAsync<MstCoopLayoutDetailEntity>(AppSettingConfig.ApplicationConfigJSON.API.GET_BY_MST_COOP_LAYOUT_DETAIL, param, true, true)).ToClass<MstCoopLayoutDetailEntity, GetByMstCoopLayoutDetailResponse>();
      return result;
    }
  }
}
