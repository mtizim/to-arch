all: to_arch

to_arch: src/*
	sed -e '/__PRESCRIPT__/{r 'src/prerun.sh'' -e 'd}' 'src/body.sh' > src/premerge
	sed -e '/__CONVERTSCRIPT__/{r 'src/convert.sh'' -e 'd}' 'src/premerge' > src/convertmerge
	sed -e '/__POSTSCRIPT__/{r 'src/postrun.sh'' -e 'd}' 'src/convertmerge' > to_arch
	rm -f src/premerge src/convertmerge
	chmod 755 to_arch

.PHONY: clean
clean:
	rm -f to_arch
