using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Requests;
using LDT.SERVICE.Models.Responses;
using System.Threading.Tasks;

namespace LDT.SERVICE.Interfaces
{
  public interface IMstCoopLayoutDetailService : IBaseService<MstCoopLayoutDetailEntity>
  {
    Task<GetByMstCoopLayoutDetailResponse> GetBy(GetByMstCoopLayoutDetailRequest param);

    Task<CreateOrUpdateCoopLayoutDetailResponse> CreateOrUpdateAsync(CreateOrUpdateMstCoopLayoutDetailRequest param);
  }
}
