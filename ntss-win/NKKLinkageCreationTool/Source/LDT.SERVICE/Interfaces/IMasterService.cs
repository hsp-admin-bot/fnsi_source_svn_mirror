using LDT.SERVICE.Models;
using System.Collections.Generic;

namespace LDT.SERVICE.Interfaces
{
  public interface IMasterService
  {
    List<CoopCdTypeModel> LoadCoopCdType();
  }
}
