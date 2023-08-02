build:
	docker-compose build

install:
	docker-compose run --rm web bundle install

dbsetup:
	docker-compose run --rm web bundle exec rails db:setup

server:
	docker-compose run --rm --service-ports web

console:
	docker-compose run --rm web bundle exec rails console

rubocop:
	docker-compose run --rm web bundle exec rubocop

bash:
	docker-compose run --rm web bash
