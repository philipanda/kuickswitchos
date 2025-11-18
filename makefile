
all: apply

debug: install
	plasmoidviewer --applet com.github.philipanda.kuickswitchos

apply: install
	plasmashell --replace &

install:
	cp -r -f . ~/.local/share/plasma/plasmoids/com.github.philipanda.kuickswitchos
