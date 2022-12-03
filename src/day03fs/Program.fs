open System.IO

/// Flip the arguments of f (the C combinator)
let flip f a b = f b a

/// A map of char -> value
let letterValue =
    lazy
        [| 'a' .. 'z' |]
        |> flip Array.append [| 'A' .. 'Z' |]
        |> flip Array.zip [| 1..52 |]
        |> Map.ofArray

let partA lines =
    let projection (line: string) =
        // Split the array into halves, and then turn each half into a set
        let split = line.Length / 2

        let toS (s: string) = s.ToCharArray() |> Set.ofArray
        let s1 = toS line[ .. split - 1 ]
        let s2 = toS line[ split .. ]

        // Find the intersection of the sets
        Set.intersect s1 s2

    // Get a seq of the intersection of halves for each rucksack
    lines
    |> Seq.collect projection
    // And sum by the letter value
    |> Seq.sumBy (flip Map.find letterValue.Value)

let partB lines =
    let projection (bags: string[]) =
        // Turn each string into a set and then intersect them
        bags
        |> Array.map (Set.ofSeq)
        |> Set.intersectMany
        // Then find the value of the only letter
        |> Set.toArray
        |> Array.exactlyOne
        |> flip Map.find letterValue.Value

    lines
    // Non-overlapping windows are called chunks in F#
    |> Seq.chunkBySize 3
    |> Seq.sumBy projection


[<EntryPoint>]
let main argv =
    let lines = argv[1] |> File.ReadLines

    partA lines
    |> printfn "%i"

    partB lines
    |> printfn "%i"

    0
