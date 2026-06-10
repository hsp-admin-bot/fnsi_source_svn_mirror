using NKKWeightScaleDB.Models;

namespace NKKWeightScaleDB.Interfaces
{
    public interface IPatientService : IBaseService<Patient>
    {
        Patient AddOrUpdate(Patient patient);
    }
}