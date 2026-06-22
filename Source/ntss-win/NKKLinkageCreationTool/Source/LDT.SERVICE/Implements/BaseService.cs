using LDT.SERVICE.Interfaces;
using Microsoft.Win32.SafeHandles;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

namespace LDT.SERVICE.Implements
{
  public class BaseService<TModel> : IBaseService<TModel> where TModel : class
    {
        public IBaseHttpClient httpClient;

        // Flag: Has Dispose already been called?
        private bool disposed = false;

        // Instantiate a SafeHandle instance.
        private SafeHandle handle = new SafeFileHandle(IntPtr.Zero, true);

        public BaseService()
        {
            httpClient = new BaseHttpClient();
        }

        public virtual TModel Create(TModel model)
        {
            throw new NotImplementedException();
        }

        public Task<TModel> CreateAsync(TModel model)
        {
            throw new NotImplementedException();
        }

        public virtual List<TModel> CreateRange(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        public Task<List<TModel>> CreateRangeAsync(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        public virtual TModel Delete(TModel model)
        {
            throw new NotImplementedException();
        }

        public Task<TModel> DeleteAsync(TModel model)
        {
            throw new NotImplementedException();
        }

        public virtual List<TModel> DeleteRange(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        public Task<List<TModel>> DeleteRangeAsync(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        // Public implementation of Dispose pattern callable by consumers.
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        // Protected implementation of Dispose pattern.
        protected virtual void Dispose(bool disposing)
        {
            if (disposed)
                return;

            if (disposing)
            {
                handle.Dispose();
                // Free any other managed objects here.
                //
            }

            disposed = true;
        }

        public virtual IQueryable<TModel> GetAll()
        {
            throw new NotImplementedException();
        }

        public IQueryable<TModel> GetAllAsync()
        {
            throw new NotImplementedException();
        }

        public virtual IQueryable<TModel> GetBy(Expression<Func<TModel, bool>> condition)
        {
            throw new NotImplementedException();
        }

        public IQueryable<TModel> GetByAsync(Expression<Func<TModel, bool>> condition)
        {
            throw new NotImplementedException();
        }

        public virtual TModel Update(TModel model)
        {
            throw new NotImplementedException();
        }

        public Task<TModel> UpdateAsync(TModel model)
        {
            throw new NotImplementedException();
        }

        public virtual List<TModel> UpdateRange(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        public Task<List<TModel>> UpdateRangeAsync(List<TModel> models)
        {
            throw new NotImplementedException();
        }
    }
}
