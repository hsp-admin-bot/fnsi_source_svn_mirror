using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Requests;
using LDT.SERVICE.Models.Responses;
using System.Threading.Tasks;

namespace LDT.SERVICE.Interfaces
{
  public interface IMstCoopLayoutService : IBaseService<MstCoopLayoutEntity>
  {
    Task<GetAllMstCoopLayoutResponse> GetAllFacilityAsync(GetAllMstCoopLayoutRequest param);

    Task<GetByMstCoopLayoutResponse> GetByFacilityAsync(GetByMstCoopLayoutRequest param);

    Task<GetAllMstCoopLayoutResponse> GetAllByFilterAsync(GetAllByFilterAsyncRequest param);

    Task<CreateOrUpdateCoopLayoutResponse> CreateOrUpdateAsync(CreateOrUpdateCoopLayoutRequest param);
  }
}
