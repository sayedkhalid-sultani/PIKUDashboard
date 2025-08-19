namespace GenericMinimalApi.Models
{
    public class IndicatorCreateDto
    {
        public string Name { get; set; } = string.Empty;
        public int DepartmentId { get; set; }
        public decimal Value { get; set; }
        public DateTime EffectiveDate { get; set; }
    }
}