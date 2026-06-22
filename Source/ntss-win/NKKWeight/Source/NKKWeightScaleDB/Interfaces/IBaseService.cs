using NKKWeightScaleDB.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace NKKWeightScaleDB.Interfaces
{
    public interface IBaseService<T> where T : BaseEntity
    {
        List<T> GetAll();

        Task<List<T>> GetAllAsync();

        T Create(T item);

        Task<T> CreateAsync(T item);

        T Update(T item);

        Task<T> UpdateAsync(T item);

        T Delete(T item);

        Task<T> DeleteAsync(T item);

        List<T> AddRange(List<T> item);

        Task<List<T>> AddRangeAsync(List<T> item);

        List<T> UpdateRange(List<T> item);

        Task<List<T>> UpdateRangeAsync(List<T> item);

        List<T> DeleteRange(List<T> item);

        Task<List<T>> DeleteRangeAsync(List<T> item);

        bool ClearAllData();

        Task<bool> ClearAllDataAsync();
    }
}