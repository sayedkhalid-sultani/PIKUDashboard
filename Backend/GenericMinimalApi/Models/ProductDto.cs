// Models/ProductDto.cs
namespace GenericMinimalApi.Models
{
    public class ProductDto 
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public decimal Price { get; set; }
    public int DepartmentId { get; set; }
}

// Models/ProductCreateDto.cs (insert – no Id)
public class ProductCreateDto
{
    public string Name { get; set; } = "";
    public decimal Price { get; set; }
    public int DepartmentId { get; set; }
}

// Models/ProductUpdateDto.cs (update – no Id in body)
public class ProductUpdateDto
{
    public string Name { get; set; } = "";
    public decimal Price { get; set; }
    public int DepartmentId { get; set; }
}
}
