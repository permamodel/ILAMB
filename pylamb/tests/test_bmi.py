from nose.tools import assert_is, assert_equal
from pylamb import BmiIlamb

def test_component_name():
    component = BmiIlamb()
    name = component.get_component_name()
    assert_equal(name, 'ILAMB')
    assert_is(component.get_component_name(), name)


def test_start_time():
    component = BmiIlamb()
    assert_equal(component.get_start_time(), 0.0)


def test_end_time():
    component = BmiIlamb()
    assert_equal(component.get_end_time(), 1.0)


def test_current_time():
    component = BmiIlamb()
    assert_equal(component.get_current_time(), 0.0)


def test_time_step():
    component = BmiIlamb()
    assert_equal(component.get_time_step(), 1.0)


def test_time_units():
    component = BmiIlamb()
    assert_equal(component.get_time_units(), 's')


def test_get_input_var_names():
    component = BmiIlamb()
    assert_equal(component.get_input_var_names(), ())


def test_get_output_var_names():
    component = BmiIlamb()
    assert_equal(component.get_output_var_names(), ())


# Todo: test initialize, update, update_until, finalize.
