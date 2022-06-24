using DoorbellPiWeb.Data;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Db.MtoM;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddJsonFile("secrets.json", true).AddEnvironmentVariables();

// ----- Add authentication capabilities using Json web tokens -----
builder.Services.AddAuthentication(opt => {
    opt.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    opt.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["WebServerURL"],
            ValidAudience = builder.Configuration["WebServerURL"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JWTServerKey"]))
        };
    });


// ----- Add database and model access -----
var mainConnectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// https://stackoverflow.com/questions/55432473/transient-failure-handling-in-net-core-2-1-mvc-for-mysql-database - Sir Crusher for MariaDb
builder.Services.AddDbContext<DoorbellDbContext>(options =>
{
    options.UseMySql(mainConnectionString,
        new MariaDbServerVersion(new Version(10, 6, 7)), // Hard coded for now to prevent fatal exceptions when database is unreachable
        mySqlOptions =>
        {
            mySqlOptions.EnableRetryOnFailure(
            maxRetryCount: 10,
            maxRetryDelay: TimeSpan.FromSeconds(30),
            errorNumbersToAdd: null);
        });
});

// Device connection models
builder.Services.AddScoped<RepositoryBase<DoorbellConnection>>();
builder.Services.AddScoped<RepositoryBase<AppConnection>>();

// Supporting models
builder.Services.AddScoped<RepositoryBase<VideoChat>>();
builder.Services.AddScoped<RepositoryBase<RelatedFile>>();
builder.Services.AddScoped<RepositoryBase<DoorbellStatus>>();

// Many-to-Many models
builder.Services.AddScoped<RepositoryBase<AppConnectionToVideoChat>>();

// UnitOfWork to provide decoupling
builder.Services.AddScoped<UnitOfWork>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();



var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
