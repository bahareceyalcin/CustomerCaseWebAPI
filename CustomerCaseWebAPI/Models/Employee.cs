using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CustomerCaseWebAPI.Models
{
    public class Employee
    {
        public int Id { get; set; }
        public string TCKN { get; set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public double Salary { get; set; }
    }
}
