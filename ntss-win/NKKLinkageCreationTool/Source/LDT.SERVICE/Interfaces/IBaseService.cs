using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace LDT.SERVICE.Interfaces
{
  public interface IBaseService<T> : IDisposable where T : class
  {
    IQueryable<T> GetAll();

    IQueryable<T> GetBy(Expression<Func<T, bool>> condition);

    T Create(T model);

    T Update(T model);

    T Delete(T model);

    List<T> CreateRange(List<T> models);

    List<T> UpdateRange(List<T> models);

    List<T> DeleteRange(List<T> models);

    IQueryable<T> GetAllAsync();

    IQueryable<T> GetByAsync(Expression<Func<T, bool>> condition);

    Task<T> CreateAsync(T model);

    Task<T> UpdateAsync(T model);

    Task<T> DeleteAsync(T model);

    Task<List<T>> CreateRangeAsync(List<T> models);

    Task<List<T>> UpdateRangeAsync(List<T> models);

    Task<List<T>> DeleteRangeAsync(List<T> models);
  }
}
