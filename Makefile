a = nasm
af = -f elf64
l = ld
s = raytracer.asm
o = raytracer.o
t = raytracer
out = christmas.ppm

all: $(t)

$(t): $(o)
	$l $(o) -o $(t)

$(o): $(s)
	$a $(af) $(s) -o $(o)

run: $(t)
	./$(t) > $(out)
	@echo "foi"

view: $(out)
	xdg-open $(out) || feh $(out) || display $(out)

clean:
	rm -f $(o) $(t) $(out)
	@echo "limpo kkk tchau"
