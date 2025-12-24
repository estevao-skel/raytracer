a = nasm
af = -f elf64
l = ld
s = raytracer.asm
o = raytracer.o
t = raytracer
out = christmas.ppm

all: $(t)

$(t): $(o)
	$(l) $(o) -o $(t)

$(o): $(s)
	$(a) $(af) $(s) -o $(o)

run: $(t)
	@echo "gerando"
	@./$(t) > $(out)
	@echo "arquivo: $(out)"
	@ls -lh $(out)

view: $(out)
	@echo "abrindo imagem"
	@feh $(out) 2>/dev/null || \
	 eog $(out) 2>/dev/null || \
	 gpicview $(out) 2>/dev/null || \
	 display $(out) 2>/dev/null || \
	 xdg-open $(out) 2>/dev/null || \
	 (echo "instala feh, eog, gpicview, imagemagick ou outro negocio" && exit 1)

clean:
	rm -f $(o) $(t) $(out)
	@echo "limpo kkk tchau"

.PHONY: all run view clean
