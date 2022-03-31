from enum import Enum


class Indicator(Enum):

    def __new__(cls, *args, **kwds):
        obj         = object.__new__(cls)
        obj._value_ = args[0]

    def __init__(self):
        self = self

    def __str__(self):
        return self.value
    
