using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IMSModel
{
    public class Issued
    {
        public DateTime Date { get; set; }
        public int itemId { get; set; }
        public string unit { get; set; }
        public int quantity { get; set; }
        public float Rate { get; set; }
        public decimal amount { get; set; }
        public int DeptId { get; set; }
        public string ISN { get; set; }
        public string remarks { get; set; }
        public string receivedby { get; set; }
        public string issuedby { get; set; }
        public string Id { get; set; }
        public string receivedId { get; set; }
    }
}
