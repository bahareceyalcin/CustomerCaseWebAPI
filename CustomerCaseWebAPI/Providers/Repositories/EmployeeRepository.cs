using CustomerCaseWebAPI.Models;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;

namespace CustomerCaseWebAPI.Providers.Repositories
{
    public class EmployeeRepository : IEmployeeRepository
    {
        private readonly string connectionString = "Server=(localdb)\\mssqllocaldb;Database=Company;Trusted_Connection=True;";
        private readonly EmployeeDbContext context;

        public EmployeeRepository(EmployeeDbContext context)
        {
            this.context = context;
        }
        //GET EmployeeById
        public async Task<Employee> GetEmployee(int id)
        {
            using (var sqlConnection = new SqlConnection(connectionString))
            {
                var employee = GetEmployeeByIdFromStoredProcedure(sqlConnection, id);
                return await employee;
            }
            
        }

        //GET AllEmployee
        public async Task<IEnumerable<Employee>> GetEmployee()
        {
            using (var sqlConnection = new SqlConnection(connectionString))
            {
                sqlConnection.Open();
                var employee = GetEmployeeIdFromStoredProcedure(sqlConnection);
                foreach (var item in employee)
                {
                    GetEmployeeSalaryFromStoredProcedure(sqlConnection, item.Id);
                }
                return await GetEmployeeFromStoredProcedure(sqlConnection);

            }
        }

        //Get All Employee from DB via Stored Procedure
        private async Task<IEnumerable<Employee>> GetEmployeeFromStoredProcedure(SqlConnection sqlConnection)
        {
            return await sqlConnection.QueryAsync<Employee>("spGetEmployee",
                   commandType: CommandType.StoredProcedure);
        }
        //Get Employee By Id from DB via Stored Procedure
        private async Task<Employee> GetEmployeeByIdFromStoredProcedure(SqlConnection sqlConnection, int id)
        {
            DynamicParameters parameters = new DynamicParameters();
            parameters.Add("@Id", id);
            sqlConnection.Execute("spCalculateEmployeeSalary", parameters, commandType: CommandType.StoredProcedure);
            IEnumerable<Employee> employee = await sqlConnection.QueryAsync<Employee>("spGetEmployeeById", parameters, commandType: CommandType.StoredProcedure);
            return employee.SingleOrDefault();
        }
        //Get All EmployeeId from DB via Stored Procedure
        private static IEnumerable<Employee> GetEmployeeIdFromStoredProcedure(SqlConnection sqlConnection)
        {

            return sqlConnection.Query<Employee>("spGetEmployeeId",
                   commandType: CommandType.StoredProcedure);
        }
        //Get Employee Salary from DB via Stored Procedure
        private static void GetEmployeeSalaryFromStoredProcedure(SqlConnection sqlConnection, int id)
        {
            DynamicParameters parameters = new DynamicParameters();
            parameters.Add("@Id", id);
            sqlConnection.Execute("spCalculateEmployeeSalary", parameters, commandType: CommandType.StoredProcedure);
        }
    }
}
