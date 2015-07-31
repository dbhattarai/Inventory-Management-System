using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IMSModel
{
   public class Item
    {
       public string ItemName { get; set; }
       public string unit { get; set; }
       public string company { get; set; }
       public string description { get; set; }
       public int Id { get; set; }

       public decimal quantity { get; set; }
       public decimal Rate { get; set; }
       public decimal amount { get; set; }
    }
}
