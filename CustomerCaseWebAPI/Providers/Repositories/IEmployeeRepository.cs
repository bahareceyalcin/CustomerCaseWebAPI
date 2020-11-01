using CustomerCaseWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CustomerCaseWebAPI.Providers.Repositories
{
    public interface IEmployeeRepository
    {
        Task<Employee> GetEmployee(int Id);
        Task<IEnumerable<Employee>> GetEmployee();
    }
}
