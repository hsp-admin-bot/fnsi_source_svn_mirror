using CsvHelper;
using CsvHelper.Configuration;
using NKKWeightScaleDB.Interfaces;
using NKKWeightScaleDB.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

namespace NKKWeightScaleDB.Services
{
    public class CsvService : ICsvService
    {
        
        private string BASE_URL =string.Empty;
        public CsvService()
        {
            DBConfig dbConfig = new DBConfig();
            BASE_URL = dbConfig.GetCSVURL();
        }

        private List<T> ReadDataInCSV<T>(string path, int retry = 3) where T : class
        {
            var pathFile = path;
            List<T> result = new List<T>();
            try
            {
                using (var stream = File.Open(path, FileMode.Open, FileAccess.Read, FileShare.Read))
                {
                    using (StreamReader streamReader = new StreamReader(stream, Encoding.GetEncoding("shift-jis")))
                    using (CsvReader csvReader = new CsvReader(streamReader, CultureInfo.InvariantCulture))
                    {
                        csvReader.Configuration.HasHeaderRecord = false;
                        result = csvReader.GetRecords<T>().ToList();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(nameof(CsvService), ex);
                retry--;
                if (retry <= 0)
                {
                    return result;
                }
                return ReadDataInCSV<T>(path, retry);
            }
            return result;
        }

        private string CleanFileName(string fileName)
        {
            string invalid = new string(Path.GetInvalidFileNameChars()) + new string(Path.GetInvalidPathChars());

            foreach (char c in invalid)
            {
                if (c.CompareTo('\\') < 0)
                    fileName = fileName.Replace(c.ToString(), "");
            }
            return fileName;
        }

        public TModel Add<TModel>(TModel data, int retry = 3) where TModel : class
        {
            string path = CreateFileIfDontExist<TModel>();
            TModel result = data;
            try
            {
                var currentData = GetAll<TModel>();
                currentData.Add(data);
                bool isSuccess = ClearAll<TModel>(3);
                using (var stream = new StreamWriter(path,true, Encoding.GetEncoding("utf-8")))
                {
                    using (var csv = new CsvWriter(stream, CultureInfo.InvariantCulture))
                    {
                        csv.Configuration.HasHeaderRecord = false;
                        csv.WriteRecords(currentData);
                        //stream.WriteLine("\n");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(nameof(Add), ex);
                retry--;
                if (retry <= 0)
                {
                    return null;
                }
                return Add<TModel>(data, retry);
            }
            return result;
        }

        public List<TModel> AddRange<TModel>(List<TModel> data, int retry = 3) where TModel : class
        {
            string path = CreateFileIfDontExist<TModel>();
            List<TModel> result = data;
            try
            {
                using (var stream = new StreamWriter(path, true, Encoding.GetEncoding("utf-8")))
                {
                    using (var csv = new CsvWriter(stream, CultureInfo.InvariantCulture))
                    {
                        csv.Configuration.HasHeaderRecord = false;
                        csv.WriteRecords(data);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(nameof(AddRange), ex);
                retry--;
                if (retry <= 0)
                {
                    return null;
                }
                return AddRange<TModel>(data, retry);
            }
            return result;
        }

        private string CreateFileIfDontExist<TModel>()
        {
            string fileName = typeof(TModel).FullName.ToUpper() + ".csv";
            bool IsExists = System.IO.Directory.Exists(this.BASE_URL);
            if (!IsExists)
                System.IO.Directory.CreateDirectory(this.BASE_URL);
            string path = Path.Combine(this.BASE_URL, fileName);
            if (!File.Exists(path))
            {
                FileStream newFile = File.Create(path);
                newFile.Close();
            }
            return path;
        }

        public bool ClearAll<TModel>(int retry = 3)
        {
            bool result = true;
            try
            {
                string fileName = typeof(TModel).FullName.ToUpper() + ".csv";
                bool IsExists = System.IO.Directory.Exists(this.BASE_URL);
                if (!IsExists)
                    System.IO.Directory.CreateDirectory(this.BASE_URL);
                string path = Path.Combine(this.BASE_URL, fileName);
                if (File.Exists(path))
                {
                    File.Delete(path);
                }
                FileStream newFile = File.Create(path);
                newFile.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                retry--;
                if (retry <= 0)
                {
                    return false;
                }
                return ClearAll<TModel>(retry);
            }

            return result;
        }

        public TModel Update<TModel>(TModel model, int retry = 3) where TModel : BaseEntity
        {
            TModel result = model;
            try
            {
                string path = CreateFileIfDontExist<TModel>();
                var data = ReadDataInCSV<TModel>(path) ?? new List<TModel>();
                var index = data.FindIndex(item => item.id == model.id);
                if (index == -1)
                {
                    return null;
                }
                data[index] = model;
                bool IsSuccess = ClearAll<TModel>();
                if (IsSuccess)
                {
                    if (AddRange(data) == null)
                    {
                        return null;
                    };
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                retry--;
                if (retry <= 0)
                {
                    return null;
                }
                return Update<TModel>(model, retry);
            }

            return result;
        }

        public List<TModel> UpdateRange<TModel>(List<TModel> models, int retry = 3) where TModel : BaseEntity
        {
            List<TModel> result = models;
            try
            {
                string path = CreateFileIfDontExist<TModel>();
                var data = ReadDataInCSV<TModel>(path) ?? new List<TModel>();
                foreach (var item in models)
                {
                    var index = data.FindIndex(x => x.id == item.id);
                    if (index == -1)
                    {
                        return null;
                    }
                    data[index] = item;
                }
                bool IsSuccess = ClearAll<TModel>();
                if (IsSuccess)
                {
                    if (AddRange(data) == null)
                    {
                        return null;
                    };
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                retry--;
                if (retry <= 0)
                {
                    return null;
                }
                return UpdateRange<TModel>(models, retry);
            }
            return result;
        }

        public List<TModel> GetAll<TModel>(int retry = 3) where TModel : class
        {
            List<TModel> models = new List<TModel>();
            try
            {
                string path = CreateFileIfDontExist<TModel>();
                models = ReadDataInCSV<TModel>(path);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                retry--;
                if (retry <= 0)
                {
                    return models;
                }
                return GetAll<TModel>(retry);
            }

            return models;
        }

        public TModel Delete<TModel>(TModel model, int retry = 3) where TModel : BaseEntity
        {
            TModel result = model;
            try
            {
                string path = CreateFileIfDontExist<TModel>();
                var data = ReadDataInCSV<TModel>(path) ?? new List<TModel>();
                var index = data.FindIndex(item => item.id == model.id);
                if (index == -1)
                {
                    return null;
                }
                data.RemoveAt(index);
                bool IsSuccess = ClearAll<TModel>();
                if (IsSuccess)
                {
                    if (AddRange(data) == null)
                    {
                        return null;
                    };
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                retry--;
                if (retry <= 0)
                {
                    return null;
                }
                return Delete<TModel>(model, retry);
            }
            return result;
        }

        public List<TModel> DeleteRange<TModel>(List<TModel> models, int retry = 3) where TModel : BaseEntity
        {
            List<TModel> result = models;
            try
            {
                string path = CreateFileIfDontExist<TModel>();
                var data = ReadDataInCSV<TModel>(path) ?? new List<TModel>();
                foreach (var item in models)
                {
                    var index = data.FindIndex(x => x.id == item.id);
                    if (index == -1)
                    {
                        return null;
                    }
                    data.RemoveAt(index);
                }
                bool IsSuccess = ClearAll<TModel>();
                if (IsSuccess)
                {
                    if (AddRange(data) == null)
                    {
                        return null;
                    };
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                retry--;
                if (retry <= 0)
                {
                    return null;
                }
                return DeleteRange<TModel>(models, retry);
            }

            return result;
        }

        private CsvConfiguration ConfigMapping<T>() where T : ClassMap
        {
            CsvConfiguration csvConfig = new CsvConfiguration(CultureInfo.InvariantCulture);
            csvConfig.RegisterClassMap<T>();
            return csvConfig;
        }
    }
}