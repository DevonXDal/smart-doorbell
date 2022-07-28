using DoorbellPiWeb.Data;
using DoorbellPiWeb.Helpers.Services;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Db.MtoM;
using DoorbellPiWeb.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.PlatformAbstractions;
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
        options.SaveToken = true;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = false,
            ValidateAudience = false,
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
builder.Services.AddScoped<FileHandler>();

// Provide the handlers for accessing other Web servers
builder.Services.AddScoped<DoorbellAPIHandler>();

builder.Services.AddControllers();

// Add a HttpClient for use with making Web requests
builder.Services.AddHttpClient();


// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    var filePath = Path.Combine(PlatformServices.Default.Application.ApplicationBasePath, "DoorbellPiWeb.xml");
    c.IncludeXmlComments(filePath);

    // https://stackoverflow.com/questions/54267137/actions-require-unique-method-path-combination-for-swagger
    c.ResolveConflictingActions(descriptions => descriptions.First());
}); 



var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();

    // https://www.codegrepper.com/code-examples/whatever/xmlhttprequest+error+flutter+web+localhost - Done for debug Flutter Web to connect
    app.Use((context, next) =>
    {
        context.Response.Headers["Access-Control-Allow-Origin"] = "https://localhost:58881/";
        context.Response.Headers["Access-Control-Allow-Credentials"] = "true";
        context.Response.Headers["Access-Control-Allow-Headers"] = "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale,X-Requested-With,Accept";
        context.Response.Headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS";
        return next.Invoke();
    });
} else
{
    app.UseHttpsRedirection();
}


app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
