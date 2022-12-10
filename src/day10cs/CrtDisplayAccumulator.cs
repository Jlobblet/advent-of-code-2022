namespace AoC202210;

public class CrtDisplayAccumulator : IRegisterAccumulator
{
#if FANCY_OUTPUT
    private const string OnPixel = "█";
    private const string OffPixel = " ";
#else
    private const string OnPixel = "#";
    private const string OffPixel = ".";
#endif
    private const int NRows = 6;
    private const int NCols = 40;
    private readonly PixelType[,] pixels = new PixelType[NRows, NCols];

    public string Format()
    {
        var stringBuilder = new StringBuilder();
        for (var i = 0; i < NRows; i++)
        {
            for (var j = 0; j < NCols; j++)
            {
                string pixel = pixels[i, j] switch
                {
                    PixelType.On => OnPixel,
                    PixelType.Off => OffPixel,
                    _ => throw new ArgumentOutOfRangeException($"Unknown {nameof(PixelType)} {pixels[i, j]}"),
                };
                stringBuilder.Append(pixel);
            }

            stringBuilder.AppendLine("");
        }

        return stringBuilder.ToString();
    }

    public void Accumulate(int clockCycle, int xValue)
    {
        clockCycle--;
        int row = clockCycle / NCols;
        clockCycle %= NCols;
        if (row >= NRows || clockCycle >= NCols)
        {
            return;
        }
        PixelType pixelType = clockCycle - 1 <= xValue && xValue <= clockCycle + 1 ? PixelType.On : PixelType.Off;
        pixels[row, clockCycle] = pixelType;
    }
}
