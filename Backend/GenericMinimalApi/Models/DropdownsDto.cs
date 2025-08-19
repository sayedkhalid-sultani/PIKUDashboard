// Models/LookupFilterDto.cs
namespace GenericMinimalApi.Models
{
    public sealed class LookupFilterDto
{
    public string? Dropdown { get; set; }
     public int[]?  ParentIds { get; set; } 
}

    public sealed class LookupOptionDto
    {
        public int    Value { get; set; }
        public string Label { get; set; } = string.Empty;
    }
}
