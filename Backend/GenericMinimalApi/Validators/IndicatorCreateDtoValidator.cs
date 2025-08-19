using FluentValidation;
using GenericMinimalApi.Models;

namespace GenericMinimalApi.Validators
{
    public class IndicatorCreateDtoValidator : AbstractValidator<IndicatorCreateDto>
    {
        public IndicatorCreateDtoValidator()
        {
            RuleFor(x => x.Name).NotEmpty();
            RuleFor(x => x.DepartmentId).GreaterThan(0);
            RuleFor(x => x.Value).NotNull();
            RuleFor(x => x.EffectiveDate).LessThanOrEqualTo(DateTime.Today.AddDays(1));
        }
    }
}
