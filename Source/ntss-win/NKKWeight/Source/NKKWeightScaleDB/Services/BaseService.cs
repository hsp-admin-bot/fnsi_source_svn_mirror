using NKKWeightScaleDB.Interfaces;
using NKKWeightScaleDB.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace NKKWeightScaleDB.Services
{
    public class BaseService<T> : IBaseService<T> where T : BaseEntity
    {
        private readonly ICsvService _csvService;

        public BaseService()
        {
            _csvService = new CsvService();
        }

        private T InitId(T model)
        {
            model.id = Guid.NewGuid().ToString();
            return model;
        }

        private List<T> InitId(List<T> models)
        {
            models = models.Select(item => { item.id = Guid.NewGuid().ToString(); return item; }).ToList();

            return models;
        }

        public virtual List<T> AddRange(List<T> item)
        {
            try
            {
                item = InitId(item);
                var result = this._csvService.AddRange(item);
                return result;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public virtual async Task<List<T>> AddRangeAsync(List<T> item)
        {
            return await Task.Run(() =>
            {
                try
                {
                    item = InitId(item);
                    var result = this._csvService.AddRange(item);
                    return result;
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex);
                    return null;
                }
            });
        }

        public virtual T Create(T item)
        {
            try
            {
                item = InitId(item);
                var result = this._csvService.Add(item);
                return result;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public virtual async Task<T> CreateAsync(T item)
        {
            return await Task.Run(() =>
            {
                try
                {
                    item = InitId(item);
                    var result = this._csvService.Add(item);
                    return result;
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex);
                    return null;
                }
            });
        }

        public virtual T Delete(T item)
        {
            try
            {
                return this._csvService.Delete<T>(item);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public virtual async Task<T> DeleteAsync(T item)
        {
            try
            {
                return await Task.Run(() => this._csvService.Delete(item));
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public virtual List<T> DeleteRange(List<T> item)
        {
            try
            {
                return this._csvService.DeleteRange(item);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public virtual async Task<List<T>> DeleteRangeAsync(List<T> items)
        {
            try
            {
                return await Task.Run(() => this._csvService.DeleteRange(items));
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public virtual List<T> GetAll()
        {
            return this._csvService.GetAll<T>();
        }

        public virtual async Task<List<T>> GetAllAsync()
        {
            return await Task.Run(() => this._csvService.GetAll<T>());
        }

        public virtual List<T> UpdateRange(List<T> items)
        {
            try
            {
                return this._csvService.UpdateRange(items);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public virtual async Task<List<T>> UpdateRangeAsync(List<T> items)
        {
            try
            {
                return await Task.Run(() => this._csvService.UpdateRange(items));
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public virtual bool ClearAllData()
        {
            return this._csvService.ClearAll<T>();
        }

        public virtual async Task<bool> ClearAllDataAsync()
        {
            return await Task.Run(() => this._csvService.ClearAll<T>());
        }

        public T Update(T item)
        {
            try
            {
                return this._csvService.Update(item);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }

        public async Task<T> UpdateAsync(T item)
        {
            try
            {
                return await Task.Run(() => this._csvService.Update(item));
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return null;
            }
        }
    }
}