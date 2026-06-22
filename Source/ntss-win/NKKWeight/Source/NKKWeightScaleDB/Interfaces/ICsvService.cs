using NKKWeightScaleDB.Models;
using System.Collections.Generic;

namespace NKKWeightScaleDB.Interfaces
{
    public interface ICsvService
    {
        TModel Add<TModel>(TModel data, int retry = 0) where TModel : class;

        List<TModel> AddRange<TModel>(List<TModel> data, int retry = 0) where TModel : class;

        bool ClearAll<TModel>(int retry = 0);

        TModel Update<TModel>(TModel model, int retry = 0) where TModel : BaseEntity;

        List<TModel> UpdateRange<TModel>(List<TModel> models, int retry = 0) where TModel : BaseEntity;

        List<TModel> GetAll<TModel>(int retry = 0) where TModel : class;

        TModel Delete<TModel>(TModel model, int retry = 0) where TModel : BaseEntity;

        List<TModel> DeleteRange<TModel>(List<TModel> model, int retry = 0) where TModel : BaseEntity;
    }
}