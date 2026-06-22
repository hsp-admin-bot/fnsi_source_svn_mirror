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
  public class SysDataSetService : BaseService<SysDataSetEntity>, ISysDataSetService
  {
    public async Task<GetAllSysDataSetResponse> GetAllAsync(GetAllSysDataSetRequest param)
    {
      GetAllSysDataSetResponse result = (await httpClient.GetAsync<List<SysDataSetEntity>>(AppSettingConfig.ApplicationConfigJSON.API.GET_ALL_DATA_SET, param)).ToClass<List<SysDataSetEntity>, GetAllSysDataSetResponse>();
      return result;
    }
  }
}
