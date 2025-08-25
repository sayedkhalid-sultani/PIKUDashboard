namespace GenericMinimalApi.Models.Filters
{
    /// <summary>
    /// General-purpose filter for SPs. Keep everything optional.
    /// Any property that ends with "*Ids" will automatically be sent as a TVP (dbo.IntList).
    /// </summary>
    public sealed class CommonFilterDto
    {
        // Common scalar filters
        public int? Id { get; set; }
        public int? DepartmentId { get; set; }
        public int? UserId { get; set; } // NOTE: you normally don't need to send this; your service adds it

        // Multi-selects (auto-TV P because of "*Ids")
        public List<int>? Ids { get; set; }
        public List<int>? DepartmentIds { get; set; }
        public List<int>? RoleIds { get; set; }

        public int? CriteriaId { get; set; }

    }
}
