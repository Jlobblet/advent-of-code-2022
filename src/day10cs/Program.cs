using AoC202210;

public static class Program
{
    public static void Main(string[] args)
    {
        IServiceCollection serviceCollection = 
            new ServiceCollection()
            .AddSingleton<IInstructionParser>(new InstructionParser())
            .AddSingleton<IRegisterAccumulator>(_ => new RegisterAccumulatorCollection(new SignalStrengthAccumulator(), new CrtDisplayAccumulator()))
            .AddSingleton<IInstructionHandler>(provider => new CrtVideoSystemInstructionHandler(provider.GetRequiredService<IRegisterAccumulator>()))
            .AddTransient<IFileProcessor>(provider => new CrtVideoSystemFileProcessor(provider.GetRequiredService<IInstructionParser>(), provider.GetRequiredService<IInstructionHandler>()));
        var serviceProviderOptions = new ServiceProviderOptions
        {
            ValidateScopes = true,
        };
        IServiceProvider serviceProvider = serviceCollection.BuildServiceProvider(serviceProviderOptions);

        IEnumerable<string> lines = File.ReadLines(args[0]);
        var fileProcessor = serviceProvider.GetRequiredService<IFileProcessor>();
        fileProcessor.ProcessFile(lines);
    }
}
