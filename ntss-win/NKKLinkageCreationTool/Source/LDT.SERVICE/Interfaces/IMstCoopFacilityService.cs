using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Requests;
using LDT.SERVICE.Models.Responses;
using System.Threading.Tasks;

namespace LDT.SERVICE.Interfaces
{
  public interface IMstCoopFacilityService : IBaseService<MstCoopFacilityEntity>
    {
        Task<GetByMstCoopFacilityResponse> GetBy(GetByMstCoopFacilityRequest param);
    }
}
