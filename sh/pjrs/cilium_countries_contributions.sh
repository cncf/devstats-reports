#!/bin/bash
STOP=1 PRINT_ITEM=1 PRINT_DO=1 ITEMS='United States@@Switzerland@@France@@Germany@@Australia@@Belgium@@Italy@@United Kingdom@@Canada@@India@@Japan@@China@@Singapore@@Russian Federation@@Turkey' DO='clear@@CUMULATIVE=2016-08-01 SKIPDT=1 PG_DB=cilium ./sh/rep.sh months country_contributions {{country}} ##@@cat out.csv' ./sh/for_each_do.sh
