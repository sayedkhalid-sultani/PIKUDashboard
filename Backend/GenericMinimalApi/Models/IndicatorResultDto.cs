

namespace GenericMinimalApi.Models
{
    public class IndicatorResultDto
    {
        public int CriteriaId { get; set; }
        public string CriteriaName { get; set; } = string.Empty;
        public string? CriteriaDescription { get; set; }

        public int ChartConfigId { get; set; }
        public string ChartName { get; set; } = string.Empty;
        public string ChartType { get; set; } = string.Empty;
        public string? ConfigJson { get; set; }

        public int CriteriaIndicatorId { get; set; }
        public int? CriteriaIndicatorParentId { get; set; }
        public string CriteriaIndicatorName { get; set; } = string.Empty;
        public int? OrderIndex { get; set; }
        public string? LocationType { get; set; }
        public string? CriteriaIndicatorDescription { get; set; }
        public string? IndicatorLevel { get; set; }

        public int SubCriteriaId { get; set; }
        public int? SubCriteriaParentId { get; set; }
        public string SubCriteriaName { get; set; } = string.Empty;
        public string? SubCriteriaDescription { get; set; }
        public string? SubCriteriaLevel { get; set; }

        public int SubCriteriaValueId { get; set; }
        public decimal? SubCriteriaValue { get; set; }  // use string? if your column is NVARCHAR
        public string? Period { get; set; }

        public int CalendarId { get; set; }
        public DateTime CalendarDate { get; set; }
        public int Year { get; set; }
        public int Month { get; set; }
        public string MonthName { get; set; } = string.Empty;

        public int LocationId { get; set; }
        public string LocationName { get; set; } = string.Empty;
    }
    }
