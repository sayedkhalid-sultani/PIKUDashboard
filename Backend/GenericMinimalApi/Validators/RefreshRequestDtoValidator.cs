using FluentValidation;
using GenericMinimalApi.Models.Auth;

namespace GenericMinimalApi.Validators
{
    public class RefreshRequestDtoValidator : AbstractValidator<RefreshRequestDto>
    {
        public RefreshRequestDtoValidator()
        {
            RuleFor(x => x.RefreshToken)
                .NotEmpty().WithMessage("Refresh token is required.")
                .MinimumLength(16).WithMessage("Refresh token is not valid.");
        }
    }
}
