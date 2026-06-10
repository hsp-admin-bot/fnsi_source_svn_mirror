using LDT.SERVICE.Configuration;
using LDT.SERVICE.Cookies;
using LDT.SERVICE.Extendsions;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Requests;
using LDT.SERVICE.Models.Responses;
using System;
using System.Net;
using System.Threading.Tasks;

namespace LDT.SERVICE.Implements
{
  public class UserService : BaseService<UserEntity>, IUserService
    {
        public void ClearCookie()
        {
            this.SetCookie(new CookieContainer());
        }

        public async Task<LoginResponse> LoginAsync(string username, string password)
        {
            var usr = new LoginRequest()
            {
                FacilityCd = AppSettingConfig.ApplicationConfigJSON.API.FACILITY_CD,
                Password = password,
                UserId = username
            };
            LoginResponse result = (await httpClient.PostAsync<LoginResponseEntity>(AppSettingConfig.ApplicationConfigJSON.API.LOGIN_URL, usr, false)).ToClass<LoginResponseEntity, LoginResponse>();
            if (result != null && result.StatusCode == HttpStatusCode.OK)
            {
                SetCookie(this.httpClient.Cookies);
            }
            return result;
        }

        private void SetCookie(CookieContainer cookies)
        {
            try
            {
                CookieManager.SetCookie(cookies);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
        }
    }
}
