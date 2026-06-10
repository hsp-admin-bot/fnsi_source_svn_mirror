using NKKWeightScaleDB.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NKKWeightScaleDB.Interfaces
{

    public interface ITreatmentConditionService : IBaseService<Treatment_condition>
    {
        Treatment_condition AddOrUpdate(Treatment_condition treatment_condition);
    }
}
