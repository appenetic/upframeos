# Default shell
SHELL := /bin/bash

# Target for installing dependencies
dep_install:
	@echo "Installing python..."
	pyenv install

	@echo "Installing pipenv..."
	pip install pipenv
	
	@echo "Installing project dependencies..."
	pipenv install

dev_environment:
	@echo "Activating dev environment..."
	pipenv shell

# Example targets that might be used in a real project
.PHONY: run clean

run:
	@echo "Running the application..."
	pipenv run python app.py

clean:
	@echo "Cleaning up..."
	rm -rf __pycache__