// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-26-2021
// ***********************************************************************
// <copyright file="AppSettingConfig.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System.IO;

namespace CoopSettingTool.Service.Configuration
{
    /// <summary>
    /// Class ConfigConstant.
    /// </summary>
    public class ConfigConstant
    {
        /// <summary>
        /// Gets or sets the coop sub cd queries.
        /// </summary>
        /// <value>The coop sub cd queries.</value>
        [JsonProperty("COOP_SUB_CD_QUERIES")]
        public string COOP_SUB_CD_QUERIES { get; set; }
    }

    /// <summary>
    /// Class ConfigApi.
    /// </summary>
    public class ConfigApi
    {
        /// <summary>
        /// Gets or sets the base domain.
        /// </summary>
        /// <value>The base domain.</value>
        [JsonProperty("BASE_DOMAIN")]
        public string BASE_DOMAIN { get; set; }

        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("FACILITY_CD")]
        public string FACILITY_CD { get; set; }

        /// <summary>
        /// Gets or sets the client certifiate search value 1.
        /// </summary>
        /// <value>The client certifiate search value 1.</value>
        [JsonProperty("CLIENT_CERTIFIATE_SEARCH_VALUE_1")]
        public string CLIENT_CERTIFIATE_SEARCH_VALUE_1 { get; set; }

        /// <summary>
        /// Gets or sets the client certifiate search value 2.
        /// </summary>
        /// <value>The client certifiate search value 2.</value>
        [JsonProperty("CLIENT_CERTIFIATE_SEARCH_VALUE_2")]
        public string CLIENT_CERTIFIATE_SEARCH_VALUE_2 { get; set; }
    }

    /// <summary>
    /// Class ApplicationConfigJSON.
    /// </summary>
    public class ApplicationConfigJSON
    {
        /// <summary>
        /// Gets or sets the API.
        /// </summary>
        /// <value>The API.</value>
        [JsonProperty("API")]
        public ConfigApi API { get; set; }

        /// <summary>
        /// Gets or sets the constant.
        /// </summary>
        /// <value>The constant.</value>
        [JsonProperty("CONSTANT")]
        public ConfigConstant CONSTANT { get; set; }
    }

    /// <summary>
    /// Class AppSettingConfig.
    /// </summary>
    public static class AppSettingConfig
    {
        /// <summary>
        /// The application configuration json
        /// </summary>
        private static ApplicationConfigJSON _ApplicationConfigJSON;

        /// <summary>
        /// Gets or sets the application configuration json.
        /// </summary>
        /// <value>The application configuration json.</value>
        public static ApplicationConfigJSON ApplicationConfigJSON
        {
            set
            {
                _ApplicationConfigJSON = value;
            }

            get
            {
                return _ApplicationConfigJSON;
            }
        }

        /// <summary>
        /// Loads the configuration.
        /// </summary>
        /// <returns>ApplicationConfigJSON.</returns>
        public static ApplicationConfigJSON LoadConfig(string path)
        {
            if (ApplicationConfigJSON == default(ApplicationConfigJSON))
            {
                LoadJsonConfig(path);
            }
            return ApplicationConfigJSON;
        }

        /// <summary>
        /// Loads the json configuration.
        /// </summary>
        private static void LoadJsonConfig(string path)
        {
            JsonSerializerSettings jsonSerializerSettings = new JsonSerializerSettings()
            {

            };
            using (StreamReader reader = new StreamReader(path))
            {
                string jsonValue = reader.ReadToEnd();
                ApplicationConfigJSON = JsonConvert.DeserializeObject<ApplicationConfigJSON>(jsonValue);
            }
        }

        public static void SaveConfig(ApplicationConfigJSON applicationConfigJSON, string path)
        {
            using (StreamWriter writer = new StreamWriter(path))
            {
                string jsonValue = JsonConvert.SerializeObject(applicationConfigJSON, Formatting.Indented);
                writer.Write(jsonValue);

            }
        }
    }
}
