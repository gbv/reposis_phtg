all: mvn copy restart

mvn:
	mvn clean install

copy:
	cp target/reposis_phtg-2022.06-SNAPSHOT.jar /home/ax/ws/container/phtg/mir-home/lib

restart:
	docker container restart phtg-mir
