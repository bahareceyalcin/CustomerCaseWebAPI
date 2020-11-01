using CustomerCaseWebAPI.Models;
using CustomerCaseWebAPI.Providers.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CustomerCaseWebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EmployeeController : ControllerBase
    {

        private readonly IEmployeeRepository _repository;
        public EmployeeController(IEmployeeRepository repository)
        {
            _repository = repository;
        }


        // GET: api/Employee/id
        [HttpGet("{id}")]
        public async Task<Employee> Get(int Id)
        {
            return await this._repository.GetEmployee(Id);
        }

        // GET: api/Employee
        [HttpGet]
        public async Task<IEnumerable<Employee>> GetEmployee()
        {
            return await this._repository.GetEmployee();
        }



    }
}
