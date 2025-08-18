using Debezium.Data;
using Debezium.Data.Entities;

namespace Debezium.Services;

public class RandomCustomerGenerator(IServiceProvider serviceProvider) : BackgroundService
{
    private static readonly string[] FirstNames = { "John", "Jane", "Alice", "Bob", "Michael", "Emma" };
    private static readonly string[] LastNames = { "Smith", "Doe", "Johnson", "Brown", "Davis", "Wilson" };
    private static readonly string[] Streets = { "Main St", "Maple Ave", "Oak St", "Pine Rd", "Cedar Ln" };
    private static readonly string[] Genders = { "Male", "Female", "Other" };
    private readonly Random _random = new Random();

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var customer = GenerateRandomCustomer();

            using (var scope = serviceProvider.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                dbContext.Customers.Add(customer);
                await dbContext.SaveChangesAsync(stoppingToken);
            }

            Console.WriteLine($"Added customer: {customer.FirstName} {customer.LastName}, {customer.Email}");

            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }

    private Customer GenerateRandomCustomer()
    {
        var firstName = FirstNames[_random.Next(FirstNames.Length)];
        var lastName = LastNames[_random.Next(LastNames.Length)];
        var email = $"{firstName.ToLower()}.{lastName.ToLower()}{_random.Next(100, 999)}@example.com";
        var address = $"{_random.Next(100, 999)} {Streets[_random.Next(Streets.Length)]}";
        var phone = $"+1{_random.Next(1000000000, 1999999999)}";
        var birthDate = DateTime.UtcNow.AddYears(-_random.Next(18, 60)).AddDays(_random.Next(0, 365));
        var gender = Genders[_random.Next(Genders.Length)];

        return new Customer
        {
            Id = Guid.NewGuid(),
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Address = address,
            PhoneNumber = phone,
            BirthDate = birthDate,
            Gender = gender
        };
    }
}