using FluentValidation;
using GenericMinimalApi.Models.Auth;

namespace GenericMinimalApi.Validators
{
    public class ChangePasswordDtoValidator : AbstractValidator<ChangePasswordDto>
    {
        public ChangePasswordDtoValidator()
        {

            RuleFor(x => x.NewPassword)
                .NotEmpty().WithMessage("New password is required.");

        }
    }
}
