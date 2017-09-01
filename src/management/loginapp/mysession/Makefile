all: clean-pyc test

test:
	python test_session.py

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +

release:
	python setup.py register
	python setup.py sdist upload
	python setup.py bdist_wheel upload
