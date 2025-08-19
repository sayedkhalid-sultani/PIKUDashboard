using FluentValidation;
using GenericMinimalApi.Models;

namespace GenericMinimalApi.Validators
{
    public class ProductDtoValidator : AbstractValidator<ProductDto>
    {
        public ProductDtoValidator()
        {
            RuleFor(p => p.Name)
                .NotEmpty().WithMessage("Product name is required.")
                .MaximumLength(100).WithMessage("Name must not exceed 100 characters.");

            RuleFor(p => p.Price)
                .GreaterThan(0).WithMessage("Price must be greater than zero.");

            RuleFor(p => p.DepartmentId)
                .GreaterThan(0).WithMessage("Valid department is required.");
        }
    }
}
