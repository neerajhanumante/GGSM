# Total global exploitable water availability in million cu m
total_water_available_global = 135  # total exploitable  # default

# total_water_available_global = 962  # total renewable
dct_break_points = {}

dct_break_points["Population"] = [
    {"Group": "Africa", "Break_points": [2030, 2100]},
    {"Group": "Asia", "Break_points": [1976, 1998, 2080]},
    {"Group": "Europe", "Break_points": [2013, 2100]},
    {"Group": "North America", "Break_points": [1992, 2014]},
    {"Group": "Oceania", "Break_points": [1996, 2025]},
    {"Group": "South America", "Break_points": [1980, 2020, 2075]},
]


dct_break_points["Agricultural Area\n(hectares)"] = [
    {"Group": "Africa", "Break_points": [2080, 2125]},
    {"Group": "Asia", "Break_points": [1976, 1994, 2014, 2045, 2120]},
    {"Group": "Europe", "Break_points": [2025, 2100]},
    {"Group": "North America", "Break_points": [1978, 2013],},
    {"Group": "Oceania", "Break_points": [2100, 2120]},
    {"Group": "South America", "Break_points": [1980, 2010]},
]

dct_break_points["Livestock\n(meat, tonnes)"] = [
    {"Group": "Africa", "Break_points": [1976, 2000, 2050]},
    #     {"Group": "Africa", "Break_points": [2000, 2050]}, 0.24
    {"Group": "Asia", "Break_points": [2008, 2075]},
    {"Group": "Europe", "Break_points": [2013, 2075]},
    {"Group": "North America", "Break_points": [2018, 2075]},
    {"Group": "Oceania", "Break_points": [2013, 2075]},
    {"Group": "South America", "Break_points": [2050, 2075]},
]


dct_break_points["GDP\n(USD)"] = [
    {"Group": "Africa", "Break_points": [1974, 1988, 2000, 2014]},
    #     {"Group": "Africa", "Break_points": [2014, 2100]}, 0.52
    #     {"Group": "Africa", "Break_points": [1974, 2000, 2014]}, 0.71
    {"Group": "Asia", "Break_points": [2030, 2075]},
    {"Group": "Europe", "Break_points": [2025, 2075]},
    {"Group": "North America", "Break_points": [2040, 2075]},
    {"Group": "Oceania", "Break_points": [1980, 2000, 2025]},
    {"Group": "South America", "Break_points": [1986, 2013, 2060, 2100]},
]

