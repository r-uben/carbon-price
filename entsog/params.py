from enum import Enum


class Indicator(Enum):

    def __new__(cls, *args, **kwds):
        obj         = object.__new__(cls)
        obj._value_ = args[0]

    def __init__(self):
        self = self

    def __str__(self):
        return self.value
    
    @property
    def code(self):
        return self.value

    interruption_capacity = "Actual interruption of interruptible capacity",
    allocation = "Allocation",
    firm_available = "Firm Available",
    firm_booked = "Firm Booked",
    firm_interruption_planned = "Firm Interruption Planned - Interrupted",
    firm_interruption_unplanned ="Firm Interruption Unplanned - Interrupted",
    firm_technical = "Firm Technical",
    gcv = "GCV",
    interruptible_available = "Interruptible Available",
    interruptible_booked = "Interruptible Booked",
    interruptible_interruption_actual = "Interruptible Interruption Actual – Interrupted",
    interruptible_interruption_planned = "Interruptible Interruption Planned - Interrupted",
    interruptible_total = "Interruptible Total",
    nominations = "Nominations",
    physical_flow = "Physical Flow",
    firm_interruption_capacity_planned = "Planned interruption of firm capacity",
    renomination = "Renomination",
    firm_interruption_capacity_unplanned = "Unplanned interruption of firm capacity",
    wobbe_index = "Wobbe Index",
    oversubscription_available = "Available through Oversubscription",
    surrender_available = "Available through Surrender",
    uioli_available_lt = "Available through UIOLI long-term",
    uioli_available_st = "Available through UIOLI short-term"