USING:
  ascii
  environment
  io io.encodings.utf8 io.files
  kernel
  math math.parser
  prettyprint
  sequences sequences.deep
  splitting
  vectors
 ;
IN: day05

TUPLE: instruction
  { count  integer }
  { source integer }
  { dest   integer } ;

C: <instruction> instruction

: array3 ( arr -- x y z )
  [ 0 swap nth ] [ 1 swap nth ] [ 2 swap nth ]
  ! tri is a "cleave combinator", which applies multiple quotations to one value
  tri
  ;

: parse-state ( strs -- state )
  ! Transpose the strings
  flip
  ! Filter out the rows that don't end with a digit
  [ last digit? ] filter
  ! Now convert each remaining row to a stack
  [ [ CHAR: \s = ] trim but-last >vector reverse! ] map
  ;

: parse-instructions ( strs -- instructions )
  [
    ! Split on spaces
    " " split
    ! Parse each substring as number
    [ string>number ] map
    ! Discard non-numbers
    [ ] filter
    ! Convert array to 3 items
    array3
    ! And convert that to an instruction
    <instruction>
  ] map
  ;

: get-input ( -- state instructions )
  ! Read in the input file
  "INPUT" os-env utf8 file-contents
  ! Split on double newline
  "\n\n" split1
  ! Split each on newlines
  ! bi@ is an "apply combinator", which applies a single quotation to multiple
  ! values. It's equivalent to w bimap
  [ "\n" split [ empty? ] reject ] bi@
  ! Parse instructions and initial state
  ! bi* is a "spread combinator", which applies multiple quotations to multiple
  ! values. It's equivalent to bimap.
  [ parse-state ] [ parse-instructions ] bi*
  ;

:: part1step ( state instruction -- state )
  ! Get the source
  instruction source>> 1 - state nth :> source
  ! and destination
  instruction dest>> 1 - state nth :> dest
  ! Repeat count times
  instruction count>> [1..b]
  ! Pop from source then push to destination
  [ source pop dest push drop ] each
  ! Return state
  state
  ;

:: part2step ( state instruction -- state )
  instruction source>> 1 - state nth :> source
  instruction dest>> 1 - state nth :> dest
  instruction count>> :> count
  count <vector> :> temp
  ! Get the top count items from source
  count [1..b] dup
  [ source pop temp push drop ] each
  ! and push onto destination
  [ temp pop dest push drop ] each
  ! Return state
  state
  ;

: part ( state instructions op -- message )
  reduce
  ! Get the top element of each stack
  [ pop ] map
  ! Turn it into a string
  >string
  ; inline

: main ( -- )
  ! Parse input
  get-input swap
  ! Duplicate for both parts
  2dup [ [ clone ] deep-map ] bi@
  ! Run parts
  [ part1step ] [ part2step ] [ part print ] bi@
  ;

MAIN: main
