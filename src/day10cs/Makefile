INPUT=../../data/10.txt

DOTNET=dotnet

.PHONY: clean run run-fancy

clean:
	$(DOTNET) clean

run:
	$(DOTNET) run --configuration Release $(INPUT)

run-fancy:
	$(DOTNET) run --configuration Release -p:DefineConstants=FANCY_OUTPUT $(INPUT)

	
