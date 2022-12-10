namespace AoC202210;

public interface IFileProcessor
{
    void ProcessLine(string line);

    void ProcessFile(IEnumerable<string> lines);
}
