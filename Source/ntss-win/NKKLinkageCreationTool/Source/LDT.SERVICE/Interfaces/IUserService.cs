using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Responses;
using System.Threading.Tasks;

namespace LDT.SERVICE.Interfaces
{
  public interface IUserService : IBaseService<UserEntity>
  {
    Task<LoginResponse> LoginAsync(string username, string password);

    void ClearCookie();
  }
}
